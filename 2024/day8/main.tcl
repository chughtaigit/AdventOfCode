source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
#set input_file "example_list2.txt"
#set input_file "example_list3.txt"
#set input_file "example_list4.txt"
set input_file "example_list5.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set data_dict_prep [str2dlookup_plus_prep $data_dict]
puts "data_dict_prep: {$data_dict_prep}"
set part1_soln [part1_soln $data_dict_prep]