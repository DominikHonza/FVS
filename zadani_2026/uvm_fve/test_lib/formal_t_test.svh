// This is the default UVM test class for timer
class formal_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( formal_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "formal_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Runs assertion-oriented response stress and coverage-clean mode/access scenarios.
    task run_phase(uvm_phase phase);

    uvm_sequence_base rst_seq;
    uvm_sequence_base setup_seq;
    uvm_sequence_base mode_seq;

    phase.raise_objection(this);

    // 1. reset
    rst_seq = timer_t_sequence_reset::type_id::create("rst_seq");
    rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // Keep the timer in a predictable state before interface stress checks.
    setup_seq = timer_t_sequence_basic::type_id::create("setup_seq");
    setup_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    mode_seq = timer_t_sequence_DISABLED::type_id::create("disabled_seq");
    mode_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // Interface stress for response-related assertions.
    seq = timer_t_sequence_oor::type_id::create("oor");
    seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    seq = timer_t_sequence_unaligned::type_id::create("unaligned");
    seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    seq = timer_t_sequence_reserved::type_id::create("reserved");
    seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    seq = timer_t_sequence_write_read::type_id::create("wr");
    seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // Coverage-oriented accesses and mode transitions use sequences that are
    // already scoreboard-clean in the regression.
    seq = timer_t_sequence_full_cov::type_id::create("full");
    seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    seq = timer_t_sequence_cover_remaining_functional::type_id::create("remaining_func");
    seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    phase.drop_objection(this);

endtask

endclass: formal_t_test
