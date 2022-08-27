-- cpu.vhd: Simple 8-bit CPU (BrainF*ck interpreter)
-- Copyright (C) 2020 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): Elena Carasec (xcaras00)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
   CLK   : in std_logic;  -- hodinovy signal
   RESET : in std_logic;  -- asynchronni reset procesoru
   EN    : in std_logic;  -- povoleni cinnosti procesoru
 
   -- synchronni pamet ROM
   CODE_ADDR : out std_logic_vector(11 downto 0); -- adresa do pameti
   CODE_DATA : in std_logic_vector(7 downto 0);   -- CODE_DATA <- rom[CODE_ADDR] pokud CODE_EN='1'
   CODE_EN   : out std_logic;                     -- povoleni cinnosti
   
   -- synchronni pamet RAM
   DATA_ADDR  : out std_logic_vector(9 downto 0); -- adresa do pameti
   DATA_WDATA : out std_logic_vector(7 downto 0); -- ram[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
   DATA_RDATA : in std_logic_vector(7 downto 0);  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
   DATA_WE    : out std_logic;                    -- cteni (0) / zapis (1)
   DATA_EN    : out std_logic;                    -- povoleni cinnosti 
   
   -- vstupni port
   IN_DATA   : in std_logic_vector(7 downto 0);   -- IN_DATA <- stav klavesnice pokud IN_VLD='1' a IN_REQ='1'
   IN_VLD    : in std_logic;                      -- data platna
   IN_REQ    : out std_logic;                     -- pozadavek na vstup data
   
   -- vystupni port
   OUT_DATA : out  std_logic_vector(7 downto 0);  -- zapisovana data
   OUT_BUSY : in std_logic;                       -- LCD je use ieee.numeric_std.all; zaneprazdnen (1), nelze zapisovat
   OUT_WE   : out std_logic                       -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'
 );
end cpu;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is

	signal pc_register : std_logic_vector(11 downto 0) := "000000000000";
	signal pc_inc : std_logic := '0';
	signal pc_dec : std_logic := '0';
	signal pc_load : std_logic := '0';

	signal ras_register : std_logic_vector(191 downto 0) := (others => '0');
	signal ras_push : std_logic := '0';
       	signal ras_pop : std_logic := '0';

	signal cnt_register : std_logic_vector(4 downto 0) := "00000";
	signal cnt_inc : std_logic := '0';
	signal cnt_dec : std_logic := '0';

	signal ptr_register : std_logic_vector(9 downto 0) := "0000000000";
	signal ptr_inc : std_logic := '0';
	signal ptr_dec : std_logic := '0';

	type states is (start, get_next, execute, 
			mem_next, mem_prev, 
			val_inc, val_dec, val_store,
			cycle_begin, cycle_end, 
			read, write, 
			other, prg_end,
			data_inc, data_dec, 
			check_cycle, check_cnt, check_brace, 
			check_cycle_end, 
			read_wait, write_enable);

	signal curr_state : states := start;
	signal next_state : states := start;

	signal mux_input : std_logic_vector(1 downto 0) := "00";
	signal mux_output : std_logic_vector(7 downto 0);

