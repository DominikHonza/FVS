class ADDR_BUS_BRANCH_COVER_TEST extends timer_t_test_base;

    `uvm_component_utils(ADDR_BUS_BRANCH_COVER_TEST)

    function new(string name = "ADDR_BUS_BRANCH_COVER_TEST", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        uvm_sequence_base rst_seq;
        uvm_sequence_base branch_seq;
        uvm_sequence_base functional_seq;

        phase.raise_objection(this);

        rst_seq = timer_t_sequence_reset::type_id::create("rst_seq");
        rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        branch_seq = timer_t_sequence_addr_bus_branch_cover::type_id::create("branch_seq");
        branch_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        functional_seq = timer_t_sequence_cover_remaining_functional::type_id::create("functional_seq");
        functional_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);
    endtask

endclass: ADDR_BUS_BRANCH_COVER_TEST
