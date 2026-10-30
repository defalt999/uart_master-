`include "apb_driver.sv"
module uart_tb;


wire clk;
wire rst_n;

reg psel;
reg penable;
reg pwrite;
reg[2:0] paddr;
reg[7:0] pwdata;
reg [7:0] data_in;


ck_rst_tb #(
.CK_SEMIPERIOD ('d10)
) i_ck_rst_tb (
.clk    (clk   ),
.rst_n  (rst_n )
);

apb_interface intf(clk, rst_n);


uart_master DUT(
    .clk_i     (intf.clk        ),
    .rst_n     (intf.rst_n    ),
    .psel_i    (intf.psel   ),
    .penable_i (intf.penable),
    .pwrite_i  (intf.pwrite ),
    .paddr_i   (intf.paddr  ),
    .pwdata_i  (intf.pwdata ),

    .data_in(data_in)
);


apb_driver apb_drv;


//REGS
localparam CTRL  = 8'd0;
localparam BAUD  = 8'd1;
localparam MIN   = 8'd2;
localparam MAX   = 8'd3;
localparam ERROR = 8'd4;
localparam OK    = 8'd5;
localparam MODE  = 8'd6;

//CONFIGS TO TEST
localparam CTRL_DEFAULT = 8'b0_0_00_0_00_1_1;







initial begin
    apb_drv=new(intf);
    apb_drv.run();
    repeat(5) @(posedge clk);
    apb_drv.drive(BAUD,5);
    apb_drv.drive(MIN, 10);
    apb_drv.drive(ERROR, 8'b0110);
    apb_drv.drive(OK, 8'd0);
    apb_drv.drive(MODE, 8'b001);
    apb_drv.drive(CTRL,CTRL_DEFAULT);
    repeat(100) @(posedge clk);
    $stop;
end


initial begin
    forever begin
        data_in = $urandom_range(31, 11);
        @(posedge clk);
    end
end

endmodule