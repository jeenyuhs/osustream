module writer

import reader

pub enum WritablePackets {
	user_id = 5
	cmd_err = 6
	send_message = 7
	pong = 8
	handle_irc_change_username = 9
	handle_irc_quit = 10
	user_stats = 11
	user_logout = 12
	spectator_joined = 13
	spectator_left = 14
	spectate_frames = 15
	version_update = 19
	spectator_cant_spectate = 22
	get_attention = 23
	notification = 24
	update_match = 26
	new_match = 27
	dispose_match = 28
	toggle_block_non_friend_dms = 34
	match_join_success = 36
	match_join_fail = 37
	fellow_spectator_joined = 42
	fellow_spectator_left = 43
	all_players_loaded = 45
	match_start = 46
	match_score_update = 48
	match_transfer_host = 50
	match_all_players_loaded = 53
	match_player_failed = 57
	match_complete = 58
	match_skip = 61
	unauthorized = 62
	channel_join_success = 64
	channel_info = 65
	channel_kick = 66
	channel_auto_join = 67
	beatmap_info_reply = 69
	privileges = 71
	friends_list = 72
	protocol_version = 75
	main_menu_icon = 76
	monitor = 80
	match_player_skipped = 81
	user_presence = 83
	restart = 86
	match_invite = 88
	channel_info_end = 89
	match_change_password = 91
	silence_end = 92
	user_silenced = 94
	user_presence_single = 95
	user_presence_bundle = 96
	user_dm_blocked = 100
	target_is_silenced = 101
	version_update_forced = 102
	switch_server = 103
	account_restricted = 104
	rtx = 105 // deprecated
	match_abort = 106
	switch_tournament_server = 107
}

struct Stream {
mut:
	content		[]byte
}

pub fn (mut s Stream) write_u8(i u8) {
	s.content << i
}

pub fn (mut s Stream) write_i8(i i8) {
	s.content << byte(i)
}

pub fn (mut s Stream) write_u16(i u16) {
	s.content << byte(i)
	s.content << byte(i >> u16(8))
}

pub fn (mut s Stream) write_i16(i i16) {
	s.write_u16(u16(i))
}

pub fn (mut s Stream) write_u32(i u32) {
	s.content << byte(i)
	s.content << byte(i >> u32(8))
	s.content << byte(i >> u32(16))
	s.content << byte(i >> u32(24))
}

pub fn (mut s Stream) write_i32(i int) {
	s.write_u32(u32(i))
}

pub fn (mut s Stream) write_packet_length(len int) {
	mut b := 0

	b += byte(len)
	b += byte(len >> u32(8))
	b += byte(len >> u32(16))
	b += byte(len >> u32(24))

	s.content[3] = byte(b)
}

pub fn (mut s Stream) write_u64(i u64) {
	s.content << byte(i)
	s.content << byte(i >> u64(8))
	s.content << byte(i >> u64(16))
	s.content << byte(i >> u64(24))
	s.content << byte(i >> u64(32))
	s.content << byte(i >> u64(40))
	s.content << byte(i >> u64(48))
	s.content << byte(i >> u64(56))
}

pub fn (mut s Stream) write_i64(i i64) {
	s.write_u64(u64(i))
}

pub fn (mut s Stream) write_str(str string) {
	mut length := str.len

	if length == 0 {
		s.write_u8(0)
		return
	}

	s.write_u8(11)

	for length >= 127 {
		s.write_u8(128)
		length -= 127
	}

	s.write_u8(byte(length))
	
	for letter in str {
		s.write_u8(byte(letter))
	}
}

pub fn (mut s Stream) write_i32_l(vals []int) {
	s.write_i16(i16(vals.len))

	for val in vals {
		s.write_i32(val)
	}
}

type PacketVal = byte | i8 | u16 | i16 | u32 | int | u64 | i64 | string

pub fn make_packet(packet reader.ReadablePackets, values ...PacketVal) ?[]byte {
	mut s := Stream{}

	s.write_u16(u16(packet))
	s.write_u8(0)
	s.write_i32(0)

	for v in values {
		match v.type_name() {
		"u8" {
			s.write_u8(v as byte)
		}
		"i8" {
			s.write_i8(v as i8)
		}
		"u16" {
			s.write_u16(v as u16)
		}
		"i16" {
			s.write_i16(v as i16)
		}
		"u32" {
			s.write_u32(v as u32)
		}
		"int" {
			s.write_i32(v as int)
		}
		"u64" {
			s.write_u64(v as u64)
		}
		"i64" {
			s.write_i64(v as i64)
		}
		"string" {
			s.write_str(v as string)
		}
		else { return error("type error: type not found") }
		}
	}

	s.write_packet_length(s.content.len - 7)

	return s.content
}
