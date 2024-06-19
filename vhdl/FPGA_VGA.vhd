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
	paddle_v1 : in integer range 49 to 518:= 200;
	paddle_v2 : in integer range 49 to 518:= 200 
	
);
end entity FPGA_VGA;


architecture main of FPGA_VGA is

--Settable constants
constant paddle_speed : integer := 5;
constant default_ball_speed : integer := 3;

--Declare components
component vga_driver3 is port (
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
 
end component vga_driver3;

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
--signal paddle_v1 : integer range 49 to 518:= 200;
signal paddle_h2 : integer range 165 to 794:= 784; -- Right Side
--signal paddle_v2 : integer range 49 to 518:= 200;

--Score Signals
signal tick_h1_1 : integer range 165 to 794:= 300; -- Left Side 
signal tick_v1_1 : integer range 49 to 518:= 146;
signal tick_h1_2 : integer range 165 to 794:= 310; -- Left Side
signal tick_v1_2 : integer range 49 to 518:= 146;
signal tick_h1_3 : integer range 165 to 794:= 320; -- Left Side
signal tick_v1_3 : integer range 49 to 518:= 146;
signal tick_h1_4 : integer range 165 to 794:= 330; -- Left Side
signal tick_v1_4 : integer range 49 to 518:= 146;
signal tick_h1_5 : integer range 165 to 794:= 340; -- Left Side
signal tick_v1_5 : integer range 49 to 518:= 146;

signal tick_h2_1 : integer range 165 to 794:= 615; -- Right Side
signal tick_v2_1 : integer range 49 to 518:= 146;
signal tick_h2_2 : integer range 165 to 794:= 625; -- Right Side
signal tick_v2_2 : integer range 49 to 518:= 146;
signal tick_h2_3 : integer range 165 to 794:= 635; -- Right Side
signal tick_v2_3 : integer range 49 to 518:= 146;
signal tick_h2_4 : integer range 165 to 794:= 645; -- Right Side
signal tick_v2_4 : integer range 49 to 518:= 146;
signal tick_h2_5 : integer range 165 to 794:= 655; -- Right Side
signal tick_v2_5 : integer range 49 to 518:= 146;

--Ball signals
signal ball_pos_h1      : integer range 165 to 794:= ((794-165)/2)+165; -- Middle
signal ball_pos_v1      : integer range 49 to 518:= ((518-49)/2)+49;    -- Middle
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
	vga1 : vga_driver3 port map (
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
		--Paddles are 70 x 7 pixels
		if ( (hpos >= paddle_h1 and hpos < paddle_h1 + 7) and (vpos >= paddle_v1 and vpos < paddle_v1 + 70) ) then
			set_red <= X"F";
			--set_green <= X"F";
		elsif ( (hpos >= paddle_h2 and hpos < paddle_h2 + 7) and (vpos >= paddle_v2 and vpos < paddle_v2 + 70) ) then
			set_red <= X"F";
			--set_green <= X"3";
		else
			set_red <= X"0";
		end if;
		
	end if;
		 
end process;

--Draws the left and right scores
draw_score : process (vga_clk) 
begin
 
	if (rising_edge(vga_clk)) then
		--Scores are from 0 to 5, displayed as 5 by 20 tick marks
		
		if ( (hpos >= 165 and hpos < 480)) then		
		  if (left_player_score > 0) then 
			if ( (hpos >= tick_h1_1 and hpos < tick_h1_1 + 5) and (vpos >= tick_v1_1 and vpos < tick_v1_1 + 20) ) then
				set_green <= X"F";
			else 
				set_green <= X"0";
			end if;
		  end if;
		  if (left_player_score > 1) then 
			if ( ((hpos >= tick_h1_2 and hpos < tick_h1_2 + 5) and (vpos >= tick_v1_2 and vpos < tick_v1_2 + 20) ) or 
			((hpos >= tick_h1_1 and hpos < tick_h1_1 + 5) and (vpos >= tick_v1_1 and vpos < tick_v1_1 + 20))) then
				set_green <= X"F";
		    else 
			    set_green <= X"0";
			end if;
		  end if;
				
		  if (left_player_score > 2) then 
			if ((hpos >= tick_h1_3 and hpos < tick_h1_3 + 5) and (vpos >= tick_v1_3 and vpos < tick_v1_3 + 20)) or 
			((hpos >= tick_h1_2 and hpos < tick_h1_2 + 5) and (vpos >= tick_v1_2 and vpos < tick_v1_2 + 20)) or 
			((hpos >= tick_h1_1 and hpos < tick_h1_1 + 5) and (vpos >= tick_v1_1 and vpos < tick_v1_1 + 20)) then
				set_green <= X"F";
			else 
			    set_green <= X"0";
			end if;
		  end if;
				
		  if (left_player_score > 3) then 
			if ((hpos >= tick_h1_4 and hpos < tick_h1_4 + 5) and (vpos >= tick_v1_4 and vpos < tick_v1_4 + 20)) or
			((hpos >= tick_h1_3 and hpos < tick_h1_3 + 5) and (vpos >= tick_v1_3 and vpos < tick_v1_3 + 20)) or 
			((hpos >= tick_h1_2 and hpos < tick_h1_2 + 5) and (vpos >= tick_v1_2 and vpos < tick_v1_2 + 20)) or 
			((hpos >= tick_h1_1 and hpos < tick_h1_1 + 5) and (vpos >= tick_v1_1 and vpos < tick_v1_1 + 20)) then
				set_green <= X"F";
			else 
			    set_green <= X"0";
			end if;
		  end if;
				
		  if (left_player_score > 4) then 
			if ((hpos >= tick_h1_5 and hpos < tick_h1_5 + 5) and (vpos >= tick_v1_5 and vpos < tick_v1_5 + 20)) or 
			((hpos >= tick_h1_4 and hpos < tick_h1_4 + 5) and (vpos >= tick_v1_4 and vpos < tick_v1_4 + 20)) or
			((hpos >= tick_h1_3 and hpos < tick_h1_3 + 5) and (vpos >= tick_v1_3 and vpos < tick_v1_3 + 20)) or 
			((hpos >= tick_h1_2 and hpos < tick_h1_2 + 5) and (vpos >= tick_v1_2 and vpos < tick_v1_2 + 20)) or 
			((hpos >= tick_h1_1 and hpos < tick_h1_1 + 5) and (vpos >= tick_v1_1 and vpos < tick_v1_1 + 20))then
				set_green <= X"F";
			else 
			    set_green <= X"0";
			end if;
		  end if;

		elsif((hpos >= 480 and hpos < 794)) then
		  if (right_player_score > 0) then 
			if ( (hpos >= tick_h2_1 and hpos < tick_h2_1 + 5) and (vpos >= tick_v2_1 and vpos < tick_v2_1 + 20) ) then
				set_green <= X"F";
			else 
				set_green <= X"0";
			end if;
		  end if;
		  if (right_player_score > 1) then 
			if ( ((hpos >= tick_h2_2 and hpos < tick_h2_2 + 5) and (vpos >= tick_v2_2 and vpos < tick_v2_2 + 20) ) or 
			((hpos >= tick_h2_1 and hpos < tick_h2_1 + 5) and (vpos >= tick_v2_1 and vpos < tick_v2_1 + 20))) then
				set_green <= X"F";
		    else 
			    set_green <= X"0";
			end if;
		  end if;
				
		  if (right_player_score > 2) then 
			if ((hpos >= tick_h2_3 and hpos < tick_h2_3 + 5) and (vpos >= tick_v2_3 and vpos < tick_v2_3 + 20)) or 
			((hpos >= tick_h2_2 and hpos < tick_h2_2 + 5) and (vpos >= tick_v2_2 and vpos < tick_v2_2 + 20)) or 
			((hpos >= tick_h2_1 and hpos < tick_h2_1 + 5) and (vpos >= tick_v2_1 and vpos < tick_v2_1 + 20)) then
				set_green <= X"F";
			else 
			    set_green <= X"0";
			end if;
		  end if;
				
		  if (right_player_score > 3) then 
			if ((hpos >= tick_h2_4 and hpos < tick_h2_4 + 5) and (vpos >= tick_v2_4 and vpos < tick_v2_4 + 20)) or
			((hpos >= tick_h2_3 and hpos < tick_h2_3 + 5) and (vpos >= tick_v2_3 and vpos < tick_v2_3 + 20)) or 
			((hpos >= tick_h2_2 and hpos < tick_h2_2 + 5) and (vpos >= tick_v2_2 and vpos < tick_v2_2 + 20)) or 
			((hpos >= tick_h2_1 and hpos < tick_h2_1 + 5) and (vpos >= tick_v2_1 and vpos < tick_v2_1 + 20)) then
				set_green <= X"F";
			else 
			    set_green <= X"0";
			end if;
		  end if;
				
		  if (right_player_score > 4) then 
			if ((hpos >= tick_h2_5 and hpos < tick_h2_5 + 5) and (vpos >= tick_v2_5 and vpos < tick_v2_5 + 20)) or 
			((hpos >= tick_h2_4 and hpos < tick_h2_4 + 5) and (vpos >= tick_v2_4 and vpos < tick_v2_4 + 20)) or
			((hpos >= tick_h2_3 and hpos < tick_h2_3 + 5) and (vpos >= tick_v2_3 and vpos < tick_v2_3 + 20)) or 
			((hpos >= tick_h2_2 and hpos < tick_h2_2 + 5) and (vpos >= tick_v2_2 and vpos < tick_v2_2 + 20)) or 
			((hpos >= tick_h2_1 and hpos < tick_h2_1 + 5) and (vpos >= tick_v2_1 and vpos < tick_v2_1 + 20))then
				set_green <= X"F";
			else 
			    set_green <= X"0";
			end if;
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


--Moves the ball and detects collisions with the edges and the paddles
move_ball : process (vga_clk) 
begin
 
if (rising_edge(vga_clk)) then
	 if new_frame = '1' then
		if (reset = '1') then
			left_player_score <= 0;
			right_player_score <= 0;
			ball_pos_v1 <= ((518-49)/2)+49;
			ball_pos_h1 <= ((794-165)/2)+165;
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
						
				if (left_player_score  < 5) then
					left_player_score <= left_player_score + 1;
					--Reset ball position
					ball_pos_v1 <= ((518-49)/2)+49;
			        ball_pos_h1 <= ((794-165)/2)+165;
				else	
					--Force a reset by stopping the ball
					ball_speed_h 			<= 0;
					ball_speed_v			<= 0;
					--left_player_score <= 0;
					--right_player_score <= 0;
				end if;
				
			--Ball travelling left and not at far left
			elsif (ball_pos_h1 >165 and ball_right = '0') then
				ball_pos_h1 <= ball_pos_h1 - ball_speed_h;
			--Ball travelling left and at far left
			elsif (ball_right = '0') then
				ball_right <= '1';
				
				if (right_player_score  < 5) then
					right_player_score <= right_player_score + 1;
					--Reset ball position
					ball_pos_v1 <= ((518-49)/2)+49;
			        ball_pos_h1 <= ((794-165)/2)+165;
				else	
					--Force a reset by stopping the ball
					ball_speed_h 			<= 0;
					ball_speed_v			<= 0;
					--left_player_score <= 0;
					--right_player_score <= 0;
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
