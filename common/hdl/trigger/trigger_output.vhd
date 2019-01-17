------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    00:11 2019-01-16
-- Module Name:    trigger_output
-- Description:    This module formats the trigger data for output to EMTF  
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.gem_pkg.all;
use work.ttc_pkg.all;

entity trigger_output is
    generic(
        g_NUM_OF_OHs        : integer;
        g_NUM_TRIG_TX_LINKS : integer
    );
    port(
        -- reset
        reset_i                 : in  std_logic;
        
        -- TTC
        ttc_clk_i               : in  t_ttc_clks;
        ttc_cmds_i              : in  t_ttc_cmds;

        -- Sbit cluster inputs
        sbit_clusters_i         : in  t_oh_sbits_arr(g_NUM_OF_OHs - 1 downto 0);
        sbit_link_status_i      : in  t_oh_sbit_links_arr(g_NUM_OF_OHs - 1 downto 0);

        -- Outputs
        tx_link_clk_i           : in  std_logic;
        trig_tx_data_arr_o      : out t_gt_8b10b_tx_data_arr(g_NUM_TRIG_TX_LINKS - 1 downto 0)
        
    );
end trigger_output;

architecture trigger_output_arch of trigger_output is

    constant FRAME_MARKERS          : t_std8_array(0 to 3) := (x"bc", x"f7", x"fb", x"fd");
    type state_t is (COMMA, DATA_0, DATA_1, DATA_2);    
    
    signal state                : state_t := COMMA;
    signal frame_counter        : integer range 0 to 3 := 0;
    
begin
    
    -- dummy output, emulating an OH
    
    process(tx_link_clk_i)
    begin
        if (rising_edge(tx_link_clk_i)) then
            if (reset_i = '1') then
                state <= COMMA;
                frame_counter <= 0;
            else
                case state is
                    when COMMA =>
                        if (frame_counter = 3) then
                            frame_counter <= 0;
                        else
                            frame_counter <= frame_counter + 1;
                        end if;
                        state <= DATA_0;
                    when DATA_0 =>
                        state <= DATA_1;
                    when DATA_1 =>
                        state <= DATA_2;
                    when DATA_2 =>
                        state <= COMMA;                        
                    when others =>
                        state <= COMMA;
                        
                end case;
            end if;
        end if;
    end process;  
    
    g_trig_tx_links: for i in 0 to g_NUM_TRIG_TX_LINKS - 1 generate
        process(tx_link_clk_i)
        begin
            if (rising_edge(tx_link_clk_i)) then
                case state is
                    when COMMA =>
                        trig_tx_data_arr_o(i).txdata <= x"000000" & FRAME_MARKERS(frame_counter);
                        trig_tx_data_arr_o(i).txcharisk <= "0001"; 
                        trig_tx_data_arr_o(i).txchardispmode <= (others => '0');
                        trig_tx_data_arr_o(i).txchardispval <= (others => '0');
                    when DATA_0 =>
                        trig_tx_data_arr_o(i).txdata <= x"ffffffff";
                        trig_tx_data_arr_o(i).txcharisk <= "0000"; 
                        trig_tx_data_arr_o(i).txchardispmode <= (others => '0');
                        trig_tx_data_arr_o(i).txchardispval <= (others => '0');                            
                    when DATA_1 =>
                        trig_tx_data_arr_o(i).txdata <= x"ffffffff";
                        trig_tx_data_arr_o(i).txcharisk <= "0000"; 
                        trig_tx_data_arr_o(i).txchardispmode <= (others => '0');
                        trig_tx_data_arr_o(i).txchardispval <= (others => '0');                            
                    when DATA_2 =>
                        trig_tx_data_arr_o(i).txdata <= x"ffffffff";
                        trig_tx_data_arr_o(i).txcharisk <= "0000"; 
                        trig_tx_data_arr_o(i).txchardispmode <= (others => '0');
                        trig_tx_data_arr_o(i).txchardispval <= (others => '0');                            
                    when others =>
                        trig_tx_data_arr_o(i).txdata <= x"ffffffff";
                        trig_tx_data_arr_o(i).txcharisk <= "0000"; 
                        trig_tx_data_arr_o(i).txchardispmode <= (others => '0');
                        trig_tx_data_arr_o(i).txchardispval <= (others => '0');                        
                end case;
            end if;
        end process;
    end generate;
    
end trigger_output_arch;