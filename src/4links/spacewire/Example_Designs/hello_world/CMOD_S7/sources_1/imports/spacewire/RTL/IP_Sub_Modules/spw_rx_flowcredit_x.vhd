----------------------------------------------------------------------------------------------------------------------------------
-- File Description  --
----------------------------------------------------------------------------------------------------------------------------------
-- @ File Name				:	
-- @ Engineer				:	James E Logan
-- @ Role					:	FPGA Engineer
-- @ Company				:	4Links ltd
-- @ Date					: 	dd/mm/yyyy

-- @ VHDL Version			:   1987, 1993, 2008
-- @ Supported Toolchain	:	Xilinx Vivado IDE
-- @ Target Device			: 	Xilinx US+ Family

-- @ Revision #				:	1

-- File Description         :

-- Document Number			:  xxx-xxxx-xxx
----------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Copyright (c) 2018-2023, 4Links Ltd All rights reserved.
--
-- Redistribution and use in source and synthesised forms, with or without 
-- modification, are permitted provided that the following conditions are met:
-- 1. Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in synthesised form must reproduce the above copyright 
--    notice, this list of conditions and the following disclaimer in the 
--    documentation and/or other materials provided with the distribution.
-- 3. All advertising materials mentioning features or use of this code
--    must display the following acknowledgement: This product includes
--    code developed by 4Links Ltd.
-- 4. Neither the name of 4Links Ltd nor the names of its contributors may be
--    used to endorse or promote products derived from this code without 
--    specific prior written permission.
--
-- THIS CODE IS PROVIDED BY 4LINKS LTD "AS IS" AND ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL 4LINKS LTD BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS CODE, EVEN IF 
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- Library Declarations  --
----------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Package Declarations --
----------------------------------------------------------------------------------------------------------------------------------
use work.ip4l_data_types.all;
use work.spw_codes.all;

----------------------------------------------------------------------------------------------------------------------------------
-- Entity Declarations --
----------------------------------------------------------------------------------------------------------------------------------
entity spw_rx_flowcredit_x is
	generic(
		fifo_size          : integer := 24
	);
	port(
		clock               : in    std_logic;
		reset				: in    std_logic;

		Tx_can_send_FCT     : in    boolean;

		Rx_FIFO_out_data    : in    nonet;
		Rx_FIFO_out_OR      : in    boolean;
		Rx_FIFO_out_IR      : in    boolean;
	
		send_FCT            :   out boolean;
		FCT_sent            : in    boolean
	);
end spw_rx_flowcredit_x;


---------------------------------------------------------------------------------------------------------------------------------
-- Code Description & Developer Notes --
---------------------------------------------------------------------------------------------------------------------------------


architecture rtl of spw_rx_flowcredit_x is

	----------------------------------------------------------------------------------------------------------------------------
	-- Constant Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Type Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Signal Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	signal FCT_to_send        : std_logic_vector( fifo_size / 8 downto 1 );
	signal nchars_read        : integer range 0 to 7;
	signal last_lsb           : integer range 0 to 1;
	signal up                 : boolean;
	signal down               : boolean;
	signal FCT_Sent_d         : boolean;
	signal extn               : boolean;
	signal extn_count         : unsigned(3 downto 0);
	----------------------------------------------------------------------------------------------------------------------------
	-- Variable Declarations --
	----------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
	-- Alias Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Attribute Declarations --
	----------------------------------------------------------------------------------------------------------------------------
	
begin

	----------------------------------------------------------------------------------------------------------------------------
	-- Entity Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Component Instantiations --
	----------------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Signal Assignments --
	----------------------------------------------------------------------------------------------------------------------------
	extn <= Rx_FIFO_out_data(8) = '1' and Rx_FIFO_out_data /= SPW_EOP and Rx_FIFO_out_data /= SPW_EEP;
	
	----------------------------------------------------------------------------------------------------------------------------
	-- Synchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------
	process( clock, reset )
    begin
		if (reset = '1') then
			FCT_to_send <= (others => '1');
			nchars_read <= fifo_size mod 8;
			last_lsb    <= 0;
			send_FCT    <= false;
			FCT_sent_d  <= false;
			extn_count  <= (others => '0');
		elsif rising_edge(clock) then
			if Tx_can_send_FCT then
				if Rx_FIFO_out_OR and Rx_FIFO_out_IR then
					if extn then
						if Rx_FIFO_out_data(7) = '1' then 
							extn_count <= unsigned(Rx_FIFO_out_data(3 downto 0));
                        else 
							extn_count <= (others => '0');
						end if;
					elsif extn_count /= 0 then
						extn_count <= extn_count - 1;
                    else
						nchars_read <= (nchars_read + 1) mod 8;
					end if;
				end if;

				up   <= 	not FCT_sent and     (nchars_read = 0 and last_lsb = 1);
				down <=     FCT_sent and not (nchars_read = 0 and last_lsb = 1);

				if up then 
					FCT_to_send <= FCT_to_send(FCT_to_send'high-1 downto 1) & '1';
				elsif down then 
					FCT_to_send <= '0' & FCT_to_send(FCT_to_send'high   downto 2);
				end if;
          
				last_lsb <= nchars_read mod 2;
            
				FCT_sent_d <= FCT_sent;
				send_FCT <= Fct_to_send(1) = '1' and not FCT_sent and not FCT_sent_d;
        
            else
				FCT_to_send <= (others => '1');
				nchars_read <= fifo_size mod 8;
				last_lsb    <= fifo_size mod 2;
				send_FCT    <= false;
				FCT_sent_d  <= false;
			end if;

		end if;
    end process;
	----------------------------------------------------------------------------------------------------------------------------
	-- Asynchronous Processes --
	----------------------------------------------------------------------------------------------------------------------------


end rtl;