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


initial begin
    apb_drv=new(intf);
    apb_drv.run();
    repeat(5) @(posedge clk);
    apb_drv.drive(8'd1,8'd10);
    repeat(25) @(posedge clk);
    apb_drv.drive(8'd0,8'b1);
    repeat(5) @(posedge clk);
    apb_drv.drive(8'd0,8'b10_0_11_1_0);
    repeat(50) @(posedge clk);
  
    $stop;
end


initial begin
    forever begin
        data_in = $urandom_range(31, 16);
        @(posedge clk);
    end
end

endmodule