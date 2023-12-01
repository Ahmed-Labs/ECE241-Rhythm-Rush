module display
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [8:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		defparam VGA.BACKGROUND_IMAGE = "main_menu.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	parameter CLOCK_SPEED = 50_000_000;

	// Colours
	parameter RED = 9'b111000000;
	parameter BLUE = 9'b000000111;
	parameter WHITE = 9'b111111111;
	parameter BG_COLOUR =  9'b000000000; // Black for now


	reg start_song = 0; // signal to start animation + song audio

	reg [10:0] song_idx = 0;
	wire [3:0] curr_note; // pull current note from song rom
	// wire store_note; // pulse to store current note 
	reg [5:0] dy = 6'd0; // 0->50px


	song s1(.clk(CLOCK_50), .reset(resetn), .index(song_idx), .notes_out(curr_note));
	note_col #(.x_border(80))  c1 (.clk(CLOCK_50), .col_note(curr_note[3]), .note_colour(BLUE), .dy(dy));
	note_col #(.x_border(120)) c2 (.clk(CLOCK_50), .col_note(curr_note[2]), .note_colour(RED), .dy(dy));
	note_col #(.x_border(160)) c3 (.clk(CLOCK_50), .col_note(curr_note[1]), .note_colour(BLUE), .dy(dy));
	note_col #(.x_border(200)) c4 (.clk(CLOCK_50), .col_note(curr_note[0]), .note_colour(RED), .dy(dy));

	// Frame Counters

	// Pulse every 1/60th second (period of 60Hz VGA)
	reg [19:0] delay_counter;
	parameter HZ_DELAY = CLOCK_SPEED / 60;
	wire dcounter_en;
	assign dcounter_en = delay_counter == HZ_DELAY;
	assign writeEn = dcounter_en; 

	//Track number of frames to control speed of movement
	// move 1 pixel every 15 frames
	reg [3:0] frame_counter;
	parameter N_FRAMES = 15;

	always @(posedge CLOCK_50) begin
		if (resetn || !start_song) begin 
			delay_counter <= 0;
			frame_counter <= 0;
			song_idx <= 0;
			dy <= 0;
		end
		else begin
			if (delay_counter == HZ_DELAY) delay_counter <= 0;
			else delay_counter <= delay_counter + 1;

			if (dcounter_en) begin
				if (frame_counter == N_FRAMES-1) begin
					dy <= dy+1; // 1px vertical displacement per 15 frames
					frame_counter <= 0;
				end 
				else frame_counter <= frame_counter + 1;
			end
		end
		if (dy == 50)begin
			song_idx <= song_idx + 1;
		end
	end

endmodule

module note_col #(parameter x_border)(
	input clk,
	input col_note,
	input [8:0] note_colour,
	input [5:0] dy,
	output reg [8:0] rgb
	)
	// Column divided into 4 rows
	reg [3:0] note_row_en = 4'b0; // MSB = top box
	parameter BG_COLOUR =  9'b000000000;

	always @(posedge clk)begin
		if (dy == 50)begin
			dy <= 0;
			note_row_en <= {col_note, note_row_en[3:1]}
		end
	end

	always@(*)begin
		if (x >= x_border-1 && x < x_border+40) begin
			rgb = BG_COLOUR;
			if (note_row_en[3] && y >= (3*50)+dy-1 && y <= (3*50)+40+dy) rgb = note_colour;
			if (note_row_en[2] && y >= (2*50)+dy-1 && y <= (2*50)+40+dy) rgb = note_colour;
			if (note_row_en[1] && y >= (1*50)+dy-1 && y <= (1*50)+40+dy) rgb = note_colour;
			if (note_row_en[0] && y >= dy && y <= 40+dy) rgb = note_colour;
		end
	end

endmodule

module pixel_gen_control(
	input clk,
	input reset,
	input done
)
    reg [2:0] current_state, next_state;

    localparam  IDLE        	= 3'd0,
				IDLE_WAIT    	= 3'd1,
                PIXEL_GEN       = 3'd2,
				PLOT_GAME_OVER  = 3'd3;
	
	always@(*)
	begin: 
	 case(current_state)
	 	IDLE: next_state = dcounter_en ? IDLE_WAIT : IDLE;
		IDLE_WAIT: next_state = dcounter_en ? IDLE_WAIT : PIXEL_GEN;
		PIXEL_GEN: next_state = done ? IDLE : PIXEL_GEN;
		PLOT_GAME_OVER: next_state = 
		default: next_state = IDLE;
	 endcase
	end

	always @(*)
	begin:
		plot = 1'b0;

		case(current_state)
			PIXEL_GEN: begin
				plot = 1'b1;
			end
			PLOT_GAME_OVER: begin
				plot = 1'b1;
				gameover_rgb_en = 1'b1;
			end
		endcase	
	end
	
	always@(posedge clk)
    begin: state_FFs
        if(!Reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
endmodule

module pixel_gen #(parameter X_SCREEN_PIXELS, parameter Y_SCREEN_PIXELS)(
	input clk,
	input reset,
	output done,
	output [8:0] rgb
)
	reg [8:0] x_count;
	reg [7:0] y_count;
	// Colours
	parameter RED = 9'b111000000;
	parameter BLUE = 9'b000000111;
	parameter WHITE = 9'b111111111;
	parameter BG_COLOUR =  9'b000000000; // Black for now

	always @(posedge clk) begin
	  if (reset) begin
            x_count <= 9'b0;
			y_count <= 8'b0;
            done <= 0;
         end
      else if (plot)begin
         if (x_count == X_SCREEN_PIXELS && y_count == Y_SCREEN_PIXELS)begin
            done <= 1;
            x_count <= 9'b0;
            y_count <= 8'b0;
         end
         else begin
			if (!done) begin
               if (x_count < X_SCREEN_PIXELS) x_count <= x_count+1;
               else begin
                  y_count <= y_count+1;
                  x_count <= 9'b0;
               end
			end
         end

      end

	end

	Background BG (.address(addr), .clock);
	Gameover GO (.address(addr), .clock);

endmodule
