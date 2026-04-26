// This is the default UVM test class for timer
class random_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( random_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "random_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Runs the constrained pseudo-random transaction sequence after reset.
    task run_phase(uvm_phase phase);

        uvm_sequence_base rst_seq;
        uvm_sequence_base rand_seq;

        phase.raise_objection(this);

        // reset
        rst_seq = timer_t_sequence_reset::type_id::create("rst_seq");
        rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // random test
        rand_seq = timer_t_sequence_rand::type_id::create("rand_seq");
        rand_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);

    endtask

endclass: random_t_test
