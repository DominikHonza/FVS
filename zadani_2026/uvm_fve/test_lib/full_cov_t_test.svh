// This is the default UVM test class for timer
class full_cov_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( full_cov_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "full_cov_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Run - start processing sequences
    task run_phase(uvm_phase phase);

        uvm_sequence_base seq;

        phase.raise_objection(this);

        // reset
        seq = timer_t_sequence_reset::type_id::create("rst");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // basic setup
        seq = timer_t_sequence_setup_regs::type_id::create("basic");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // FULL CROSS
        seq = timer_t_sequence_full_cov::type_id::create("full");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // IRQ coverage
        seq = timer_t_sequence_irq_modes::type_id::create("irq");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);

    endtask

endclass: full_cov_t_test
