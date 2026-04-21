// This class measures exercised combinations of DUTs interface ports.
class timer_t_coverage extends uvm_subscriber #(timer_t_transaction);

    // registration of component tools
    `uvm_component_utils( timer_t_coverage )

    // member attributes
    local T m_transaction_h;
    virtual dut_internal_if ivif;

    // Covergroup definition
    covergroup FunctionalCoverage( string inst );
        
        // 1. Coverpoint and bins for timer modes
       mode_cp : coverpoint ivif.ctrl_reg_d[1:0]{
            option.weight = 1;
            bins disabled     = {DISABLED};
            bins auto_restart = {AUTO_RESTART};
            bins one_shot     = {ONE_SHOT};
            bins continous    = {CONTINOUS};
        }

        // 2. Coverpoint and bins for allowed requests
        req_cp : coverpoint m_transaction_h.REQUEST {
            option.weight = 1;
            bins req_none  = {CP_REQ_NONE};
            bins req_read  = {CP_REQ_READ};
            bins req_write = {CP_REQ_WRITE};
            ignore_bins req_reserved = {CP_REQ_RESERVED};
        }

        // 3. Coverpoint and bins for reset values
        rst_cp : coverpoint m_transaction_h.RST {
            bins rst_active   = {0};
            bins rst_inactive = {1};
        }

        // 4. Transition coverpoint for reset transitions
        rst_trans_cp : coverpoint m_transaction_h.RST {
            bins rise[] = (0 => 1);
            bins fall[] = (1 => 0);
        }

        // 5. Address cover point
        addr_cp : coverpoint m_transaction_h.ADDRESS[7:0] {
            option.weight = 1;

            bins timer_cnt     = {TIMER_CNT};
            bins timer_cmp     = {TIMER_CMP};
            bins timer_cr      = {TIMER_CR};
            bins timer_cycle_l = {TIMER_CYCLE_L};
            bins timer_cycle_h = {TIMER_CYCLE_H};
        }

        //6. Cross: address + WRITE + reset inactive
        addr_write_cross : cross addr_cp, req_cp, rst_cp {
            ignore_bins ignore_other =
                !binsof(req_cp.req_write) || !binsof(rst_cp.rst_inactive);
        }

                // 7. Cross: address + READ + reset inactive
        addr_read_cross : cross addr_cp, req_cp, rst_cp {
            ignore_bins ignore_other =
                !binsof(req_cp.req_read) || !binsof(rst_cp.rst_inactive);
        }

         // 8. Interrupt coverpoint
        irq_cp : coverpoint m_transaction_h.P_IRQ {
            bins irq_0 = {0};
            bins irq_1 = {1};
        }

        // 9. Interrupt transitions
        irq_trans_cp : coverpoint m_transaction_h.P_IRQ {
            bins rise = (0 => 1);
            bins fall = (1 => 0);
        }
    
        // 10. Cross: interrupt active in all modes except DISABLED
        irq_mode_cross : cross irq_cp, mode_cp {
            ignore_bins ignore_other =
                binsof(mode_cp.disabled) || !binsof(irq_cp.irq_1);
        }

        // 11. Transition between modes
        mode_trans_cp : coverpoint ivif.ctrl_reg_d[1:0] {
            bins disabled_to_auto = (DISABLED => AUTO_RESTART);
            bins auto_to_one      = (AUTO_RESTART => ONE_SHOT);
            bins one_to_cont      = (ONE_SHOT => CONTINOUS);
            bins cont_to_disabled = (CONTINOUS => DISABLED);
        }

        // 12. Cross: address + request + reset inactive + mode
        full_cross : cross addr_cp, req_cp, rst_cp, mode_cp {
            ignore_bins ignore_other =
                binsof(rst_cp.rst_active);
        }

    endgroup

    // Constructor - creates new instance of this class
    function new( string name = "m_coverage_h", uvm_component parent = null );
        super.new( name, parent );
        FunctionalCoverage = new( "timer" );
    endfunction: new

    // Build - instantiates child components
    function void build_phase( uvm_phase phase );
        super.build_phase( phase );
        if ( !uvm_config_db #(virtual dut_internal_if)::get(this,
            "*", "dut_internal_if", ivif) ) begin
            `uvm_fatal( "configuration:", "Cannot find 'dut_internal_if' inside uvm_config_db, probably not set!" )
        end
    endfunction: build_phase

    // Write - obligatory function, samples value on the interface.
    function void write( T t );
        // skip invalid transactions
        m_transaction_h = t;
        FunctionalCoverage.sample();
    endfunction: write

endclass: timer_t_coverage
