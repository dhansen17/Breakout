----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:39:15 01/28/2008 
-- Design Name: 
-- Module Name:    vga_gen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity vgatest is
port(clk50_in : in std_logic;
red_out : out std_logic_vector(2 downto 0);
green_out : out std_logic_vector(2 downto 0);
blue_out : out std_logic_vector(2 downto 0);
but_left : IN STD_LOGIC;		--use for left button click
but_right : IN STD_LOGIC;		--use for right but click
hs_out : out std_logic;
vs_out : out std_logic);
end vgatest;


architecture behavioral of vgatest is

signal clk25              : std_logic;
signal hcounter : integer range 0 to 800;
signal vcounter   : integer range 0 to 521;
signal color: std_logic_vector(2 downto 0);
signal ballx : integer range -1000 to 1000 := 100;				--will use this for a ball movement in x direction
signal bally : integer range -1000 to 1000 := 100;				--same but in y direction
signal paddle_length: integer := 50;
signal paddle_height : integer := 10;
signal bricks			: STD_LOGIC_VECTOR(4 downto 0) := "11111";
begin

-- generate a 25Mhz clock
process (clk50_in)
begin
  if clk50_in'event and clk50_in='1' then
    clk25 <= not clk25;
  end if;
end process;

-- change color every one second
p1: process (clk25)
	variable cnt: integer;
begin
	if clk25'event and clk25='1' then
		cnt := cnt + 1;
		if cnt = 25000000 then
			color <= color + "001";
			cnt := 0;
		end if;
	end if;
end process;

p2: process (clk25, hcounter, vcounter)
	variable x: integer range 0 to 639;
	variable y: integer range 0 to 479;
	variable counter: integer;				--counter counts the location on the screen, adds one when moving left and pressing left button and doing the opposite for right
	variable game_tick : integer := 0;	--game tick clock to allow things to move at a useful speed
	---These are variables so you can easliy change different sizes and know the locations
	variable paddle_left : integer;
	variable paddle_right : integer;
	variable paddle_top : integer := 439;
	variable paddle_bot : integer;
	variable ball_left : integer;
	variable ball_right : integer;
	variable ball_bot : integer;
	variable ball_top : integer;
	variable brick_height : integer := 170;
	variable brick_width  : integer := 20;
	variable brick0_left : integer := 50;
	variable brick0_right : integer;
	variable brick1_left : integer := 75;
	variable brick1_right : integer ;
	variable brick2_left : integer := 100;
	variable brick2_right : integer;
	variable brick3_left : integer := 125;
	variable brick3_right : integer;
	variable bricks_bot : integer := 150;

