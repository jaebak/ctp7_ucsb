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
    constant CFG_NUM_OF_OHs         : integer := 4;     -- total number of OHs to instanciate (remember to adapt the CFG_OH_LINK_CONFIG_ARR accordingly)

    -- this should normally be set to false, but in special cases where the board is in a test stand that doesn't have AMC13, the board can use the internal oscillator for MGTs
    -- and then this parameter should be set to true (in this case the clockinit command should also be updated in CTP7 to use the oscillator instead of the backplane for reference)
    constant CFG_DISABLE_TTC_PHASE_LOCKING : boolean := false;

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

    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
        (0, 1, 2, 24, 25), 
        (3, 4, 5, 26, 27),
        (6, 7, 8, 28, 29), 
        (9, 10, 11, 30, 31)
    );
    
--    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
--        (0, 1, 2, 0, 0), 
--        (3, 4, 5, 0, 0),
--        (6, 7, 8, 0, 0), 
--        (9, 10, 11, 0, 0),
--
--        (12, 13, 14, 0, 0), 
--        (15, 16, 17, 0, 0), 
--        (18, 19, 20, 0, 0), 
--        (21, 22, 23, 0, 0), 
--
--        (24, 25, 26, 0, 0), 
--        (27, 28, 29, 0, 0), 
--        (30, 31, 32, 0, 0), 
--        (33, 34, 35, 0, 0) 
--    );

    -- this record is used in CXP fiber to GTH map (holding tx and rx GTH index)
    type t_cxp_fiber_to_gth_link is record
        tx      : integer range 0 to 35; -- GTH TX index
        rx      : integer range 0 to 35; -- GTH RX index
    end record;
    
    -- this array is meant to hold mapping from CXP fiber index to GTH TX and RX indexes
    type t_cxp_fiber_to_gth_link_map is array (0 to 35) of t_cxp_fiber_to_gth_link;

    -- defines the GTH TX and RX index for each index of the CXP fiber
    constant CFG_CXP_FIBER_TO_GTH_MAP : t_cxp_fiber_to_gth_link_map := (
        (1, 2), -- fiber 0 (CXP 0)
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
        (13, 15), -- fiber 12 (CXP 1)
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
        (25, 27), -- fiber 24 (CXP 2)
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
        (31, 34)  -- fiber 35
    );
    
end package gem_board_config_package;
--============================================================================
--                                                                 Package end 
--============================================================================

