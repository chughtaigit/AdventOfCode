source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set data_dict_prep [str2dlookup_prep $data_dict]
puts "data_dict_prep: {$data_dict_prep}"
puts "str2d_str: {\n[str2d_str $data_dict_prep]}"
#exit
set max_iterations 2
set max_iterations 100000000000000
set data_dict_prep [guard_move $data_dict_prep $max_iterations]
puts "str2d_str: {\n[str2d_str $data_dict_prep]}"
puts "Total steps: [string_occurrences {X} [str2d_str $data_dict_prep]]"
exit
#
puts "str2d_find_char_yx: {[str2d_find_char_yx $data_dict_prep {^}]}"
set str2d_find_char_yx [str2d_find_char_yx $data_dict_prep {^}]
set str2d_replace_char_at_yx [str2d_replace_char_at_yx $data_dict_prep [lindex $str2d_find_char_yx 0] [lindex $str2d_find_char_yx 1] {X}]
set new_data_dict_prep $str2d_replace_char_at_yx
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set status [guard_move_next_direction $data_dict_prep]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
#
set move_direction [lindex $status 0]
set status [guard_move_next_direction $new_data_dict_prep $move_direction]
puts "status {$status}"
set new_data_dict_prep [lindex $status 2]
puts "str2d_str: {\n[str2d_str $new_data_dict_prep]}"
##
puts "[string_occurrences {X} {...XX...\n...XX...}]"
puts "Total steps: [string_occurrences {X} [str2d_str $new_data_dict_prep]]"
#set mid_pg_sums [part1_soln $data_dict_prep]