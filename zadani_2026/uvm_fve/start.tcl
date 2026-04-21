package require cmdline

# ================================
# BASIC PROJECT DIRECTORIES SETUP
# ================================
set BUILD_DIR "build"
set UCDB_DIR  "ucdb"

if {![file exists $BUILD_DIR]} {
    file mkdir $BUILD_DIR
}

if {![file exists $UCDB_DIR]} {
    file mkdir $UCDB_DIR
}

# Ensure local modelsim.ini is used (avoid old system ModelSim)
if {![file exists "modelsim.ini"]} {
    vmap -c
}

# ================================
# ERROR HANDLING
# ================================
proc run_on_error { ERROR_MESSAGE } {
    echo "\nERROR: ${ERROR_MESSAGE}\n"
    if {[batch_mode]} {
        quit -f
    } else {
        pause
    }
}

# ================================
# COVERAGE HANDLING
# ================================
proc save_coverage { COVERAGE_FILE } {
    global CODE_COVERAGE_ENABLED
    global FUNC_COVERAGE_ENABLED

    if {$CODE_COVERAGE_ENABLED || $FUNC_COVERAGE_ENABLED} {
        set CODE_PARAMS ""
        set FUNC_PARAMS ""

        if {$CODE_COVERAGE_ENABLED} {
            append CODE_PARAMS "-codeAll -assert "
        }

        if {$FUNC_COVERAGE_ENABLED} {
            append FUNC_PARAMS "-cvg "
        }

        eval coverage save $CODE_PARAMS $FUNC_PARAMS $COVERAGE_FILE
    }
}

# ================================
# TRANSCRIPT CONTROL
# ================================
proc clear_transcript_file {} {
    transcript file ""
    transcript file transcript
    transcript sizelimit 1048576
}

# ================================
# ARGUMENT PARSING
# ================================
proc parse_arguments { ARGV } {
    global UVM_TESTNAME
    global UVM_TESTS_FILE
    global RUN_MULTIPLE_TESTS

    set USAGE "do start.tcl -uvm_testname name -uvm_tests_file file -run_multiple_tests"

    set PARAMETERS {
        { "uvm_testname.arg" "" "Specify UVM test name" }
        { "uvm_tests_file.arg" "" "File with list of tests" }
        { "run_multiple_tests" "Run all tests in file" }
    }

    array set ARGUMENTS [::cmdline::getoptions ARGV $PARAMETERS $USAGE]

    if {[string length $ARGUMENTS(uvm_testname)] > 0} {
        set UVM_TESTNAME $ARGUMENTS(uvm_testname)
    }

    if {[string length $ARGUMENTS(uvm_tests_file)] > 0} {
        set UVM_TESTS_FILE $ARGUMENTS(uvm_tests_file)
    }

    if {$ARGUMENTS(run_multiple_tests)} {
        set RUN_MULTIPLE_TESTS 1
    }
}

# ================================
# SIMULATION RUN
# ================================
proc run_program { VSIM_RUN_CMD UVM_TESTNAME COVERAGE_FILE } {
    global ERROR_MESSAGE
    global UCDB_DIR

    quietly set ERROR_MESSAGE "Error while running test ${UVM_TESTNAME}"

    append VSIM_RUN_CMD " +UVM_TESTNAME=${UVM_TESTNAME}"

    eval ${VSIM_RUN_CMD}

    onbreak resume
    onfinish stop

    #if {![batch_mode]} {
    #    source "./wave_setup.do"
    #}

    if { ![batch_mode] } {
        source "./wawe.tcl"
        global DUT_MODULE
        global HDL_DUT
        customize_gui /$DUT_MODULE /$HDL_DUT
    }

    run -all

    save_coverage ./${UCDB_DIR}/${COVERAGE_FILE}
}

# ================================
# GLOBAL VARIABLES
# ================================
quietly set WORKING_LIBRARY "work"
quietly set HDL_DIRECTORY [file join .. rtl]
quietly set TOP_MODULE "top"
quietly set DUT_MODULE "$TOP_MODULE/dut"
quietly set HDL_DUT "$DUT_MODULE/HDL_DUT_U"

quietly set UVM_TESTNAME "timer_t_test"
quietly set UVM_TESTS_FILE "./test_lib/test_list"
quietly set RUN_MULTIPLE_TESTS 0

quietly set FUNC_COVERAGE_ENABLED 1
quietly set CODE_COVERAGE_ENABLED 1

#quietly set VSIM_RUN_CMD "vsim -voptargs=\"-debug\" -coverage -t 1ps -lib ${WORKING_LIBRARY} ${TOP_MODULE}"
#quietly set VSIM_RUN_CMD "vsim -voptargs=\"-lint=full +acc\" -coverage -t 1ps -lib ${WORKING_LIBRARY} ${TOP_MODULE}"
quietly set VSIM_RUN_CMD "vsim -voptargs=\"-access=rw+/. +acc=a\" -suppress 12130 -assertdebug -coverage -t 1ps -lib ${WORKING_LIBRARY} ${TOP_MODULE}"
#-voptargs="-access=rw+/. +acc" -suppress 12130 

quietly set VSIM_COV_MERGE_FILE "./${UCDB_DIR}/final.ucdb"
quietly set VSIM_COVERAGE_MERGE "vcover merge -64 ${VSIM_COV_MERGE_FILE} ./${UCDB_DIR}/*.ucdb"

# ================================
# ERROR HOOKS
# ================================
onElabError { run_on_error $errorInfo }
onerror { run_on_error $ERROR_MESSAGE }

quit -sim

# ================================
# ARGUMENT COLLECTION
# ================================
set DO_ARGS ""
while {$argc != 0} {
    set DO_ARGS [concat $DO_ARGS ${1}]
    shift
}

parse_arguments $DO_ARGS
clear_transcript_file

# ================================
# COMPILATION
# ================================
source "./compile.tcl"
compile_sources $WORKING_LIBRARY $HDL_DIRECTORY

# ================================
# RUN MODE
# ================================
if {$RUN_MULTIPLE_TESTS} {

    if {![file isfile $UVM_TESTS_FILE]} {
        run_on_error "Test list file not found: $UVM_TESTS_FILE"
    }

    set TESTS_RUN 0
    set fp [open $UVM_TESTS_FILE r]

    while {[gets $fp uvm_test] >= 0} {
        if {[string trim $uvm_test] != ""} {
            set TESTS_RUN 1
            run_program [subst $VSIM_RUN_CMD] $uvm_test "$uvm_test.ucdb"
            quit -sim
        }
    }

    close $fp

    if {$TESTS_RUN} {
        if {[file exists $VSIM_COV_MERGE_FILE]} {
            file delete $VSIM_COV_MERGE_FILE
        }
        eval $VSIM_COVERAGE_MERGE
    }

} else {

    if {[string length $UVM_TESTNAME] == 0} {
        run_on_error "UVM test name must be specified"
    }

    run_program [subst $VSIM_RUN_CMD] $UVM_TESTNAME "$UVM_TESTNAME.ucdb"
}

if {[batch_mode]} {
    quit -f
} else {
    pause
}
