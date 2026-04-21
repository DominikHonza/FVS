// Represents the golden model of the processor used to predict results of the DUT.
class timer_t_gm extends uvm_subscriber #(timer_t_transaction);//uvm_component;

    // registration of component tools
    `uvm_component_utils( timer_t_gm )

    // analysis port for outside components to access transactions from the monitor
    uvm_analysis_port #(timer_t_transaction) timer_t_analysis_port;

    // static local variables accesible by waveform
    static logic                  P_IRQ;
    static logic [2:0]            RESPONSE;
    static logic [DATA_WIDTH-1:0] DATA_OUT;

    // local variables
    /* INSERT YOUR CODE HERE */

    static logic [2:0]  response_buffer = 0;
    static logic match = 0;
    static logic irq_next = 0;
    static logic [DATA_WIDTH-1:0] cnt_reg = 0;
    static logic [DATA_WIDTH-1:0] cmp_reg = 0;
    static logic [DATA_WIDTH-1:0] cmp_reg_buffer = 0;
    logic [1:0] ctrl_reg = 0;
    logic [63:0] cycle_cnt = 0;

    // base name prefix for created transactions
    string m_name = "gold";

    // Constructor - creates new instance of this class
    function new( string name = "m_timer_t_gm_h", uvm_component parent = null );
        super.new( name, parent );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
    	super.build_phase( phase );

      timer_t_analysis_port = new( "timer_t_analysis_port", this );

    endfunction: build_phase

    // Connect - create interconnection between child components
    function void connect_phase( uvm_phase phase );
        super.connect_phase( phase );
    endfunction: connect_phase

    // Write - get all transactions from driver for computing predictions
    function void write( T t );
  		timer_t_transaction out_t;

        out_t = timer_t_transaction::type_id::create(
            $sformatf("%0s: %0t", m_name, $time) );

        out_t.copy(t);

        // predict outputs
        predict( out_t );

        // support function for displaying data in wave
        wave_display_support_func(out_t);

        // send predicted outputs to scoreboard
        timer_t_analysis_port.write(out_t);
  	endfunction: write

    // implements behavior of the golden model
    local function automatic void predict(timer_t_transaction t);

        set_default_outputs(t);

        t.P_IRQ = 0;

        //--------------------------------
        // RESPONSE logic (priority)
        //--------------------------------

        t.RESPONSE = response_buffer;
        if (t.REQUEST == 2'b00)
            response_buffer = 3'b000; // idle

        else if (t.REQUEST == 2'b11)
            response_buffer =  3'b011; // error

        else if (t.ADDRESS > 8'h14)
            response_buffer =  3'b101; // out of range

        else if (t.ADDRESS[1:0] != 2'b00)
            response_buffer =  3'b100; // unaligned

        else
            response_buffer =  3'b001; // acknowledge

        if (t.RST == 0) begin
            cnt_reg      = 0;
            cmp_reg      = 0;
            ctrl_reg     = 0;
        end
        else begin
            

            //--------------------------------
            // WRITE
            //--------------------------------

            if (t.REQUEST == 2'b10 && response_buffer  == 3'b001) begin

                case (t.ADDRESS)

                    8'h00: cnt_reg  = t.DATA_IN;

                    8'h04: cmp_reg  = t.DATA_IN;

                    8'h08: ctrl_reg = t.DATA_IN[1:0];

                    default: ;

                endcase
            end


            //--------------------------------
            // READ
            //--------------------------------

            if (t.REQUEST == 2'b01 && response_buffer == 3'b001) begin

                case (t.ADDRESS)

                    8'h00: t.DATA_OUT = cnt_reg;

                    8'h04: t.DATA_OUT = cmp_reg;

                    8'h08: t.DATA_OUT = ctrl_reg;

                    8'h10: t.DATA_OUT = cycle_cnt[31:0];

                    8'h14: t.DATA_OUT = cycle_cnt[63:32];

                    default: t.DATA_OUT = 0;

                endcase
            end

            //--------------------------------
            // TIMER increment
            //--------------------------------
            
            match = (cnt_reg) == cmp_reg && (ctrl_reg != 2'b00);

            cycle_cnt++;


            // WARNING MAYBE FOUND BUH HERE
            // DUT COUNTS EVEN WHEN t.RESPONSE is 3'b000
            if (ctrl_reg != 2'b00 && t.RESPONSE == 3'b000)
                cnt_reg++;


            //--------------------------------
            // IRQ generation
            //--------------------------------

        
            //`uvm_info(get_type_name(),"VALUES",UVM_LOW)
            //`uvm_info(get_type_name(),$sformatf("%x %x %x",cnt_reg, cmp_reg, ctrl_reg),UVM_LOW)
            if (match) begin
               // `uvm_info(get_type_name(),"AFTER COMPARE",UVM_LOW)

                t.P_IRQ = 1;

                case (ctrl_reg)

                    2'b01: cnt_reg = 0; // AUTO_RESTART

                    2'b10: begin       // ONE_SHOT
                        cnt_reg = 0;
                        ctrl_reg = 2'b00;
                    end

                    2'b11: ;           // CONTINUOUS

                endcase
        
            end
        end

    endfunction: predict

    // Setting default outputs
    local function void set_default_outputs( timer_t_transaction t );
        t.P_IRQ    = 0;
        t.RESPONSE = 0;
        t.DATA_OUT = 0;
    endfunction: set_default_outputs

    // Waveform display for golden model signals
    local function automatic void wave_display_support_func( timer_t_transaction t );
        P_IRQ    = t.P_IRQ;
        RESPONSE = t.RESPONSE;
        DATA_OUT = t.DATA_OUT;
    endfunction: wave_display_support_func

endclass: timer_t_gm
