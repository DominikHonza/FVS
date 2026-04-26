// This is the default UVM test class for timer
class full_access_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( full_access_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "full_access_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Run - start processing sequences
    task run_phase(uvm_phase phase);

        uvm_sequence_base rst_seq;
        uvm_sequence_base basic_seq;
        uvm_sequence_base read_seq;

        phase.raise_objection(this);

        rst_seq = timer_t_sequence_reset::type_id::create("rst_seq");
        rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        basic_seq = timer_t_sequence_setup_regs::type_id::create("basic_seq");
        basic_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        read_seq = timer_t_sequence_read_all::type_id::create("read_seq");
        read_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);

    endtask

endclass: full_access_t_test
