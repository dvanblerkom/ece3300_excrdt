`timescale 1ns/1ps

//
// Complete the Ser2Par design, as described in the README file
//

module Ser2Par #(parameter WORD_SIZE = 8) (
    input clk,          // Clock signal
    input reset,        // Reset signal
    input serial_in,    // Serial data input
    input lsb_in,       // Signal to indicate LSB
    output reg [WORD_SIZE-1:0] parallel_out, // Parallelized word output
    output reg valid         // Valid signal to indicate output ready
);


// add your verilog here
   
endmodule
