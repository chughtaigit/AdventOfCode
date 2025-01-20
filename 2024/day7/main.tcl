source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set data_dict_prep [prep_data $data_dict]
puts "data_dict_prep: {$data_dict_prep}"
set part1_soln [part1_soln $data_dict_prep]
exit
puts "data_dict_prep: {$data_dict_prep}"
set size_needed 1; puts "size_needed {$size_needed} op_list {[get_operators $size_needed]}"
set size_needed 2; puts "size_needed {$size_needed} op_list {[get_operators $size_needed]}"
set size_needed 3; puts "size_needed {$size_needed} op_list {[get_operators $size_needed]}"
set size_needed 4; puts "size_needed {$size_needed} op_list {[get_operators $size_needed]}"
puts "apply_operators {[apply_operators { 10 19} {+ *}]}"
puts "apply_operators {[apply_operators { 10 19} {+ *} 29]}"
puts "apply_operators {[apply_operators { 10 19} {+ *} 190]}"
puts "apply_operators {[apply_operators { 81 40 27}  {{+ +} {+ *} {* +} {* *}} 3267]}"
puts "apply_operators {[apply_operators { 81 40 27}  {{+ +} {+ *} {* +} {* *}} -1]}"
puts "apply_operators {[apply_operators {  11 6 16 20}  [get_operators 4] -1]}"
exit