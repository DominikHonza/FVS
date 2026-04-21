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


// [assert] Ridici signaly (ADDRESS, REQUEST, RESPONSE a P_IRQ) nesmi mit nedefinovane hodnoty (X,Z).
property pr_control_known;
    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    !$isunknown({ADDRESS, REQUEST, RESPONSE, P_IRQ});
endproperty

a_control_known: assert property (pr_control_known)
    else `uvm_error("ABV", "Control signal contains X or Z");

// [assert] Čtené (DATA_OUT) a zapisované (DATA_IN) data nesmí mít nedefinované hodnoty (X,Z). Vyhodnocení jen při operacích READ a WRITE! 
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

// [assert + cover] Při zápisu/čtení na/z adresy mimo adresový prostor timeru je v dalším cyklu nastaven RESPONSE OOR. 

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

// [assert + cover] Při zápisu/čtení na/z nezarovnané adresy v adresovém prostoru timeru je v dalším cyklu nastaven RESPONSE UNALIGNED. 

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

// [assert + cover] Kontrola zápisu a čtení v po sobě jdoucích cyklech na stejnou adresu. Pozn. Měla by se pročíst nově zapsaná data.  

property pr_write_read_same_addr;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    // WRITE v minulém cyklu
    ($past(REQUEST) == CP_REQ_WRITE &&
     REQUEST == CP_REQ_READ &&

     // stejna adresa a read/write registr
     ADDRESS == $past(ADDRESS) &&
     (ADDRESS == TIMER_CNT || ADDRESS == TIMER_CMP || ADDRESS == TIMER_CR))

    |=> (($past(ADDRESS) == TIMER_CR) ?
            (DATA_OUT == ($past(DATA_IN, 2) & 32'h3)) :
            (DATA_OUT == $past(DATA_IN, 2)));

endproperty

a_write_read_same_addr: assert property (pr_write_read_same_addr)
    else `uvm_error("ABV", "Read data does not match previously written data");

c_write_read_same_addr: cover property (pr_write_read_same_addr);

// [assert + cover] Při zápisu/čtení na/z správnou adresu v adresovém prostoru timeru je v dalším cyklu nastaven RESPONSE ACK. 

property pr_ack_response;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    ((REQUEST == CP_REQ_READ || REQUEST == CP_REQ_WRITE) &&
     (ADDRESS <= TIMER_CYCLE_H) &&      // neni OOR
     (ADDRESS[1:0] == 2'b00))           // není UNALIGNED

    |=> (RESPONSE == CP_RSP_ACK);

endproperty

a_ack_response: assert property (pr_ack_response)
    else `uvm_error("ABV", "ACK response not generated for valid access");

c_ack_response: cover property (pr_ack_response);

// [assert + cover] Odpověď na NONE REQUEST je vždy IDLE. 

property pr_none_idle;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (REQUEST == CP_REQ_NONE)

    |=> (RESPONSE == CP_RSP_IDLE);

endproperty

a_none_idle: assert property (pr_none_idle)
    else `uvm_error("ABV", "RESPONSE is not IDLE for NONE request");

c_none_idle: cover property (pr_none_idle);

// [assert + cover] Odpověď na RESERVED REQUEST je vždy ERROR. 

property pr_reserved_error;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (REQUEST == CP_REQ_RESERVED)

    |=> (RESPONSE == CP_RSP_ERROR);

endproperty

a_reserved_error: assert property (pr_reserved_error)
    else `uvm_error("ABV", "RESPONSE is not ERROR for RESERVED request");

c_reserved_error: cover property (pr_reserved_error);

// [assert] Odpověď WAIT se nesmí nikdy objevit. 

property pr_no_wait;

    @(posedge CLK)
    disable iff (RST !== RST_INACT_LEVEL)

    (RESPONSE != CP_RSP_WAIT);

endproperty

a_no_wait: assert property (pr_no_wait)
    else `uvm_error("ABV", "WAIT response detected - illegal state");

// [assert + cover] Když se hodnota v cnt_reg rovná hodnotě v cmp_reg, v dalším cyklu je P_IRQ nastaven na 1 (neplatí v módu DISABLED), jinak má hodnotu 0.  
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

// [assert + cover] Když se hodnota v cnt_reg rovná hodnotě v cmp_reg a mód je nastaven na AUTO_RESTART, v dalším cyklu je cnt_reg vynulován. 

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
