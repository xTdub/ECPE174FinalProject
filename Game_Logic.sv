/***************************************************************
 * Game Logic
 * 
 * Top level entity, controls if game is playing, paused, not
 * yet started, point made, etc. Also, determines what the 
 * current level of game is.
 * 
 * Project: ECPE 174: Advanced Digital Design Final Project
 * Author:Jennifer Valencia
 * Date: 2013-11-08
 ***************************************************************/
 module Game_Logic(input logic clk,game_on,reset, input logic joystickup1, joystickup2, joystickdown1,joystickdown2, wrapping,
					   output logic [2:0] P1Total, P2Total, output logic LCD_E, LCD_RS, LCD_RW, LCD_ON, output logic [7:0] LCD_DB, input logic [1:0] diff1, diff2, 
						output I2C_SCLK, inout I2C_SDAT, output AUD_XCK, input AUD_DACLRCK, input AUD_ADCLRCK, input AUD_BCLK,
						input AUD_ADCDAT, output AUD_DACDAT, output logic vga_clk, vga_h_sync, vga_v_sync, vga_n_sync, vga_n_blank, 
						vgaRed, vgaBlue, vgaGreen,output logic [3:0] cnt);
						
//missing (wires)	ball: paddle_position1, paddle_position2
//						audio: point, win
//						score: P1Point, P2Point
//						compPlayer: position
			
 logic rst;
 logic gameOn;
 logic lvl_up;
 logic [2:0] level;
 logic playerPoint1, playerPoint2, wallHit, paddleHit;
 int compPosition1, compPosition2, ballx, bally;
 logic ball_clk;
 logic rstball;
 logic start_ball_dir;
 
 //assign cnt = {joystickup1,joystickdown1,joystickup2,joystickdown2};
 
 hclockdiv ballc(.iclk(clk),.oclk(ball_clk));
 
 compPlayer computer1(.ballY(bally), .reset(rst), .diff(diff1), .game_on(gameOn), .clk(clk), .humanUp(~joystickup1), .humanDown(~joystickdown1), .wrapping(wrapping),
                      .position(compPosition1),.moving_up(cnt[3]),.moving_down(cnt[2]));
 
 compPlayer computer2(.ballY(bally), .reset(rst), .diff(diff2), .game_on(gameOn), .clk(clk), .humanUp(~joystickup2), .humanDown(~joystickdown2), .wrapping(wrapping),
                      .position(compPosition2),.moving_up(cnt[1]),.moving_down(cnt[0]));
	
	//logic wrap = 0;
	//logic 
 //Paddle2 p1(.clk(clk),.up(joystickup1),.down(joystickdown1),.reset(rst),.game_on(game_on),.wrap_mode(1'b0),.ticks_per_px(200000),.position(compPosition1));
 //Paddle2 p2(.clk(clk),.up(joystickup2),.down(joystickdown2),.reset(rst),.game_on(game_on),.wrap_mode(1'b0),.ticks_per_px(200000),.position(compPosition2));
				
 Ball gameball(.clk(ball_clk), .reset(rstball),.game_on(gameOn), .paddle_position1(compPosition1), .paddle_position2(compPosition2), .dir(start_ball_dir), .lvl(level),
					.ball_x(ballx), .ball_y(bally), .wall_hit(wallHit), .paddle_hit(paddleHit), .player1_point(playerPoint1), .player2_point(playerPoint2));

 /*Audio sound(.wall_hit(wallHit), .paddle_hit(paddleHit), .point(playerPoint1 | playerPoint2), .win(P1Total | P2Total == 7), .lvl_up(lvl_up), .clk(clk),
				 .rst(rst), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT), .AUD_XCK(AUD_XCK), .AUD_DACLRCK(AUD_DACLRCK), .AUD_ADCLRCK(AUD_ADCLRCK), 
				 .AUD_BCLK(AUD_BCLK), .AUD_ADCDAT(AUD_ADCDAT), .AUD_DACDAT(AUD_DACDAT));*/

 Score points(.clk(clk), .reset(rst), .Level(level), .P1Point(playerPoint1), .P2Point(playerPoint2), .P1Type(diff1), .P2Type(diff2),
              .P1Total(P1Total), .P2Total(P2Total), .E(LCD_E), .RS(LCD_RS), .RW(LCD_RW), .ON(LCD_ON), .DB(LCD_DB)); 
				  
 int VGA_X, VGA_Y;
 logic disp_en;
 vga vga1(.clk50(clk),.H_SYNC(vga_h_sync),.V_SYNC(vga_v_sync),.N_SYNC(vga_n_sync),.N_BLANK(vga_n_blank),.VGA_CLOCK(vga_clk),.DISP_EN(disp_en),.XPOS(VGA_X),.YPOS(VGA_Y));
 display disp1(.VGA_CLOCK(vga_clk),.XPOS(VGA_X),.YPOS(VGA_Y),.DISP_EN(disp_en),.R(vgaRed),.B(vgaBlue),.G(vgaGreen),.PADDLE1Y(compPosition1),.PADDLE2Y(compPosition2),.BALLX(ballx),.BALLY(bally));
										  
	assign start_ball_dir = P1Total & P2Total;
// if someone wins level up! also make level up sound							  
	always_ff @ (posedge clk or negedge reset) begin
		if (!reset) begin
			rst <= 1'b0;
			rstball <= 1'b0;
			gameOn <= 1'b1;
			level <= 3'b0;
		end
	
		else begin
			rst <= 1'b1;
			if(playerPoint1 || playerPoint2)
			begin
				rstball <= 1'b0;
			end else begin
				rstball <= 1'b1;
			end
			if (game_on && (P1Total == 7 || P2Total == 7)) begin
				rst <= 1'b0;
				lvl_up <= 1'b1;
				level <= level + 1'b1;
				gameOn <= 1'b1;
			end
		
			else if (game_on <= 1'b0) begin
				rst <= 1'b1;
				lvl_up <= 1'b1;
				gameOn <= 1'b0;
			end
			else begin
				rst <= 1'b1;
				lvl_up <= 1'b1;
				gameOn <= 1'b1;
			end
		end
	
	end	
					
endmodule
