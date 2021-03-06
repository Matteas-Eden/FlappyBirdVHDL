LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

entity pipe is
	port(vert_sync : in std_logic;
		move_en: in std_logic;
		reset: in std_logic;
		pipe_size: in std_logic_vector(10 DOWNTO 0);
		lfsr_in: in std_logic_vector(10 downto 0);
		level : in std_logic_vector(1 downto 0);
		pipe_x: out std_logic_vector(10 DOWNTO 0);
		pipe_gap: out std_logic_vector(10 DOWNTO 0);
		pipe_display : out std_logic --turn the pipe display on or off
	);
end entity;

architecture piper of pipe is

SIGNAL Pipe_gap_pos, Pipe_X_motion : std_logic_vector(10 DOWNTO 0) := "00000000000"; 
SIGNAL Pipe_X_pos	: std_logic_vector(10 DOWNTO 0) := "01010000000"; --start at right edge of screen
SIGNAL Pipe_on : std_logic;

BEGIN
Move_Pipe: process(reset,vert_sync)
	BEGIN
		if (reset = '1') then
			pipe_x_pos <= CONV_STD_LOGIC_VECTOR(640,11);
			pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
			pipe_on <= '0';
		elsif (vert_sync'event and vert_sync = '1') then
			if (move_en = '1') then
				case level is
					when "00" => pipe_x_motion <= -CONV_STD_LOGIC_VECTOR(3,11);
					when "01" => pipe_x_motion <= -CONV_STD_LOGIC_VECTOR(4,11);
					when "10" => pipe_x_motion <= -CONV_STD_LOGIC_VECTOR(6,11);
					when "11" => pipe_x_motion <= -CONV_STD_LOGIC_VECTOR(6,11);
					when others => pipe_x_motion <= -CONV_STD_LOGIC_VECTOR(3,11);
				end case;
				pipe_on <= '1';
			else
				pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
			end if;
			pipe_x_pos <= pipe_x_pos + pipe_x_motion;
		end if;
		pipe_x <= pipe_x_pos;
		pipe_display <= pipe_on;
end process Move_Pipe;

--reset gap when pipe is reset
Pipe_Gapper: process(reset,vert_sync)
	variable rng : std_logic_vector(10 downto 0);
	BEGIN
		if (vert_sync'event and vert_sync = '1') then
			rng := lfsr_in;
			rng(10) := '0';
			rng(9) := '0';
			rng(8) := '0';
			pipe_gap_pos <= rng;
		end if;
		--falling edge of reset signal
		if (reset'event and reset = '0') then
			pipe_gap <= pipe_gap_pos;
		end if;
end process Pipe_Gapper;
end architecture;