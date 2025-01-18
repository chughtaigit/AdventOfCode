source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set data_dict_prep [str2dlookup_prep $data_dict]
puts "data_dict_prep: {$data_dict_prep}"
puts "str2d_str: {\n[str2d_str $data_dict_prep]}"
if {0} {
set num_options [part2_soln $data_dict_prep]
set status [place_obstruction $data_dict_prep 0 4]
#set status [place_obstruction $data_dict_prep 0 0]
#set status [place_obstruction $data_dict_prep 100 100]
puts "status {$status}"
if {[lindex $status 0] != -1} {
    set data_dict_prep [lindex $status 3]
}
}
puts "str2d_str: {\n[str2d_str $data_dict_prep]}"
set abc [part2_soln $data_dict_prep]
#set data_dict_prep $abc
#puts "str2d_str: {\n[str2d_str $data_dict_prep]}"
puts "abc {$abc}"
exit