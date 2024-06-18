--VHDL VGA PONG demo
--An FPGA version of the classic pong game
--Score counts up to 9
--Right player uses buttons 0 and 1
--Left player uses Switch 0 (Much harder!)
--Button 2 resets the game and score

library ieee; use ieee.std_logic_1164.all; USE ieee.std_logic_arith.all;

entity FPGA_VGA is 
port (
	CLOCK_50 : in std_logic := '0';
	VGA_HS, VGA_VS	: out std_logic:= '0';
	VGA_R  : out std_logic_vector(3 downto 0) := "0000";
	VGA_G  : out std_logic_vector(3 downto 0):= "0000";
	VGA_B  : out std_logic_vector(3 downto 0):= "0000";
	SW     : in std_logic_vector(9 downto 0):= "0000000000";
	BUTTON : in std_logic_vector(3 downto 0):= "0000"
	
);
end entity FPGA_VGA;


architecture main of FPGA_VGA is

--Settable constants
constant paddle_speed : integer := 5;
constant default_ball_speed : integer := 3;

--Declare components
component vga_driver is port (
	vga_clk	: in std_logic;
	h_sync 	: out std_logic;
	v_sync 	: out std_logic;
	red	: out std_logic_vector(3 downto 0);
	green	: out std_logic_vector(3 downto 0);
	blue	: out std_logic_vector(3 downto 0);
	new_frame : out std_logic;
	-- Updated for 800x524
	current_h : out integer range 0 to 800:=0;
	current_v : out integer range 0 to 524:=0;
	red_in	 : in std_logic_vector(3 downto 0);
	green_in  : in std_logic_vector(3 downto 0);
	blue_in	 : in std_logic_vector(3 downto 0)
 );
 
end component vga_driver;

component vga_clk_pll is port (
	clk_in   : in  std_logic := '0'; 
	clk_out  : out std_logic  
);
end component vga_clk_pll;


 --VGA signals
signal vga_clk : std_logic:='0'; 
signal reset : std_logic:='0'; 
signal new_frame : std_logic:='0';
signal set_red, set_green, set_blue : std_logic_vector(3 downto 0):= (others => '0');
-- Updated for Different screen size
signal hpos : integer range 0 to 800:=0;
signal vpos : integer range 0 to 524:=0;

--Paddle Signals
signal paddle_h1 : integer range 165 to 794:= 167; -- Left Side
signal paddle_v1 : integer range 49 to 518:= 200;
signal paddle_h2 : integer range 165 to 794:= 769; -- Right Side
signal paddle_v2 : integer range 49 to 518:= 200;

--Score Signals
signal tick_h1_1 : integer range 165 to 794:= 167; -- Left Side 
signal tick_v1_1 : integer range 49 to 518:= 200;
signal tick_h1_2 : integer range 165 to 794:= 167; -- Left Side
signal tick_v1_2 : integer range 49 to 518:= 200;
signal tick_h1_3 : integer range 165 to 794:= 167; -- Left Side
signal tick_v1_3 : integer range 49 to 518:= 200;
signal tick_h1_4 : integer range 165 to 794:= 167; -- Left Side
signal tick_v1_4 : integer range 49 to 518:= 200;
signal tick_h1_5 : integer range 165 to 794:= 167; -- Left Side
signal tick_v1_5 : integer range 49 to 518:= 200;

signal tick_h2_1 : integer range 165 to 794:= 769; -- Right Side
signal tick_v2_1 : integer range 49 to 518:= 200;
signal tick_h2_2 : integer range 165 to 794:= 769; -- Right Side
signal tick_v2_2 : integer range 49 to 518:= 200;
signal tick_h2_3 : integer range 165 to 794:= 769; -- Right Side
signal tick_v2_3 : integer range 49 to 518:= 200;
signal tick_h2_4 : integer range 165 to 794:= 769; -- Right Side
signal tick_v2_4 : integer range 49 to 518:= 200;
signal tick_h2_5 : integer range 165 to 794:= 769; -- Right Side
signal tick_v2_5 : integer range 49 to 518:= 200;

--Ball signals
signal ball_pos_h1      : integer range 165 to 794:= (794-165)/2; -- Middle
signal ball_pos_v1      : integer range 49 to 518:= 260;          -- Middle
signal ball_up	  	: std_logic:= '0';
signal ball_right	: std_logic:= '1';
signal ball_speed_h 	: integer range 0 to 15:= default_ball_speed;
signal ball_speed_v	: integer range 0 to 15:= default_ball_speed;

