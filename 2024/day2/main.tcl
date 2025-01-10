source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
set data_dict [parse_file $input_file]
#puts "data_dict: {$data_dict}"
#set myrep [dict get $data_dict 3]
#puts "myrep {$myrep} sort_inc {[sort_list $myrep {-increasing}]} sort_dec {[sort_list $myrep {-decreasing}]}"
#puts "myrep {$myrep} list_is_sorted {[list_is_sorted $myrep]}"
#puts "myrep {$myrep} get_within_list_distances {[get_within_list_distances $myrep]}"
#puts "myrep {$myrep} get_within_list_distances_sort {[sort_list [get_within_list_distances $myrep]]}"
#puts "myrep {$myrep} get_list_min_max_nums {[get_list_min_max_nums [get_within_list_distances $myrep]]}"
set use_problem_dampner 0
set safe_cnt [get_safe_unsafe_counts $data_dict $use_problem_dampner]
puts "Safe count: $safe_cnt (use_problem_dampner {$use_problem_dampner})"