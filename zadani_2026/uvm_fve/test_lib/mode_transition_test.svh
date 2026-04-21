// This is the default UVM test class for timer
class mode_transition_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( mode_transition_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "mode_transition_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Run - start processing sequences
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        timer_t_sequence_reset::type_id::create("rst")
            .start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        // DISABLED → AUTO
        timer_t_sequence_AUTO_RESTART::type_id::create("auto").start(...);

        // AUTO → ONE_SHOT
        timer_t_sequence_ONE_SHOT::type_id::create("one").start(...);

        // ONE → CONT
        timer_t_sequence_CONTINOUS::type_id::create("cont").start(...);

        // CONT → DISABLED
        timer_t_sequence_DISABLED::type_id::create("dis").start(...);

        phase.drop_objection(this);

    endtask

endclass: mode_transition_test
