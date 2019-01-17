-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: gem_board_config_package
--                                                                            
--     Description: Configuration for CTP7 board
--
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--           Notes:                                                           
--                                                                            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--============================================================================
--                                                         Package declaration
--============================================================================
package gem_board_config_package is

    constant CFG_BOARD_TYPE         : std_logic_vector(3 downto 0) := x"1"; 

    constant CFG_USE_TRIG_LINKS     : boolean := true; -- this should be TRUE by default, but could be set to false for tests or quicker compilation if not needed
    constant CFG_NUM_OF_OHs         : integer := 12;   -- total number of OHs to instanciate (remember to adapt the CFG_OH_LINK_CONFIG_ARR accordingly)

    -- this should normally be set to false, but in special cases where the board is in a test stand that doesn't have AMC13, the board can use the internal oscillator for MGTs
    -- and then this parameter should be set to true (in this case the clockinit command should also be updated in CTP7 to use the oscillator instead of the backplane for reference)
    constant CFG_DISABLE_TTC_PHASE_LOCKING : boolean := false;

    constant CFG_USE_TRIG_TX_LINKS  : boolean := false; -- if true, then trigger transmitters will be instantiated (used to connect to EMTF)
    constant CFG_NUM_TRIG_TX        : integer := 12; -- number of trigger transmitters used to connect to EMTF

    --========================--
    --== Link configuration ==--
    --========================--

    -- defines the GT index for each type of OH link
    type t_oh_link_config is record
        gbt0_link       : integer range 0 to 79; -- main GBT link on OH v2b
        gbt1_link       : integer range 0 to 79; -- with OH v2b this is just for test, this will be needed with OH v3
        gbt2_link       : integer range 0 to 79; -- with OH v2b this is just for test, this will be needed with OH v3
        trig0_rx_link   : integer range 0 to 79; -- trigger RX link for clusters 0, 1, 2, 3
        trig1_rx_link   : integer range 0 to 79; -- trigger RX link for clusters 4, 5, 6, 7
    end record t_oh_link_config;
    
    type t_oh_link_config_arr is array (0 to CFG_NUM_OF_OHs - 1) of t_oh_link_config;

--    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
--        (0, 1, 2, 24, 25), 
--        (3, 4, 5, 26, 27) 
--    );

