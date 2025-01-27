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
    #puts "New: data_dict {$data_dict}"
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
proc is_freespace { in_char {obstruction_char "."} } {
    if {$in_char == $obstruction_char} {
        return 1
    }
    return -1
}
proc diskmap_to_blocks { data_dict { diskmap_in_line_num 0} {free_space_char "."} } {
    # Input Dict:
    #  info max_lines #
    #  info max_strlen #
    #  info strlen Line# #
    #  info op_results [list command {Results of the command}]
    #  Line# String
    #  0 ????
    #  1 ????

    # Output Dict: Same as Input plus below:
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]

    # ASSUMPTION: There's only one line
    set ln_cnt $diskmap_in_line_num
    set diskmap [dict get $data_dict $ln_cnt]
    #puts "diskmap {$diskmap}"
    set file_ids [list]
    set curr_file_id -1
    set blocks_map ""
    foreach {file_blocks free_space_blocks} [split $diskmap {}] {
        #puts "file_blocks {$file_blocks} free_space_blocks {$free_space_blocks}"
        # File blocks
        if {$file_blocks == ""} {
            # Done!
            puts "No more file_blocks!"
            break
        }
        incr curr_file_id
        lappend file_ids $curr_file_id
        append blocks_map [string repeat $curr_file_id $file_blocks]
        # Free space
        if {$free_space_blocks == ""} {
            # Done!
            puts "No more free_space_blocks!"
            break
        }
        append blocks_map [string repeat $free_space_char $free_space_blocks]
    }
    #puts "blocks_map {$blocks_map}"
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    dict set data_dict info diskmap $diskmap
    dict set data_dict info blocks_map $blocks_map
    dict set data_dict info file_ids $file_ids
    return $data_dict
}
proc checksum_calc { in_str {free_space_char "."} } {
    # Inputs: String
    # Outputs:
    #   checksum
    #puts "in_str {$in_str}"
    set in_str_len [string length $in_str]
    set checksum 0
    for {set i 0} {$i < $in_str_len} {incr i} {
        set curr_file_id [string index $in_str $i]
        if {$curr_file_id == $free_space_char} { continue }
        incr checksum [expr $i * $curr_file_id]
    }
    return $checksum
}
proc move_file_blocks_one_at_a_time { in_str {free_space_char "."} } {
    # Inputs: String
    # Outputs:
    #   -1  (No movement was done) or Modified_String

    # Find the right-most non-free-space char
    #puts "in_str {$in_str}"
    set in_str_len [string length $in_str]
    set last_file_block [string index $in_str end]
    set last_file_block_index [expr $in_str_len - 1]
    set i 0; set max_i $in_str_len
    while {$last_file_block == $free_space_char && $i < $max_i} {
        incr i
        set last_file_block [string index $in_str end-$i]
        set last_file_block_index [expr $in_str_len - 1 - $i]
    }
    #puts "last_file_block {$last_file_block} last_file_block_index {$last_file_block_index}"
    # Find the left-most free space
    set first_free_space_index [string first $free_space_char $in_str]
    #puts "$first_free_space_index {$first_free_space_index}"
    # If the free space is to the right of the last_file_block
    # then can't optimize anymore
    if {$first_free_space_index > $last_file_block_index} {
        return -1
    }
    set new_str [string replace $in_str $first_free_space_index $first_free_space_index $last_file_block]
    set new_str [string replace $new_str $last_file_block_index $last_file_block_index $free_space_char]
    return $new_str
}
proc move_file_blocks { data_dict {free_space_char "."} } {
    # Input Dict: 
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    #
    # Output Dict: Same as Input plus below:
    #  info opt_blocks_map String

    set blocks_map [dict get $data_dict info blocks_map]
    set opt_blocks_map $blocks_map
    set status ""
    set max_iterations [string length $blocks_map]
    set curr_iter 0
    while {$status != -1 && $curr_iter < $max_iterations} {
        set status [move_file_blocks_one_at_a_time $opt_blocks_map]
        if {$status != -1} {
            set opt_blocks_map $status
        }
    }
    set checksum [checksum_calc $opt_blocks_map]
    dict set data_dict info opt_blocks_map $opt_blocks_map
    dict set data_dict info opt_blocks_checksum $checksum
    #puts "    blocks_map {$blocks_map}"
    #puts "opt_blocks_map {$opt_blocks_map}"
    puts "      checksum {$checksum}"
    return $data_dict
}
proc diskmap_to_blocks_list { data_dict { diskmap_in_line_num 0} {free_space_char "."} } {
    # Input Dict:
    #  info max_lines #
    #  info max_strlen #
    #  info strlen Line# #
    #  info op_results [list command {Results of the command}]
    #  Line# String
    #  0 ????
    #  1 ????

    # Output Dict: Same as Input plus below:
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    #  info file_num_blocks file_id blocks#

    # ASSUMPTION: There's only one line
    set ln_cnt $diskmap_in_line_num
    set diskmap [dict get $data_dict $ln_cnt]
    #puts "diskmap {$diskmap}"
    puts "len(diskmap) {[string length $diskmap]}"
    set file_ids [list]
    set curr_file_id -1
    set blocks_map [list]
    set file_num_blocks 0
    foreach {file_blocks free_space_blocks} [split $diskmap {}] {
        #puts "file_blocks {$file_blocks} free_space_blocks {$free_space_blocks}"
        # File blocks
        if {$file_blocks == ""} {
            # Done!
            puts "No more file_blocks!"
            break
        }
        incr curr_file_id
        lappend file_ids $curr_file_id
        lappend blocks_map {*}[lrepeat $file_blocks $curr_file_id]
        set file_num_blocks $file_blocks
        dict set data_dict info file_num_blocks $curr_file_id $file_num_blocks
        # Free space
        if {$free_space_blocks == ""} {
            # Done!
            puts "No more free_space_blocks!"
            break
        }
        lappend blocks_map {*}[lrepeat $free_space_blocks $free_space_char]
    }
    #puts "blocks_map {$blocks_map}"
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    dict set data_dict info diskmap $diskmap
    dict set data_dict info blocks_map $blocks_map
    dict set data_dict info file_ids $file_ids
    return $data_dict
}
proc checksum_calc_list { in_str {free_space_char "."} } {
    # Inputs: List
    # Outputs:
    #   checksum
    set in_str_len [llength $in_str]
    set checksum 0
    for {set i 0} {$i < $in_str_len} {incr i} {
        set curr_file_id [lindex $in_str $i]
        if {$curr_file_id == $free_space_char} { continue }
        incr checksum [expr $i * $curr_file_id]
    }
    return $checksum
}
proc move_file_blocks_one_at_a_time_list { in_str {free_space_char "."} } {
    # Inputs: List
    # Outputs:
    #   -1  (No movement was done) or Modified_String

    # Find the right-most non-free-space char
    #puts "in_str {$in_str}"
    set in_str_len [llength $in_str]
    set last_file_block [lindex $in_str end]
    set last_file_block_index [expr $in_str_len - 1]
    set i 0; set max_i $in_str_len
    while {$last_file_block == $free_space_char && $i < $max_i} {
        incr i
        set last_file_block [lindex $in_str end-$i]
        set last_file_block_index [expr $in_str_len - 1 - $i]
    }
    #puts "last_file_block {$last_file_block} last_file_block_index {$last_file_block_index}"
    # Find the left-most free space
    set first_free_space_index [lsearch -exact $in_str $free_space_char]
    #puts "first_free_space_index {$first_free_space_index}"
    # If the free space is to the right of the last_file_block
    # then can't optimize anymore
    if {$first_free_space_index > $last_file_block_index} {
        return -1
    }
    set new_str [lreplace $in_str $first_free_space_index $first_free_space_index $last_file_block]
    set new_str [lreplace $new_str $last_file_block_index $last_file_block_index $free_space_char]
    return $new_str
}
proc move_file_blocks_list { data_dict {free_space_char "."} } {
    # Input Dict: 
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    #
    # Output Dict: Same as Input plus below:
    #  info opt_blocks_map String

    set blocks_map [dict get $data_dict info blocks_map]
    set opt_blocks_map $blocks_map
    set status ""
    set max_iterations [llength $blocks_map]
    set curr_iter 0
    while {$status != -1 && $curr_iter < $max_iterations} {
        set status [move_file_blocks_one_at_a_time_list $opt_blocks_map]
        if {$status != -1} {
            set opt_blocks_map $status
        }
        incr curr_iter
    }
    dict set data_dict info opt_blocks_map $opt_blocks_map
    #puts "    blocks_map {$blocks_map}"
    #puts "opt_blocks_map {$opt_blocks_map}"
    set checksum [checksum_calc_list $opt_blocks_map]
    dict set data_dict info opt_blocks_checksum $checksum
    puts "      checksum {$checksum}"
    return $data_dict
}
proc diskmap_inventory { data_dict {free_space_char "."} } {
    # Input Dict:
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    #  info file_num_blocks file_id blocks#

    # Output Dict: Same as Input plus below:
    #  info file_start_index file_id# start_index
    #  info free_spaces num_free_spaces# [list index0 index1 ...]
    #  info free_space_indices [list index0 index1 ...]
    #  info free_space_num_blocks index# num_free_spaces#
    #  info opt_blocks_map String
    #   
    set blocks_map [dict get $data_dict info blocks_map]
    dict set data_dict info opt_blocks_map $blocks_map
    set file_ids [dict get $data_dict info file_ids]
    puts "file_ids {$file_ids}"

    # Free space is all the places where there's no file blocks.
    set first_free_space_index [lsearch -exact -start 0 $blocks_map $free_space_char]
    dict set data_dict info free_spaces_indices [list]
    # Get file_start_index (ASSUMPTION: all files are continuous. NOT AN ASSUMPTION because this is how blocks_map is created!)
    foreach file_id $file_ids {
        set file_start_index [lsearch -exact $blocks_map $file_id]
        #puts "file_start_index {$file_start_index}"
        #  info file_start_index file_id# start_index
        dict set data_dict info file_start_index $file_id $file_start_index
    }
    foreach file_id $file_ids {
        set file_start_index [lsearch -exact $blocks_map $file_id]
        #puts "file_start_index {$file_start_index} first_free_space_index {$first_free_space_index}"
        # Figure out free space
        if {$first_free_space_index > $file_start_index} { continue }
        if {$first_free_space_index == -1} { continue }
        set num_free_spaces [expr $file_start_index - $first_free_space_index]
        #puts "  num_free_spaces {$num_free_spaces}"
        if {$num_free_spaces == 0} { continue }
        #  info free_spaces num_free_spaces# [list index0 index1 ...]
        if {![dict exists $data_dict info free_spaces $num_free_spaces]} {
            dict set data_dict info free_spaces $num_free_spaces [list]
        }
        dict set data_dict info free_spaces $num_free_spaces [concat [dict get $data_dict info free_spaces $num_free_spaces] $first_free_space_index]
        # Set the next free space after the current file_id
        # set first_free_space_index [expr $file_start_index + [dict get $data_dict info file_num_blocks $file_id]]
        set first_free_space_index [lsearch -exact -start [expr $first_free_space_index + $num_free_spaces] $blocks_map $free_space_char]
    }
    set all_free_space_indices [list]
    dict for {free_spaces this_list} [dict get $data_dict info free_spaces] {
        set all_free_space_indices [concat $all_free_space_indices $this_list]
        foreach this_index $this_list {
            #  info free_space_num_blocks index# num_free_spaces#
            dict set data_dict info free_space_num_blocks $this_index $free_spaces
        }
    }
    dict set data_dict info free_spaces_indices [lsort -integer -increasing $all_free_space_indices]
    return $data_dict
}
proc move_whole_file_one_at_a_time_list { data_dict file_id_to_move {free_space_char "."} } {
    # Inputs: Dict
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    #  info file_num_blocks file_id blocks#
    #  info file_start_index file_id# start_index
    #  info free_spaces num_free_spaces# [list index0 index1 ...]
    #
    # Outputs: 
    #   -1  (No movement was done) or Modified_Dict

    # Start with the file_id_to_move
    set file_num_blocks [dict get $data_dict info file_num_blocks $file_id_to_move]
    puts "file_id_to_move {$file_id_to_move} file_num_blocks {$file_num_blocks}"
    # Starting from left, find a space big enough to fit the whole file
    set free_spaces_indices [dict get $data_dict info free_spaces_indices]
    set found_enough_space -1
    set loc_this_index 0
    foreach this_index $free_spaces_indices {
        set free_space_num_blocks [dict get $data_dict info free_space_num_blocks $this_index]
        if {$free_space_num_blocks >= $file_num_blocks} {
            # Found a space big enough!
            set found_enough_space 1
            break
        }
        incr loc_this_index
    }
    if {$found_enough_space == -1} {
        # Couldn't find space large enough so Punt
        puts "PUNT: Couldn't find space!"
        return -1
    }
    set file_start_index [dict get $data_dict info file_start_index $file_id_to_move]
    if {$this_index >= $file_start_index} {
        # If open space is found after where the file currently is
        # If there is no span of free space to the left of a file that is large enough to fit the file, the file does not move
        puts "PUNT: Open space after the file!"
        return -1
    }
    #puts "Space found: Index {$this_index} Blocks {$free_space_num_blocks} ..."

    # Replace free space by files & update the dictionary
    set opt_block_map [dict get $data_dict info opt_blocks_map]
    #puts "this_index {$this_index} file_num_blocks {$file_num_blocks} file_id_to_move {$file_id_to_move} file_start_index {$file_start_index}"
    # The following lreplace/lrepeat code is making the list non-flat with {9 9} and {. .}
    # opt_block_map {0 0 . . . 1 1 1 . . . 2 . . . 3 3 3 . 4 4 . 5 5 5 5 . 6 6 6 6 . 7 7 7 . 8 8 8 8 9 9}
    #  new_map {0 0 {9 9} . 1 1 1 . . . 2 . . . 3 3 3 . 4 4 . 5 5 5 5 . 6 6 6 6 . 7 7 7 . 8 8 8 8 9 {. .}}
    #set new_map [lreplace $opt_block_map $this_index       [expr $this_index + $file_num_blocks - 1]       [lrepeat $file_num_blocks $file_id_to_move]]
    #set new_map [lreplace $new_map       $file_start_index [expr $file_start_index + $file_num_blocks - 1] [lrepeat $file_num_blocks $free_space_char]]
    set new_map $opt_block_map
    for {set i $this_index} {$i < [expr $this_index + $file_num_blocks]} {incr i} {
        set new_map [lreplace $new_map $i $i $file_id_to_move]
    }
    for {set i $file_start_index} {$i < [expr $file_start_index + $file_num_blocks]} {incr i} {
        set new_map [lreplace $new_map $i $i $free_space_char]
    }
    #puts "opt_block_map {$opt_block_map}\n      new_map {$new_map}"
    dict set data_dict info opt_blocks_map $new_map
    # Update the dictionary
    # File
    set upd_file_start_index $this_index
    dict set data_dict info file_start_index $file_id_to_move $upd_file_start_index
    # Free space
    # 1. END: Where the file was
    set upd_end_free_space_index $file_start_index
    set upd_end_free_space_num_blocks $file_num_blocks
    #puts "upd_end_free_space_index {$upd_end_free_space_index} upd_end_free_space_num_blocks {$upd_end_free_space_num_blocks}"
    lappend free_spaces_indices $upd_end_free_space_index
    dict set data_dict info free_space_num_blocks $upd_end_free_space_index $upd_end_free_space_num_blocks
    # 2. BEGINNING: Where the free space was replaced
    set upd_replaced_free_space_num_blocks [expr $free_space_num_blocks - $file_num_blocks]
    #puts "upd_replaced_free_space_num_blocks {$upd_replaced_free_space_num_blocks}"
    set free_spaces_indices [lreplace $free_spaces_indices $loc_this_index $loc_this_index]
    dict unset data_dict info free_space_num_blocks $this_index
    if {$upd_replaced_free_space_num_blocks == 0} {
        # Free space was completely consumed!
    } else {
        # Free space was NOT completely consumed!
        set upd_replaced_free_space_index [expr $this_index + $file_num_blocks]
        #puts "upd_replaced_free_space_index {$upd_replaced_free_space_index} upd_replaced_free_space_num_blocks {$upd_replaced_free_space_num_blocks}"
        lappend free_spaces_indices $upd_replaced_free_space_index
        dict set data_dict info free_space_num_blocks $upd_replaced_free_space_index $upd_replaced_free_space_num_blocks
    }
    # Update the dict
    dict set data_dict info free_spaces_indices [lsort -integer -increasing $free_spaces_indices]
    # NOTE: The info free_spaces dictionary setting is now out of date. Since it was only used
    #       in diskmap_inventory, leaving it alone for now!
    return $data_dict
}
proc move_whole_file_list { data_dict {free_space_char "."} } {
    # Inputs: Dict
    #  info diskmap String (same as Line0 String)
    #  info blocks_map String
    #  info file_ids [list]
    #  info file_num_blocks file_id blocks#
    #  info file_start_index file_id# start_index
    #  info free_spaces num_free_spaces# [list index0 index1 ...]
    #
    # Outputs: 
    #   -1  (No movement was done) or Modified_Dict

    set file_ids_rev [lsort -integer -decreasing [dict get $data_dict info file_ids]]
    set status ""
    foreach file_id $file_ids_rev {
        set status [move_whole_file_one_at_a_time_list $data_dict $file_id]
        if {$status != -1} {
            set data_dict $status
        }
    }
    set blocks_map [dict get $data_dict info blocks_map]
    set opt_blocks_map [dict get $data_dict info opt_blocks_map]
    #puts "    blocks_map {$blocks_map}"
    #puts "opt_blocks_map {$opt_blocks_map}"
    set checksum [checksum_calc_list $opt_blocks_map]
    dict set data_dict info opt_blocks_checksum $checksum
    puts "      checksum {$checksum}"
    return $data_dict
}