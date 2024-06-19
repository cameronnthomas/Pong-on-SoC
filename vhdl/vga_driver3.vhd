--VGA driver for 640 x 480 60Hz monitor
 
library ieee; use ieee.std_logic_1164.all;
 
entity vga_driver3 is port (
	vga_clk	: in std_logic;
	--Outputs to VGA port
	h_sync 	: out std_logic;
	v_sync 	: out std_logic;
	red	: out std_logic_vector(3 downto 0);
	green	: out std_logic_vector(3 downto 0);
	blue	: out std_logic_vector(3 downto 0);
	
	--Outputs so other modules know where on the screen we are
	new_frame : out std_logic;
	current_h : out integer range 0 to 800:=0;
	current_v : out integer range 0 to 524:=0;

	--Inputs from other modules to set display
	red_in	 : in std_logic_vector(3 downto 0);
	green_in  : in std_logic_vector(3 downto 0);
	blue_in	 : in std_logic_vector(3 downto 0)

  
);
 
end entity vga_driver3;
 
architecture main of vga_driver3 is

--Store current position within screen
signal h_pos : integer range 0 to 800:=0;   --FP+SYNC+BP+Visible = 16 + 96 + 48 + 640 = 800
signal v_pos : integer range 0 to 524:=0;	--FP+SYNC+BP+Visible = 11 + 2 + 31 + 480 = 524

 
begin

current_h <= h_pos;
current_v <= v_pos;
 
vga_timing : process(vga_clk)

begin
	if rising_edge(vga_clk) then
		
		--Count up pixel position
		if (h_pos < 800) then
		
			new_frame <= '0';
			
			h_pos <= h_pos + 1;
		else
			h_pos <= 0;  --Reset position at end of line
			
			--Count up line position
			if (v_pos < 524) then
				v_pos <= v_pos + 1;
			else 
				v_pos <= 0;  --Reset position at end of frame
				
				new_frame <= '1';
				
			end if;
		end if;
		
		--Generate horizontal sync signal (negative pulse)
		if (h_pos > 15 and h_pos < 48) then
			h_sync <= '0';
		else
			h_sync <= '1';
		end if;
		--Generate vertical sync signal (positive pulse)
		if (v_pos > 10 and v_pos < 31) then
			v_sync <= '1';
		else
			v_sync <= '0';
		end if;
		
		--Blank screen during FP, BP and Sync
		if ( (h_pos >= 0 and h_pos < 160) or (v_pos >= 0 and v_pos < 44) ) then
				red <= (others => '0');
				green <= (others => '0');
				blue <= (others => '0');
				
		--In visible range of screen		
		else
			--Print white screen boarder with width 5
			if ( (h_pos >= 160 and h_pos < 165 ) or (v_pos >= 44 and v_pos < 49 ) or (h_pos >= 795 and h_pos < 800 ) or (v_pos >= 519 and v_pos < 524 ) ) then
					red <= (others => '1');
					green <= (others => '1');
					blue <= (others => '1');
			else
					--Within the boarder other modules can write to the screen
					red <= red_in;
					green <= green_in;
					blue <= blue_in;
			end if;
		
		end if;
	
	end if;
	
end process;
 
end main;