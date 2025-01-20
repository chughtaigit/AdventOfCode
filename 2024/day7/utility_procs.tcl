proc parse_file { in_file } {
    set data_dict [dict create]
    puts "Parsing file $in_file ..."
    set ln_cnt 0
    set fp [open $in_file]
    while {[gets $fp ln] >= 0} {   
        dict set data_dict $ln_cnt $ln
        incr ln_cnt
    }
    puts "Done (parsed $ln_cnt lines)"
    return $data_dict
}
proc prep_data { data_dict } {
    # Input Dict:
    #  Line# String
    #  0 ????
    #  1 ????
    # Output Dict:
    #  info parsed Line# [list SUMPROD length_Numbers [list Numbers] [list Operators]]
    #  ...
    #  Line# String
    #  0 ????
    #  1 ????
    #
    # e.g. for "0 {190: 10 19}",
    #      info parsed 0 [list 190 2 [list 10 19] [list {+} {*}]]

    dict for {ln_cnt in_str} $data_dict {
        if {$ln_cnt == "info"} { continue }
        set in_str_split [split $in_str ":"]
        set sum_prod [lindex $in_str_split 0]
        set nums [lindex $in_str_split 1]
        set len_nums [llength $nums]
        puts "len_nums {$len_nums} sum_prod {$sum_prod} nums {$nums} in_str {$in_str}"
        set op_list [get_operators $len_nums]
        dict set data_dict info parsed $ln_cnt [list $sum_prod $len_nums $nums $op_list]
    }
    puts "New: data_dict {$data_dict}"
    return $data_dict
}
proc get_operators { size_needed {op_types "+ *"}} {
    # Input: size_needed (Integer)
    # Output: -1 (invalid size_needed) or List of operators
    # e.g. size_needed list_of_operators
    #      2           {+} {*}
    #      3           {+ +} {+ *} {* +} {* *}
    #      4           {+ + +} {+ + *} {+ * +} {+ * *} {* + +} {* + *} {* * +} {* * *}
    #      ...

    # Punt if size_needed is < 2
    if {$size_needed < 2} { return -1 }
    set op_list [list]
    set pow_of_2 [expr int(pow(2,$size_needed - 1))]
    set each_op_len [expr $size_needed - 1]
    set width $each_op_len
    #puts "size_needed {$size_needed} pow_of_2 {$pow_of_2} each_op_len {$each_op_len}"
    for {set i 0} {$i < $pow_of_2} {incr i} {
        set num $i
        set bin_num [format {%0*b} $width $num]
        set this_op $bin_num
        regsub -all {0} $this_op [lindex $op_types 0] this_op
        regsub -all {1} $this_op [lindex $op_types 1] this_op
        set this_op_split [split $this_op {}]
        #puts "i {$i} bin_num {$bin_num} this_op {$this_op} this_op_split {$this_op_split}"
        lappend op_list $this_op_split
    }
    return $op_list
}
proc apply_operators { nums_list ops_list {target_sumprod -1} } {
    # Input: 
    #  nums_list (e.g. [list 10 19])
    #  ops_list  (e.g. [list {+} {*}])
    # Output:
    #  [list 
    #    [list sumprod0 ops_list0]
    #    [list sumprod1 ops_list1]
    #    ...
    #    [list sumprodN ops_listN]
    #  ]
    # If any of the sumprod* becomes >= target_sumprod, no more sumprod are calculated,
    #   UNLESS target_sumprod == -1 then all sumprod* are calculated.

    set ret_out [list]
    set len_ops_list [llength $ops_list]
    #puts "len_ops_list {$len_ops_list}"
    for {set i 0} {$i < $len_ops_list} {incr i} {
        set this_sumprod [lindex $nums_list 0]
        set each_op [lindex $ops_list $i]
        set len_each_op [llength $each_op]
        #puts "i {$i} len_each_op {$len_each_op} each_op {$each_op}"
        for {set j 0} {$j < $len_each_op} {incr j} {
            set expression "expr $this_sumprod [lindex $each_op $j] [lindex $nums_list $j+1]"
            #puts "this_sumprod {$this_sumprod} expression {$expression}"
            set this_sumprod [eval $expression]
        }
        lappend ret_out $this_sumprod
        if {$target_sumprod != -1 && $this_sumprod == $target_sumprod} {
            break
        }
    }
    return $ret_out
}
# Credit: https://code.activestate.com/recipes/133524-converting-numbers-from-arbitrary-bases/
proc base_characters {base_n} {
    set base [list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M \
	    N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p \
	    q r s t u v w x y z]
    if {$base_n < 2 || $base_n > 62} {
	error "Invalid base \"$base_n\" (should be an integer between 2 and 62)"
    }
    return [lrange $base 0 [expr $base_n - 1]]
}
proc base_n_to_decimal {number base_n} {
    set base   [base_characters $base_n]
    # trim white space in case [format] is used
    set number [string trim $number]
    # bases 11 through 36 can be treated in a case-insensitive fashion
    if {$base_n <= 36} {
	set number [string toupper $number]
    }
    set decimal 0
    set power [string length $number]

    foreach char [split $number ""] {
	incr power -1
	set dec_val [lsearch $base $char]
	if {$dec_val == -1} {
	    error "$number is not a valid base $base_n number"
	}
	set decimal [expr $decimal + $dec_val * int(pow($base_n,$power))]
    }

    return $decimal
}
proc decimal_to_base_n {number base_n} {
    set base [base_characters $base_n]
    # trim white space in case [format] is used
    set number [string trim $number]

    if {![string is integer $number] || $number < 0} {
	error "$number is not a base-10 integer between 0 and 2147483647"
    }

    while 1 {
	set quotient  [expr $number / $base_n]
	set remainder [expr $number % $base_n]
	lappend remainders $remainder
	set number $quotient
	if {$quotient == 0} {
	    break
	}
    }

    set base_n [list]

    for {set i [expr [llength $remainders] - 1]} {$i >= 0} {incr i -1} {
	lappend base_n [lindex $base [lindex $remainders $i]]
    }

    return [join $base_n ""]

}
proc convert_number {number "from" "base" base_from "to" "base" base_to} {
    return [decimal_to_base_n [base_n_to_decimal $number $base_from] $base_to]
}
# END Credit: https://code.activestate.com/recipes/133524-converting-numbers-from-arbitrary-bases/

