source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
set two_lists [parse_file $input_file]
set list_a [lindex $two_lists 0]
set list_b [lindex $two_lists 1]
set list_a_sorted [sort_list $list_a]
set list_b_sorted [sort_list $list_b]
#set distance [get_list_distance $list_a_sorted $list_b_sorted]
#puts "list_b_sorted {$list_b_sorted}"
set distance [freq_of_list $list_b_sorted]
set elem "3"
set distance [freq_of_elem_in_list $elem $list_b_sorted]
set sim_score [get_similarity_score $list_a_sorted $list_b_sorted]
puts "Similarity Score: $sim_score"