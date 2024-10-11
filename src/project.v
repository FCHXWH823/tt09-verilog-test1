/*
 * Copyright (c) 2024 Weihua Xiao
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_koggestone_adder4 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [3:0] a, b;
  wire [3:0] sum;
  wire carry_out;
  
  assign a = ui_in[3:0];
  assign b = ui_in[7:4];
   

  wire [3:0] p; // Propagate
  wire [3:0] g; // Generate
  wire [3:0] c; // Carry

  // Precompute generate and propagate signals
  assign p = a ^ b; // Propagate
  assign g = a & b; // Generate

  // Stage 1: Compute generate and propagate signals for neighbor 1-bit pairs
  wire g1_0, g1_1, g1_2, g1_3;
  wire p1_0, p1_1, p1_2, p1_3;

  assign g1_0 = g[0];                               // First bit generate stays the same
  assign p1_0 = p[0];                               // First bit propagate stays the same
  assign g1_1 = g[1] | (p[1] & g[0]);               // Combine 1st and 0th bits
  assign p1_1 = p[1] & p[0];                        // Combine propagate of 1st and 0th bits
  assign g1_2 = g[2] | (p[2] & g[1]);               // Combine 2nd and 1st bits
  assign p1_2 = p[2] & p[1];                        // Combine propagate of 2nd and 1st bits
  assign g1_3 = g[3] | (p[3] & g[2]);               // Combine 3rd and 2nd bits
  assign p1_3 = p[3] & p[2];                        // Combine propagate of 3rd and 2nd bits

  // Stage 2: Compute generate and propagate signals for 2-bit groups
  wire g2_0, g2_1, g2_2, g2_3;
  wire p2_0, p2_1, p2_2, p2_3;

  assign g2_0 = g1_0;                               // No change for the 0th bit
  assign p2_0 = p1_0;                               // No change for the 0th bit
  assign g2_1 = g1_1;                               // No change for the 1st bit
  assign p2_1 = p1_1;                               // No change for the 1st bit
  assign g2_2 = g1_2 | (p1_2 & g1_0);               // Combine 2-bit group (2nd and 0th bits)
  assign p2_2 = p1_2 & p1_0;                        // Combine propagate of 2-bit group
  assign g2_3 = g1_3 | (p1_3 & g1_1);               // Combine 2-bit group (3rd and 1st bits)
  assign p2_3 = p1_3 & p1_1;                        // Combine propagate of 2-bit group

  // Stage 3: Compute final carry signals (full 4-bit group)
  wire g3_0, g3_1, g3_2, g3_3;

  assign g3_0 = g2_0;                               // No change for the 0th bit
  assign g3_1 = g2_1;                               // No change for the 1st bit
  assign g3_2 = g2_2;                               // No change for the 2nd bit
  assign g3_3 = g2_3 | (p2_3 & g2_0);               // Combine 4-bit group (3rd and 0th bits)

  // Compute final carry and sum
  assign c[0] = 0;                                  // No carry into the first bit
  assign c[1] = g3_0;
  assign c[2] = g3_1;
  assign c[3] = g3_2;
  assign carry_out = g3_3;

  // Sum computation
  assign sum = p ^ c;                               // XOR of propagate and carry

  assign uo_out[3:0] = sum;
  assign uo_out[4] = carry_out; 
endmodule