--Score signals
signal right_player_score : integer range 0 to 10:= 0;
signal left_player_score  : integer range 0 to 10:= 0;

begin

	reset <= sw(1);
	pll1 :  vga_clk_pll port map (CLOCK_50, vga_clk);  --Generate a 25MHz MHz clk (actual result 147.22MHz)
	
	--Instantiate 2 seven segment displays. One to show each players score


	--Instantiate VGA driver. This Deals with H and V sync timings
	--New frame goes high for one clock cycle at the start of every frame. This can be used to redraw animations
	--current_h and current_v give the coordinates of the current pixel as they are scanned out.
	vga1 : vga_driver port map (
		vga_clk	 => vga_clk,
		h_sync 	 => VGA_HS,
		v_sync 	 => VGA_VS,
		red	 => VGA_R,
		green	 => VGA_G,
		blue	 => VGA_B,
		new_frame => new_frame,
		current_h => hpos,
		current_v => vpos,
		red_in	 => set_red,
		green_in  => set_green,
		blue_in	 => set_blue
 );

 
--Draws the left and right paddles
draw_paddle : process (vga_clk) 
begin
 
	if (rising_edge(vga_clk)) then
		--Paddles are 15 x 80 pixels
		if ( (hpos >= paddle_h1 and hpos < paddle_h1 + 15) and (vpos >= paddle_v1 and vpos < paddle_v1 + 80) ) then
			set_red <= X"F";
		elsif ( (hpos >= paddle_h2 and hpos < paddle_h2 + 15) and (vpos >= paddle_v2 and vpos < paddle_v2 + 80) ) then
			set_red <= X"F";
		elsepa
			set_red <= X"0";
		end if;
		
	end if;
		 
end process;

