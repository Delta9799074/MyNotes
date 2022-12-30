module my_top_top(
    input wire clk, 
    input wire rst, 
    input wire[31:0] w_data, 
    input wire[11:0] w_addr,
    input wire[11:0] r_addr, 
    output reg[31:0] r_data,
    input wire [39:0] top_csel);
    genvar i;
    wire [31:0] r_data_top_array[3:0];
    wire [3:0] top_sel;
    assign top_sel[0] = |top_csel[9:0];
    assign top_sel[1] = |top_csel[19:10];
    assign top_sel[2] = |top_csel[29:20];
    assign top_sel[3] = |top_csel[39:30];

    generate
        for (i = 0; i < 4 ; i = i+1) begin
            my_top my_top(
                .clk(clk), 
                .rst(rst & top_sel[i]), 
                .w_data(w_data & {32{top_sel[i]}}), 
                .w_addr(w_addr & {12{top_sel[i]}}),
                .r_addr(r_addr & {12{top_sel[i]}}), 
                .r_data(r_data_top_array[i]),
                .csel(top_csel[(9+i*10) : (0+i*10)])
            );
        end    
    endgenerate
    
    always@(*)begin
        case(top_sel)
            4'b0001: r_data = r_data_top_array[0];
            4'b0010: r_data = r_data_top_array[1];
            4'b0100: r_data = r_data_top_array[2];
            4'b1000: r_data = r_data_top_array[3];
            default : r_data = r_data_top_array[0];
        endcase
    end
endmodule