// This is the default UVM test class for timer
class reset_stress_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( reset_stress_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "reset_stress_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Runs reset stress by toggling reset during timer interface activity.
    task run_phase(uvm_phase phase);

        uvm_sequence_base seq;

        phase.raise_objection(this);

        seq = timer_t_sequence_reset_stress::type_id::create("seq");
        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);

    endtask

endclass: reset_stress_t_test