--    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
--        (0, 1, 2, 24, 25), 
--        (3, 4, 5, 26, 27),
--        (6, 7, 8, 28, 29), 
--        (9, 10, 11, 30, 31)
--    );
    
    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
        (0, 1, 2, 40, 41), 
        (3, 4, 5, 42, 43),
        (6, 7, 8, 44, 45), 
        (9, 10, 11, 46, 47),

        (12, 13, 14, 48, 49), 
        (15, 16, 17, 50, 51), 
        (18, 19, 20, 52, 53), 
        (21, 22, 23, 54, 55), 

        (24, 25, 26, 56, 57), 
        (27, 28, 29, 58, 59), 
        (30, 31, 32, 68, 69), 
        (33, 34, 35, 70, 71) 
    );

    type t_trig_tx_link_config_arr is array (0 to CFG_NUM_TRIG_TX - 1) of integer range 0 to 79;
    
    constant CFG_TRIG_TX_LINK_CONFIG_ARR : t_trig_tx_link_config_arr := (48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59);


    -- this record is used in CXP fiber to GTH map (holding tx and rx GTH index)
    type t_cxp_fiber_to_gth_link is record
        tx      : integer range 0 to 67; -- GTH TX index (#67 means disconnected/non-existing)
        rx      : integer range 0 to 67; -- GTH RX index (#67 means disconnected/non-existing)
    end record;
    
    -- this array is meant to hold mapping from CXP fiber index to GTH TX and RX indexes
    type t_cxp_fiber_to_gth_link_map is array (0 to 71) of t_cxp_fiber_to_gth_link;

    -- defines the GTH TX and RX index for each index of the CXP and MP fiber
    -- CXP0: fibers 0-11
    -- CXP1: fibers 12-23
    -- CXP2: fibers 24-35
    -- MP0 RX: fibers 36-47
    -- MP1 RX: fibers 48-59
    -- MP TX : fibers 48-59
    -- MP2 RX: fibers 60-71
    -- note that GTH channel #67 is used as a placeholder for fiber links that are not connected to the FPGA
    constant CFG_CXP_FIBER_TO_GTH_MAP : t_cxp_fiber_to_gth_link_map := (
        --=== CXP0 ===--
        (1, 2), -- fiber 0
        (3, 0), -- fiber 1
        (5, 4), -- fiber 2
        (0, 3), -- fiber 3
        (2, 5), -- fiber 4
        (4, 1), -- fiber 5
        (10, 7), -- fiber 6
        (8, 9), -- fiber 7
        (6, 10), -- fiber 8
        (11, 6), -- fiber 9
        (9, 8), -- fiber 10
        (7, 11), -- fiber 11
        --=== CXP1 ===--        
        (13, 15), -- fiber 12
        (15, 12), -- fiber 13
        (17, 16), -- fiber 14
        (12, 14), -- fiber 15 
        (14, 18), -- fiber 16
        (16, 13), -- fiber 17
        (22, 19), -- fiber 18
        (20, 23), -- fiber 19
        (18, 20), -- fiber 20
        (23, 17), -- fiber 21
        (21, 21), -- fiber 22
        (19, 22), -- fiber 23
        --=== CXP2 ===--        
        (25, 27), -- fiber 24
        (27, 24), -- fiber 25
        (29, 28), -- fiber 26
        (24, 26), -- fiber 27
        (26, 30), -- fiber 28
        (28, 25), -- fiber 29
        (34, 31), -- fiber 30
        (32, 35), -- fiber 31
        (30, 32), -- fiber 32
        (35, 29), -- fiber 33
        (33, 33), -- fiber 34
        (31, 34), -- fiber 35
        --=== no TX / MP0 RX ===--
        (67, 67), -- fiber 36 -- RX NULL (not connected)
        (67, 66), -- fiber 37
        (67, 64), -- fiber 38
        (67, 65), -- fiber 39
        (67, 62), -- fiber 40
        (67, 63), -- fiber 41
        (67, 61), -- fiber 42
        (67, 60), -- fiber 43
        (67, 59), -- fiber 44
        (67, 58), -- fiber 45
        (67, 57), -- fiber 46
        (67, 56), -- fiber 47
        --=== MP TX / MP1 RX ===--
        (59, 54), -- fiber 48 
        (56, 55), -- fiber 49
        (63, 52), -- fiber 50
        (52, 53), -- fiber 51
        (62, 50), -- fiber 52
        (53, 51), -- fiber 53
        (61, 49), -- fiber 54
        (54, 48), -- fiber 55
        (60, 47), -- fiber 56
        (55, 46), -- fiber 57
        (58, 45), -- fiber 58
        (57, 44), -- fiber 59
        --=== no TX / MP2 RX ===--
        (67, 67),  -- fiber 60 -- RX NULL (not connected)
        (67, 67), -- fiber 61 -- RX NULL (not connected)
        (67, 43), -- fiber 62
        (67, 67), -- fiber 63 -- RX NULL (not connected)
        (67, 42), -- fiber 64 
        (67, 67), -- fiber 65 -- RX NULL (not connected)
        (67, 40), -- fiber 66
        (67, 36), -- fiber 67 -- RX inverted
        (67, 41), -- fiber 68 
        (67, 37), -- fiber 69 -- RX inverted
        (67, 38), -- fiber 70
        (67, 39) -- fiber 71        
    );
    
end package gem_board_config_package;
--============================================================================
--                                                                 Package end 
--============================================================================

