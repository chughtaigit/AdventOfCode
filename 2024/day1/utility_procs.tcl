proc parse_file { in_file } {
    set ret_list_a [list]
    set ret_list_b [list]
    puts "Parsing file $in_file ..."
    set ln_cnt 0
    set fp [open $in_file]
    while {[gets $fp ln] >= 0} {   
        incr ln_cnt
        lappend ret_list_a [lindex $ln 0]
        lappend ret_list_b [lindex $ln 1]
    }
    puts "Done (parsed $ln_cnt lines)"
    puts "List sizes:"
    puts "  list_a [llength $ret_list_a]"
    puts "  list_b [llength $ret_list_b]"
    return [list $ret_list_a $ret_list_b]
}
proc sort_list { in_list } {
    set new_list [lsort -integer $in_list]
    puts "Original: [lindex $in_list 0] [lindex $in_list end]"
    puts "     New: [lindex $new_list 0] [lindex $new_list end]"
    return $new_list
}
proc distance_nums { num_a num_b } {
    set distance [expr abs($num_a - $num_b)]
    puts "INFO: distance: num_a {$num_a} num_b {$num_b} distance {$distance}"
    if {$distance < 0} {
        puts "ERROR: Negative distance: num_a {$num_a} num_b {$num_b} distance {$distance}"
    }
    return $distance
}
proc get_list_distance { list_a list_b } {
    set ret_distance 0
    puts "List sizes:"
    puts "  list_a [llength $list_a]"
    puts "  list_b [llength $list_b]"
    set list_a_len [llength $list_a]
    for {set i 0} {$i < $list_a_len} {incr i} {
        set num_a [lindex $list_a $i]
        set num_b [lindex $list_b $i]
        set dist_nums [distance_nums $num_a $num_b]
        incr ret_distance $dist_nums
    }
    return $ret_distance
}
proc freq_of_list { in_list } {
    set counters_dict {}
    foreach item $in_list {
        dict incr counters_dict $item
    }
    #puts "counters_dict {$counters_dict}"
    return $counters_dict
}
proc freq_of_elem_in_list { elem in_list } {
    set counters_dict [freq_of_list $in_list]
    set ret_freq 0
    if {[dict exists $counters_dict $elem]} {
        set ret_freq [dict get $counters_dict $elem]
    }
    return $ret_freq
}
proc get_similarity_score { list_a list_b } {
    set ret_score 0
    foreach elem $list_a {
        set freq_elem_in_b [freq_of_elem_in_list $elem $list_b]
        incr ret_score [expr $elem * $freq_elem_in_b]
    }
    return $ret_score
}