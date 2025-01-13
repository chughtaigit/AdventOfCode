source utility_procs.tcl
puts "main.tcl"
set input_file "input.txt"
#set input_file "example_list.txt"
#set input_file "demo2.txt"
set data_dict [parse_file $input_file]
puts "data_dict: {$data_dict}"
set safe_cnt [process_data_b $data_dict]
# Final Resolution
# ================
# Real issue was line 100 in utility_procs.tcl where I added a $ in front of the global variable by mistake: 
# set $IN_DONT_TRACKER $in_dont
# One this issue got resolved, there was no need to combine all the lines without line breaks!

# Initial Resolution
# ================
# ISsue was line breaks! If process individual lines then get the 107991598 answer, but if
# combine all the lines without line breaks then get the actual answer of 93729253
# set safe_cnt [process_data_c $data_dict]
# Right answer: 93729253
# Previous attempts
# 107991598
# Answer too high
# <0>: 24129420
# <1>: 25835880
# <2>: 21798505
# <3>: 15301835
# <4>: 16072518
# <5>: 4853440

# CH
# <0> Part2 answer: 24129420
# <1> Part2 answer: 25835880
# <2> Part2 answer: 21798505
# <3> Part2 answer: 15301835
# <4> Part2 answer: 16072518
# <5> Part2 answer: 4853440
# puts "Total: [expr 24129420 +25835880 +21798505 +15301835 +16072518 +4853440]"