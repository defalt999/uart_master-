module uart_master#(
    parameter DATA_SIZE=8,
    parameter ADDR_SIZE=3
)
(
    //Sys Interface
    input clk_i,
    input rst_n,

    //Data Interface
    input[DATA_SIZE-1:0] data_in,

    //UART Interface
    output reg tx_baud_tick,
    output reg tx_out,
    output reg tx_busy,

    //APB Inteface
    input psel_i,
    input penable_i,
    input[ADDR_SIZE-1:0] paddr_i,
    input pwrite_i,
    input[DATA_SIZE-1:0]pwdata_i,
    output reg pready_o,
    output reg pslverr_o
);


reg[7:0] ctrl_reg;
 //1R, 2PARITy,  1 STOP BITS ,1  1 DATA_SIZE, 1 TX_EN, 1 EN
 //DATA SIZE: 00 - 5 bits, 01-6bits, 10 - 7bits, 11 8 bits
 //PARITY: 00 - no parity, 01 - even , 10 - odd, 11 -reserved
reg[7:0] baud_reg;

reg[7:0] mode_reg;
//000 - default trimite data in

reg[DATA_SIZE-1:0] min_reg;
reg[DATA_SIZE-1:0] max_reg;
reg[DATA_SIZE-1:0] error_msg_reg;
reg[DATA_SIZE-1:0] ok_msg_reg;


reg[DATA_SIZE-1:0] data_reg;



//APB
//================================================================================================================

localparam IDLE   = 2'b00;
localparam SETUP  = 2'b01;
localparam ACCESS = 2'b10;



reg[1:0] state, next_state;

reg [ADDR_SIZE-1:0] paddr_setup;
reg [DATA_SIZE-1:0] pwdata_setup;
reg                 pwrite_setup;


//Checking for stable signals
//========================================================
wire setup_stable = (paddr_setup == paddr_i) && (pwdata_setup == pwdata_i) && (pwrite_i == pwrite_setup) && psel_i && penable_i;

always @(posedge clk_i or negedge rst_n)
if(~rst_n) paddr_setup <= 'd0; else
           paddr_setup <= paddr_i;

always @(posedge clk_i or negedge rst_n)
if(~rst_n) pwdata_setup <= 'd0; else
           pwdata_setup <= pwdata_i;

always @(posedge clk_i or negedge rst_n)
if(~rst_n) pwrite_setup <= 'd0; else
           pwrite_setup <= pwrite_i;
//========================================================


//FSM
//========================================================
always @(posedge clk_i or negedge rst_n)
if(~rst_n) state <=       IDLE; else
           state <= next_state;

always @(*) begin
next_state = state;
case (state)
 IDLE: if(psel_i && ~penable_i) next_state =  SETUP;

 SETUP:if(psel_i && penable_i)  next_state = ACCESS;else
                                next_state =   IDLE;

 ACCESS:if(psel_i && ~penable_i) next_state = SETUP;else
                                 next_state = IDLE;
 default:next_state = IDLE;
endcase
end
//========================================================


//PREADY
//========================================================
always@(*)
if(~rst_n)               pready_o <= 'd0; else
if(next_state == ACCESS) pready_o <= 'd1; else
                         pready_o <= 'd0;
//========================================================


//PSLVERR
//========================================================
always@(*)
if(~rst_n)                            pslverr_o <= 'd0; else
if((state == SETUP) && ~setup_stable) pslverr_o <= 'd1; else
                                      pslverr_o <= 'd0;
//========================================================


always@(posedge clk_i or negedge rst_n)
if((next_state == ACCESS) && setup_stable) begin
case(paddr_i)
 'd0: ctrl_reg      <= pwdata_i;
 'd1: baud_reg      <= pwdata_i;
 'd2: min_reg       <= pwdata_i;
 'd3: max_reg       <= pwdata_i;
 'd4: error_msg_reg <= pwdata_i;
 'd5: ok_msg_reg    <= pwdata_i;
 'd6: mode_reg      <= pwdata_i;
 default: ctrl_reg <= ctrl_reg;
endcase
end


//UART
//================================================================================================================
localparam TX_IDLE    = 3'b000;
localparam TX_START   = 3'b001;
localparam TX_DATA    = 3'b010;
localparam TX_PARITY  = 3'b100;
localparam TX_STOP    = 3'b011;
reg[2:0] uart_state;

//BAUD GEN
//========================================================
reg[7:0] baud_counter;


