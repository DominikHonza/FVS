// This class represents UVM sequence base for DUT/DUV.
class timer_t_sequence extends uvm_sequence #(timer_t_transaction);

    // registration of object tools
    `uvm_object_utils( timer_t_sequence )

    // local shotimerut to transaction type
    typedef REQ seq_item_t;
    // member attributes, equivalent with interface ports
    rand logic                  default_RST;
    rand logic [ADDR_WIDTH-1:0] default_ADDRESS;
    rand logic [1:0]            default_REQUEST;
    rand logic [DATA_WIDTH-1:0] default_DATA_IN;

    // Constructor - creates new instance of this class
    function new( string name = "timer_t_sequence" );
        super.new( name );
    endfunction: new

    // create_and_finish_item - create single item, set default values and finish it
    protected task automatic create_and_finish_item();
        seq_item_t item;
        // create item using the factory
        item = seq_item_t::type_id::create( "item" );
        // blocks until the sequencer grants the sequence access to the driver
        start_item( item );
        // prepare item to be used (assign default data)
        item.RST     = default_RST;
        item.ADDRESS = default_ADDRESS;
        item.REQUEST = default_REQUEST;
        item.DATA_IN = default_DATA_IN;
        // block until the driver has completed its side of the transfer protocol
        finish_item( item );
    endtask: create_and_finish_item

endclass: timer_t_sequence

// This class represents UVM sequence reseting the DUT/DUV.
class timer_t_sequence_reset extends timer_t_sequence;

    // registration of object tools
    `uvm_object_utils( timer_t_sequence_reset )

    // Constructor - creates new instance of this class
    function new( string name = "timer_t_sequence_reset" );
        super.new( name );
    endfunction: new

    // body 
    task body();
        // set reset values, randomize() cannot be used here
        default_RST     = RST_ACT_LEVEL;
        default_ADDRESS = 0;
        default_REQUEST = 0;
        default_DATA_IN = 0;
        create_and_finish_item();
        create_and_finish_item();
    endtask: body
endclass: timer_t_sequence_reset

class timer_t_sequence_DISABLED extends timer_t_sequence;

    // registration of object tools
    `uvm_object_utils( timer_t_sequence_DISABLED )

    // Constructor - creates new instance of this class
    function new( string name = "timer_t_sequence_DISABLED" );
        super.new( name );
    endfunction: new

    // body 
    task body();
        // set reset values, randomize() cannot be used here
        default_RST     = ~RST_ACT_LEVEL;
        default_ADDRESS = TIMER_CR;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = DISABLED;
        create_and_finish_item();
    endtask: body
endclass: timer_t_sequence_DISABLED

class timer_t_sequence_AUTO_RESTART extends timer_t_sequence;

    // registration of object tools
    `uvm_object_utils( timer_t_sequence_AUTO_RESTART )

    // Constructor - creates new instance of this class
    function new( string name = "timer_t_sequence_AUTO_RESTART" );
        super.new( name );
    endfunction: new

    // body 
    task body();
        // set reset values, randomize() cannot be used here
        default_RST     = ~RST_ACT_LEVEL;
        default_ADDRESS = TIMER_CR;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = AUTO_RESTART;
        create_and_finish_item();
    endtask: body
endclass: timer_t_sequence_AUTO_RESTART

class timer_t_sequence_ONE_SHOT extends timer_t_sequence;

    // registration of object tools
    `uvm_object_utils( timer_t_sequence_ONE_SHOT )

    // Constructor - creates new instance of this class
    function new( string name = "timer_t_sequence_ONE_SHOT" );
        super.new( name );
    endfunction: new

    // body 
    task body();
        // set reset values, randomize() cannot be used here
        default_RST     = ~RST_ACT_LEVEL;
        default_ADDRESS = TIMER_CR;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = ONE_SHOT;
        create_and_finish_item();
    endtask: body
endclass: timer_t_sequence_ONE_SHOT

class timer_t_sequence_CONTINOUS extends timer_t_sequence;

    // registration of object tools
    `uvm_object_utils( timer_t_sequence_CONTINOUS )

    // Constructor - creates new instance of this class
    function new( string name = "timer_t_sequence_CONTINOUS" );
        super.new( name );
    endfunction: new

    // body 
    task body();
        // set reset values, randomize() cannot be used here
        default_RST     = ~RST_ACT_LEVEL;
        default_ADDRESS = TIMER_CR;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = CONTINOUS;
        create_and_finish_item();
    endtask: body