begin

	pc : process(CLK, RESET, pc_inc, pc_dec, pc_load) is
	begin
		if (RESET = '1') then
			pc_register <= (others => '0');
		elsif (rising_edge(CLK)) then
			if (pc_inc = '1') then
				pc_register <= pc_register + 1;
		    	elsif (pc_dec = '1') then
				pc_register <= pc_register - 1;
			elsif (pc_load = '1') then
				pc_register <= ras_register(191 downto 180);
			end if;
		end if;
	end process;
	CODE_ADDR <= pc_register;

	ras : process(CLK, RESET, ras_push, ras_pop) is
	begin
		if (RESET = '1') then
			ras_register <= (others => '0');
		elsif (rising_edge(CLK)) then
			if (ras_push = '1') then
				ras_register <= pc_register & ras_register(191 downto 12);
			elsif (ras_pop = '1') then
				ras_register <= ras_register(179 downto 0) & "000000000000";
			end if;
		end if;
	end process;

	cnt : process(CLK, RESET, cnt_inc, cnt_dec) is
	begin
		if (RESET = '1') then
			cnt_register <= (others => '0');
		elsif (rising_edge(CLK)) then
			if cnt_inc = '1' then
				cnt_register <= cnt_register + 1;
			elsif cnt_dec = '1' then
				cnt_register <= cnt_register - 1;
			end if;
		end if;
	end process;
	OUT_DATA <= DATA_RDATA;

	ptr : process(CLK, RESET, ptr_inc, ptr_dec) is
	begin
		if (RESET = '1') then
			ptr_register <= (others => '0');
		elsif (rising_edge(CLK)) then
			if (ptr_inc = '1') then
				ptr_register <= ptr_register + 1;
			elsif (ptr_dec = '1') then
				ptr_register <= ptr_register - 1;
			end if;
		end if;
	end process;
	DATA_ADDR <= ptr_register;
 
	mux : process(CLK, RESET, mux_input) is
	begin
		if (RESET = '1') then
			mux_output <= (others => '0');
		elsif (rising_edge(CLK)) then
			case mux_input is
				when "00" => mux_output <= IN_DATA;
				when "01" => mux_output <= DATA_RDATA + 1;
				when "10" => mux_output <= DATA_RDATA - 1;
				when others => mux_output <= (others => '0');
			end case;
		end if;
	end process;
	DATA_WDATA <= mux_output;

	fsm_state_transition : process(CLK, RESET, EN) is
	begin
		if (RESET = '1') then
			curr_state <= start;
		elsif rising_edge(CLK) then
	       		if (EN = '1') then
				curr_state <= next_state;
			end if;
		end if;
	end process;

	fsm_logic : process(curr_state, CODE_DATA, IN_VLD, OUT_BUSY, DATA_RDATA, cnt_register) is
	begin
		pc_inc <= '0';
		pc_dec <= '0';
		pc_load <= '0';
		ras_push <= '0';
		ras_pop <= '0';
		cnt_inc <= '0';
		cnt_dec <= '0';
		ptr_inc <= '0';
		ptr_dec <= '0';
		mux_input <= "00";

		DATA_EN <= '0';
		DATA_WE <= '0';
		CODE_EN <= '0';
		IN_REQ <= '0';
		OUT_WE <= '0';

		case curr_state is
			when start => 
				next_state <= get_next;
			when get_next =>
				CODE_EN <= '1';
				next_state <= execute;
			when execute =>
				case CODE_DATA is
					when X"3E" => next_state <= mem_next;
					when X"3C" => next_state <= mem_prev;
					when X"2B" => next_state <= val_inc;
					when X"2D" => next_state <= val_dec;
					when X"5B" => next_state <= cycle_begin;
					when X"5D" => next_state <= cycle_end;
					when X"2C" => next_state <= read;
					when X"2E" => next_state <= write;
					when X"00" => next_state <= prg_end;
					when others => 
							pc_inc <= '1';
							next_state <= get_next;
				end case;

			---- PTR INC/DEC ----
			when mem_next =>
				pc_inc <= '1';
				ptr_inc <= '1';
				next_state <= get_next;
			when mem_prev => 
				pc_inc <= '1';
				ptr_dec <= '1';
				next_state <= get_next;
			---- PTR INC/DEC ----

			---- VALUE INC/DEC ----
			when val_inc =>
				DATA_EN <= '1';
				DATA_WE <= '0';
				next_state <= data_inc;
			when data_inc =>
				mux_input <= "01";
				next_state <= val_store;
			when val_dec =>
				DATA_EN <= '1';
				DATA_WE <= '0';
				next_state <= data_dec;
			when data_dec =>
				mux_input <= "10";
				next_state <= val_store;
			when val_store =>
				pc_inc <= '1';
				DATA_EN <= '1';
				DATA_WE <= '1';
				next_state <= get_next;
			---- VALUE INC/DEC ----

			---- CYCLE START ----
			when cycle_begin =>
				pc_inc <= '1';
				DATA_EN <= '1';
				DATA_WE <= '0';
				next_state <= check_cycle;

			when check_cycle =>
				if (DATA_RDATA /= "00000000") then
					ras_push <= '1';
					next_state <= get_next;
				else
					cnt_inc <= '1';
					CODE_EN <= '1';
					next_state <= check_cnt;
				end if;

			when check_cnt =>
				if (cnt_register = "00000") then
					next_state <= get_next;
				else
					case CODE_DATA is
						when X"5B" =>
							cnt_inc <= '1';
						when X"5D" =>
							cnt_dec <= '1';
						when others =>
					end case;
					pc_inc <= '1';					
					next_state <= check_brace;
				end if;

			when check_brace =>
				CODE_EN <= '1';
				next_state <= check_cnt;

			---- CYCLE END ----
			when cycle_end =>
				DATA_EN <= '1';
				DATA_WE <= '0';
				next_state <= check_cycle_end;
			when check_cycle_end =>
				if (DATA_RDATA = "00000000") then
					ras_pop <= '1';
					pc_inc <= '1';
				else
					pc_load <= '1';
				end if;
				next_state <= get_next;
			---- CYCLE END ---

			---- READ ----
			when read =>
				IN_REQ <= '1';
				mux_input <= "00";
				next_state <= read_wait;
			when read_wait =>
				if (IN_VLD /= '1') then
					IN_REQ <= '1';
					mux_input <= "00";					
					next_state <= read_wait;
				else
					DATA_EN <= '1';
					DATA_WE <= '1';
					pc_inc <= '1';
					next_state <= get_next;
				end if;
			---- READ ----

			---- WRITE ----
			when write =>
				DATA_EN <= '1';
				DATA_WE <= '0';
				next_state <= write_enable;
			when write_enable =>
				if (OUT_BUSY = '1') then
					DATA_EN <= '1';
					DATA_WE <= '0';
					next_state <= write_enable;
				else
					OUT_WE <= '1';
					pc_inc <= '1';
					next_state <= get_next;
				end if;				
			---- WRITE ----
			
			when prg_end =>
				next_state <= prg_end;

			when others =>
				null;
		end case;
	end process;
end behavioral;
 
