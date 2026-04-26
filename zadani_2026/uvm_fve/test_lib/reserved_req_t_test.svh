// This is the default UVM test class for timer
class reserved_req_t_test extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( reserved_req_t_test )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "reserved_req_t_test", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Sends a single RESERVED request to check error-response handling.
    task run_phase(uvm_phase phase);

        uvm_sequence_base seq;

        phase.raise_objection(this);

        seq = timer_t_sequence::type_id::create("seq");

        seq.default_RST     = ~RST_ACT_LEVEL;
        seq.default_ADDRESS = TIMER_CNT;
        seq.default_REQUEST = CP_REQ_RESERVED;
        seq.default_DATA_IN = 0;

        seq.start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

        phase.drop_objection(this);

    endtask

endclass: reserved_req_t_test