endclass: timer_t_sequence_CONTINOUS

class timer_t_sequence_run extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_run)

    function new(string name = "timer_t_sequence_run");
        super.new(name);
    endfunction

    task body();

        default_RST = ~RST_ACT_LEVEL;

        // žádná operace → timer běží
        default_ADDRESS = 0;
        default_REQUEST = CP_REQ_NONE;
        default_DATA_IN = 0;

        // necháme běžet třeba 20 cyklů
        repeat (20) begin
            create_and_finish_item();
        end

    endtask

endclass

// This class represents basic UVM sequence 
class timer_t_sequence_basic extends timer_t_sequence;

    // registration of object tools
    `uvm_object_utils( timer_t_sequence_basic )

    // Constructor - creates new instance of this class
    function new( string name = "timer_t_sequence_basic" );
        super.new( name );
    endfunction: new

    // body - implements behavior of the reset sequence (unidirectional)
    task body();
        default_RST = ~RST_ACT_LEVEL;

        //setting counter to 0
        default_ADDRESS = TIMER_CNT;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = 32'b0;
        create_and_finish_item();

        //setting compare to 4
        default_ADDRESS = TIMER_CMP;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = 32'b100;
        create_and_finish_item();

        //setting control to AUTO_RESTART
        default_ADDRESS = TIMER_CR;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = 32'b01;
        create_and_finish_item();

        // just counting
        default_ADDRESS = 32'b0;
        default_REQUEST = 3'b0;
        default_DATA_IN = 32'b00;
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();
        create_and_finish_item();

    endtask: body

endclass: timer_t_sequence_basic

class timer_t_sequence_setup_regs extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_setup_regs)

    function new(string name = "timer_t_sequence_setup_regs");
        super.new(name);
    endfunction

    task body();
        default_RST = ~RST_ACT_LEVEL;

        default_ADDRESS = TIMER_CNT;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = 32'd0;
        create_and_finish_item();

        default_ADDRESS = TIMER_CMP;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = 32'd4;
        create_and_finish_item();
    endtask

endclass

class timer_t_sequence_read_all extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_read_all)

    function new(string name = "timer_t_sequence_read_all");
        super.new(name);
    endfunction

    task body();
        default_RST = ~RST_ACT_LEVEL;
        default_REQUEST = CP_REQ_READ;

        default_ADDRESS = TIMER_CNT;
        create_and_finish_item();

        default_ADDRESS = TIMER_CMP;
        create_and_finish_item();

        default_ADDRESS = TIMER_CR;
        create_and_finish_item();

        default_ADDRESS = TIMER_CYCLE_L;
        create_and_finish_item();

        default_ADDRESS = TIMER_CYCLE_H;
        create_and_finish_item();
    endtask

endclass

class timer_t_sequence_mode_switch extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_mode_switch)

    function new(string name = "timer_t_sequence_mode_switch");
        super.new(name);
    endfunction

    task body();

        default_RST     = ~RST_ACT_LEVEL;
        default_ADDRESS = TIMER_CR;
        default_REQUEST = CP_REQ_WRITE;

        // DISABLED → AUTO
        default_DATA_IN = AUTO_RESTART;
        create_and_finish_item();

        // AUTO → ONE_SHOT
        default_DATA_IN = ONE_SHOT;
        create_and_finish_item();

        // ONE → CONT
        default_DATA_IN = CONTINOUS;
        create_and_finish_item();

        // CONT → DISABLED
        default_DATA_IN = DISABLED;
        create_and_finish_item();

    endtask

endclass

class timer_t_sequence_reset_stress extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_reset_stress)

    function new(string name = "timer_t_sequence_reset_stress");
        super.new(name);
    endfunction

    task body();

        repeat (10) begin
            default_RST = RST_ACT_LEVEL;
            default_ADDRESS = TIMER_CNT;
            default_REQUEST = CP_REQ_NONE;
            default_DATA_IN = 0;
            create_and_finish_item();

            default_RST = ~RST_ACT_LEVEL;
            default_ADDRESS = TIMER_CNT;
            default_REQUEST = CP_REQ_NONE;
            default_DATA_IN = 0;
            create_and_finish_item();
        end

    endtask

endclass

class timer_t_sequence_rand extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_rand)

    // --------------------------------
    // RESET distribution
    // --------------------------------
    constraint c_rst {
        default_RST dist {
            ~RST_ACT_LEVEL := 20,
             RST_ACT_LEVEL := 1
        };
    }

    // --------------------------------
    // ADDRESS distribution
    // --------------------------------
    constraint c_addr {
        default_ADDRESS dist {
            TIMER_CNT      := 7,
            TIMER_CMP      := 6,
            TIMER_CR       := 5,
            TIMER_CYCLE_L  := 2,
            TIMER_CYCLE_H  := 2,
            [0 : 2**ADDR_WIDTH-1] := 1
        };
    }

    // --------------------------------
    // REQUEST distribution
    // --------------------------------
    constraint c_req {
        default_REQUEST dist {
            CP_REQ_NONE     := 10,
            CP_REQ_READ     := 5,
            CP_REQ_WRITE    := 5,
            CP_REQ_RESERVED := 1
        };
    }

    // --------------------------------
    // DATA_IN distribution
    // --------------------------------
    constraint c_data {
        default_DATA_IN dist {
            0                         := 10,
            [1:20]                    := 20,
            [21:(2**DATA_WIDTH-1)]    := 1
        };
    }

    // Constructor
    function new(string name = "timer_t_sequence_rand");
        super.new(name);
    endfunction

    // body
    task body();
        this.srandom($urandom());

        repeat (TRANSACTION_COUNT) begin
            if (!this.randomize()) begin
                `uvm_error("RAND_SEQ", "Randomization failed")
            end

            create_and_finish_item();
        end
    endtask

