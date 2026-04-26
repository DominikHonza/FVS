// This is the default UVM test class for timer
class muj_prvni_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( muj_prvni_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "muj_prvni_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Legacy smoke flow through reset and all direct mode-setting sequences.
    task run_phase( uvm_phase phase );
        // creation of sequences
        uvm_sequence_base basic_seq = timer_t_sequence_reset::type_id::create( "ttimer_t_sequence_basic" );
        uvm_sequence_base rst_seq = timer_t_sequence_reset::type_id::create( "reset" );
        uvm_sequence_base set_disabled_seq = timer_t_sequence_DISABLED::type_id::create( "timer_t_sequence_DISABLED" );
        uvm_sequence_base set_autorestart_seq = timer_t_sequence_AUTO_RESTART::type_id::create( "timer_t_sequence_AUTO_RESTART");
        uvm_sequence_base set_oneshot_seq = timer_t_sequence_ONE_SHOT::type_id::create( "timer_t_sequence_ONE_SHOT" );
        uvm_sequence_base set_continous_seq = timer_t_sequence_CONTINOUS::type_id::create( "timer_t_sequence_CONTINOUS" );
        uvm_sequence_base set_rand_seq = timer_t_sequence_rand::type_id::create( "timer_t_sequence_rand" );

        // prevent the phase from immediate termination
        phase.raise_objection( this );

        // starting reset sequence
        rst_seq.start( m_env_h.m_timer_t_agent_h.m_sequencer_h );

        basic_seq.start( m_env_h.m_timer_t_agent_h.m_sequencer_h );
        set_disabled_seq.start( m_env_h.m_timer_t_agent_h.m_sequencer_h );
        set_autorestart_seq.start( m_env_h.m_timer_t_agent_h.m_sequencer_h );
        set_oneshot_seq.start( m_env_h.m_timer_t_agent_h.m_sequencer_h );
        set_continous_seq.start( m_env_h.m_timer_t_agent_h.m_sequencer_h );

        phase.drop_objection( this );
    endtask: run_phase

endclass: muj_prvni_test
