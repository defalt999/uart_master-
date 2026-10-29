module counter#(
    parameter RESET_VALUE  = 0,
    parameter COUNTER_SIZE = 8
)(
    input clk_i,
    input rst_n,

    input                    cu_i, //Count up: 1, Count down: 0 ;
    input                    load_i,
    input                    enable_i,
    input [COUNTER_SIZE-1:0] data_in,

    output reg[COUNTER_SIZE-1:0] counter_o,
    output reg                   ovf_o
);

localparam LIMIT = {COUNTER_SIZE{1'b1}};

always @(posedge clk_i or negedge rst_n)
if(~rst_n)             counter_o <=           'd0; else
if(load_i && enable_i) counter_o <=       data_in; else
if(cu_i   && enable_i) counter_o <= counter_o + 1; else
if(~cu_i  && enable_i) counter_o <= counter_o - 1; else
                       counter_o <= counter_o;



always @(posedge clk_i or negedge rst_n)
if(~rst_n)                                                                            ovf_o <= 1'b0; else
if((counter_o == LIMIT && cu_i && enable_i) || (counter_o == 0 && ~cu_i && enable_i)) ovf_o <= 1'b1; else
                                                                                      ovf_o <= 1'b0; 

endmodule 