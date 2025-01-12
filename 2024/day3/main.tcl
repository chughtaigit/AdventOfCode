source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set safe_cnt [process_data $data_dict]