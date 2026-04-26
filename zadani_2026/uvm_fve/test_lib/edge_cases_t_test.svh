// This is the default UVM test class for timer
class edge_cases_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( edge_cases_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "edge_cases_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Exercises RESERVED requests, invalid addresses and CNT read/write edge cases.
    task run_phase(uvm_phase phase);

        uvm_sequence_base rst_seq;
        uvm_sequence_base reserved_seq;
        uvm_sequence_base invalid_seq;
        uvm_sequence_base cnt_mix_seq;

        phase.raise_objection(this);

        // reset
        rst_seq = timer_t_sequence_reset::type_id::create("rst_seq");
        rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // RESERVED request
        reserved_seq = timer_t_sequence_reserved::type_id::create("reserved_seq");
        reserved_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // invalid address
        invalid_seq = timer_t_sequence_invalid_addr::type_id::create("invalid_seq");
        invalid_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // CNT read/write mix
        cnt_mix_seq = timer_t_sequence_cnt_rw_mix::type_id::create("cnt_mix_seq");
        cnt_mix_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);

    endtask

endclass: edge_cases_t_test
