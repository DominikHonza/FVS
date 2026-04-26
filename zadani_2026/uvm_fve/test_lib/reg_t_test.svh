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

    // Runs a register-model frontdoor access with idle alignment around the RAL transaction.
    task run_phase(uvm_phase phase);

    timer_t_sequence_reset rst_seq;
    timer_reg_seq reg_seq;
    uvm_sequence_base idle_before_reg_seq;
    uvm_sequence_base idle_after_reg_seq;

    rst_seq = timer_t_sequence_reset::type_id::create("reset");
    reg_seq = timer_reg_seq::type_id::create("reg_seq");
    idle_before_reg_seq = timer_t_sequence_run::type_id::create("idle_before_reg_seq");
    idle_after_reg_seq = timer_t_sequence_run::type_id::create("idle_after_reg_seq");

    phase.raise_objection(this);

    // reset sequence
    rst_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // release reset and let the scoreboard align before the RAL access
    idle_before_reg_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // assign RAL model
    reg_seq.m_timer_reg_block = m_env_h.m_timer_reg_block;

    // start register sequence on same bus sequencer
    reg_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    // keep the bus idle after the register transaction
    idle_after_reg_seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    phase.drop_objection(this);

endtask

endclass: reg_t_test
