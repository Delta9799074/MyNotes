`timescale 1ns/1ps
module array(
    input logic clk,
    input logic rst,
    input logic [31:0] w_data,
    input logic [11:0] w_addr,
    input logic [11:0] r_addr,
    output logic [31:0] r_data
);
parameter ADDR_SIZE = 4096 , WORD_SIZE = 32;
logic [WORD_SIZE-1:0] my_array [ADDR_SIZE - 1:0];
//integer i;
always_ff @(posedge clk) begin
    if (~rst) begin
        my_array[w_addr] <= 32'h0;
    end
    else begin
        my_array[w_addr] <= w_data;
    end
end

assign r_data = my_array[r_addr];

endmodule
