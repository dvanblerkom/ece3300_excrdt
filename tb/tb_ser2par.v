`timescale 1ns/1ps

module tb_ser2par;

    // Parameters
    parameter WORD_SIZE = 8;

    // Testbench signals
    reg clk;
    reg reset;
    reg serial_in;
    reg lsb_in;
   reg	test_fail;
   reg [WORD_SIZE:0] testdata, grab_data, checkdata;
    wire [WORD_SIZE-1:0] parallel_out;
    wire valid;
   reg	 new_data = 0;
   

    // Instantiate the DUT (Device Under Test)
    Ser2Par #(WORD_SIZE) uut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .lsb_in(lsb_in),
        .parallel_out(parallel_out),
        .valid(valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test stimulus
    initial begin
        // Initialize signals
       reset = 1;
       serial_in = 0;
       lsb_in = 0;

        // Apply reset
       #10;
       reset = 0;

        // Wait a few clock cycles
       @(posedge clk) lsb_in = 0;
       @(posedge clk);


       for (testdata = 0; testdata <= 255; testdata = testdata + 19) begin
        // lsb_in asserted on the last bit
          send_serial_data(testdata[WORD_SIZE-1:0]);

        // Wait a clock cycle and check the value
	  @(posedge clk) lsb_in <= 0;
	  @(posedge clk);
       end

        // Finish simulation
       #10000;
       $finish_and_return(test_fail | (checkdata < 255));  
    end

   always @(posedge clk)
     if (valid) begin
	grab_data <= parallel_out;
	new_data <= 1;
     end else begin
	new_data <= 0;
     end
   
   initial begin
        // Initialize signals
       test_fail = 0;

        // Wait a few clock cycles
       @(posedge clk);
       @(posedge clk);

       for (checkdata = 0; checkdata <= 255; checkdata = checkdata + 19) begin
        // lsb_in asserted on the last bit

        // Wait a clock cycle and check the value
	  @(posedge new_data);
	  if (grab_data != checkdata[WORD_SIZE-1:0]) test_fail = 1;
       end

        // Finish simulation
       @(posedge clk);
       @(posedge clk);

    end
   
    // Task to send serial data with LSB indication
    task send_serial_data(input [WORD_SIZE-1:0] data);
        integer i;
        begin
            for (i = 0; i < WORD_SIZE; i = i + 1) begin
	       @(posedge clk);
                serial_in <= data[WORD_SIZE-1-i];
                lsb_in <= (i == WORD_SIZE-1) ? 1 : 0; // Assert LSB signal on the last bit
            end
        end
    endtask

    // Monitor outputs
   always @(posedge clk)
     begin
	$display("Time: %0dns, Serial_in: %b, Lsb_in: %b, Parallel_Out: %8h, Valid: %b, test_fail: %b",
		 $time, serial_in, lsb_in, parallel_out, valid, test_fail);
     end
   
//    initial begin
//        $monitor("Time: %0dns, ParallelOut: %b, Valid: %b",
//                 $time, parallel_out, valid);
//    end

//   initial begin
//       $dumpfile("tb_ser2par.vcd");
//       $dumpvars(0,tb_ser2par);
//    end

endmodule
