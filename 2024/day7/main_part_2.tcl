source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set data_dict_prep [prep_data $data_dict]
puts "data_dict_prep: {$data_dict_prep}"
set part2_soln [part2_soln $data_dict_prep]
exit
#puts "data_dict_prep: {$data_dict_prep}"
set number 1; set base_from 10; set base_to 3; puts "Convert num: [convert_number $number "from" "base" $base_from "to" "base" $base_to]"
set number 1; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 2; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 3; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 4; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 5; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 6; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 7; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 8; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set number 9; set base_from 10; set base_to 3; set width 6; puts "Convert num: {$number} [format {%0*s} $width [convert_number $number "from" "base" $base_from "to" "base" $base_to]]"
set size_needed 1; puts "size_needed {$size_needed} op_list {[get_operators_b $size_needed]}"
set size_needed 2; puts "size_needed {$size_needed} op_list {[get_operators_b $size_needed]}"
set size_needed 3; puts "size_needed {$size_needed} op_list {[get_operators_b $size_needed]}"
set size_needed 4; puts "size_needed {$size_needed} op_list {[get_operators_b $size_needed]}"
set nums_list {10 19}; set size_needed [expr [llength $nums_list] - 1]; puts "apply_operators_b {[apply_operators_b $nums_list [get_operators_b $size_needed]]}"
set nums_list {81 40 27}; set size_needed [expr [llength $nums_list] - 1]; puts "apply_operators_b {[apply_operators_b $nums_list [get_operators_b $size_needed]]}"
set nums_list {11 6 16 20}; set size_needed [expr [llength $nums_list] - 1]; puts "apply_operators_b {[apply_operators_b $nums_list [get_operators_b $size_needed]]}"
set nums_list {15 6}; set size_needed [expr [llength $nums_list] - 1]; puts "apply_operators_b {[apply_operators_b $nums_list [get_operators_b $size_needed]]}"
set nums_list {6 8 6 15}; set size_needed [expr [llength $nums_list] - 1]; puts "apply_operators_b {[apply_operators_b $nums_list [get_operators_b $size_needed]]}"
set nums_list {17 8 14}; set size_needed [expr [llength $nums_list] - 1]; puts "apply_operators_b {[apply_operators_b $nums_list [get_operators_b $size_needed]]}"
exit
puts "apply_operators {[apply_operators { 10 19} {+ *} 29]}"
puts "apply_operators {[apply_operators { 10 19} {+ *} 190]}"
puts "apply_operators {[apply_operators { 81 40 27}  {{+ +} {+ *} {* +} {* *}} 3267]}"
puts "apply_operators {[apply_operators { 81 40 27}  {{+ +} {+ *} {* +} {* *}} -1]}"
puts "apply_operators {[apply_operators {  11 6 16 20}  [get_operators 4] -1]}"
exit