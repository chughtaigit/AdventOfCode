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