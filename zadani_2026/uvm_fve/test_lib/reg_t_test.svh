// This is the default UVM test class for timer
class reg_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( reg_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "reg_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Run - start processing sequences
    task run_phase(uvm_phase phase);

    timer_t_sequence_reset rst_seq;
    timer_reg_seq reg_seq;
    uvm_sequence_base basic_seq;

    rst_seq = timer_t_sequence_reset::type_id::create("reset");
    reg_seq = timer_reg_seq::type_id::create("reg_seq");
    basic_seq = timer_t_sequence_basic::type_id::create( "basic" );

    phase.raise_objection(this);

    // reset sequence
    rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // assign RAL model
    reg_seq.m_timer_reg_block = m_env_h.m_timer_reg_block;

    // start register sequence on same bus sequencer
    reg_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);
    rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    basic_seq.start( m_env_h.m_timer_t_agent_h.m_sequencer_h );

    phase.drop_objection(this);

endtask

endclass: reg_t_test
