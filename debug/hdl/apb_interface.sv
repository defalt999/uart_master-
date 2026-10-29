interface apb_interface(input clk, input rst_n);
    logic psel;
    logic penable;
    logic pwrite;
    logic[7:0] paddr;
    logic[7:0] pwdata;
    logic pready;
    logic pslverr;

    modport drv(
        output psel,
        output penable,
        output pwrite,
        output paddr,
        output pwdata,
        input pready,
        input pslverr,
        input clk,
        input rst_n
    );

endinterface