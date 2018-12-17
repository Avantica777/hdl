// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
// csc = c1*d[23:16] + c2*d[15:8] + c3*d[7:0] + c4;

`timescale 1ns/100ps

module ad_csc #(

  parameter   DELAY_DW    = 16) (

  // data

  input                         clk,
  input       [DELAY_DW-1:0]    sync,
  input       [        23:0]    data,

  // constants

  input  signed     [16:0]      C1,
  input  signed     [16:0]      C2,
  input  signed     [16:0]      C3,
  input  signed     [23:0]      C4,

  // sync is delay matched

  output reg  [DELAY_DW-1:0]    csc_sync,
  output      [         7:0]    csc_data);

  // internal wires

  reg  signed [        23:0]  data_d1;
  reg  signed [        23:0]  data_d2;
  reg  signed [        25:0]  data_1;
  reg  signed [        25:0]  data_2;
  reg  signed [        25:0]  data_3;
  reg  signed [        25:0]  s_data_1;
  reg  signed [        25:0]  s_data_2;
  reg  signed [        25:0]  s_data_3;
  reg         [DELAY_DW-1:0]  sync_1_m;
  reg         [DELAY_DW-1:0]  sync_2_m;
  reg         [DELAY_DW-1:0]  sync_3_m;
  reg         [DELAY_DW-1:0]  sync_4_m;
  reg         [         7:0]  csc_data_d;


  wire signed [8:0]  color1;
  wire signed [8:0]  color2;
  wire signed [8:0]  color3;

  // delay signals

  always @(posedge clk) begin
    data_d1 <= data;
    data_d2 <= data_d1;
    sync_1_m <= sync;
    sync_2_m <= sync_1_m;
    sync_3_m <= sync_2_m;
    sync_4_m <= sync_3_m;
    csc_sync <= sync_4_m;
  end

  assign color1 = {1'd0,    data[23:16]};
  assign color2 = {1'd0, data_d1[15: 8]};
  assign color3 = {1'd0, data_d2[ 7: 0]};

  // pipeline DSPs for multiplications and additions

  always @(posedge clk) begin
    data_1 <= color1 * C1;
    data_2 <= color2 * C2;
    data_3 <= color3 * C3;
  end

  always @(posedge clk) begin
    s_data_1 <= data_1 + C4;
    s_data_2 <= s_data_1 + data_2;
    s_data_3 <= s_data_2 + data_3;
  end

  assign csc_data = s_data_3[23:16];

endmodule

// ***************************************************************************
// ***************************************************************************
