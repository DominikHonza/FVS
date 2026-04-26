// This is the default UVM test class for timer
class test_irq_autorestart extends timer_t_test_base;

    // registration of component tools
    `uvm_component_utils( test_irq_autorestart )

    uvm_sequence_base seq;
    // Constructor - creates new instance of this class
    function new( string name = "test_irq_autorestart", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
    endfunction: build_phase

    // Legacy AUTO_RESTART IRQ scenario built from direct base-sequence transactions.
    task run_phase(uvm_phase phase);

    timer_t_sequence seq; // ✅ deklarace MUSÍ být nahoře

    phase.raise_objection(this);

    timer_t_sequence_reset::type_id::create("rst")
        .start(m_env_h.m_timer_t_agent_h.m_sequencer_h);

    seq = timer_t_sequence::type_id::create("seq"); // ✅ až teď přiřazení

    // nastav cmp = 5
    seq.default_RST = ~RST_ACT_LEVEL;
    seq.default_ADDRESS = TIMER_CMP;
    seq.default_REQUEST = CP_REQ_WRITE;
    seq.default_DATA_IN = 5;
    seq.create_and_finish_item();

    // nastav mode AUTO_RESTART
    seq.default_ADDRESS = TIMER_CR;
    seq.default_DATA_IN = AUTO_RESTART;
    seq.create_and_finish_item();

    // nech běžet
    repeat (20) begin
        seq.default_REQUEST = CP_REQ_NONE;
        seq.create_and_finish_item();
    end

    phase.drop_objection(this);

endtask

endclass: test_irq_autorestart
