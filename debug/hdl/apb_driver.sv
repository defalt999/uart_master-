class apb_driver;

    virtual apb_interface.drv drv;

    function new(virtual apb_interface.drv vif);
        this.drv = vif;
    endfunction


    task run();
     drv.psel <= 1'd0;
     drv.penable <= 1'd0;
     drv.pwrite <= 1'd0;
     drv.paddr <= 'd0;
     drv.pwdata <= 'd0;
    endtask
    task drive(input [7:0] addr, input [7:0] data);

        wait (drv.rst_n == 1'b1);

        drv.psel   <= 1'b1;
        drv.paddr  <= addr;
        drv.pwdata <= data;
        drv.pwrite <= 1'b1;

        @(posedge drv.clk);
        drv.penable <= 1'b1;

        @(posedge drv.clk);
        drv.psel    <= 1'b0;
        drv.penable <= 1'b0;
        drv.paddr   <= '0;
        drv.pwdata  <= '0;

    endtask

endclass : apb_driver