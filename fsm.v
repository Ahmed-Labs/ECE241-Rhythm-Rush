module fsm(input Clk, reset, mouseClick, keyPressed, accurate, noMoreLives, finishSong, output z);
    reg[3:0] presentState, nextState; //present and next states
    localparam mainMenu = 4'b0000, 
					mainMenu_wait = 4'b0001,
					selectDiff = 4'b0010, 
					selectDiff_wait = 4'b0011,
					loadLevel = 4'b0100,
					loadLevel_wait = 4'b0101,
					idle = 4'b0110, 
					hit = 4'b0111, 
					miss = 4'b1000, 
					win = 4'b1001,
					win_wait = 4'b1010,
					lose = 4'b1011,
					lose_wait = 4'b1100;

    always @(*)
        begin
            case (presentState)
                mainMenu: if (mouseClick) nextState = mainMenu_wait; 
				mainMenu_wait: if (!mouseClick) nextState = selectDiff; 
								
				selectDiff: if (mouseClick) nextState = selectDiff_wait; 
				selectDiff_wait: if (!mouseClick) nextState = loadLevel;
								
				loadLevel: if (mouseClick) nextState = loadLevel_wait; 
				loadLevel_wait: if (!mouseClick) nextState = idle; 
					 
                idle: if (keyPressed & accurate & !noMoreLives & !finishSong) nextState = hit; 
                    else if (keyPressed & !accurate & !noMoreLives & !finishSong) nextState = miss;
                    else if (finishSong & !noMoreLives) nextState = win;  
                    else if (noMoreLives) nextState = lose; 
						  
                hit: if (!keyPressed) nextState = idle; 
                    else if (keyPressed & !accurate) nextState = miss; 
						  
                miss: if (keyPressed & accurate & !noMoreLives) nextState = hit; 
							else if (!keyPressed | noMoreLives) nextState = idle;
							
						  
                win: if (mouseClick) nextState = win_wait; 
					 win_wait: if (!mouseClick) nextState = mainMenu;
					 
                lose: if (mouseClick) nextState = lose_wait;
					 lose_wait: if (!mouseClick) nextState = mainMenu;
									
                default: nextState = mainMenu;
            endcase
        end

    //state register
    always @(posedge Clk)
        begin
            if(!reset)
                presentState <= mainMenu;
            else
                presentState <= nextState;

        end
		  
    assign z = ((presentState == win_wait)|(presentState == lose_wait));
		  
		  
//	// combinational logic block for Mealy FSM
//    always @(*)
//        begin
//            case (presentState)
//                mainMenu: z = 0;
//					 mainMenu_wait: if (!mouseClick) z = 1; else z = 0;
//					 
//					 selectDiff: z = 0;
//					 selectDiff_wait: if (!mouseClick) z = 1; else z = 0;
//					 
//                loadLevel: z = 0;
//					 loadLevel_wait: if (!mouseClick) z = 1; else z = 0;
//					 
//                idle: z = 0;
//                hit: z = 0;
//                miss: z = 0;
//					 
//                win: z = 0; 
//					 win_wait: if (!mouseClick) z = 1; else z = 0;
//                lose: z = 0;
//					 lose_wait: if (!mouseClick) z = 1; else z = 0;
//					 
//                default: z = 0;
//            endcase
//        end

    always @(*)
        begin
            // set all signals to 0
            setClick = 1'b0;
            setKeyPress = 1'b0;
            setSwitchDiff = 1'b0; //to store the difficulty selected by the switch
            setScore = 1'b0;
            setLives = 1'b0;
            setStreak = 1'b0;
            changeScore = 1'b0;
            loseLife = 1'b0;
            changeStreak = 1'b0;
            hitNote = 1'b0; //if the note was hit accurately
            endOfSong = 1'b0;

            case (presentState)
            
                mainMenu: begin
                    setClick = 1'b1;
                end
                mainMenu_wait: begin
                    setClick = 1'b1;
                end

                selectDiff: begin 
                    setClick = 1'b1;
                    setSwitchDiff = 1'b1;
                end
                selectDiff_wait: begin
                    setClick = 1'b1;
                end

                loadLevel: begin
                    setClick = 1'b1;
                    setScore = 1'b1;
                    setLives = 1'b1;
                    setStreak = 1'b1;
                end
                loadLevel_wait: begin
                    setClick = 1'b1;
                end

                //gameplay
                idle: begin
                    setKeyPress = 1'b1;
                    hitNote = 1'b1;
                    changeScore = 1'b1;
                    endOfSong = 1'b1;
                end
                hit: begin
                    setKeyPress = 1'b1;
                    hitNote = 1'b1;
                    changeStreak = 1'b1;
                end
                miss: begin
                    setKeyPress = 1'b1;
                    hitNote = 1'b1;
                    loseLife = 1'b1;
                end

                //terminating screens
                win: begin
                    setClick = 1'b1;
                end
                win_wait: begin
                    setClick = 1'b1;
                end

                lose: begin
                    setClick = 1'b1;
                end
                lose_wait: begin
                    setClick = 1'b1;
                end
        end


endmodule