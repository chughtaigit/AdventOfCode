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
            #puts " in_str {$in_str}\nnew_str {$new_str}"
            dict set data_dict $ln_cnt $new_str
            break
        }
    }
    return $data_dict
}
proc is_obstruction { in_char {obstruction_char "#"} } {
    if {$in_char == $obstruction_char || $in_char == "O"} {
        return 1
    }
    return -1
}
proc is_guard { in_char {guard_char "^"} } {
    if {$in_char == $guard_char} {
        return 1
    }
    return -1
}
proc is_guard_or_obs { in_char } {
    if {[is_obstruction $in_char] != -1 || [is_guard $in_char] != -1} {
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
    #puts "move_direction_exists {$move_direction_exists}"
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
    #puts "move_direction {$move_direction} next_direction {$next_direction}"
    # Punt if next_direction is invalid 
    if {$next_direction == -1} {
        return [list $next_direction $move_status -1]
    }

    # Keep taking a step forward until hit an obstacle (X) or wall (-1 go out of the map)
    set current_y [lindex $move_direction_exists 0]
    set current_x [lindex $move_direction_exists 1]
    set current_step [str2dlookup_yx $data_dict $current_y $current_x]
    #puts "current_step {$current_step} current_y {$current_y} current_x {$current_x} {[is_obstruction $current_step]}"
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
        #puts "curr_iter {$curr_iter} current_step {$current_step} current_y {$current_y} current_x {$current_x} {[is_obstruction $current_step]}"
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
    set curr_iter 0
    while {$move_status != -1 && $curr_iter < $max_iterations} {
        set status [guard_move_next_direction $data_dict $next_direction]
        set next_direction [lindex $status 0]
        set move_status [lindex $status 1]
        set data_dict [lindex $status 2]
        incr curr_iter
    }
    if {$curr_iter == $max_iterations} {
        puts "guard_move: max_iterations reached! Stuck in a loop!"
        dict set data_dict info op_results [list {guard_move} [list max_iterations_reached]]
    }
    if {$move_status == -1} {
        puts "guard_move: Hit a wall!"
        dict set data_dict info op_results [list {guard_move} [list hit_a_wall]]
    }
    return $data_dict
}
proc place_obstruction { data_dict y x {obs_char "O"}} {
    # Input:
    #   Dict
    #   y x -> Location to place obs
    # Output: [list 
    #   status (1 - Successfully placed obs at y,x) or (2 - Successfuly placed obs at obs_y,obs_x) or (-1 failed to place obs)
    #   obs_y (=y if that location worked, otherwise new location. -1 if failed) 
    #   obs_x (=x if that location worked, otherwise new location. -1 if failed) 
    #   Updated Dict]

    # Place a new obstruction at this location. Go to the next location
    # if this location is 
    #   1) Already an obstruction 2) Starting position of the guard "^"
    set obs_y -1
    set obs_x -1
    set status -1
    set max_iterations [string length [str2d_str $data_dict]]
    set curr_iter 0
    set current_y $y
    set current_x $x
    # Punt if current_y/x is out of bounds
    set current_step [str2dlookup_yx $data_dict $current_y $current_x]
    set current_step_is_obs [is_guard_or_obs $current_step]
    #puts "curr_iter {$curr_iter} current_step {$current_step} current_y {$current_y} current_x {$current_x} current_step_is_obs {$current_step_is_obs}"
    if {$current_step == -1} {
        return [list $status $obs_y $obs_x -1]
    }
    # If not out of bound, then is it an obstruction?
    if {$current_step_is_obs == 1} {
        # Find the next non-obs location
        set max_lines [dict get $data_dict info max_lines]
        #puts "max_lines {$max_lines}"
        for {set current_y $current_y} {$current_y < $max_lines} {incr current_y} {
            set max_x [dict get $data_dict info strlen $current_y]
            #puts " max_x {$max_x}"
            for {set current_x $current_x} {$current_x < $max_x} {incr current_x} {
                set current_step [str2dlookup_yx $data_dict $current_y $current_x]
                set current_step_is_obs [is_guard_or_obs $current_step]
                #puts "  curr_iter {$curr_iter} current_step {$current_step} current_y {$current_y} current_x {$current_x} current_step_is_obs {$current_step_is_obs}"
                # Stop when go out of bound or not an obstruction
                if {$current_step == -1 || $current_step_is_obs == -1} {
                    break
                }
            }
            # Stop when go out of bound or not an obstruction
            if {$current_step == -1 || $current_step_is_obs == -1} {
                break
            }
        }
    }
    # Punt if couldn't Find the next non-obs location
    # Punt if went out of bounds
    if {$current_step == -1} {
        return [list $status $obs_y $obs_x -1]
    }
    # Punt if still on obs
    if {$current_step_is_obs != -1} {
        return [list $status $obs_y $obs_x -1]
    }
    # Found a non-obs spot where obs can be placed
    # Because of earlier checks, this should never be -1, but just in case ..
    set status2 [str2d_replace_char_at_yx $data_dict $current_y $current_x $obs_char]
    if {$status2 == -1} {
        puts "FATALERROR: place_obstruction: Unexpected error, needs triage!"
        return [list $status $obs_y $obs_x -1]
    }
    set obs_y $current_y
    set obs_x $current_x
    if {$y == $current_y && $x == $current_x} {
        set status 1
    } else {
        set status 2
    }
    return [list $status $obs_y $obs_x $status2]
}
proc part2_soln { data_dict {max_iterations ""} {start_y 0} {start_x 0} {obs_char "O"}} {
    # max_iterations or maximum number of steps is the character length of the map (conservatively)
    # because there are obstructions which will reduce the number of steps, and then eventually 
    # the guard will step outside the map.
    # ASSUMPTION: Conservatively, we will assume that the maximum number of steps the guard will take is 
    # not more than the max_iterations.
    # ASSUMPTION 2: If there is a new obstruction placed any where, and the guard gets 
    # stuck in a loop, when the loop number of steps reaches max_iterations, then we know that the 
    # guard is stuck in a loop. ALTERNATIVELY if the guard steps outside the map before max_iterations
    # then the new obstructions is not working!
    # Keep saving the location of the new obstructions until we run out of the map. 
    # Output: RETURN the COUNT of the new obstruction locations

    # Save the original data_dict which will get walked thru & new obstruction is added
    # at each location to evaluate the results
    set orig_data_dict $data_dict

    # Calculate max_iterations if not given
    if {$max_iterations == ""} {
        set max_iterations [string length [str2d_str $data_dict]]
        puts "max_iterations {$max_iterations}"
    }

    # Start from the top-left of the map: start_y & start_x = 0
    # Place a new obstruction at this location. Go to the next location
    # if this location is 
    #   1) Already an obstruction 2) Starting position of the guard "^"
    set current_y $start_y
    set current_x $start_x
    set already_processed_yx [list]
    set new_obs_locations [list]
    set max_lines [dict get $data_dict info max_lines]
    #puts "max_lines {$max_lines}"
    for {set current_y $start_y} {$current_y < $max_lines} {incr current_y} {
        set max_x [dict get $orig_data_dict info strlen $current_y]
        #puts " max_x {$max_x} current_y {$current_y}"
        for {set current_x $start_x} {$current_x < $max_x} {incr current_x} {
            #puts "  current_y {$current_y} current_x {$current_x}"
            set place_obs_res [place_obstruction $orig_data_dict $current_y $current_x]
            #puts "place_obs_res {$place_obs_res}"
            lassign $place_obs_res status obs_y obs_x obs_data_dict
            #puts "status {$status} obs_y {$obs_y} obs_x {$obs_x} obs_data_dict {$obs_data_dict}"
            # Punt if anything went wrong!
            if {$status == -1} {
                # Need to understand why return -1 is not working?!? 
                continue
                return -1
            }
            # Go to the next location if this has been previsouly processed!
            if {[lsearch -exact $already_processed_yx "$obs_y $obs_x"] != -1} {
                puts "SKIPPING previously processed location: {$obs_y $obs_y}"
                continue
            }
            lappend already_processed_yx [list $obs_y $obs_x]
            # Process this location
            #set data_dict $obs_data_dict
            #puts "PROCESSING location: {$obs_y $obs_x} already_processed_yx {$already_processed_yx}"
            puts "PROCESSING location: {$obs_y $obs_x}"
            #puts "str2d_str: {\n[str2d_str $obs_data_dict]}"
            set data_dict_res [guard_move $obs_data_dict $max_iterations]
            set op_results [dict get $data_dict_res info op_results]
            lassign $op_results operation op_output
            if {$op_output == "max_iterations_reached"} {
                # Stuck in a loop!
                lappend new_obs_locations [list $obs_y $obs_x]
            } elseif {$op_output == "hit_a_wall"} {
                # Hit a wall!
            } else {
                # Something unexpected happened!
                puts "FATALERROR: part2_soln: Unexpected error, needs triage!"
            }
            #break
        }
        #break
    }
    # Print new map with obstructions
    if {[llength $new_obs_locations] != 0} {
        set print_obs $orig_data_dict
        foreach obs_yx $new_obs_locations {
            lassign $obs_yx obs_y obs_x
            set status2 [str2d_replace_char_at_yx $print_obs $obs_y $obs_x $obs_char]
            if {$status2 == -1} {
                puts "FATALERROR: part2_soln: Another Unexpected error, needs triage!"
            }
            set print_obs $status2
        }
        puts "str2d_str: {\n[str2d_str $print_obs]}"
    }
    puts "{[llength $new_obs_locations]} new_obs_locations {$new_obs_locations}"
    return [llength $new_obs_locations]
}