endclass

class timer_t_sequence_reserved extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_reserved)

    function new(string name = "timer_t_sequence_reserved");
        super.new(name);
    endfunction

    task body();
        default_RST     = ~RST_ACT_LEVEL;
        default_ADDRESS = TIMER_CNT;
        default_REQUEST = CP_REQ_RESERVED;
        default_DATA_IN = 0;

        create_and_finish_item();
    endtask

endclass

class timer_t_sequence_invalid_addr extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_invalid_addr)

    function new(string name = "timer_t_sequence_invalid_addr");
        super.new(name);
    endfunction

    task body();
        default_RST     = ~RST_ACT_LEVEL;
        default_REQUEST = CP_REQ_WRITE;

        // mimo validní rozsah
        default_ADDRESS = 8'hFF;
        default_DATA_IN = 32'hDEADBEEF;

        create_and_finish_item();
    endtask

endclass

class timer_t_sequence_cnt_rw_mix extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_cnt_rw_mix)

    function new(string name = "timer_t_sequence_cnt_rw_mix");
        super.new(name);
    endfunction

    task body();

        default_RST = ~RST_ACT_LEVEL;

        // WRITE CNT
        default_ADDRESS = TIMER_CNT;
        default_REQUEST = CP_REQ_WRITE;
        default_DATA_IN = 32'd10;
        create_and_finish_item();

        // READ CNT
        default_ADDRESS = TIMER_CNT;
        default_REQUEST = CP_REQ_READ;
        default_DATA_IN = 0;
        create_and_finish_item();

    endtask

endclass

