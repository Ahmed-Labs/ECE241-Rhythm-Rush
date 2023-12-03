module display
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		SW,
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
	input 	[7:0] 	SW;	
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
	// reg toggleBuffer = 0;

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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	// Clock Freq
	parameter CLOCK_SPEED = 50000000;

	// ----- Colours ----- 
	parameter RED = 9'b111000000;
	parameter BLUE = 9'b000000111;
	parameter WHITE = 9'b111111111;
	parameter BG_COLOUR =  9'b000000000;


	wire start_song; // signal to start animation + song audio
	assign start_song = SW[7];

	reg [5:0] song_idx = 6'b0; // index of current note in song rom
	wire [3:0] curr_note; // pull current note from song rom

	reg [5:0] dy = 6'b0; // Vertical displacement of blocks: 0->50px
	
	// pixel gen control & signals
    wire col_en_1, col_en_2, col_en_3, col_en_4;
	wire [8:0] game_rgb_1;
    wire [8:0] game_rgb_2;
    wire [8:0] game_rgb_3;
    wire [8:0] game_rgb_4;
    wire [8:0] game_rgb = col_en_1 ? game_rgb_1 : (col_en_2? game_rgb_2: (col_en_3 ? game_rgb_3 : (col_en_4 ? game_rgb_4 : BG_COLOUR)));
	wire main_menu, gameover, done;
	reg dcounter_en;
	
	pixel_gen_control PGC (.clk(CLOCK_50), .reset(resetn), .dcounter_en(dcounter_en), 
		.done(done), .main_menu(main_menu), .gameover(gameover), .writeEn(writeEn));
	// pixel gen
	pixel_gen #(.X_SCREEN_PIXELS(320), .Y_SCREEN_PIXELS(240)) PG (.clk(CLOCK_50), .reset(resetn), .game_rgb(game_rgb), .main_menu(main_menu), .gameover(gameover), 
		.writeEn(writeEn), .x_count(x), .y_count(y), .colour(colour), .done(done));
	
	song s1(.clk(CLOCK_50), .reset(resetn), .index(song_idx), .notes_out(curr_note));
	note_col #(.x_border(80))  c1 (.clk(CLOCK_50), .reset(resetn), .col_note(curr_note[3]), .note_colour(BLUE), .dy(dy), .x(x), .y(y), .col_en(col_en_1), .game_rgb(game_rgb_1));
	note_col #(.x_border(120)) c2 (.clk(CLOCK_50), .reset(resetn), .col_note(curr_note[2]), .note_colour(RED), .dy(dy), .x(x), .y(y), .col_en(col_en_2), .game_rgb(game_rgb_2));
	note_col #(.x_border(160)) c3 (.clk(CLOCK_50), .reset(resetn), .col_note(curr_note[1]), .note_colour(BLUE), .dy(dy), .x(x), .y(y), .col_en(col_en_3), .game_rgb(game_rgb_3));
	note_col #(.x_border(200)) c4 (.clk(CLOCK_50), .reset(resetn), .col_note(curr_note[0]), .note_colour(RED), .dy(dy), .x(x), .y(y), .col_en(col_en_4), .game_rgb(game_rgb_4));

	// ------- Frame Counters ------- 

	// Pulse every 1/60th second (period of 60Hz VGA)
	reg [19:0] delay_counter;
	parameter HZ_DELAY = CLOCK_SPEED / 60;
	
	//assign dcounter_en = delay_counter == HZ_DELAY;
	// assign writeEn = dcounter_en; 

	//Track number of frames to control speed of movement
	// move 1 pixel every 15 frames
	reg [3:0] frame_counter;
	parameter N_FRAMES = 15;
	parameter num_px = 1;

	always @(posedge CLOCK_50) begin
		if (resetn || !start_song) begin 
			delay_counter <= 20'b0;
			frame_counter <= 4'b0;
			song_idx <= 6'b0;
			dy <= 0;
			dcounter_en <= 0;
			// writeEn <= 0;
		end
		else begin
			if (delay_counter == HZ_DELAY) begin
				dcounter_en <= 1;
				delay_counter <= 0;
				// writeEn <= 1;
			end
			else begin
				dcounter_en <= 0;
				delay_counter <= delay_counter + 1;
			end

			if (delay_counter == HZ_DELAY) begin
				// toggleBuffer = !toggle_buffer;
				if (frame_counter == N_FRAMES-1) begin
					dy <= dy+num_px; // 1px vertical displacement per 15 frames (4px/s speed)
					frame_counter <= 0;
				end 
				else frame_counter <= frame_counter + 1;
			end
		end
		if (dy == 50-num_px) song_idx <= song_idx + 1;
		if (dy == 50)begin
			dy <= 0;
		end
	end