begin
	-- hcounter counts from 0 to 799
	-- vcounter counts from 0 to 520
	-- x coordinate: 0 - 639 (x = hcounter - 144, i.e., hcounter -Tpw-Tbp)
	-- y coordinate: 0 - 479 (y = vcounter - 31, i.e., vcounter-Tpw-Tbp)
	x := hcounter - 144;
	y := vcounter - 31;

  	if clk25'event and clk25 = '1' then
 		-- To draw a pixel in (x0, y0), simply test if the ray trace to it
		-- and set its color to any value between 1 to 7. The following example simply sets 
		-- the whole display area to a single-color wash, which is changed every one 
		-- second. 	
		paddle_left := 50 + counter;
		paddle_right := paddle_length + 50 + counter;
		paddle_bot := 449 + paddle_height; 
		ball_left := abs(ballx);			--the left side of the ball 
		ball_right := abs(ballx) + 15;	--right side of ball, bot as faceing screen
		ball_top :=  abs(bally);		--actual top of ball
		ball_bot := abs(bally) + 20;
		----these are made so that it is easy to change, and makes it easier to do checks on if the brick's locations-----
		--`--to make better (architecture) need these in their own module with their own signal of lower priority than ball and paddle.----
		brick0_right := 50 + brick_width;
		brick1_right := 75 + brick_width;
		brick2_right := 100 + brick_width;
		brick3_right := 125 + brick_width;
		----first if for screen--------
		if(x < 639 and x > 0 and y < 479 and y > 0) then
		------This is the deal that draws our ball---------
			if(( x >= ball_left) and (x <= ball_right) and (y >=  ball_top) and (y <= ball_bot)) then
				red_out <= "000";
				green_out <= "000";
				blue_out <= "111";
		------Draws the paddle---------- Implament in another module with diff priority signals to be better programe
			elsif (( x > paddle_left ) and (x < paddle_right) and (y > paddle_top) and (y < paddle_bot)) then
				red_out <= "011";
				green_out <= "011"; 
				blue_out <= "000";
		----This draws our bricks, to make a better programe I would implament these in another module-----
			elsif (x > brick0_left and x < brick0_right and y > bricks_bot and y < brick_height and bricks(0) = '1') then
				red_out <= "111";
				green_out <= "000";
				blue_out <= "000";
			
			elsif (x > brick1_left and x < brick1_right and y > bricks_bot and y < brick_height and bricks(1) = '1') then
				red_out <= "111";
				green_out <= "000";
				blue_out <= "000";
			
			elsif (x > brick2_left and x < brick2_right and y > bricks_bot and y < brick_height and bricks(2) = '1') then
				red_out <= "111";
				green_out <= "000";
				blue_out <= "000";
				
			elsif (x > brick3_left and x < brick3_right and y > bricks_bot and y < brick_height and bricks(3) = '1') then
				red_out <= "111";
				green_out <= "000";
				blue_out <= "000";
				
			else 
				-- if not traced, set it to "black" color
				red_out <= "000";
				green_out <= "000";
				blue_out <= "000";
			end if;
		end if;
			
    	if hcounter > 0 and hcounter < 97 then
      	hs_out <= '0';
    	else
      	hs_out <= '1';
    	end if;

    	if vcounter > 0 and vcounter < 3 then
      	vs_out <= '0';
    	else
      	vs_out <= '1';
    	end if;

    	hcounter <= hcounter+1;
    	if hcounter = 800 then
      	vcounter <= vcounter+1;
      	hcounter <= 0;
    	end if;

    	if vcounter = 521 then		    
      	vcounter <= 0;
    	end if;
		
		------Collision logic---------
		
		---This is the collision with the paddle logic-------
			if(bally >= 452) then
			bally <= bally  * (-1);
		end if;
		
		if (ballx >= 611) then
			ballx <= ballx * (-1);
		end if;
		
		if(ball_bot >= paddle_top and ball_right >= paddle_left and ball_left <= paddle_right) then 
			bally <= bally * (-1);
		end if;
		
		
		
		--collide with brick--
		--this works, but when you hit the brick from the top it has a funny looking responce. needs love.. (maybe architecture maybe now we will see on time)
		if(ball_bot <= brick_height and ball_right >= brick0_left and ball_left <= brick0_right) then 
			red_out <= "000";
			green_out <= "000";
			blue_out <= "000";
			if(bricks(0) = '1') then	-- this is so that if you have already seen that block go through it and don't act like you have hit it already. 
				bally <= bally * (-1);
				bricks(0) <= '0';
			end if;
		end if;
		--the following brick collisions are not working, they are defaulting to balck as if they have already collided when they havent, not sure why-----
		if(ball_bot <= brick_height and ball_right >= brick1_left and ball_left <= brick1_right) then 
			red_out <= "000";
			green_out <= "000";
			blue_out <= "000";
			if(bricks(1) = '1') then	
				bally <= bally * (-1);
				bricks(1) <= '0';
			end if;
		end if;

		if(ball_bot <= brick_height and ball_right <= brick2_left and ball_left >= brick2_right) then 
			red_out <= "000";
			green_out <= "000";
			blue_out <= "000";
			if(bricks(2) = '1') then	
				bally <= bally * (-1);
				bricks(2) <= '0';
			end if;
		end if;

		if(ball_bot <= brick_height and ball_right <= brick3_left and ball_left >= brick3_right) then 
			red_out <= "000";
			green_out <= "000";
			blue_out <= "000";
			if(bricks(3) = '1') then	 
				bally <= bally * (-1);
				bricks(3) <= '0';
			end if;
		end if;		
		
		
		--for button presses move counter up or down, aka move to certain locations
		game_tick := game_tick + 1; 
		if game_tick >= 80000 then
		
			if but_left = '0' and (paddle_right <= 637) then
				counter := counter + 1;
			end if;
			if but_right = '0' and (paddle_left >= 0)  then
				counter := counter - 1;
			end if;
			
			ballx <= ballx + 1;
			bally <= bally + 1;
			
			game_tick := 0;
		end if;
  end if;
end process;

end behavioral;