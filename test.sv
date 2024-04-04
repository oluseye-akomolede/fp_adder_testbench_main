`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 04:27:14 AM
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import tb_pkg::*;
program automatic test
    (
        adder_ifc.TB_rx rx,
        adder_ifc.TB_tx tx,
        input logic i_rst
    );
    
    
    environment env;
    initial begin
        env = new(rx,tx);
        env.gen_cfg();
        env.build();
        env.run();
        env.wrap_up();
    end
    
endprogram //test
