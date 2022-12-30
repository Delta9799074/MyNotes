module my_top(
    input wire clk, 
    input wire rst, 
    input wire[31:0] w_data, 
    input wire[11:0] w_addr,
    input wire[11:0] r_addr, 
    output wire[31:0] r_data,
    input wire [9:0] csel);
    genvar i;
    wire [31:0] r_data_array[9:0];
    generate
        for (i = 0; i < 10 ; i = i+1) begin
            array array( 
                .clk    (clk   ), 
                .rst    (rst & csel[i]  ), 
                .w_data (w_data & {32{csel[i]}}), 
                .w_addr (w_addr & {12{csel[i]}}), 
                .r_addr (r_addr & {12{csel[i]}}), 
                .r_data (r_data_array[i]) );
        end    
    endgenerate
reg [5:0] read_sel;
always@(posedge clk)begin
    case(csel)
    10'b00000_00001: read_sel <= 0;
    10'b00000_00010: read_sel <= 1;
    10'b00000_00100: read_sel <= 2;
    10'b00000_01000: read_sel <= 3;
    10'b00000_10000: read_sel <= 4;
    10'b00001_00000: read_sel <= 5;
    10'b00010_00000: read_sel <= 6;
    10'b00100_00000: read_sel <= 7;
    10'b01000_00000: read_sel <= 8;
    10'b10000_00000: read_sel <= 9;
    endcase
end
    assign r_data = r_data_array[read_sel];
endmodule