endmodule

module note_col #(parameter x_border)(
	input clk,
	input reset,
	input col_note,
	input [8:0] note_colour,
	input [5:0] dy,
	input [8:0] x,
	input [7:0] y,
	output reg col_en,
	output reg [8:0] game_rgb
	);
	// Column divided into 4 rows
	reg [3:0] note_row_en; // MSB = top box
	parameter BG_COLOUR =  9'b000000000;

	always @(posedge clk)begin
		if (reset) begin
			col_en <= 0;
			note_row_en <= {col_note, 3'b0};
		end
		else if (dy == 50)begin
			note_row_en <= {col_note, note_row_en[3:1]};
		end
	end

	always@(*)begin
        col_en = 1'b0;
		if ((x >= x_border-1 && x < x_border+40)) begin
			col_en = 1'b1;
			game_rgb = BG_COLOUR;
			if (note_row_en[0] && y >= (3*50)+dy-1 && y <= (3*50)+40+dy) game_rgb = note_colour;
			else if (note_row_en[1] && y >= (2*50)+dy-1 && y <= (2*50)+40+dy) game_rgb = note_colour;
			else if (note_row_en[2] && y >= (1*50)+dy-1 && y <= (1*50)+40+dy) game_rgb = note_colour;
			else if (note_row_en[3] && y >= dy && y <= 40+dy) game_rgb = note_colour;
        end
	end

endmodule

module pixel_gen_control(
	input clk,
	input reset,
	input dcounter_en,
	input done,
	output reg main_menu,
	output reg gameover,
	output reg writeEn
);
    reg [3:0] current_state, next_state;

    localparam  MAIN_MENU       = 3'd0,
				IDLE        	= 3'd1,
				IDLE_WAIT    	= 3'd2,
                PIXEL_GEN       = 3'd3,
				PLOT_GAME_OVER  = 3'd4;
	
	always@(*)
	begin
	 case(current_state)
	 	IDLE: next_state = gameover ? PLOT_GAME_OVER : (dcounter_en ? PIXEL_GEN : IDLE);
		IDLE_WAIT: next_state = gameover ? PLOT_GAME_OVER : (dcounter_en ? IDLE_WAIT : PIXEL_GEN);
		PIXEL_GEN: next_state = done ? IDLE : PIXEL_GEN;
		PLOT_GAME_OVER: next_state = done ? IDLE: PLOT_GAME_OVER; 
		default: next_state = IDLE;
	 endcase
	end

	always @(*)
	begin
		writeEn = 1'b0;
		gameover = 1'b0;
		main_menu = 1'b0;

		case(current_state)
			PIXEL_GEN: begin
				writeEn = 1'b1;
			end
			PLOT_GAME_OVER: begin
				writeEn = 1'b1;
				gameover = 1'b1;
			end
		endcase	
	end
	
	always@(posedge clk)
    begin
        if(reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
endmodule

module pixel_gen #(parameter X_SCREEN_PIXELS, parameter Y_SCREEN_PIXELS)(
	input clk,
	input reset,
	input [8:0] game_rgb,

	//screen signals
	input main_menu,
	input gameover,
	input writeEn,
	output reg [8:0] x_count,
	output reg [7:0] y_count,
	output reg [8:0] colour,
	output reg done
	// output toggle_buffer,
);
	// ----- Screens (memory) -----
	reg [16:0] memory_address;

	// wire [8:0] gameover_px;
	//gameover_ram g0 (.address(memory_address), .clock(clock), .q(gameover_px));
	wire [8:0] menu_px;
	main_menu_rom m0 (.address(memory_address), .clock(clock), .q(menu_px));

	always @(*)begin
		if (gameover) colour = 9'b0;
		else if (main_menu) colour = menu_px;
		else colour = game_rgb;
	end

	always @(posedge clk) begin
	  if (reset) begin
            x_count <= 9'b0;
			y_count <= 8'b0;
            done <= 0;
			// toggle_buffer <= 0;
			memory_address <= 17'b0;
         end
      else if (writeEn)begin
		 memory_address <= memory_address + 1;
         done <= 0;
         if (x_count == X_SCREEN_PIXELS && y_count == Y_SCREEN_PIXELS)begin
            done <= 1;
            x_count <= 9'b0;
            y_count <= 8'b0;
			// toggle_buffer <= !toggle_buffer;
			memory_address <= memory_address + 1;
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

endmodule