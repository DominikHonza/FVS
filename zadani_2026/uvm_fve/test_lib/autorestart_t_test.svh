// This is the default UVM test class for timer
class autorestart_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( autorestart_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "autorestart_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Runs the basic AUTO_RESTART scenario and lets the timer generate interrupts.
    task run_phase(uvm_phase phase);

        uvm_sequence_base rst_seq;
        uvm_sequence_base setup_seq;
        uvm_sequence_base run_seq;

        phase.raise_objection(this);

        // 1. reset
        rst_seq = timer_t_sequence_reset::type_id::create("rst_seq");
        rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // 2. setup (CNT, CMP, MODE)
        setup_seq = timer_t_sequence_basic::type_id::create("setup_seq");
        setup_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // 3. běh timeru (musíš přidat vlastní sekvenci!)
        run_seq = timer_t_sequence_run::type_id::create("run_seq");
        run_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);

    endtask

endclass: autorestart_t_test
