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

    // Run - start processing sequences
    task run_phase(uvm_phase phase);

    uvm_sequence_base rst_seq;
    uvm_sequence_base setup_seq;
    uvm_sequence_base mode_seq;
    uvm_sequence_base run_seq;

    phase.raise_objection(this);

    // 1. reset
    rst_seq = timer_t_sequence_reset::type_id::create("rst_seq");
    rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // 2. CNT + CMP
    setup_seq = timer_t_sequence_basic::type_id::create("setup_seq");
    setup_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // 3. continous
    mode_seq = timer_t_sequence_CONTINOUS::type_id::create("continous_seq");
    mode_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // ----------------------------------------
    // STRESS části co chybí
    // ----------------------------------------

    repeat (10) begin

        // OOR
        seq = timer_t_sequence_oor::type_id::create("oor");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // UNALIGNED
        seq = timer_t_sequence_unaligned::type_id::create("unaligned");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // RESERVED
        seq = timer_t_sequence_reserved::type_id::create("reserved");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // WRITE → READ
        seq = timer_t_sequence_write_read::type_id::create("wr");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    end

    // ----------------------------------------
    // IRQ + MODE BEHAVIOR
    // ----------------------------------------

    repeat (5) begin
        seq = timer_t_sequence_irq_modes::type_id::create("irq_modes");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);
    end

    // ----------------------------------------
    // FULL CROSS (nejdůležitější!)
    // ----------------------------------------

    seq = timer_t_sequence_full_cov::type_id::create("full");
    seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    phase.drop_objection(this);

endtask

endclass: formal_t_test
