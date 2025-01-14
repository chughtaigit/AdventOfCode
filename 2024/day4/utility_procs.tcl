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
proc get_matches { data_dict } {
    # Matches: 
    #  XMAS
    #  SAMX
    #
    #  X    S
    #  M    A
    #  A    M
    #  S    X
    #
    #  X      S          X     S
    #   M      A        M     A
    #    A      M      A     M
    #     S      X    S     X   
    #

    set all_matches_found 0
    # Start walking from y=0, x=0 caharacter and look for all possible matches
    # until get to y=max_lines-1 & x=max_strlen
    set max_lines [dict get $data_dict info max_lines]
    set max_strlen [dict get $data_dict info max_strlen]
    set FMAT(XMAS) 0
    set FMAT(SAMX) 0
    set FMAT(VXMAS) 0
    set FMAT(VSAMX) 0
    set FMAT(DAXMAS) 0
    set FMAT(DBSAMX) 0
    set FMAT(DCXMAS) 0
    set FMAT(DDSAMX) 0
    for {set yi 0} {$yi < $max_lines} {incr yi} {
        for {set xj 0} {$xj < $max_strlen} {incr xj} {
            #puts -nonewline [str2dlookup_yx $data_dict $yi $xj]
            ########
            # XMAS
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list $yi [expr $xj+0] X] [list $yi [expr $xj+1] M] [list $yi [expr $xj+2] A] [list $yi [expr $xj+3] S]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(XMAS)
            }
            ########
            # SAMX
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list $yi [expr $xj+0] S] [list $yi [expr $xj+1] A] [list $yi [expr $xj+2] M] [list $yi [expr $xj+3] X]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(SAMX)
            }
            ########
            #  X    S
            #  M    A
            #  A    M
            #  S    X
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] $xj X] [list [expr $yi+1] $xj M] [list [expr $yi+2] $xj A] [list [expr $yi+3] $xj S]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(VXMAS)
            }
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] $xj S] [list [expr $yi+1] $xj A] [list [expr $yi+2] $xj M] [list [expr $yi+3] $xj X]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(VSAMX)
            }
            ########
            #  X      S          X     S
            #   M      A        M     A
            #    A      M      A     M
            #     S      X    S     X   
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+0] X] [list [expr $yi+1] [expr $xj+1] M] [list [expr $yi+2] [expr $xj+2] A] [list [expr $yi+3] [expr $xj+3] S]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(DAXMAS)
            }
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+0] S] [list [expr $yi+1] [expr $xj+1] A] [list [expr $yi+2] [expr $xj+2] M] [list [expr $yi+3] [expr $xj+3] X]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(DBSAMX)
            }
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+3] X] [list [expr $yi+1] [expr $xj+2] M] [list [expr $yi+2] [expr $xj+1] A] [list [expr $yi+3] [expr $xj+0] S]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(DCXMAS)
            }
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+3] S] [list [expr $yi+1] [expr $xj+2] A] [list [expr $yi+2] [expr $xj+1] M] [list [expr $yi+3] [expr $xj+0] X]]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(DDSAMX)
            }
        }
        #puts -nonewline "\n"
    }
    foreach kk [lsort [array names FMAT]] {
        puts "FMAT($kk) {$FMAT($kk)}"
    }
    puts "all_matches_found {$all_matches_found}"
    return $all_matches_found
}
proc get_matches_b { data_dict } {
    # Matches: 
    # M M
    #  A
    # S S
    #
    # S S
    #  A
    # M M
    #
    # M S
    #  A
    # M S
    #
    # S M
    #  A
    # S M
    #

    set all_matches_found 0
    # Start walking from y=0, x=0 caharacter and look for all possible matches
    # until get to y=max_lines-1 & x=max_strlen
    set max_lines [dict get $data_dict info max_lines]
    set max_strlen [dict get $data_dict info max_strlen]
    set FMAT(MMASS) 0
    set FMAT(SSAMM) 0
    set FMAT(MSAMS) 0
    set FMAT(SMASM) 0
    for {set yi 0} {$yi < $max_lines} {incr yi} {
        for {set xj 0} {$xj < $max_strlen} {incr xj} {
            #puts -nonewline [str2dlookup_yx $data_dict $yi $xj]
            ########
            # M M
            #  A
            # S S
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+0] M]                                    [list [expr $yi+0] [expr $xj+2] M] \
                                                   [list [expr $yi+1] [expr $xj+1] A] \
                [list [expr $yi+2] [expr $xj+0] S]                                    [list [expr $yi+2] [expr $xj+2] S] \
                ]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(MMASS)
            }
            ########
            # S S
            #  A
            # M M
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+0] S]                                    [list [expr $yi+0] [expr $xj+2] S] \
                                                   [list [expr $yi+1] [expr $xj+1] A] \
                [list [expr $yi+2] [expr $xj+0] M]                                    [list [expr $yi+2] [expr $xj+2] M] \
                ]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(SSAMM)
            }
            ########
            # M S
            #  A
            # M S
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+0] M]                                    [list [expr $yi+0] [expr $xj+2] S] \
                                                   [list [expr $yi+1] [expr $xj+1] A] \
                [list [expr $yi+2] [expr $xj+0] M]                                    [list [expr $yi+2] [expr $xj+2] S] \
                ]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(MSAMS)
            }
            ########
            # S M
            #  A
            # S M
            set found_match [str2dlookup_multi_yx $data_dict [list \
                [list [expr $yi+0] [expr $xj+0] S]                                    [list [expr $yi+0] [expr $xj+2] M] \
                                                   [list [expr $yi+1] [expr $xj+1] A] \
                [list [expr $yi+2] [expr $xj+0] S]                                    [list [expr $yi+2] [expr $xj+2] M] \
                ]]
            if {[lindex $found_match 0] == 0 && [lindex $found_match 1] == 0} {
                incr all_matches_found
                incr FMAT(SMASM)
            }
        }
        #puts -nonewline "\n"
    }
    foreach kk [lsort [array names FMAT]] {
        puts "FMAT($kk) {$FMAT($kk)}"
    }
    puts "all_matches_found {$all_matches_found}"
    return $all_matches_found
}
proc get_mul_matches { in_str {use_pattern_b 0} } {
    set pattern {mul\(([0-9]+),([0-9]+)\)}
    if {$use_pattern_b != 0} {
        set pattern {((do\(\))+|(don\'t\(\))+)|mul\(([0-9]+),([0-9]+)\)}
    }
    set matchTuples [regexp -all -inline $pattern $in_str]
    #puts "matchTuples {$matchTuples}\n     in_str {$in_str}"
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
proc get_mul_matches_b { in_str {use_pattern_b 1} } {
    set pattern {mul\(([0-9]+),([0-9]+)\)}
    if {$use_pattern_b != 0} {
        set pattern {((do\(\))+|(don\'t\(\))+)|mul\(([0-9]+),([0-9]+)\)}
    }
    set matchTuples [regexp -all -inline $pattern $in_str]
    puts "matchTuples {$matchTuples}\n     in_str {$in_str}"
    return $matchTuples
}
proc filter_mul_matches_b { in_matches } {
    global IN_DONT_TRACKER
    # in_matches is a list like this: 
    #   mul(X0,Y0) X0 Y0   mul(X1,Y1) X1 Y1 ...
    set filtered_matches [list]
    set in_dont $IN_DONT_TRACKER
    foreach {whole junk_a junk_b junk_c num_a num_b} $in_matches {
        puts "START: whole {$whole} in_dont {$in_dont}"
        if {[string match "don't*" $whole]} {
            set in_dont 1
        } elseif {[string match "do()*" $whole]} {
            set in_dont 0
            continue
        }
        puts "  END: whole {$whole} in_dont {$in_dont}"
        if {$in_dont != 0} {
            continue
        }
        if {$num_a > 999 || $num_b > 999} { 
            #puts "Filtered: {$whole} >999 $num_a or $num_b" 
            continue 
        }
        puts "  ADDED: whole {$whole} in_dont {$in_dont} num_a {$num_a} num_b {$num_b}"
        lappend filtered_matches $whole
        lappend filtered_matches $junk_a
        lappend filtered_matches $junk_b
        lappend filtered_matches $junk_c
        lappend filtered_matches $num_a
        lappend filtered_matches $num_b
    }
    set IN_DONT_TRACKER $in_dont
    puts "filtered_matches -> {$filtered_matches}"
    return $filtered_matches
}
proc process_mul_matches_b { in_matches } {
    # in_matches is a list like this: 
    #   mul(X0,Y0) X0 Y0   mul(X1,Y1) X1 Y1 ...
    set mul_results 0
    foreach {whole junk_a junk_b junk_c num_a num_b} $in_matches {
        incr mul_results [expr $num_a * $num_b]
        puts "do it: $num_a * $num_b (answer = $mul_results)"
    }
    return $mul_results
}
proc process_data_b { data_dict {use_problem_dampner 0} } {
    global IN_DONT_TRACKER
    set mul_results 0
    set IN_DONT_TRACKER 0
    dict for {ln_cnt in_str} $data_dict {
        set mul_matches [get_mul_matches_b $in_str 1]
        set filtered_mul_matches [filter_mul_matches_b $mul_matches]
        if {[llength $mul_matches] != [llength $filtered_mul_matches]} {
            puts "  Line $ln_cnt: One or more entries filtered ..."
        }
        set mul_result [process_mul_matches_b $filtered_mul_matches]
        #puts "<$ln_cnt>: $mul_result {$in_str}"
        puts "<$ln_cnt>: $mul_result"
        incr mul_results $mul_result
    }
    puts "mul_results: $mul_results"
    return $mul_results
}
proc process_data_c { data_dict {use_problem_dampner 0} } {
    global IN_DONT_TRACKER
    set mul_results 0
    set IN_DONT_TRACKER 0
    # Add all lines to one string without line breaks
    set one_str ""
    dict for {ln_cnt in_str} $data_dict {
        append one_str $in_str
    }
    dict for {ln_cnt in_str} [list 0 $one_str] {
        set mul_matches [get_mul_matches_b $in_str 1]
        set filtered_mul_matches [filter_mul_matches_b $mul_matches]
        if {[llength $mul_matches] != [llength $filtered_mul_matches]} {
            puts "  Line $ln_cnt: One or more entries filtered ..."
        }
        set mul_result [process_mul_matches_b $filtered_mul_matches]
        #puts "<$ln_cnt>: $mul_result {$in_str}"
        puts "<$ln_cnt>: $mul_result"
        incr mul_results $mul_result
    }
    puts "mul_results: $mul_results"
    return $mul_results
}