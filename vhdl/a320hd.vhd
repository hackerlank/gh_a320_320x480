library ieee;
use ieee.std_logic_1164.all;

entity GG_AV is 
	port(
		d_in:		in std_logic_vector(0 to 3);
		csync: 		in std_logic;
		hsync: 		in std_logic;
		pix_clk: 	in std_logic;
		en_in: 		in std_logic;
		
		red_out: 	out std_logic_vector(0 to 3);
		green_out: 	out std_logic_vector(0 to 3);
		blue_out: 	out std_logic_vector(0 to 3);
		sc_out: 	out std_logic;
		cs_out: 	out std_logic;
		en_out:		out std_logic
    );
end GG_AV;

architecture behavioral of GG_AV is
begin
	process(pix_clk)
		variable ffa_in: std_logic := '1';
		variable ffa_out: std_logic := '1';
		
		variable ffb_in: std_logic := '1';
		variable ffb_out: std_logic := '1';
		
		variable ffc_in: std_logic := '1';
		variable ffc_out: std_logic := '1';

		variable ffred_in: std_logic_vector(0 to 3) := "1111";
		variable ffred_clk: std_logic := '1';		
		
		variable ffgreen_in: std_logic_vector(0 to 3) := "1111";
		variable ffgreen_clk: std_logic := '1';
		
		variable ffblue_in: std_logic_vector(0 to 3) := "1111";
		variable ffblue_clk: std_logic := '1';
		
		variable cnt: integer range 0 to 8 := 0;
	begin
		if rising_edge(pix_clk) then
			ffa_out := ffa_in;
			ffb_out := ffb_in;
			ffc_out := ffc_in;
			
			ffa_in := not ffc_out;
			ffb_in := ffa_out;
			ffc_in := ffb_out;
			
			if (hsync = '1') then
				ffa_out := '0';
				ffb_out := '0';
				ffc_out := '0';
			end if;
			
			if (ffred_clk = '0') and (ffa_out = '1') then
				red_out <= ffred_in;
			end if;
			
			if (ffgreen_clk = '0') and (ffc_out = '1') then
				green_out <= ffgreen_in;
			end if;
			
			if (ffblue_clk = '1') and (ffb_out = '0') then
				blue_out <= ffblue_in;
			end if;
			
			ffred_clk := ffa_out;
			ffgreen_clk := ffc_out;
			ffblue_clk := ffb_out;
		
			ffred_in := d_in;
			ffgreen_in := d_in;
			ffblue_in := d_in;
		
			cnt := cnt + 1;
			if (cnt >= 8) then
				cnt := 0;
			end if;
			
			if (cnt >= 4) then
				sc_out <= '1';
			else
				sc_out <= '0';
			end if;
			
			en_out <= '1';
			cs_out <= csync;
		end if;
	end process;
end behavioral;