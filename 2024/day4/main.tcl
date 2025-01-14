source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
#set input_file "example_list2.txt"
#set input_file "example_list3.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set in_str "MMMSXXMASM\nMSAMXMSMSA"
#set safe_cnt [get_matches $in_str]
set data_dict_prep [str2dlookup_prep $data_dict]
puts "data_dict_prep: {$data_dict_prep}"
puts "# (y,x)"
puts "# (0,0) T -> [str2dlookup_yx $data_dict_prep 0 0]"
puts "# (0,1) h -> [str2dlookup_yx $data_dict_prep 0 1]"
puts "# (0,1000) -1 -> [str2dlookup_yx $data_dict_prep 0 1000]"
puts "# (2,13) 2 -> [str2dlookup_yx $data_dict_prep 2 13]"
puts "# (-1,13) ? -> [str2dlookup_yx $data_dict_prep -1 13]"
puts "# (0,-1) ? -> [str2dlookup_yx $data_dict_prep 0 -1]"
set abc [str2dlookup_multi_yx $data_dict_prep [list [list 0 0 T] [list 0 1 h]]]
puts "# (0,0) T (0,1) h -> {$abc}"
set abc [str2dlookup_multi_yx $data_dict_prep [list [list 0 0 j] [list 0 1 h]]]
puts "# (0,0) j (0,1) h -> {$abc}"
set abc [str2dlookup_multi_yx $data_dict_prep [list [list 0 0 T] [list 0 1 j]]]
puts "# (0,0) T (0,1) j -> {$abc}"
set abc [str2dlookup_multi_yx $data_dict_prep [list [list 0 100 T] [list 0 1 h]]]
puts "# (0,100) T (0,1) h -> {$abc}"
set abc [str2dlookup_multi_yx $data_dict_prep [list [list 3 5 X] [list 3 6 M] [list 3 7 A] [list 3 8 S]]]
puts "# 3 5-8 XMAS -> {$abc}"
set safe_cnt [get_matches $data_dict_prep]