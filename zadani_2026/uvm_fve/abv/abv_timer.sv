`include "uvm_macros.svh"
import uvm_pkg::*;
import sv_param_pkg::*;

module abv_timer (
    input logic                  CLK,
    input logic                  RST,
    input logic                  P_IRQ,
    input logic [ADDR_WIDTH-1:0] ADDRESS,
    input logic [1:0]            REQUEST,
    input logic [2:0]            RESPONSE,
    input logic [DATA_WIDTH-1:0] DATA_OUT,
    input logic [DATA_WIDTH-1:0] DATA_IN,
    input logic [1:0]            ctrl_reg_d,
    input logic [DATA_WIDTH-1:0] cnt_reg_d,
    input logic [DATA_WIDTH-1:0] cmp_reg_d,
    input logic [63:0]           cycle_cnt
);

localparam logic RST_INACT_LEVEL = ~RST_ACT_LEVEL;

property auto_restart_irq_p;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (ctrl_reg_d == AUTO_RESTART && cnt_reg_d == cmp_reg_d)
    |=> (P_IRQ == 1);

endproperty

// TEST PROPERRTY from lecture
assert property (auto_restart_irq_p)
    else `uvm_error("ABV", "AUTO_RESTART: IRQ was not asserted when CNT == CMP");


// [assert] Control signals (ADDRESS, REQUEST, RESPONSE and P_IRQ) must not contain unknown values (X/Z).
property pr_control_known;
    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    !$isunknown({ADDRESS, REQUEST, RESPONSE, P_IRQ});
endproperty

a_control_known: assert property (pr_control_known)
    else `uvm_error("ABV", "Control signal contains X or Z");

// [assert] Read data (DATA_OUT) and write data (DATA_IN) must not contain unknown values (X/Z). Checked only during READ and WRITE operations.
property pr_data_in_known;
    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (REQUEST == CP_REQ_WRITE)
    |-> !$isunknown(DATA_IN);
endproperty

a_data_in_known: assert property (pr_data_in_known)
    else `uvm_error("ABV", "DATA_IN contains X/Z during WRITE");

property pr_data_out_known;
    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (REQUEST == CP_REQ_READ)
    |-> ##[1:$] (!$isunknown(DATA_OUT));
endproperty

a_data_out_known: assert property (pr_data_out_known)
    else `uvm_error("ABV", "DATA_OUT contains X/Z during READ");

// [assert + cover] A read/write access outside the timer address space must produce an OOR response in the next cycle.

property pr_oor_response;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    ((REQUEST == CP_REQ_READ || REQUEST == CP_REQ_WRITE) &&
     (ADDRESS > TIMER_CYCLE_H))

    |=> (RESPONSE == CP_RSP_OOR);

endproperty

a_oor_response: assert property (pr_oor_response)
    else `uvm_error("ABV", "OOR response not generated for invalid address");

c_oor_response: cover property (pr_oor_response);

// [assert + cover] A read/write access to an unaligned timer address must produce an UNALIGNED response in the next cycle.

property pr_unaligned_response;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    ((REQUEST == CP_REQ_READ || REQUEST == CP_REQ_WRITE) &&
     (ADDRESS <= TIMER_CYCLE_H) &&
     (ADDRESS[1:0] != 2'b00))

    |=> (RESPONSE == CP_RSP_UNALIGNED);

endproperty

a_unaligned_response: assert property (pr_unaligned_response)
    else `uvm_error("ABV", "UNALIGNED response not generated");

c_unaligned_response: cover property (pr_unaligned_response);

// [assert + cover] Checks write followed by read to the same address in consecutive cycles. The read should return the newly written data.

property pr_write_read_same_addr;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    // WRITE in the previous cycle.
    ($past(REQUEST) == CP_REQ_WRITE &&
     REQUEST == CP_REQ_READ &&

     // Same address and a readable/writable register.
     ADDRESS == $past(ADDRESS) &&
     (ADDRESS == TIMER_CNT || ADDRESS == TIMER_CMP || ADDRESS == TIMER_CR))

    |=> (($past(ADDRESS) == TIMER_CR) ?
            (DATA_OUT == ($past(DATA_IN, 2) & 32'h3)) :
            (DATA_OUT == $past(DATA_IN, 2)));

endproperty

a_write_read_same_addr: assert property (pr_write_read_same_addr)
    else `uvm_error("ABV", "Read data does not match previously written data");

c_write_read_same_addr: cover property (pr_write_read_same_addr);

// [assert + cover] A read/write access to a valid timer address must produce an ACK response in the next cycle.

property pr_ack_response;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    ((REQUEST == CP_REQ_READ || REQUEST == CP_REQ_WRITE) &&
     (ADDRESS <= TIMER_CYCLE_H) &&      // Not OOR.
     (ADDRESS[1:0] == 2'b00))           // Not UNALIGNED.

    |=> (RESPONSE == CP_RSP_ACK);

endproperty

a_ack_response: assert property (pr_ack_response)
    else `uvm_error("ABV", "ACK response not generated for valid access");

c_ack_response: cover property (pr_ack_response);

// [assert + cover] A NONE request must always produce an IDLE response.

property pr_none_idle;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (REQUEST == CP_REQ_NONE)

    |=> (RESPONSE == CP_RSP_IDLE);

endproperty

a_none_idle: assert property (pr_none_idle)
    else `uvm_error("ABV", "RESPONSE is not IDLE for NONE request");

c_none_idle: cover property (pr_none_idle);

// [assert + cover] A RESERVED request must always produce an ERROR response.

property pr_reserved_error;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (REQUEST == CP_REQ_RESERVED)

    |=> (RESPONSE == CP_RSP_ERROR);

endproperty

a_reserved_error: assert property (pr_reserved_error)
    else `uvm_error("ABV", "RESPONSE is not ERROR for RESERVED request");

c_reserved_error: cover property (pr_reserved_error);

// [assert] The WAIT response must never appear.

property pr_no_wait;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (RESPONSE != CP_RSP_WAIT);

endproperty

a_no_wait: assert property (pr_no_wait)
    else `uvm_error("ABV", "WAIT response detected - illegal state");

// [assert + cover] When cnt_reg equals cmp_reg, P_IRQ is asserted in the next cycle unless the timer is DISABLED; otherwise it stays low.
property pr_irq_on_match;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (cnt_reg_d == cmp_reg_d && ctrl_reg_d != DISABLED)

    |=> (P_IRQ == 1);

endproperty

a_irq_on_match: assert property (pr_irq_on_match)
    else `uvm_error("ABV", "IRQ not asserted when CNT == CMP");

c_irq_on_match: cover property (pr_irq_on_match);

property pr_irq_when_no_match;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (cnt_reg_d != cmp_reg_d)

    |=> (P_IRQ == 0);

endproperty

a_irq_when_no_match: assert property (pr_irq_when_no_match)
    else `uvm_error("ABV", "IRQ asserted when CNT != CMP");

c_irq_when_no_match: cover property (pr_irq_when_no_match);

// [assert + cover] When cnt_reg equals cmp_reg in AUTO_RESTART mode, cnt_reg is reset to zero in the next cycle.

property pr_auto_restart_reset_cnt;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (cnt_reg_d == cmp_reg_d &&
     ctrl_reg_d == AUTO_RESTART)

    |=> (cnt_reg_d == 0);

endproperty

a_auto_restart_reset_cnt: assert property (pr_auto_restart_reset_cnt)
    else `uvm_error("ABV", "AUTO_RESTART did not reset CNT");

c_auto_restart_reset_cnt: cover property (pr_auto_restart_reset_cnt);

endmodule : abv_timer