always @(posedge clk_i or negedge rst_n)
if(~rst_n)                   tx_baud_tick <= 'd0; else
if(ctrl_reg[0])begin
if(baud_counter == baud_reg) tx_baud_tick <= 'd1; else
                             tx_baud_tick <= 'd0;
end

always @(posedge clk_i or negedge rst_n)
if(~rst_n)                   baud_counter <= 'd0; else
if(ctrl_reg[0]) begin
if(baud_counter == baud_reg) baud_counter <=              'd0; else
                             baud_counter <= baud_counter + 1;
end
//========================================================

//TX
//========================================================
reg[3:0] bit_count;
reg stop_count;

always@(posedge clk_i or negedge rst_n)
if(~rst_n) bit_count <= 'd0; else
if(uart_state == TX_DATA && tx_baud_tick) begin
case(ctrl_reg[3:2])
 2'b00: if(bit_count == 5 - 1) bit_count <= 'd0; else bit_count <= bit_count + 1;
 2'b01: if(bit_count == 6 - 1) bit_count <= 'd0; else bit_count <= bit_count + 1;
 2'b10: if(bit_count == 7 - 1) bit_count <= 'd0; else bit_count <= bit_count + 1;
 2'b11: if(bit_count == 8 - 1) bit_count <= 'd0; else bit_count <= bit_count + 1;
endcase
end


always@(posedge clk_i or negedge rst_n)
if(~rst_n) uart_state = TX_IDLE; else
if(ctrl_reg[1] && tx_baud_tick)begin
case(uart_state)
 TX_IDLE : uart_state <= TX_START;
 TX_START: uart_state <= TX_DATA;
 TX_DATA:
  case(ctrl_reg[3:2])
   2'b00: if(bit_count == 5 - 1) uart_state <= (ctrl_reg[6:5] == 2'b00) ? TX_STOP : TX_PARITY;
   2'b01: if(bit_count == 6 - 1) uart_state <= (ctrl_reg[6:5] == 2'b00) ? TX_STOP : TX_PARITY;
   2'b10: if(bit_count == 7 - 1) uart_state <= (ctrl_reg[6:5] == 2'b00) ? TX_STOP : TX_PARITY;
   2'b11: if(bit_count == 8 - 1) uart_state <= (ctrl_reg[6:5] == 2'b00) ? TX_STOP : TX_PARITY;
  endcase
  TX_PARITY: uart_state <= TX_STOP;
  TX_STOP: if(ctrl_reg[4] && stop_count) uart_state <= TX_IDLE; else
           if(~ctrl_reg[4])              uart_state <= TX_IDLE;
                                         
endcase
end

always@(posedge clk_i or negedge rst_n)
if(~rst_n)                stop_count <= 1'd0; else
if(uart_state != TX_STOP) stop_count <= 1'd0; else
                          stop_count <= stop_count + 1;

always@(posedge clk_i or negedge rst_n)
if(~rst_n)                  tx_out <= 1'd1; else
if(tx_baud_tick) begin
if(uart_state == TX_START)  tx_out <= 1'd0; else
if(uart_state == TX_STOP)   tx_out <= 1'd1; else
if(uart_state == TX_DATA)   tx_out <= data_reg[bit_count]; else
if(uart_state == TX_PARITY) begin
 case(ctrl_reg[6:5])
  2'b01:   tx_out <= ~^data_reg; //EVEN
  2'b10:   tx_out <=  ^data_reg; //ODD
  default: tx_out <= tx_out;
 endcase; 
end 
    else tx_out <=                1'd1;
end

always @(posedge clk_i or negedge rst_n)
if(~rst_n)                tx_busy <= 'd0; else
if(uart_state != TX_IDLE) tx_busy <= 'd1; else
                          tx_busy <= 'd0;



//================================================================================================================   




//DATA_REG
//================================================================================================================   

always @(posedge clk_i or negedge rst_n)
if(~rst_n) data_reg <= 'd0; else
case(mode_reg[2:0])
 3'b000: if(~tx_busy) data_reg <= data_in; else
                      data_reg <= data_reg;
 3'b001: if(data_in > min_reg) data_reg <=    ok_msg_reg; else
                               data_reg <= error_msg_reg;

 3'b010: if(data_in < max_reg) data_reg <=    ok_msg_reg; else
                               data_reg <= error_msg_reg;

 3'b011: if(data_in < max_reg && data_in > min_reg) data_reg <=    ok_msg_reg; else
                                                    data_reg <= error_msg_reg;


 

 default: if(~tx_busy) data_reg <=  data_in; else
                       data_reg <= data_reg;

endcase 

//================================================================================================================   

endmodule