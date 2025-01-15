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
    # Output Dict: (por = Page Ordering Rules, upd = Updates)
    #  por #|# [list # #]
    #  por #|# [list # #]
    #  ...
    #  upd #,#,# [list # # #]
    #  upd #,#,# [list # # #]
    #  ...
    #  Line# String
    #  0 ????
    #  1 ????

    dict for {ln_cnt in_str} $data_dict {
        if {$ln_cnt == "por" || $ln_cnt == "upd"} { continue }
        if {[string match "*|*" $in_str]} {
            puts "por: $in_str"
            # Does this already exist? It shouldn't ...
            if {[dict exists $data_dict por $in_str]} {
                puts "WARNING: por already exists, overwriting previous one: $in_str"
            }
            dict set data_dict por $in_str [split $in_str {|}]
        } elseif {[string match "*,*" $in_str]} {
            puts "upd: $in_str"
            # Does this already exist? It shouldn't ...
            if {[dict exists $data_dict upd $in_str]} {
                puts "WARNING: upd already exists, overwriting previous one: $in_str"
            }
            dict set data_dict upd $in_str [split $in_str {,}]
        }
    }
    puts "New: data_dict {$data_dict}"
    return $data_dict
}
proc part1_soln { data_dict } {
    # Input Dict: (por = Page Ordering Rules, upd = Updates)
    #  por #|# [list # #]
    #  por #|# [list # #]
    #  ...
    #  upd #,#,# [list # # #]
    #  upd #,#,# [list # # #]
    #  ...
    #  Line# String
    #  0 ????
    #  1 ????
    # Output: Sum of middle page numbers for the Correctly Ordered Updates

    # Get all page ordering rules in a dict
    set por_subdict [dict get $data_dict "por"]
    set por_keys [dict keys $por_subdict]
    puts "por_subdict {$por_subdict}"
    puts "por_keys {$por_keys}"
    # Get all updates in a dict
    set upd_subdict [dict get $data_dict "upd"]
    set upd_keys [dict keys $upd_subdict]
    puts "upd_subdict {$upd_subdict}"
    puts "upd_keys {$upd_keys}"

    # Process all updates to see which are in right order
    #   - For the right order ones, add up the middle page numbers
    set mid_pg_sums 0
    foreach updt $upd_keys {
        set updt_list [dict get $upd_subdict $updt]
        set updt_list_len [llength $updt_list]
        set updt_in_order 1
        puts "Processing update: $updt {$updt_list_len} {$updt_list}"
        for {set i 0} {$i < $updt_list_len - 1} {incr i} {
            set num_a [lindex $updt_list $i]
            set num_b [lindex $updt_list [expr $i+1]]
            set por_key "$num_a|$num_b"
            if {![dict exists $por_subdict $por_key]} {
                set updt_in_order 0
            }
        }
        puts "  $updt_in_order {$updt_in_order}"
        if {$updt_in_order == 1} {
            set mid_pg [lindex $updt_list [expr int($updt_list_len / 2)]]
            incr mid_pg_sums $mid_pg
            puts "  mid_pg {$mid_pg} mid_pg_sums {$mid_pg_sums}"
        }
    }
    puts "mid_pg_sums {$mid_pg_sums}"
    return $mid_pg_sums
}
proc part2_soln { data_dict } {
    # Input Dict: (por = Page Ordering Rules, upd = Updates)
    #  por #|# [list # #]
    #  por #|# [list # #]
    #  ...
    #  upd #,#,# [list # # #]
    #  upd #,#,# [list # # #]
    #  ...
    #  Line# String
    #  0 ????
    #  1 ????
    # Output: Sum of middle page numbers for the INCORRECTLY Ordered Updates

    # Get all page ordering rules in a dict
    set por_subdict [dict get $data_dict "por"]
    set por_keys [dict keys $por_subdict]
    puts "por_subdict {$por_subdict}"
    puts "por_keys {$por_keys}"
    # Get all updates in a dict
    set upd_subdict [dict get $data_dict "upd"]
    set upd_keys [dict keys $upd_subdict]
    puts "upd_subdict {$upd_subdict}"
    puts "upd_keys {$upd_keys}"

    # Process all updates to see which are in right order
    #   - For the right order ones, add up the middle page numbers
    set mid_pg_sums 0
    foreach updt $upd_keys {
        set updt_list [dict get $upd_subdict $updt]
        set updt_list_len [llength $updt_list]
        set updt_in_order 1
        #puts "Processing update: $updt {$updt_list_len} {$updt_list}"
        for {set i 0} {$i < $updt_list_len - 1} {incr i} {
            set num_a [lindex $updt_list $i]
            set num_b [lindex $updt_list [expr $i+1]]
            set por_key "$num_a|$num_b"
            if {![dict exists $por_subdict $por_key]} {
                set updt_in_order 0
            }
        }
        #puts "  $updt_in_order {$updt_in_order}"
        if {$updt_in_order == 0} {
            set fixed_updt_list $updt_list
            puts "Processing update: fixed_updt_list {$fixed_updt_list}"
            set one_swap_done 1
            set pass 0
            set max_passes 1000
            while {$one_swap_done == 1 && $pass < $max_passes} {
                puts "  PASS: {$pass}"
                incr pass
                set one_swap_done 0
                for {set j 0} {$j < $updt_list_len - 1} {incr j} {
                    set num_a [lindex $fixed_updt_list $j]
                    set num_b [lindex $fixed_updt_list [expr $j+1]]
                    set por_key "$num_a|$num_b"
                    #puts "  Processing: por_key {$por_key}"
                    if {![dict exists $por_subdict $por_key]} {
                        set fixed_updt_list [lreplace $fixed_updt_list $j $j $num_b]
                        set fixed_updt_list [lreplace $fixed_updt_list $j+1 $j+1 $num_a]
                        puts "    Swap: por_key {$por_key} fixed_updt_list {$fixed_updt_list}"
                        set one_swap_done 1
                    }
                }
            }
            puts "Done update: fixed_updt_list {$fixed_updt_list}"
            #puts "Processing update: $updt {$updt_list_len} {$updt_list}"
            #puts "  $updt_in_order {$updt_in_order} fixed_updt_list {$fixed_updt_list}"
            #continue
            set mid_pg [lindex $fixed_updt_list [expr int($updt_list_len / 2)]]
            incr mid_pg_sums $mid_pg
            puts "  mid_pg {$mid_pg} mid_pg_sums {$mid_pg_sums}"
        }
    }
    puts "mid_pg_sums {$mid_pg_sums}"
    return $mid_pg_sums
}