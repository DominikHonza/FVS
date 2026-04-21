// Backward-compatible alias for the misspelled test name.
// The real implementation is in continuous_t_test.svh.
class continous_t_test extends continuous_t_test;

    `uvm_component_utils( continous_t_test )

    function new( string name = "continous_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

endclass: continous_t_test
