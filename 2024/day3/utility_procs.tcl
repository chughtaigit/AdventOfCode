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
proc get_mul_matches { in_str } {
    set pattern {mul\(([0-9]+),([0-9]+)\)}
    set matchTuples [regexp -all -inline $pattern $in_str]
    #puts "matchTuples {$matchTuples} in_str {$in_str}"
    return $matchTuples
}
proc filter_mul_matches { in_matches } {
    # in_matches is a list like this: 
    #   mul(X0,Y0) X0 Y0   mul(X1,Y1) X1 Y1 ...
    set filtered_matches [list]
    foreach {whole num_a num_b} $in_matches {
        if {$num_a > 999 || $num_b > 999} { 
            #puts "Filtered: {$whole} >999 $num_a or $num_b" 
            continue 
        }
        lappend filtered_matches $whole
        lappend filtered_matches $num_a
        lappend filtered_matches $num_b
    }
    return $filtered_matches
}
proc process_mul_matches { in_matches } {
    # in_matches is a list like this: 
    #   mul(X0,Y0) X0 Y0   mul(X1,Y1) X1 Y1 ...
    set mul_results 0
    foreach {whole num_a num_b} $in_matches {
        incr mul_results [expr $num_a * $num_b]
    }
    return $mul_results
}
proc process_data { data_dict {use_problem_dampner 0} } {
    set mul_results 0
    dict for {ln_cnt in_str} $data_dict {
        set mul_matches [get_mul_matches $in_str]
        set filtered_mul_matches [filter_mul_matches $mul_matches]
        if {[llength $mul_matches] != [llength $filtered_mul_matches]} {
            puts "  Line $ln_cnt: One or more entries filtered ..."
        }
        set mul_result [process_mul_matches $filtered_mul_matches]
        puts "<$ln_cnt>: $mul_result {$in_str}"
        incr mul_results $mul_result
    }
    puts "mul_results: $mul_results"
    return $mul_results
}
proc sort_list { in_list {stype "-increasing"} } {
    if {$stype == "-decreasing"} {
        set new_list [lsort -integer -decreasing $in_list]
    } else {
        set new_list [lsort -integer -increasing $in_list]
    }
    #puts "Original: [lindex $in_list 0] [lindex $in_list end]"
    #puts "     New: [lindex $new_list 0] [lindex $new_list end]"
    return $new_list
}
proc list_is_sorted { in_list } {
    if {$in_list == [sort_list $in_list "-increasing"] || \
        $in_list == [sort_list $in_list "-decreasing"]} {
        return 1
    }
    return 0
}
proc distance_nums { num_a num_b } {
    set distance [expr abs($num_a - $num_b)]
    #puts "INFO: distance: num_a {$num_a} num_b {$num_b} distance {$distance}"
    if {$distance < 0} {
        puts "ERROR: Negative distance: num_a {$num_a} num_b {$num_b} distance {$distance}"
    }
    return $distance
}
proc get_within_list_distances { in_list } {
    set ret_distances_list [list]
    #puts "List sizes:"
    #puts "  in_list [llength $in_list]"
    set in_list_len [llength $in_list]
    for {set i 0} {$i + 1 < $in_list_len} {incr i} {
        set num_a [lindex $in_list $i]
        set num_b [lindex $in_list [expr $i + 1]]
        #puts "i <$i> num_a {$num_a} num_b {$num_b}"
        set dist_nums [distance_nums $num_a $num_b]
        lappend ret_distances_list $dist_nums
    }
    return $ret_distances_list
}
proc get_list_min_max_nums { in_list } {
    set in_list_sort [sort_list $in_list]
    set min_num [lindex $in_list_sort 0]
    set max_num [lindex $in_list_sort end]
    #puts "in_list {$in_list} min_num {$min_num} max_num {$max_num}"
    return [list $min_num $max_num]
}
proc is_safe_or_unsafe { in_list } {
    # Count as safe if both of following is true:
    # 1. The levels are either all increasing or all decreasing.
    # 2. Any two adjacent levels differ by at least one and at most three.
    set levels_all_inc_dec 0
    set two_adj_level_differ_by 0
    set levels_all_inc_dec [list_is_sorted $in_list]
    set list_min_max_nums [get_list_min_max_nums [get_within_list_distances $in_list]]
    set min_dist [lindex $list_min_max_nums 0]
    set max_dist [lindex $list_min_max_nums end]
    if {$min_dist >= 1 && $max_dist <= 3} {
        set two_adj_level_differ_by 1
    }
    #puts "levels_all_inc_dec {$levels_all_inc_dec} two_adj_level_differ_by {$two_adj_level_differ_by} in_list {$in_list}"
    if {$levels_all_inc_dec != 0 && $two_adj_level_differ_by != 0} {
        return 1
    }
    return 0
}
proc problem_dampner_module { in_list } {
    # Punt if already safe
    set is_safe [is_safe_or_unsafe $in_list]
    if {$is_safe != 0} {
        return 1
    }
    # The Problem Dampener is a reactor-mounted module that lets the reactor safety systems tolerate a 
    # single bad level in what would otherwise be a safe report. It's like the bad level never happened!
    set found_solution 0
    for {set i 0} {$i < [llength $in_list]} {incr i} {
        # Create a new list without the i'th element
        set new_list [lreplace $in_list $i $i]
        set is_safe [is_safe_or_unsafe $new_list]
        #puts "i {$i} is_safe {$is_safe} in_list {$in_list} new_list {$new_list}"
        # Stop when a solution is found
        if {$is_safe != 0} {
            return 1
        }
    }
    # Couldn't find a solution
    return 0
}
proc get_safe_unsafe_counts { data_dict {use_problem_dampner 0} } {
    set reports_cnt 0
    set safe_cnt 0
    dict for {ln_cnt in_list} $data_dict {
        set is_safe [is_safe_or_unsafe $in_list]
        if {$is_safe != 0} {
          incr safe_cnt
        } else {
            if {$use_problem_dampner != 0} {
                # Problem Dampner
                set dampner_worked_or_not [problem_dampner_module $in_list]
                if {$dampner_worked_or_not != 0} {
                    incr safe_cnt
                }
            }
        }
        incr reports_cnt
    }
    puts "Reports analyzed: {$reports_cnt}, Safe {$safe_cnt}"
    return $safe_cnt
}