# Timestamp
set now [clock seconds]; set timestr [clock format $now -format "%y-%m-%d %H:%M:%S"]; puts "Time: {$timestr}"; set start_now $now
source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
#set input_file "example_list2.txt"
#set input_file "example_list3.txt"
#set input_file "example_list4.txt"
#set input_file "example_list5.txt"
set data_dict [parse_file $input_file]
set data_dict [diskmap_to_blocks_list $data_dict]
#set diskmap [dict get $data_dict info diskmap]; puts "diskmap {$diskmap}"
#set blocks_map [dict get $data_dict info blocks_map]; puts "blocks_map {$blocks_map}"
set data_dict [diskmap_inventory $data_dict]
#puts "data_dict: {$data_dict}"
#exit
set data_dict [move_whole_file_list $data_dict]
# Timestamp
set now [clock seconds]; set timestr [clock format $now -format "%y-%m-%d %H:%M:%S"]; puts "Time: {$timestr}"
set total_time [expr $now - $start_now]; set timestr [clock format $total_time -format "%M:%S"]; puts "Total Time: {$timestr}"
exit
if {0} {
PUNT: Open space after the file!
      checksum {5773744292133}
Time: {25-01-24 12:21:46}
Total Time: {01:10}
}

set status [move_whole_file_one_at_a_time_list $data_dict 9]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 8]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 7]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 6]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 5]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 4]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 3]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 2]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 1]; if {$status != -1} { set data_dict $status}
set status [move_whole_file_one_at_a_time_list $data_dict 0]; if {$status != -1} { set data_dict $status}
puts "data_dict: {$status}"
#set opt_block_map [dict get $data_dict info opt_blocks_map]

if {0} {
$ tclsh86.exe main.tcl
Time: {25-01-22 12:38:22}
main.tcl
Parsing file input.txt ...
Done (parsed 1 lines)
No more free_space_blocks!
      checksum {6331212425418}
Time: {25-01-22 12:46:25}
Total Time: {08:03}
}

#puts "move_file_blocks_one_at_a_time_list:[move_file_blocks_one_at_a_time_list [split {0..111....22222} {}]]"
#puts "move_file_blocks_one_at_a_time_list:[move_file_blocks_one_at_a_time_list [split {02.111....2222.} {}]]"
puts "move_file_blocks_one_at_a_time_list:[move_file_blocks_one_at_a_time_list [dict get $data_dict info blocks_map]]"
exit


exit
################################
# Initial attempt to do this with strings took a long time, so trying to do this with lists
#puts "data_dict: {$data_dict}"
set data_dict_prep [str2dlookup_prep $data_dict]
#puts "data_dict_prep: {$data_dict_prep}"
set data_dict_prep [diskmap_to_blocks $data_dict_prep]
#puts "move_file_blocks_one_at_a_time:[move_file_blocks_one_at_a_time {0..111....22222}]"
#puts "move_file_blocks_one_at_a_time:[move_file_blocks_one_at_a_time {02.111....2222.}]"
#puts "move_file_blocks_one_at_a_time:[move_file_blocks_one_at_a_time [dict get $data_dict_prep info blocks_map]]"
#puts "diskmap_to_blocks: {[diskmap_to_blocks $data_dict_prep]}"
#set part1_soln [part1_soln $data_dict_prep]
set data_dict_prep [move_file_blocks $data_dict_prep]


if {0} {
Khurram@LAPTOP-MP6AUBR8 MINGW64 ~/Desktop/AOC/AdventOfCode/2024/day9 (main)
$ tclsh86.exe main.tcl
main.tcl
Parsing file input.txt ...
Done (parsed 1 lines)
No more free_space_blocks!
      checksum {90428939430}

}