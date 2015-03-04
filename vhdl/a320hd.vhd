library ieee;
use ieee.std_logic_1164.all;

entity a320hd is 
	port(
		new_data:	out std_logic_vector(0 to 15);
		new_cs: 	out std_logic;
		new_rs:		out std_logic;
		new_wr: 	out std_logic;
		new_rd:		out std_logic;
		new_rst:	out std_logic;
		new_frame:	out std_logic;
		
		old_data:	in std_logic_vector(0 to 15);
		old_cs: 	in std_logic;
		old_rs:		in std_logic;
		old_wr: 	in std_logic;
		old_rd:		in std_logic;
		old_rst:	in std_logic;
		
		clk:		in std_logic;
		pd3:		in std_logic;
		pd4:		in std_logic
    );
end a320hd;

architecture main of a320hd is
	type CONTROL is (powerup, init, ready, send);
	signal state: CONTROL;
	constant freq: integer:= 100;
begin
	process(clk)
		variable clk_count: integer:= 0;
	begin
		if (clk'event and clk = '1') then
		end if;
	end process;
end main;