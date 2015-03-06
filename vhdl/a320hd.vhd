---------------------------------------------------------------
--
-- Dingoo A320 screen replacement (use 320x480 lcd)
-- Steward Fu
-- 20150306
--
---------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
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
	type CONTROL is (powerup1, powerup2, powerup3, init, gui_set_pos, gui_draw_color, delay);
	signal state: CONTROL:= powerup1;
	constant freq: integer:= 100; -- 100MHz
	
	--LCD commands
	type LCD_SIGNAL is array (0 to 71) of std_logic;
	type LCD_COMMAND is array (0 to 71) of std_logic_vector (0 to 15);
	constant lcd_sig: LCD_SIGNAL:= (
		'0', '1', '1', '1', '0', '1', '0', '0', 
		'0', '1',
		-- 1
		'0', '1', '1', '1', '1', '1', '1',
		-- 2
		'0', '1', '1', '1', '1', '1', '1',
		-- 3
		'0', '1', '1', '1', '1', '1', '1', '1',
		-- 4
		'0', '1', '1', '1', '1', '1', '1', '1',
		'1', '1', '1', '1', '1', '1', '1',
		-- 5
		'1', '1', '1', '1', '1', '1', '1', '1',
		'1', '1', '1', '1', '1', '1', 
		-- 6
		'1', '1', '1', '1', '1', '1',
		-- 7
		'0', '1', '0', '0',
		-- 8 landscape mode
		'0'
	);
    constant lcd_cmd: LCD_COMMAND:=(
		x"00b9", x"00ff", x"0083", x"0057", x"00b6", x"002c", x"0011", x"0035",
		x"003a", x"0055",
		-- 1
		x"00b1", x"0000", x"0015", x"000d", x"000d", x"0083", x"0048",
		-- 2
		x"00c0", x"0024", x"0024", x"0001", x"003c", x"00c8", x"0008",
		-- 3
		x"00b4", x"0002", x"0040", x"0000", x"002a", x"002a", x"000d", x"004f",
		-- 4
		x"00e0", x"0000", x"0015", x"001d", x"002a", x"0031", x"0042", x"004c",
		x"0053", x"0045", x"0040", x"003b", x"0032", x"002e", x"0028",
		-- 5
		x"0024", x"0003", x"0000", x"0015", x"001d", x"002a", x"0031", x"0042",
		x"004c", x"0053", x"0045", x"0040", x"003b", x"0032",
		-- 6
		x"002e", x"0028", x"0024", x"0003", x"0000", x"0001",
		-- 7
		x"0036", x"0048", x"0021", x"0029",
		-- 8 landscape mode
		x"363b"
		);
		
	type GUI_SIGNAL is array (0 to 10) of std_logic;
	type GUI_COMMAND is array (0 to 10) of std_logic_vector (0 to 15);
	constant gui_sig: GUI_SIGNAL:= (
		'0', '1', '1', '1', '1',
		'0', '1', '1', '1', '1',
		'0'
	);
	constant gui_cmd: GUI_COMMAND:= (
		x"002a", x"0000", x"0000", x"0000", x"0000",
		x"002b", x"0000", x"0000", x"0000", x"0000",
		x"002c"
	);
begin
	process(clk)
		variable clk_count: integer:= 0;
		variable cmd_index: integer:= 0;
		variable color: integer:= 0;
	begin
		if (clk'event and clk = '1') then
			clk_count:= clk_count + 1;
			
			case state is
			when powerup1 =>
				if (clk_count > (50000 * freq)) then
					clk_count:= 0;
					new_rst<= '1';
					new_rs<= '1';
					new_wr<= '1';
					new_rd<= '1';
					state<= powerup2;
				end if;
			when powerup2 =>
				if (clk_count > (120000 * freq)) then
					clk_count:= 0;
					new_rst<= '0';
					state<= powerup3;
				end if;
			when powerup3 =>
				if (clk_count > (50000 * freq)) then
					clk_count:= 0;
					cmd_index:= 0;
					new_rst<= '1';
					state<= init;
				end if;
			when init =>
				if (clk_count < (10000 * freq)) then
					new_cs<= '0';
					new_data<= lcd_cmd(cmd_index);
					new_rs<= lcd_sig(cmd_index); -- data or command
				elsif (clk_count < (30000 * freq)) then
					new_wr<= '0';
				elsif (clk_count < (50000 * freq)) then
					new_wr<= '1';
				elsif (clk_count < (70000 * freq)) then
					new_cs<= '1';
					clk_count:= 0;
					cmd_index:= cmd_index + 1; -- next command
					if (cmd_index >= lcd_cmd'high) then
						state<= gui_set_pos;
						cmd_index:= 0;
					end if;
				end if;
			when gui_set_pos =>
				if (clk_count < (10000 * freq)) then
					new_cs<= '0';
					new_data<= gui_cmd(cmd_index);
					new_rs<= gui_sig(cmd_index); -- data or command
				elsif (clk_count < (30000 * freq)) then
					new_wr<= '0';
				elsif (clk_count < (50000 * freq)) then
					new_wr<= '1';
				elsif (clk_count < (70000 * freq)) then
					new_cs<= '1';
					clk_count:= 0;
					cmd_index:= cmd_index + 1; -- next command
					if (cmd_index >= gui_cmd'high) then
						state<= gui_draw_color;
						color:= 0;
					end if;
				end if;
			when gui_draw_color =>
				if (clk_count < (10000 * freq)) then
					new_cs<= '0';
					new_data<= std_logic_vector(to_unsigned(color, new_data'length));
					new_rs<= '1'; -- data
				elsif (clk_count < (30000 * freq)) then
					new_wr<= '0';
				elsif (clk_count < (50000 * freq)) then
					new_wr<= '1';
				elsif (clk_count < (70000 * freq)) then
					new_cs<= '1';
					clk_count:= 0;
					color:= color + 50; -- next color
					if (color > 65000) then
						state<= delay;
					end if;
				end if;
			when delay => -- delay 500ms
				if (clk_count > (500000 * freq)) then
					state<= gui_set_pos;
					clk_count:= 0;
				end if;
			end case;
		end if;
	end process;
end main;