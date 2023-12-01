


module song (clk, reset, start, notes_out)
    input clk;
    input reset;
    input index;
    output reg [3:0] notes_out;

    // parameter clock_freq = 50000000;
    reg [3:0] notes [0:999];
    // reg [25:0] counter; // to delay sending out notes, 1 per second

    reg [9:0] curr_note

    always @(posedge clk) begin
	    notes_out <= notes[index];
    end

    // always @(posedge clk) begin
    //     notes_out <= notes[curr_note];
    //     if (start)begin
    //         if (reset) counter <= 0;
    //         else if (counter == clock_freq-1) begin
    //             counter <= 0;
    //             curr_note <= curr_note + 1;
    //         end
    //         else begin
    //             counter <= counter +1;
    //         end
    //     end
    // end
    initial begin
        	notes[0] =  4'b0000;
            notes[1] =  4'b0000;
            notes[2] =  4'b0000;
            notes[3] =  4'b0000;
            notes[4] =  4'b0000;
            notes[5] =  4'b0000;
            notes[6] =  4'b0000;
            notes[7] =  4'b0000;
            notes[8] =  4'b0000;
            notes[1] =  4'b0000;
            notes[9] =  4'b0000;
            notes[10] = 4'b0000;
            notes[11] = 4'b0000;
            notes[12] = 4'b0000;
            notes[13] = 4'b0000;
            notes[14] = 4'b0000;
            notes[15] = 4'b0000;
            notes[16] = 4'b0010;
            notes[17] = 4'b0010;
            notes[18] = 4'b0000;
            notes[19] = 4'b0010;
            notes[20] = 4'b0001;
            notes[21] = 4'b0000;
            notes[22] = 4'b0001;
            notes[23] = 4'b0000;
            notes[24] = 4'b0100;
            notes[25] = 4'b0100;
            notes[26] = 4'b0000;
            notes[27] = 4'b0100;
            notes[28] = 4'b0100;
            notes[29] = 4'b0100;
            notes[30] = 4'b0000;
            notes[31] = 4'b0100;
            notes[32] = 4'b0010;
            notes[33] = 4'b0010;
            notes[34] = 4'b0000;
            notes[35] = 4'b0010;
            notes[36] = 4'b0001;
            notes[37] = 4'b0000;
            notes[38] = 4'b0001;
            notes[39] = 4'b0000;
            notes[40] = 4'b1000;
            notes[41] = 4'b1000;
            notes[42] = 4'b0000;
            notes[43] = 4'b1000;
            notes[44] = 4'b1000;
            notes[45] = 4'b1000;
            notes[46] = 4'b0000;
            notes[47] = 4'b0000;
            notes[48] = 4'b0010;
            notes[49] = 4'b0010;
            notes[50] = 4'b0000;
            notes[51] = 4'b0010;
            notes[52] = 4'b0001;
            notes[53] = 4'b0000;
            notes[54] = 4'b0001;
            notes[55] = 4'b0000;
            notes[56] = 4'b0100;
            notes[57] = 4'b0100;
            notes[58] = 4'b0000;
            notes[59] = 4'b0100;
            notes[60] = 4'b0100;
            notes[61] = 4'b0100;
            notes[62] = 4'b0000;
            notes[63] = 4'b0100;
            notes[64] = 4'b0010;
            notes[65] = 4'b0010;
            notes[66] = 4'b0000;
            notes[67] = 4'b0010;
            notes[68] = 4'b0000;
            notes[69] = 4'b0000;
            notes[70] = 4'b0001;
            notes[71] = 4'b0000;
            notes[72] = 4'b0010;
            notes[73] = 4'b0010;
            notes[74] = 4'b0010;
            notes[75] = 4'b0010;
            notes[76] = 4'b0100;
            notes[77] = 4'b0100;
            notes[78] = 4'b0100;
            notes[79] = 4'b0100;
            notes[80] = 4'b0010;
            notes[81] = 4'b0010;
            notes[82] = 4'b0000;
            notes[83] = 4'b0010;
            notes[84] = 4'b0001;
            notes[85] = 4'b0000;
            notes[86] = 4'b0001;
            notes[87] = 4'b0000;
            notes[88] = 4'b0100;
            notes[89] = 4'b0100;
            notes[90] = 4'b0000;
            notes[91] = 4'b0100;
            notes[92] = 4'b0100;
            notes[93] = 4'b0100;
            notes[94] = 4'b0000;
    end
endmodule