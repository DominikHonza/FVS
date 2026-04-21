# compile SystemVerilog source file(s)
proc compile_sv { LIBRARY SRC_FILES } {
    foreach SRC_FILE $SRC_FILES {
        regsub "/\[^/\]+\$" $SRC_FILE "/" INC_DIR
        set COMPILE_CMD "vlog -sv -source -work $LIBRARY +incdir+$INC_DIR $SRC_FILE"
        eval $COMPILE_CMD
    }
}

# create working library and compile source files
proc compile_sources { LIBRARY HDL_DIRECTORY } {
    # backup previous error message and set new one
    global ERROR_MESSAGE
    quietly set prev_error_msg ERROR_MESSAGE
    quietly set ERROR_MESSAGE "Compilation error has been encountered."

    # recreate working library so Questa cannot reuse stale incremental units
    if {[file exists $LIBRARY]} {
        vdel -lib $LIBRARY -all
    }

    vlib $LIBRARY

    # DUT compilation
    eval "vcom -explicit -93 -source +cover=sbcef -nowarn 13 -work $LIBRARY $HDL_DIRECTORY/timer_fvs.vhd"
    
    # verification environment compilation
    compile_sv $LIBRARY test_parameters.sv
    compile_sv $LIBRARY [file join agents . sv_agent_pkg.sv]
    compile_sv $LIBRARY [file join golden_model sv_golden_model_pkg.sv]
    compile_sv $LIBRARY [file join regmodel registers_pkg.sv]
    compile_sv $LIBRARY [file join env_lib . sv_env_pkg.sv]
    compile_sv $LIBRARY [file join test_lib . sv_test_pkg.sv]
    compile_sv $LIBRARY [file join agents . ifc.sv]
    compile_sv $LIBRARY [file join abv . abv_timer.sv]
    compile_sv $LIBRARY top_level.sv
    
    # restore previous error message
    quietly set ERROR_MESSAGE prev_error_msg
}