--Draws the left and right scores
draw_score : process (vga_clk) 
begin
 
	if (rising_edge(vga_clk)) then
		--Scores are from 0 to 5, displayed as 5 by 20 tick marks
		if (left_player_score > 0) then 
			if ( (hpos >= 250 and hpos < 250 + 5) and (vpos >= 250 and vpos < 250 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		if (left_player_score > 1) then 
			if ( (hpos >= 260 and hpos < 260 + 5) and (vpos >= 250 and vpos < 250 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		if (left_player_score > 2) then 
			if ( (hpos >= 270 and hpos < 270 + 5) and (vpos >= 250 and vpos < 250 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		if (left_player_score > 3) then 
			if ( (hpos >= 280 and hpos < 280 + 5) and (vpos >= 250 and vpos < 250 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		if (left_player_score > 4) then 
			if ( (hpos >= 290 and hpos < 290 + 5) and (vpos >= 250 and vpos < 250 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		--right score
		if (right_player_score > 0) then 
			if ( (hpos >= tick_h2 and hpos < tick_h2 + 5) and (vpos >= tick_v2 and vpos < tick_v2 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		if (right_player_score > 1) then 
			if ( (hpos >= tick_h2 and hpos < tick_h2 + 5) and (vpos >= tick_v2 and vpos < tick_v2 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		if (right_player_score > 2) then 
			if ( (hpos >= tick_h2 and hpos < tick_h2 + 5) and (vpos >= tick_v2 and vpos < tick_v2 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
		if (right_player_score > 3) then 
			if ( (hpos >= tick_h2 and hpos < tick_h2 + 5) and (vpos >= tick_v2 and vpos < tick_v2 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
		
		if (left_player_score > 4) then 
			if ( (hpos >= tick_h2 and hpos < tick_h2 + 5) and (vpos >= tick_v2 and vpos < tick_v2 + 20) ) then
				set_green <= X"F";
			end if;
		end if;
				
				
	end if;
		 
end process;

--Draws the ball
draw_ball : process (vga_clk) 
begin
 
	if (rising_edge(vga_clk)) then
		--The ball is 15 x 15 pixels
		if ( (hpos >= ball_pos_h1 and hpos < ball_pos_h1 + 5) and (vpos >= ball_pos_v1 and vpos < ball_pos_v1 + 15) ) then
			set_blue <= X"F";
		elsif ( (hpos >= ball_pos_h1 and hpos < ball_pos_h1 + 10) and (vpos >= ball_pos_v1 + 3 and vpos < ball_pos_v1 + 12) ) then
			set_blue <= X"F";
		elsif ( (hpos >= ball_pos_h1 and hpos < ball_pos_h1 + 15) and (vpos >= ball_pos_v1 + 6 and vpos < ball_pos_v1 + 9) ) then
			set_blue <= X"F";
		else
			set_blue <= X"0";
		end if;
		
	end if;
		 
end process;

--Moves the paddles based on user input
--There are only 3 buttons on the DE0 development board, so a switch is used for one player. 
--This makes it a bit fiddly to play as the paddles are always moving
move_paddle : process (vga_clk) 
begin
 
	if (rising_edge(vga_clk) and new_frame = '1') then
		
		--Right Player Controls
		if (BUTTON(0) = '0') then  --When switch is in up position move paddle down --sw(0) = '0' 
			if (paddle_v2 < 438) then
				paddle_v2 <= paddle_v2 + paddle_speed;
			else
				paddle_v2 <= paddle_v2;		--If at the top then dont move paddle any higher
			end if;
		elsif ( BUTTON(1) = '0') then  --When switch is in down position move paddle up --sw(0) = '1' or
			if (paddle_v2 > 49) then
				paddle_v2 <= paddle_v2 - paddle_speed;
			else
				paddle_v2 <= paddle_v2;  --If at the bottom then don't move paddle any lower
			end if;
		end if;
		
		--Left Player Controls
		if (BUTTON(2) = '0') then
			if (paddle_v1 < 438) then
				paddle_v1 <= paddle_v1 + paddle_speed;
			else
				paddle_v1 <= paddle_v1;
			end if;
		elsif (BUTTON(3) = '0') then
			if (paddle_v1 > 49) then
				paddle_v1 <= paddle_v1 - paddle_speed;
			else
				paddle_v1 <= paddle_v1;
			end if;
		end if;
			
	end if;
		 
end process;

--Moves the ball and detects collisions with the edges and the paddles
move_ball : process (vga_clk) 
begin
 
if (rising_edge(vga_clk)) then
	 if new_frame = '1' then
		if (reset = '1') then
			left_player_score <= 0;
			right_player_score <= 0;
			ball_pos_v1 <= (518-33)/2;
			ball_pos_h1 <= (794-185)/2;
			ball_speed_h <= default_ball_speed;
			ball_speed_v <= default_ball_speed;
		else

			--If ball travelling down, and not at bottom
			if (ball_pos_v1 < (518-15) and ball_up = '0') then
				ball_pos_v1 <= ball_pos_v1 + ball_speed_v;
			--If ball travelling up and at top
			elsif (ball_up = '0') then
				ball_up <= '1';
			--Ball travelling up and not at top
			elsif (ball_pos_v1 >49 and ball_up = '1') then
				ball_pos_v1 <= ball_pos_v1 - ball_speed_v;
			--Ball travelling down and at bottom
			elsif (ball_up = '1') then
				ball_up <= '0';
			end if;
			
			--If ball travelling right, and not far right
			if (ball_pos_h1 < (794-15) and ball_right = '1') then
				ball_pos_h1 <= ball_pos_h1 + ball_speed_h;
			--If ball travelling right and at far right
			elsif (ball_right = '1') then
				ball_right	<= '0';
						
				if (left_player_score  < 9) then
					left_player_score <= left_player_score + 1;
					--Reset ball position
					ball_pos_v1 <= (518-33)/2;
			        ball_pos_h1 <= (794-185)/2;
				else	
					--Force a reset by stopping the ball
					ball_speed_h 			<= 0;
					ball_speed_v			<= 0;
				end if;
				
			--Ball travelling left and not at far left
			elsif (ball_pos_h1 >165 and ball_right = '0') then
				ball_pos_h1 <= ball_pos_h1 - ball_speed_h;
			--Ball travelling left and at far left
			elsif (ball_right = '0') then
				ball_right <= '1';
				
				if (right_player_score  < 9) then
					right_player_score <= right_player_score + 1;
					--Reset ball position
					ball_pos_v1 <= (518-33)/2;
			        ball_pos_h1 <= (794-185)/2;
				else	
					--Force a reset by stopping the ball
					ball_speed_h 			<= 0;
					ball_speed_v			<= 0;
				end if;
			end if;
		end if;
	
	--Very simple collision detection 
	else
		--Since only the ball is blue and only the paddles are red then if they occur together a collision has happend!
		if (set_blue = X"F" and set_red = X"F") then
			ball_right <= ball_right XOR '1'; --Toggle horizontal ball direction on collision
		end if;
	end if;		
end if;
		 
end process;

end main;

