module reader

import encoding.binary
import math

pub enum ReadablePackets {
	change_action = 0
	send_public_message = 1
	logout = 2
	request_status_update = 3
	ping = 4
	start_spectating = 16
	stop_spectating = 17
	spectate_frames = 18
	error_report = 20
	cant_spectate = 21
	send_private_message = 25
	part_lobby = 29
	join_lobby = 30
	create_match = 31
	join_match = 32
	part_match = 33
	match_change_slot = 38
	match_ready = 39
	match_lock = 40
	match_change_settings = 41
	match_start = 44
	match_score_update = 47
	match_complete = 49
	match_change_mods = 51
	match_load_complete = 52
	match_no_beatmap = 54
	match_not_ready = 55
	match_failed = 56
	match_has_beatmap = 59
	match_skip_request = 60
	channel_join = 63
	beatmap_info_request = 68
	match_transfer_host = 70
	friend_add = 73
	friend_remove = 74
	match_change_team = 77
	channel_part = 78
	receive_updates = 79
	set_away_message = 82
	irc_only = 84
	user_stats_request = 85
	match_invite = 87
	match_change_password = 90
	tournament_match_info_request = 93
	user_presence_request = 97
	user_presence_request_all = 98
	toggle_block_non_friend_dms = 99
	tournament_join_match_channel = 108
	tournament_leave_match_channel = 109
	end = 110
}

pub struct Reader {
pub:
	buffer_		[]byte 	[required]

pub mut:
	pos			int

mut:
	length		int
	buffer_t	ReadablePackets
	buffer_id	u16
}

pub fn (r &Reader) buffer() []byte {
	return r.buffer_[r.pos..]
}

pub fn (mut r Reader) read_byte() u8 {
	ret := r.buffer()[0]
	r.pos += 1
	return ret
}

pub fn (mut r Reader) read_i16() i16 {
	ret := i16(binary.little_endian_u16(r.buffer()[..2]))
	r.pos += 2
	return ret
}

pub fn (mut r Reader) read_u16() u16 {
	ret := binary.little_endian_u16(r.buffer()[..2])
	r.pos += 2
	return ret
}

pub fn (mut r Reader) read_i32() int {
	ret := int(binary.little_endian_u32(r.buffer()[..4]))
	r.pos += 4
	return ret
}

pub fn (mut r Reader) read_u32() u32 {
	ret := binary.little_endian_u32(r.buffer()[..4])
	r.pos += 4
	return ret
}

pub fn (mut r Reader) read_i64() i64 {
	ret := i64(binary.little_endian_u64(r.buffer()[..8]))
	r.pos += 8
	return ret
}

pub fn (mut r Reader) read_u64() u64 {
	ret := binary.little_endian_u64(r.buffer()[..8])
	r.pos += 8
	return ret
}

pub fn (mut r Reader) read_string() string {
	r.pos += 1

	mut shift := 0
	mut result := 0

	for {
		b := r.buffer()[0]
		r.pos += 1

		result |= (b & 0x7F) << shift

		if (b & 0x80) == 0 {
			break
		}

		shift += 7
	}
	
	ret := r.buffer()[..result].bytestr()
	r.pos += result

	return ret
}

pub fn (mut r Reader) read_f32() f32 {
	ret := math.f32_from_bits(binary.little_endian_u32(r.buffer()[..4]))
	r.pos += 4
	return ret
}

pub fn (mut r Reader) read_f64() f64 {
	ret := math.f64_from_bits(binary.little_endian_u64(r.buffer()[..8]))
	r.pos += 8
	return ret
}

pub fn (mut r Reader) read_i32_l() []int {
	len := r.read_u16()

	mut i32_l := []int{}

	for _ in 1 .. len {
		i32_l << r.read_i32()
	}

	return i32_l
}
