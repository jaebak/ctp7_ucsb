
`timescale 1 ns / 1 ps

`include "gem_loader_v_v1_0_tb_include.vh"

// lite_response Type Defines
`define RESPONSE_OKAY 2'b00
`define RESPONSE_EXOKAY 2'b01
`define RESP_BUS_WIDTH 2
`define BURST_TYPE_INCR  2'b01
`define BURST_TYPE_WRAP  2'b10

// AMBA AXI4 Lite Range Constants
`define S_CFG_AXI_MAX_BURST_LENGTH 1
`define S_CFG_AXI_DATA_BUS_WIDTH 32
`define S_CFG_AXI_ADDRESS_BUS_WIDTH 32
`define S_CFG_AXI_MAX_DATA_SIZE (`S_CFG_AXI_DATA_BUS_WIDTH*`S_CFG_AXI_MAX_BURST_LENGTH)/8

// Burst Size Defines
`define BURST_SIZE_4_BYTES   3'b010

// Lock Type Defines
`define LOCK_TYPE_NORMAL    1'b0

// AMBA S_C2C_AXI AXI4 Range Constants
`define S_C2C_AXI_MAX_BURST_LENGTH 8'b1111_1111
`define S_C2C_AXI_MAX_DATA_SIZE (`S_C2C_AXI_DATA_BUS_WIDTH*(`S_C2C_AXI_MAX_BURST_LENGTH+1))/8
`define S_C2C_AXI_DATA_BUS_WIDTH 32
`define S_C2C_AXI_ADDRESS_BUS_WIDTH 32
`define S_C2C_AXI_RUSER_BUS_WIDTH 1
`define S_C2C_AXI_WUSER_BUS_WIDTH 1

module gem_loader_v_v1_0_tb;
	reg tb_ACLK;
	reg tb_ARESETn;

	// Create an instance of the example tb
	`BD_WRAPPER dut (.ACLK(tb_ACLK),
				.ARESETN(tb_ARESETn));

	// Local Variables

	// AMBA S_CFG_AXI AXI4 Lite Local Reg
	reg [`S_CFG_AXI_DATA_BUS_WIDTH-1:0] S_CFG_AXI_rd_data_lite;
	reg [`S_CFG_AXI_DATA_BUS_WIDTH-1:0] S_CFG_AXI_test_data_lite [3:0];
	reg [`RESP_BUS_WIDTH-1:0] S_CFG_AXI_lite_response;
	reg [`S_CFG_AXI_ADDRESS_BUS_WIDTH-1:0] S_CFG_AXI_mtestAddress;
	reg [3-1:0]   S_CFG_AXI_mtestProtection_lite;
	integer S_CFG_AXI_mtestvectorlite; // Master side testvector
	integer S_CFG_AXI_mtestdatasizelite;
	integer result_slave_lite;


	// AMBA S_C2C_AXI AXI4 Local Reg
	reg [(`S_C2C_AXI_DATA_BUS_WIDTH*(`S_C2C_AXI_MAX_BURST_LENGTH+1)/16)-1:0] S_C2C_AXI_rd_data;
	reg [(`S_C2C_AXI_DATA_BUS_WIDTH*(`S_C2C_AXI_MAX_BURST_LENGTH+1)/16)-1:0] S_C2C_AXI_test_data [2:0];
	reg [(`RESP_BUS_WIDTH*(`S_C2C_AXI_MAX_BURST_LENGTH+1))-1:0] S_C2C_AXI_vresponse;
	reg [`S_C2C_AXI_ADDRESS_BUS_WIDTH-1:0] S_C2C_AXI_mtestAddress;
	reg [(`S_C2C_AXI_RUSER_BUS_WIDTH*(`S_C2C_AXI_MAX_BURST_LENGTH+1))-1:0] S_C2C_AXI_v_ruser;
	reg [(`S_C2C_AXI_WUSER_BUS_WIDTH*(`S_C2C_AXI_MAX_BURST_LENGTH+1))-1:0] S_C2C_AXI_v_wuser;
	reg [`RESP_BUS_WIDTH-1:0] S_C2C_AXI_response;
	integer  S_C2C_AXI_mtestID; // Master side testID
	integer  S_C2C_AXI_mtestBurstLength;
	integer  S_C2C_AXI_mtestvector; // Master side testvector
	integer  S_C2C_AXI_mtestdatasize;
	integer  S_C2C_AXI_mtestCacheType = 0;
	integer  S_C2C_AXI_mtestProtectionType = 0;
	integer  S_C2C_AXI_mtestRegion = 0;
	integer  S_C2C_AXI_mtestQOS = 0;
	integer  S_C2C_AXI_mtestAWUSER = 0;
	integer  S_C2C_AXI_mtestARUSER = 0;
	integer  S_C2C_AXI_mtestBUSER = 0;
	integer result_slave_full;


	// Simple Reset Generator and test
	initial begin
		tb_ARESETn = 1'b0;
	  #500;
		// Release the reset on the posedge of the clk.
		@(posedge tb_ACLK);
	  tb_ARESETn = 1'b1;
		@(posedge tb_ACLK);
	end

	// Simple Clock Generator
	initial tb_ACLK = 1'b0;
	always #10 tb_ACLK = !tb_ACLK;

	//------------------------------------------------------------------------
	// TEST LEVEL API: CHECK_RESPONSE_OKAY
	//------------------------------------------------------------------------
	// Description:
	// CHECK_RESPONSE_OKAY(lite_response)
	// This task checks if the return lite_response is equal to OKAY
	//------------------------------------------------------------------------
	task automatic CHECK_RESPONSE_OKAY;
		input [`RESP_BUS_WIDTH-1:0] response;
		begin
		  if (response !== `RESPONSE_OKAY) begin
			  $display("TESTBENCH ERROR! lite_response is not OKAY",
				         "\n expected = 0x%h",`RESPONSE_OKAY,
				         "\n actual   = 0x%h",response);
		    $stop;
		  end
		end
	endtask

	//------------------------------------------------------------------------
	// TEST LEVEL API: COMPARE_LITE_DATA
	//------------------------------------------------------------------------
	// Description:
	// COMPARE_LITE_DATA(expected,actual)
	// This task checks if the actual data is equal to the expected data.
	// X is used as don't care but it is not permitted for the full vector
	// to be don't care.
	//------------------------------------------------------------------------
	`define S_AXI_DATA_BUS_WIDTH 32 
	task automatic COMPARE_LITE_DATA;
		input [`S_AXI_DATA_BUS_WIDTH-1:0]expected;
		input [`S_AXI_DATA_BUS_WIDTH-1:0]actual;
		begin
			if (expected === 'hx || actual === 'hx) begin
				$display("TESTBENCH ERROR! COMPARE_LITE_DATA cannot be performed with an expected or actual vector that is all 'x'!");
		    result_slave_lite = 0;
		    $stop;
		  end

			if (actual != expected) begin
				$display("TESTBENCH ERROR! Data expected is not equal to actual.",
				         "\nexpected = 0x%h",expected,
				         "\nactual   = 0x%h",actual);
		    result_slave_lite = 0;
		    $stop;
		  end
			else 
			begin
			   $display("TESTBENCH Passed! Data expected is equal to actual.",
			            "\n expected = 0x%h",expected,
			            "\n actual   = 0x%h",actual);
			end
		end
	endtask

	//------------------------------------------------------------------------
	// TEST LEVEL API: COMPARE_DATA
	//------------------------------------------------------------------------
	// Description:
	// COMPARE_DATA(expected,actual)
	// This task checks if the actual data is equal to the expected data.
	// X is used as don't care but it is not permitted for the full vector
	// to be don't care.
	//------------------------------------------------------------------------
	`define S_AXI_DATA_BUS_WIDTH 32 
	`define S_AXI_BURST_LENGTH 16 
	task automatic COMPARE_DATA;
		input [(`S_AXI_DATA_BUS_WIDTH*`S_AXI_BURST_LENGTH)-1:0]expected;
		input [(`S_AXI_DATA_BUS_WIDTH*`S_AXI_BURST_LENGTH)-1:0]actual;
		begin
			if (expected === 'hx || actual === 'hx) begin
				$display("TESTBENCH ERROR! COMPARE_DATA cannot be performed with an expected or actual vector that is all 'x'!");
		    result_slave_full = 0;
		    $stop;
		  end

			if (actual != expected) begin
				$display("TESTBENCH ERROR! Data expected is not equal to actual.",
				         "\n expected = 0x%h",expected,
				         "\n actual   = 0x%h",actual);
		    result_slave_full = 0;
		    $stop;
		  end
			else 
			begin
			   $display("TESTBENCH Passed! Data expected is equal to actual.",
			            "\n expected = 0x%h",expected,
			            "\n actual   = 0x%h",actual);
			end
		end
	endtask

	task automatic S_CFG_AXI_TEST;
		begin
			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST : S_CFG_AXI");
			$display("Simple register write and read example");
			$display("---------------------------------------------------------");

			S_CFG_AXI_mtestvectorlite = 0;
			S_CFG_AXI_mtestAddress = `S_CFG_AXI_SLAVE_ADDRESS;
			S_CFG_AXI_mtestProtection_lite = 0;
			S_CFG_AXI_mtestdatasizelite = `S_CFG_AXI_MAX_DATA_SIZE;

			 result_slave_lite = 1;

			for (S_CFG_AXI_mtestvectorlite = 0; S_CFG_AXI_mtestvectorlite <= 3; S_CFG_AXI_mtestvectorlite = S_CFG_AXI_mtestvectorlite + 1)
			begin
			  dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT( S_CFG_AXI_mtestAddress,
				                     S_CFG_AXI_mtestProtection_lite,
				                     S_CFG_AXI_test_data_lite[S_CFG_AXI_mtestvectorlite],
				                     S_CFG_AXI_mtestdatasizelite,
				                     S_CFG_AXI_lite_response);
			  $display("EXAMPLE TEST %d write : DATA = 0x%h, lite_response = 0x%h",S_CFG_AXI_mtestvectorlite,S_CFG_AXI_test_data_lite[S_CFG_AXI_mtestvectorlite],S_CFG_AXI_lite_response);
			  CHECK_RESPONSE_OKAY(S_CFG_AXI_lite_response);
			  dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.READ_BURST(S_CFG_AXI_mtestAddress,
				                     S_CFG_AXI_mtestProtection_lite,
				                     S_CFG_AXI_rd_data_lite,
				                     S_CFG_AXI_lite_response);
			  $display("EXAMPLE TEST %d read : DATA = 0x%h, lite_response = 0x%h",S_CFG_AXI_mtestvectorlite,S_CFG_AXI_rd_data_lite,S_CFG_AXI_lite_response);
			  CHECK_RESPONSE_OKAY(S_CFG_AXI_lite_response);
			  COMPARE_LITE_DATA(S_CFG_AXI_test_data_lite[S_CFG_AXI_mtestvectorlite],S_CFG_AXI_rd_data_lite);
			  $display("EXAMPLE TEST %d : Sequential write and read burst transfers complete from the master side. %d",S_CFG_AXI_mtestvectorlite,S_CFG_AXI_mtestvectorlite);
			  S_CFG_AXI_mtestAddress = S_CFG_AXI_mtestAddress + 32'h00000004;
			end

			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST S_CFG_AXI: PTGEN_TEST_FINISHED!");
				if ( result_slave_lite ) begin                                        
					$display("PTGEN_TEST: PASSED!");                 
				end	else begin                                         
					$display("PTGEN_TEST: FAILED!");                 
				end							   
			$display("---------------------------------------------------------");
		end
	endtask

	task automatic S_C2C_AXI_TEST;
		begin
			//---------------------------------------------------------------------
			// EXAMPLE TEST 1:
			// Simple sequential write and read burst transfers example
			// DESCRIPTION:
			// The following master code does a simple write and read burst for
			// each burst transfer type.
			//---------------------------------------------------------------------
			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST S_C2C_AXI:");
			$display("Simple sequential write and read burst transfers example");
			$display("---------------------------------------------------------");
			
			S_C2C_AXI_mtestID = 1;
			S_C2C_AXI_mtestvector = 0;
			S_C2C_AXI_mtestBurstLength = 15;
			S_C2C_AXI_mtestAddress = `S_C2C_AXI_SLAVE_ADDRESS;
			S_C2C_AXI_mtestCacheType = 0;
			S_C2C_AXI_mtestProtectionType = 0;
			S_C2C_AXI_mtestdatasize = `S_C2C_AXI_MAX_DATA_SIZE;
			S_C2C_AXI_mtestRegion = 0;
			S_C2C_AXI_mtestQOS = 0;
			S_C2C_AXI_mtestAWUSER = 0;
			S_C2C_AXI_mtestARUSER = 0;
			 result_slave_full = 1;
			
			dut.`BD_INST_NAME.master_0.cdn_axi4_master_bfm_inst.WRITE_BURST_CONCURRENT(S_C2C_AXI_mtestID,
			                        S_C2C_AXI_mtestAddress,
			                        S_C2C_AXI_mtestBurstLength,
			                        `BURST_SIZE_4_BYTES,
			                        `BURST_TYPE_INCR,
			                        `LOCK_TYPE_NORMAL,
			                        S_C2C_AXI_mtestCacheType,
			                        S_C2C_AXI_mtestProtectionType,
			                        S_C2C_AXI_test_data[S_C2C_AXI_mtestvector],
			                        S_C2C_AXI_mtestdatasize,
			                        S_C2C_AXI_mtestRegion,
			                        S_C2C_AXI_mtestQOS,
			                        S_C2C_AXI_mtestAWUSER,
			                        S_C2C_AXI_v_wuser,
			                        S_C2C_AXI_response,
			                        S_C2C_AXI_mtestBUSER);
			$display("EXAMPLE TEST 1 : DATA = 0x%h, response = 0x%h",S_C2C_AXI_test_data[S_C2C_AXI_mtestvector],S_C2C_AXI_response);
			CHECK_RESPONSE_OKAY(S_C2C_AXI_response);
			S_C2C_AXI_mtestID = S_C2C_AXI_mtestID+1;
			dut.`BD_INST_NAME.master_0.cdn_axi4_master_bfm_inst.READ_BURST(S_C2C_AXI_mtestID,
			                       S_C2C_AXI_mtestAddress,
			                       S_C2C_AXI_mtestBurstLength,
			                       `BURST_SIZE_4_BYTES,
			                       `BURST_TYPE_WRAP,
			                       `LOCK_TYPE_NORMAL,
			                       S_C2C_AXI_mtestCacheType,
			                       S_C2C_AXI_mtestProtectionType,
			                       S_C2C_AXI_mtestRegion,
			                       S_C2C_AXI_mtestQOS,
			                       S_C2C_AXI_mtestARUSER,
			                       S_C2C_AXI_rd_data,
			                       S_C2C_AXI_vresponse,
			                       S_C2C_AXI_v_ruser);
			$display("EXAMPLE TEST 1 : DATA = 0x%h, vresponse = 0x%h",S_C2C_AXI_rd_data,S_C2C_AXI_vresponse);
			CHECK_RESPONSE_OKAY(S_C2C_AXI_vresponse);
			// Check that the data received by the master is the same as the test 
			// vector supplied by the slave.
			COMPARE_DATA(S_C2C_AXI_test_data[S_C2C_AXI_mtestvector],S_C2C_AXI_rd_data);

			$display("EXAMPLE TEST 1 : Sequential write and read FIXED burst transfers complete from the master side.");
			$display("---------------------------------------------------------");
			$display("EXAMPLE TEST S_C2C_AXI: PTGEN_TEST_FINISHED!");
				if ( result_slave_full ) begin				   
					$display("PTGEN_TEST: PASSED!");                 
				end	else begin                                         
					$display("PTGEN_TEST: FAILED!");                 
				end							   
			$display("---------------------------------------------------------");
		end
	endtask 

	// Create the test vectors
	initial begin
		// When performing debug enable all levels of INFO messages.
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);  

		dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.set_channel_level_info(1);

		// Create test data vectors
		S_CFG_AXI_test_data_lite[0] = 32'h0101FFFF;
		S_CFG_AXI_test_data_lite[1] = 32'habcd0001;
		S_CFG_AXI_test_data_lite[2] = 32'hdead0011;
		S_CFG_AXI_test_data_lite[3] = 32'hbeef0011;

		dut.`BD_INST_NAME.master_0.cdn_axi4_master_bfm_inst.set_channel_level_info(1);

		// Create test data vectors
		S_C2C_AXI_test_data[1] = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		S_C2C_AXI_test_data[0] = 512'h00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF;
		S_C2C_AXI_test_data[2] = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
		S_C2C_AXI_v_ruser = 0;
		S_C2C_AXI_v_wuser = 0;
	end

	// Drive the BFM
	initial begin
		// Wait for end of reset
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     

		S_C2C_AXI_TEST();

	end

	// Drive the BFM
	initial begin
		// Wait for end of reset
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     

		S_CFG_AXI_TEST();

	end

endmodule
