//---------------------------------------------------------------
// Proiect    : Electronica Digitala
//              Carte de invatatura
// Autor      : Dan NICULA 
// An         : 2025
//---------------------------------------------------------------
// Descriere  : Generator de semnal de ceas si 
//              de reset asincron (sincronizat, activ 0)
//---------------------------------------------------------------

module ck_rst_tb #(
parameter CK_SEMIPERIOD = 'd5 // semi-perioada ceas
)(
output reg clk              , // ceas
output reg rst_n              // reset asincron, activ 0
);  

initial begin
  clk = 1'b0;             // valoare initiala 0
  forever #CK_SEMIPERIOD  // valoare complementata 
    clk = ~clk;           // la fiecare semi-perioada
end

initial begin
  rst_n <= 1'b0;    // initial inactiv
  @(posedge clk);
  rst_n <= 1'b0;    // activare sincrona
  @(posedge clk);
  @(posedge clk);
  rst_n <= 1'b1;    // inactivare dupa doua perioade de ceas
  @(posedge clk);   // ramane inactiv pentru totdeauna
end

endmodule // ck_rst_tb
