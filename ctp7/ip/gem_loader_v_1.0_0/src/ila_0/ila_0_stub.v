// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.1 (lin64) Build 1538259 Fri Apr  8 15:45:23 MDT 2016
// Date        : Fri Dec 23 13:34:40 2016
// Host        : moonraker.cern.ch running 64-bit Scientific Linux CERN SLC release 6.8 (Carbon)
// Command     : write_verilog -force -mode synth_stub /data/alex/test/ip_repo/gem_loader_v_1.0/src/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "ila,Vivado 2016.1" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4, probe5, probe6)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[7:0],probe1[0:0],probe2[0:0],probe3[0:0],probe4[0:0],probe5[0:0],probe6[0:0]" */;
  input clk;
  input [7:0]probe0;
  input [0:0]probe1;
  input [0:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
endmodule
