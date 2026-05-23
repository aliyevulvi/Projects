`timescale 1ns/1ps

module processor_tb;

  // Instantiate the processor under test
  processor uut();

  initial begin
    $dumpfile("processor_tb.vcd");
    $dumpvars(0, processor_tb);

    // Wait enough time for the processor internal simulation to run
    #500;
    $display("Simulation finished.");
    $finish;
  end

endmodule