proc get_operators_b { size_needed {op_types "+ * c"}} {
    # Input: size_needed (Integer)
    # Output: -1 (invalid size_needed) or List of operators
    # e.g. size_needed list_of_operators
    #      1           {+} {*} {c}
    #      2           {+ +} {+ *} {+ c} 
    #                  {* +} {* *} {* c} 
    #                  {c +} {c *} {c c} 
    #      3           {+ + +} {+ + *} {+ + c} {+ * +} {+ * *} {+ * c} {+ c +} {+ c *} {+ c c} 
    #                  {* + +} {* + *} {* + c} {* * +} {* * *} {* * c} {* c +} {* c *} {* c c} 
    #                  {c + +} {c + *} {c + c} {c * +} {c * *} {c * c} {c c +} {c c *} {c c c} 
    #      4           
    #      ...

    # Punt if size_needed is < 1
    if {$size_needed < 1} { return -1 }
    set op_list [list]
    #set pow_of_2 [expr int(pow(2,$size_needed - 1))]
    set pow_of_3 [expr int(pow(3,$size_needed))]
    #puts "size_needed {$size_needed} pow_of_3 {$pow_of_3}"
    set each_op_len $size_needed
    set width $each_op_len
    set base_from 10; set base_to 3
    #puts "size_needed {$size_needed} pow_of_3 {$pow_of_3} each_op_len {$each_op_len}"
    for {set i 0} {$i < $pow_of_3} {incr i} {
        set num $i
        set base3_num [format {%0*s} $width [convert_number $num "from" "base" $base_from "to" "base" $base_to]]
        #puts "i {$i} base3_num {$base3_num}" 
        set this_op $base3_num
        regsub -all {0} $this_op [lindex $op_types 0] this_op
        regsub -all {1} $this_op [lindex $op_types 1] this_op
        regsub -all {2} $this_op [lindex $op_types 2] this_op
        set this_op_split [split $this_op {}]
        #puts "i {$i} bin_num {$bin_num} this_op {$this_op} this_op_split {$this_op_split}"
        lappend op_list $this_op_split
    }
    return $op_list
}
proc apply_operators_b { nums_list ops_list {target_sumprod -1} } {
    # Input: 
    #  nums_list (e.g. [list 10 19])
    #  ops_list  (e.g. [list {+} {*} {c}])
    # Output:
    #  [list 
    #    [list sumprod0 ops_list0]
    #    [list sumprod1 ops_list1]
    #    ...
    #    [list sumprodN ops_listN]
    #  ]
    # If any of the sumprod* becomes >= target_sumprod, no more sumprod are calculated,
    #   UNLESS target_sumprod == -1 then all sumprod* are calculated.

    set ret_out [list]
    set len_ops_list [llength $ops_list]
    #puts "len_ops_list {$len_ops_list}"
    for {set i 0} {$i < $len_ops_list} {incr i} {
        set this_sumprod [lindex $nums_list 0]
        set each_op [lindex $ops_list $i]
        set len_each_op [llength $each_op]
        #puts "i {$i} len_each_op {$len_each_op} each_op {$each_op}"
        for {set j 0} {$j < $len_each_op} {incr j} {
            set this_op [lindex $each_op $j]
            set this_second_num [lindex $nums_list $j+1]
            set expression "expr $this_sumprod $this_op $this_second_num"
            #puts "this_sumprod {$this_sumprod} expression {$expression}"
            if {$this_op == "c"} {
                append this_sumprod $this_second_num
            } else {
                set this_sumprod [eval $expression]
            }
        }
        lappend ret_out $this_sumprod
        if {$target_sumprod != -1 && $this_sumprod == $target_sumprod} {
            break
        }
    }
    return $ret_out
}
proc part1_soln { data_dict } {
    # Input Dict:
    #  info parsed Line# [list SUMPROD length_Numbers [list Numbers] [list Operators]]
    #  ...
    #  Line# String
    #  0 ????
    #  1 ????
    # e.g. for "0 {190: 10 19}",
    #      info parsed 0 [list 190 2 [list 10 19] [list {+} {*}]]
    #
    # Output:
    #  total calibration result (which is the sum of the test values from just the equations that could possibly be true.)

    set parsed_subdict [dict get $data_dict info parsed]
    set tcr 0
    dict for {ln_cnt in_str} $parsed_subdict {
        if {$ln_cnt == "info"} { continue }
        lassign $in_str expected_sumprod nums_len nums_list ops_list
        #puts "ln_cnt {$ln_cnt} expected_sumprod {$expected_sumprod} nums_len {$nums_len} nums_list {$nums_list} ops_list {$ops_list} in_str {$in_str}"
        set apply_ops_results [apply_operators $nums_list $ops_list]
        set found_exp_sp [lsearch -exact $apply_ops_results $expected_sumprod]
        if {$found_exp_sp == -1} {
            puts "NOT TRUE: {$ln_cnt} {[dict get $data_dict $ln_cnt]}"
            continue
        }
        puts "True: {$ln_cnt} {[dict get $data_dict $ln_cnt]}"
        incr tcr $expected_sumprod
    }
    puts "total calibration result: {$tcr}"
    return $tcr
}
proc part2_soln { data_dict } {
    # Input Dict:
    #  info parsed Line# [list SUMPROD length_Numbers [list Numbers] [list Operators]]
    #  ...
    #  Line# String
    #  0 ????
    #  1 ????
    # e.g. for "0 {190: 10 19}",
    #      info parsed 0 [list 190 2 [list 10 19] [list {+} {*}]]
    #
    # Output:
    #  total calibration result (which is the sum of the test values from just the equations that could possibly be true.)

    set parsed_subdict [dict get $data_dict info parsed]
    set tcr 0
    dict for {ln_cnt in_str} $parsed_subdict {
        if {$ln_cnt == "info"} { continue }
        lassign $in_str expected_sumprod nums_len nums_list ops_list
        #puts "ln_cnt {$ln_cnt} expected_sumprod {$expected_sumprod} nums_len {$nums_len} nums_list {$nums_list} ops_list {$ops_list} in_str {$in_str}"
        set apply_ops_results [apply_operators $nums_list $ops_list]
        set found_exp_sp [lsearch -exact $apply_ops_results $expected_sumprod]
        if {$found_exp_sp == -1} {
            puts "NOT TRUE: {$ln_cnt} {[dict get $data_dict $ln_cnt]}"
            # Try with the third operator
            set size_needed [expr [llength $nums_list] - 1]
            set apply_ops_b_results [apply_operators_b $nums_list [get_operators_b $size_needed]]
            set found_exp_sp_b [lsearch -exact $apply_ops_b_results $expected_sumprod]
            if {$found_exp_sp_b == -1} {
                puts "--> STILL NOT TRUE: {$ln_cnt} {[dict get $data_dict $ln_cnt]}"
                continue
            }
            puts "-->           True: {$ln_cnt} {[dict get $data_dict $ln_cnt]}"
        }
        puts "True: {$ln_cnt} {[dict get $data_dict $ln_cnt]}"
        incr tcr $expected_sumprod
    }
    puts "total calibration result: {$tcr}"
    return $tcr
}