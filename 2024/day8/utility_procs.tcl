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
proc str2dlookup_plus_prep { data_dict {ignore_uniq_char "."} {empty_map_fill_char "."} {out_of_map_indicator "o"} } {
    # Input Dict:
    #  Line# String
    #  0 ????
    #  1 ????
    # Output Dict:
    #  info max_lines #
    #  info max_strlen #
    #  info strlen Line# #
    #  info map_size_yx [list max_y(=max_lines) max_x(=max_strlen)]
    #  info char_uniq [list char0 char1 char2 ...]
    #  info char_freq char0 [list y0 x0 y1 x1 ...]
    #  info char_freq char1 [list y0 x0 y1 x1 ...]
    #  ...
    #  info empty_map Line# String
    #  info char_freq_pairs char0 [list [list y0 x0 y1 x1] [list y1 x1 y2 x2] ...]
    #  info op_results [list command {Results of the command}]
    #  Line# String
    #  0 ????
    #  1 ????

    set max_lines [llength [dict keys $data_dict]]
    dict set data_dict info max_lines $max_lines
    set max_strlen 0
    set char_uniq [list]
    set char_freq [dict create]
    dict for {ln_cnt in_str} $data_dict {
        if {$ln_cnt == "info"} { continue }
        set strlen [string length $in_str]
        dict set data_dict info strlen $ln_cnt $strlen
        if {$strlen > $max_strlen} {
            set max_strlen $strlen
        }
        # Find unique characters
        foreach char [split $in_str {}] {
            if {$char == $ignore_uniq_char} { continue }
            if {[lsearch -exact $char_uniq $char] == -1} {
                lappend char_uniq $char
                #  info char_freq char0 [list y0 x0 y1 x1 ...]
                dict set data_dict info char_freq $char [list]
            }
        }
        # Record each unique char's location
        foreach char $char_uniq {
            if {$char == $ignore_uniq_char} { continue }
            set all_char_loc_x [lsearch -all -exact [split $in_str {}] $char]
            #puts "char {$char} all_char_loc_x {$all_char_loc_x} in_str {$in_str}"
            foreach char_loc_x $all_char_loc_x {
                #  info char_freq char0 [list y0 x0 y1 x1 ...]
                dict set data_dict info char_freq $char [concat [dict get $data_dict info char_freq $char] [list $ln_cnt $char_loc_x]]
            }
        }
    }
    dict set data_dict info max_strlen $max_strlen
    dict set data_dict info op_results [list {str2dlookup_prep} [list]]
    dict set data_dict info map_size_yx [list $max_lines $max_strlen]
    dict set data_dict info char_uniq $char_uniq

    #############
    # 2nd pass: Do some more pre-processing on 2nd pass
    # For empty_map
    #dict set data_dict info empty_map info max_lines $max_lines
    #dict set data_dict info empty_map info max_strlen $max_strlen
    dict for {ln_cnt in_str} $data_dict {
        # Generate empty_map
        #  info empty_map Line# String
        #dict set data_dict info empty_map info strlen $ln_cnt $strlen
        dict set data_dict info empty_map $ln_cnt [string repeat $empty_map_fill_char $max_strlen]
        set strlen [string length $in_str]
    }
    # Generate char_freq_maps
    foreach char $char_uniq {
        #  info char_freq char0 [list y0 x0 y1 x1 ...]
        set all_char_loc_yx [dict get $data_dict info char_freq $char]
        # DOESN't MEET THE SPEC: Only creates pairs between last two locations
        # Create pairs
        #set i 0
        #set all_pairs [list]
        #foreach {y x} $all_char_loc_yx {
        #    if {$i == 0} {
        #        set prev_y $y; set prev_x $x
        #        incr i
        #        continue
        #    }
        #    set antinodes_0_y [expr $prev_y + ($prev_y - $y)]
        #    set antinodes_0_x [expr $prev_x + ($prev_x - $x)]
        #    set antinodes_1_y [expr $y + ($y - $prev_y)]
        #    set antinodes_1_x [expr $x + ($x - $prev_x)]
        #    set this_pair [list $prev_y $prev_x $y $x $antinodes_0_y $antinodes_0_x $antinodes_1_y $antinodes_1_x]
        #    lappend all_pairs $this_pair
        #    set prev_y $y; set prev_x $x
        #}
        #  info char_freq_pairs char0 [list [list y0 x0 y1 x1] [list y1 x1 y2 x2] ...]
        #dict set data_dict info char_freq_pairs $char $all_pairs

        # SPEC: Need to make pairs with ALL locations!
        set all_pairs [list]
        set len_all_char_loc_yx [llength $all_char_loc_yx]
        set len_yx_pair_all_char_loc_yx [expr $len_all_char_loc_yx / 2]
        for {set i 0} {$i < $len_all_char_loc_yx} {incr i 2} {
            set prev_y [lindex $all_char_loc_yx $i]
            set prev_x [lindex $all_char_loc_yx $i+1]
            for {set j [expr $i + 2]} {$j < $len_all_char_loc_yx} {incr j 2} {
                set y [lindex $all_char_loc_yx $j]
                set x [lindex $all_char_loc_yx $j+1]
                set antinodes_0_y [expr $prev_y + ($prev_y - $y)]
                set antinodes_0_x [expr $prev_x + ($prev_x - $x)]
                set antinodes_1_y [expr $y + ($y - $prev_y)]
                set antinodes_1_x [expr $x + ($x - $prev_x)]
                # Anything out of the map - mark it as "o" for "out of bound"
                set antinodes_0_check [str2dlookup_yx $data_dict $antinodes_0_y $antinodes_0_x]
                set antinodes_1_check [str2dlookup_yx $data_dict $antinodes_1_y $antinodes_1_x]
                if {$antinodes_0_check == -1} { set antinodes_0_y $out_of_map_indicator; set antinodes_0_x $out_of_map_indicator}
                if {$antinodes_1_check == -1} { set antinodes_1_y $out_of_map_indicator; set antinodes_1_x $out_of_map_indicator}
                set this_pair [list $prev_y $prev_x $y $x $antinodes_0_y $antinodes_0_x $antinodes_1_y $antinodes_1_x ]
                # Part 2
                #WORKING_HERE
                # Not the most optimized solution but it will do for now :D
                set this_second_pair [list]
                for {set ky 2} {$ky < [expr $max_lines + $max_strlen]} {incr ky} {
                    set antinodes_dn_y [expr $prev_y + $ky*($prev_y - $y)]
                    set antinodes_dn_x [expr $prev_x + $ky*($prev_x - $x)]
                    set antinodes_up_y [expr $y + $ky*($y - $prev_y)]
                    set antinodes_up_x [expr $x + $ky*($x - $prev_x)]
                    # Check for out of bound
                    set antinodes_dn_check [str2dlookup_yx $data_dict $antinodes_dn_y $antinodes_dn_x]
                    if {$antinodes_dn_check == -1} { set antinodes_dn_y $out_of_map_indicator; set antinodes_dn_x $out_of_map_indicator}
                    set antinodes_up_check [str2dlookup_yx $data_dict $antinodes_up_y $antinodes_up_x]
                    if {$antinodes_up_check == -1} { set antinodes_up_y $out_of_map_indicator; set antinodes_up_x $out_of_map_indicator}
                    set this_second_pair [concat $this_second_pair $antinodes_dn_y $antinodes_dn_x $antinodes_up_y $antinodes_up_x]
                }
                #set antinodes_12_y [expr $y + 2*($y - $prev_y)]; set antinodes_12_x [expr $x + 2*($x - $prev_x)]
                #set antinodes_13_y [expr $y + 3*($y - $prev_y)]; set antinodes_13_x [expr $x + 3*($x - $prev_x)]
                #set antinodes_02_y [expr $prev_y + 2*($prev_y - $y)]; set antinodes_02_x [expr $prev_x + 2*($prev_x - $x)]
                #set antinodes_03_y [expr $prev_y + 3*($prev_y - $y)]; set antinodes_03_x [expr $prev_x + 3*($prev_x - $x)]
                #set antinodes_02_check [str2dlookup_yx $data_dict $antinodes_02_y $antinodes_02_x]
                #set antinodes_03_check [str2dlookup_yx $data_dict $antinodes_03_y $antinodes_03_x]
                #set antinodes_12_check [str2dlookup_yx $data_dict $antinodes_12_y $antinodes_12_x]
                #set antinodes_13_check [str2dlookup_yx $data_dict $antinodes_13_y $antinodes_13_x]
                #if {$antinodes_02_check == -1} { set antinodes_02_y $out_of_map_indicator; set antinodes_02_x $out_of_map_indicator}
                #if {$antinodes_03_check == -1} { set antinodes_03_y $out_of_map_indicator; set antinodes_03_x $out_of_map_indicator}
                #if {$antinodes_12_check == -1} { set antinodes_12_y $out_of_map_indicator; set antinodes_12_x $out_of_map_indicator}
                #if {$antinodes_13_check == -1} { set antinodes_13_y $out_of_map_indicator; set antinodes_13_x $out_of_map_indicator}
                #set this_pair [list $prev_y $prev_x $y $x $antinodes_0_y $antinodes_0_x $antinodes_1_y $antinodes_1_x \
                #                    $antinodes_02_y $antinodes_02_x $antinodes_03_y $antinodes_03_x \
                #                    $antinodes_12_y $antinodes_12_x $antinodes_13_y $antinodes_13_x \
                #                    ]
                set this_pair [concat $this_pair $this_second_pair]
                lappend all_pairs $this_pair
            }
        }
        #  info char_freq_pairs char0 [list [list y0 x0 y1 x1] [list y1 x1 y2 x2] ...]
        dict set data_dict info char_freq_pairs $char $all_pairs
    }
    puts "New: data_dict {$data_dict}"
    return $data_dict
}
proc str2dlookup_yx { data_dict y x} {
    # Input:
        # Dict:
        #  info max_lines #
        #  info strlen Line# #
        #  Line# String
        #  0 ????
        #  1 ????
        # x Number (positive)
        # y Number (positive) 
    # 
    # Output:
    #   String: Single Character at location (x,y)
    #       -1: If x,y are out of bounds
    #
    # String coordinates can be looked up as following:
    #   Line#(y) Character_index(x)
    #          0 This_is_line_0
    #          1 tHIS_IS_LINE_1
    #          2 THIS_IS_LINE_2
    #
    # (0,0) "T"
    # (0,1) "h"
    # (0,1000) -1
    # (2,13) "2"

    # Out of bounds check
    # y
    if {$y < 0 || $y >= [dict get $data_dict info max_lines]} { return -1}
    # x
    if {$x <0 || $x >= [dict get $data_dict info strlen $y]} { return -1}
    # x,y
    return [string index [dict get $data_dict $y] $x]
}
proc str2dlookup_multi_yx { data_dict yx_list } {
    # Input:
        # Dict:
        # yx pairs as list: [list {y0 x0 expected_char0} {y1 x1 expected_char1} ...]
    # Output:
        # [list 
        #    one_out_of_bound
        #    one_expected_char_not_found
        #    [list result_y0_x0 result_y1_x1 ...]]
        # Both one_* -> 0 (no issues) , -1 (one problem found)

    set lookup_chars [list]
    set one_out_of_bound 0
    set one_expected_char_not_found 0
    foreach {yxe} $yx_list {
        set y [lindex $yxe 0]
        set x [lindex $yxe 1]
        set expected_char [lindex $yxe 2]
        set yx_lookup_result [str2dlookup_yx $data_dict $y $x]
        lappend lookup_chars $yx_lookup_result
        if {$yx_lookup_result == -1} {
            set one_out_of_bound -1
        }
        if {$yx_lookup_result != $expected_char} {
            set one_expected_char_not_found -1
        }
    }
    return [list $one_out_of_bound $one_expected_char_not_found $lookup_chars]
}
proc str2d_str { data_dict } {
    # Input:
        # Dict:
        #  info max_lines #
        #  info strlen Line# #
        #  Line# String
        #  0 ????
        #  1 ????
        # x Number (positive)
        # y Number (positive) 
    # 
    # Output:
    #   String: All lines concatenated with newlines (\n)
    #
    set ret_str ""
    dict for {ln_cnt in_str} $data_dict {
        if {$ln_cnt == "info"} { continue }
        append ret_str $in_str
        append ret_str "\n"
    }
    return $ret_str
}
proc str2d_find_char_yx { data_dict my_char } {
    # Input:
        # Dict:
        #  info max_lines #
        #  info strlen Line# #
        #  Line# String
        #  0 ????
        #  1 ????
        # my_char String 
    # 
    # Output:
    #   [list y x] where y is line, and x is first my_char on that line
    #      Note: If there are multiple my_char in the string, only the first occurance will be returned.
    #   [list -1 -1] if my_char wasn't found
    #
    set ret_yx [list -1 -1]
    dict for {ln_cnt in_str} $data_dict {
        if {$ln_cnt == "info"} { continue }
        set found_my_char [string first $my_char $in_str]
        if {$found_my_char != -1} {
            set ret_yx [list $ln_cnt $found_my_char]
            break
        }
    }
    return $ret_yx
}
proc str2d_replace_char_at_yx { data_dict y x new_char } {
    # Input:
        # Dict:
        #  info max_lines #
        #  info strlen Line# #
        #  Line# String
        #  0 ????
        #  1 ????
        # my_char String 
    # 
    # Output: -1 or Updated_Dict
    # 

    # Start by looking up character at y x. This will do basic error checking
    # and also give us a chance to see if existing character is same as new_char
    set curr_char [str2dlookup_yx $data_dict $y $x]
    # Out of bounds
    if {$curr_char == -1} {
        return -1
    }
    # Character same as what's there? Return the Input Dict UNCHANGED
    if {$curr_char == $new_char} {
        return $data_dict
    }
    # Character NOT same, Update it & return the updated dictionary 
    dict for {ln_cnt in_str} $data_dict {
        if {$ln_cnt == "info"} { continue }
        if {$ln_cnt == $y} {
            set new_str [string replace $in_str $x $x $new_char]
            #puts " in_str {$in_str}\nnew_str {$new_str}"
            dict set data_dict $ln_cnt $new_str
            break
        }
    }
    return $data_dict
}
# Source/Credit: https://wiki.tcl-lang.org/page/String+occurrences
proc string_occurrences {args} {

    set opt [lindex $args 0]
    set needleString [lindex $args end-1]
    set haystackString [lindex $args end]

    set j [string first $needleString $haystackString 0]

    if {$j == -1} {return ""}
    append res $j

    set i 0
    set d [string length $needleString]
    while {$j != -1 } {
        set j [string first $needleString $haystackString [incr j]]
        incr i $d
        if {$j != -1} { lappend res $j }
    }

    if { $opt eq "-inline" } { return $res }
    return $i
}
proc part1_soln { data_dict {harmonics 0} {ignore_uniq_char "."} {empty_map_fill_char "."} {out_of_map_indicator "o"} {antinode_symbol "#"} } {
    # Input Dict:
    #  info max_lines #
    #  info max_strlen #
    #  info strlen Line# #
    #  info map_size_yx [list max_y(=max_lines) max_x(=max_strlen)]
    #  info char_uniq [list char0 char1 char2 ...]
    #  info char_freq char0 [list y0 x0 y1 x1 ...]
    #  info char_freq char1 [list y0 x0 y1 x1 ...]
    #  ...
    #  info empty_map Line# String
    #  info char_freq_pairs char0 [list [list y0 x0 y1 x1] [list y1 x1 y2 x2] ...]
    #  info op_results [list command {Results of the command}]
    #  Line# String
    #  0 ????
    #  1 ????
    #
    # Output: How many unique locations within the bounds of the map contain an antinode?

    set char_freq_pairs_subdict [dict get $data_dict info char_freq_pairs]
    set empty_map_subdict [dict get $data_dict info empty_map]

    dict for {char freq_pairs} $char_freq_pairs_subdict {
        puts "char {$char} freq_pairs {$freq_pairs}"
        if {$harmonics == 0} {
            foreach fpair $freq_pairs {
                lassign $fpair y0 x0 y1 x1 an_y0 an_x0 an_y1 an_x1
                # Map it on the empty map
                if {$an_y0 != $out_of_map_indicator} {
                    # Put an antinode symbol on the empty map
                    set data_dict [str2d_replace_char_at_yx $data_dict $an_y0 $an_x0 $antinode_symbol]
                    #puts "an_*0 status: {$status}"
                }
                if {$an_y1 != $out_of_map_indicator} {
                    # Put an antinode symbol on the empty map
                    set data_dict [str2d_replace_char_at_yx $data_dict $an_y1 $an_x1 $antinode_symbol]
                    #puts "an_*1 status: {$status}"
                }
            }
        } else {
            foreach fpair $freq_pairs {
                foreach {any_y any_x} $fpair {
                    #puts "any_y {$any_y} any_x {$any_x}"
                    # Map it on the empty map
                    if {$any_y != $out_of_map_indicator} {
                        # Put an antinode symbol on the empty map
                        set data_dict [str2d_replace_char_at_yx $data_dict $any_y $any_x $antinode_symbol]
                        #puts "an_*0 status: {$status}"
                    }
                }
            }
        }
    }
    set final_map [str2d_str $data_dict]
    puts "str2d_str: {\n[str2d_str $data_dict]}"
    set uniq_locs [string_occurrences $antinode_symbol $final_map]
    if {$harmonics != 0} { puts "Harmonics included: harmonics {$harmonics}" }
    puts "Total unique locations: $uniq_locs"
    return $uniq_locs
}