class timer_t_sequence_full_cov extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_full_cov)

    function new(string name = "timer_t_sequence_full_cov");
        super.new(name);
    endfunction

    task body();

        int modes[4];
        int addrs[5];
        int reqs[3];

        // inicializace
        modes = '{DISABLED, AUTO_RESTART, ONE_SHOT, CONTINOUS};
        addrs = '{TIMER_CNT, TIMER_CMP, TIMER_CR, TIMER_CYCLE_L, TIMER_CYCLE_H};
        reqs  = '{CP_REQ_NONE, CP_REQ_READ, CP_REQ_WRITE};

        default_RST = ~RST_ACT_LEVEL;

        foreach (modes[i]) begin

            // nastavení módu
            default_ADDRESS = TIMER_CR;
            default_REQUEST = CP_REQ_WRITE;
            default_DATA_IN = modes[i];
            create_and_finish_item();

            foreach (addrs[j]) begin
                foreach (reqs[k]) begin

                    default_ADDRESS = addrs[j];
                    default_REQUEST = reqs[k];
                    default_DATA_IN = $urandom_range(0,100);

                    create_and_finish_item();

                end
            end
        end

    endtask

endclass

class timer_t_sequence_irq_modes extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_irq_modes)

    function new(string name = "timer_t_sequence_irq_modes");
        super.new(name);
    endfunction

    task body();

        int modes[3];
        modes = '{AUTO_RESTART, ONE_SHOT, CONTINOUS};

        default_RST = ~RST_ACT_LEVEL;

        foreach (modes[i]) begin

            // nastav mode
            default_ADDRESS = TIMER_CR;
            default_REQUEST = CP_REQ_WRITE;
            default_DATA_IN = modes[i];
            create_and_finish_item();

            // nastav CNT = 0
            default_ADDRESS = TIMER_CNT;
            default_REQUEST = CP_REQ_WRITE;
            default_DATA_IN = 0;
            create_and_finish_item();

            // nastav CMP = 3
            default_ADDRESS = TIMER_CMP;
            default_REQUEST = CP_REQ_WRITE;
            default_DATA_IN = 3;
            create_and_finish_item();

            // nech běžet → IRQ
            default_REQUEST = CP_REQ_NONE;
            repeat (10) create_and_finish_item();

        end

    endtask

endclass

class timer_t_sequence_oor extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_oor)

    function new(string name = "timer_t_sequence_oor");
        super.new(name);
    endfunction

    task body();

        default_RST = ~RST_ACT_LEVEL;

        repeat (5) begin
            // horní bity ≠ 0 → OOR
            default_ADDRESS = (1 << TIMER_ADDR_SPACE_BITS); 

            default_REQUEST = CP_REQ_READ;
            default_DATA_IN = 0;
            create_and_finish_item();
        end

    endtask

endclass

class timer_t_sequence_unaligned extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_unaligned)

    function new(string name = "timer_t_sequence_unaligned");
        super.new(name);
    endfunction

    task body();

        default_RST = ~RST_ACT_LEVEL;

        repeat (5) begin
            default_ADDRESS = TIMER_CNT + 1; // nezarovnané
            default_REQUEST = CP_REQ_WRITE;
            default_DATA_IN = 32'h1234;
            create_and_finish_item();
        end

    endtask

endclass

class timer_t_sequence_reserved_extend extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_reserved)

    function new(string name = "timer_t_sequence_reserved");
        super.new(name);
    endfunction

    task body();

        default_RST = ~RST_ACT_LEVEL;

        repeat (5) begin
            default_ADDRESS = TIMER_CNT;
            default_REQUEST = CP_REQ_RESERVED;
            default_DATA_IN = 0;
            create_and_finish_item();
        end

    endtask

endclass

class timer_t_sequence_write_read extends timer_t_sequence;

    `uvm_object_utils(timer_t_sequence_write_read)

    function new(string name = "timer_t_sequence_write_read");
        super.new(name);
    endfunction

    task body();

        default_RST = ~RST_ACT_LEVEL;

        repeat (5) begin
            // WRITE
            default_ADDRESS = TIMER_CMP;
            default_REQUEST = CP_REQ_WRITE;
            default_DATA_IN = $urandom_range(1,50);
            create_and_finish_item();

            // OKAMŽITĚ READ (same addr!)
            default_ADDRESS = TIMER_CMP;
            default_REQUEST = CP_REQ_READ;
            default_DATA_IN = 0;
            create_and_finish_item();
        end

    endtask

endclass
