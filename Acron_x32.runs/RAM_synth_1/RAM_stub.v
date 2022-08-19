// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Aug  9 02:32:03 2022
// Host        : Julian-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_stub.v
// Design      : RAM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module RAM(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[12:0],dina[31:0],douta[31:0],clkb,web[0:0],addrb[12:0],dinb[31:0],doutb[31:0]" */;
  input clka;
  input [0:0]wea;
  input [12:0]addra;
  input [31:0]dina;
  output [31:0]douta;
  input clkb;
  input [0:0]web;
  input [12:0]addrb;
  input [31:0]dinb;
  output [31:0]doutb;
endmodule
