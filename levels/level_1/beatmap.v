
`timescale 1ns / 1ps

module beatmap(
    input [2:0] addr,
    output reg [7:0] notes

    );
    always @*
        case(addr)
            3'b000 :    data = 8'b00111100; 
            3'b001 :    data = 8'b01111110;
            3'b010 :    data = 8'b11111111; 
            3'b011 :    data = 8'b11111111; 
            3'b100 :    data = 8'b11111111;
            3'b101 :    data = 8'b11111111; 
            3'b110 :    data = 8'b01111110; 
            3'b111 :    data = 8'b00111100; 
        endcase
    
endmodule