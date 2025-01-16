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
proc str2dlookup_prep { data_dict } {
    # Input Dict:
    #  Line# String
    #  0 ????
    #  1 ????
    # Output Dict:
    #  info max_lines #
    #  info max_strlen #
    #  info strlen Line# #
    #  info op_results [list command {Results of the command}]
    #  Line# String
    #  0 ????
    #  1 ????

    set max_lines [llength [dict keys $data_dict]]
    dict set data_dict info max_lines $max_lines
    set max_strlen 0
    dict for {ln_cnt in_str} $data_dict {
        if {$ln_cnt == "info"} { continue }
        set strlen [string length $in_str]
        dict set data_dict info strlen $ln_cnt $strlen
        if {$strlen > $max_strlen} {
            set max_strlen $strlen
        }
    }
    dict set data_dict info max_strlen $max_strlen
    dict set data_dict info op_results [list {str2dlookup_prep} [list]]
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
            puts " in_str {$in_str}\nnew_str {$new_str}"
            dict set data_dict $ln_cnt $new_str
            break
        }
    }
    return $data_dict
}
proc is_obstruction { in_char {obstruction_char "#"} } {
    if {$in_char == $obstruction_char} {
        return 1
    }
    return -1
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
proc guard_move_next_direction { data_dict {move_direction ""} {guard_prev_step_char "X"} {default_first_direction "^"} } {
    # Input: Dict
    # Outputs: 
    #     [list 
    #      next_direction (^ up, v down, < left, > right, -1 Couldn't find the input next_direction in the map)
    #      move_status    (-1 (Hit a wall) or 1 (Move was successful) or 0 (No move was made))
    #      Dict
    #    ]
    #    Note: if any elements before the Dict in the list are -1, then don't look at Dict :-)

    # Defaults:
    set next_direction -1
    set move_status 0

    # Start by finding the move_direction (if not given)
    if {$move_direction == ""} {
        # we'll assume it's default_first_direction
        set move_direction $default_first_direction
    }
    set move_direction_exists [str2d_find_char_yx $data_dict $move_direction]
    puts "move_direction_exists {$move_direction_exists}"
    # Punt if this direction is not in the map
    if {$move_direction_exists == -1} { return [list $next_direction $move_status -1]}

    # Since move_direction was found, determine the next direction 
    # If there is something directly in front of you, turn right 90 degrees.
    # move_direction next_direction move_x move_y
    # ^              >              0      -1
    # >              v              1      0
    # v              <              0      1
    # <              ^              -1     0
          if {$move_direction == "^"} { set next_direction ">"; set move_x 0; set move_y -1
    } elseif {$move_direction == ">"} { set next_direction "v"; set move_x 1; set move_y 0
    } elseif {$move_direction == "v"} { set next_direction "<"; set move_x 0; set move_y 1
    } elseif {$move_direction == "<"} { set next_direction "^"; set move_x -1; set move_y 0
    } else {
        set next_direction -1; set move_x "INVALID_MOVE_X"; set move_y "INVALID_MOVE_Y"
    }
    puts "move_direction {$move_direction} next_direction {$next_direction}"
    # Punt if next_direction is invalid 
    if {$next_direction == -1} {
        return [list $next_direction $move_status -1]
    }

    # Keep taking a step forward until hit an obstacle (X) or wall (-1 go out of the map)
    set current_y [lindex $move_direction_exists 0]
    set current_x [lindex $move_direction_exists 1]
    set current_step [str2dlookup_yx $data_dict $current_y $current_x]
    puts "current_step {$current_step} current_y {$current_y} current_x {$current_x} {[is_obstruction $current_step]}"
    set max_iterations 100000000000000
    set curr_iter 0
    while {[is_obstruction $current_step] == -1 && $current_step != -1 && $curr_iter < $max_iterations} {
        # Mark the previous step
        set prev_step_marked [str2d_replace_char_at_yx $data_dict $current_y  $current_x $guard_prev_step_char]
        if {$prev_step_marked == -1} {
            puts "FATALERROR: Couldn't mark previous step, something unexpected happened & needs triaging!"
            break
        }
        set data_dict $prev_step_marked
        # Take the next step
        set prev_y $current_y
        set prev_x $current_x
        incr current_y $move_y
        incr current_x $move_x
        set current_step [str2dlookup_yx $data_dict $current_y $current_x]
        puts "curr_iter {$curr_iter} current_step {$current_step} current_y {$current_y} current_x {$current_x} {[is_obstruction $current_step]}"
        incr curr_iter
        # Punt if current_step is -1 (This shouldn't happen in a valid map but just in case)
        #if {$current_step == -1} {
        #    puts "ERROR: Went outside the map ... Map maybe invalid?!?"
        #    break
        #}
        # if current_step is an obstruction, then mark the prev step with next_direction
        if {[is_obstruction $current_step] == 1} {
            set prev_step_marked [str2d_replace_char_at_yx $data_dict $prev_y  $prev_x $next_direction]
            if {$prev_step_marked == -1} {
                puts "FATALERROR: Couldn't mark previous step, something unexpected happened & needs triaging!"
                break
            }
            set data_dict $prev_step_marked
            set move_status 1
        }
        # if current_step is out of map, then mark the prev step with next_direction
        if {$current_step == -1} {
            set move_status -1
        }
    }
    return [list $next_direction $move_status $data_dict]
}
proc guard_move { data_dict {max_iterations 10000000}} {
    # Input: Dict
    # Outputs: Dict

    #     [list 
    #      next_direction (^ up, v down, < left, > right, -1 Couldn't find the input next_direction in the map)
    #      move_status    (-1 (Hit a wall) or 1 (Move was successful) or 0 (No move was made))
    #      Dict
    #    ]
    #    Note: if any elements before the Dict in the list are -1, then don't look at Dict :-)
    set move_status 0
    set next_direction ""
    #set max_iterations 10000000
    #set max_iterations 10
    set curr_iter 0
    while {$move_status != -1 && $curr_iter < $max_iterations} {
        set status [guard_move_next_direction $data_dict $next_direction]
        set next_direction [lindex $status 0]
        set move_status [lindex $status 1]
        set data_dict [lindex $status 2]
        incr curr_iter
    }
    return $data_dict
}