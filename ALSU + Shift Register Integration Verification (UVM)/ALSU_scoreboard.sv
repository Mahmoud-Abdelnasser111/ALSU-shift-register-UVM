package ALSU_scoreboard_pkg;

parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER    = "ON";

import shared_package_ALSU::*;
import ALSU_seq_item_pkg::*;
import shift_reg_seq_item_pkg::*;   
import uvm_pkg::*;
`include "uvm_macros.svh"

class ALSU_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(ALSU_scoreboard)

 
  uvm_analysis_export #(ALSU_seq_item) sb_export;
  uvm_tlm_analysis_fifo #(ALSU_seq_item) sb_fifo;
  ALSU_seq_item seq_item_sb;


  uvm_analysis_export #(shift_reg_seq_item) shift_export;
  uvm_tlm_analysis_fifo #(shift_reg_seq_item) shift_fifo;
  shift_reg_seq_item shift_item;


  int error_count = 0;
  int correct_count = 0;


  bit [15:0] leds_ref;
  bit signed [5:0] out_ref;

  function new(string name = "ALSU_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    sb_export    = new("sb_export", this);
    sb_fifo      = new("sb_fifo", this);

    shift_export = new("shift_export", this);   
    shift_fifo   = new("shift_fifo", this);   
  endfunction

 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    sb_export.connect(sb_fifo.analysis_export);
    shift_export.connect(shift_fifo.analysis_export);
  endfunction

 
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin

      sb_fifo.get(seq_item_sb);
      shift_fifo.get(shift_item); 

      ref_model(seq_item_sb);

    
      if (seq_item_sb.opcode == 3'h4 || seq_item_sb.opcode == 3'h5) begin

        if (seq_item_sb.out !== shift_item.dataout) begin
          `uvm_error("run_phase",
            $sformatf("SHIFT/ROTATE ERROR | DUT=%0h SHIFT=%0h",
            seq_item_sb.out, shift_item.dataout))
          error_count++;
        end
        else begin
          correct_count++;
        end

      end

      
      else begin

        if (seq_item_sb.out !== out_ref || seq_item_sb.leds !== leds_ref) begin
          `uvm_error("run_phase",
            $sformatf("Mismatch | DUT=%0h REF=%0h",
            seq_item_sb.out, out_ref))
          error_count++;
        end
        else begin
          correct_count++;
        end

      end

    end
  endtask

  
  task ref_model(ALSU_seq_item item);

    static bit signed [2:0] A_reg = 0, B_reg = 0;
    static bit [2:0] opcode_reg = 0;
    static bit cin_reg = 0;
    static bit red_op_A_reg = 0, red_op_B_reg = 0;
    static bit bypass_A_reg = 0, bypass_B_reg = 0;

    static bit signed [5:0] out_reg = 0;
    static bit [15:0] leds_reg = 0;

    bit invalid;

  
    if (item.rst) begin
      A_reg = 0;
      B_reg = 0;
      opcode_reg = 0;
      cin_reg = 0;
      red_op_A_reg = 0;
      red_op_B_reg = 0;
      bypass_A_reg = 0;
      bypass_B_reg = 0;

      out_reg  = 0;
      leds_reg = 0;
    end

    else begin

     
      invalid = (item.opcode[1] & item.opcode[2]);

   
      if (invalid)
        leds_reg = ~leds_reg;
      else
        leds_reg = 0;

    
      if (bypass_A_reg && bypass_B_reg)
        out_reg = A_reg;

      else if (bypass_A_reg)
        out_reg = A_reg;

      else if (bypass_B_reg)
        out_reg = B_reg;

      else if (invalid)
        out_reg = 0;

      else begin
        case (opcode_reg)

          // OR
          3'h0: begin
            if (red_op_A_reg)
              out_reg = |A_reg;
            else if (red_op_B_reg)
              out_reg = |B_reg;
            else
              out_reg = A_reg | B_reg;
          end

          // XOR
          3'h1: begin
            if (red_op_A_reg)
              out_reg = ^A_reg;
            else if (red_op_B_reg)
              out_reg = ^B_reg;
            else
              out_reg = A_reg ^ B_reg;
          end

          // ADD
          3'h2: begin
            if (FULL_ADDER == "ON")
              out_reg = A_reg + B_reg + cin_reg;
            else
              out_reg = A_reg + B_reg;
          end

          // MULT
          3'h3: begin
            out_reg = A_reg * B_reg;
          end

    
          3'h4: out_reg = out_reg;
          3'h5: out_reg = out_reg;

          default: out_reg = 0;

        endcase
      end

      
      A_reg = item.A;
      B_reg = item.B;
      opcode_reg = item.opcode;
      cin_reg = item.cin;
      red_op_A_reg = item.red_op_A;
      red_op_B_reg = item.red_op_B;
      bypass_A_reg = item.bypass_A;
      bypass_B_reg = item.bypass_B;

    end

    
    out_ref  = out_reg;
    leds_ref = leds_reg;

  endtask

endclass

endpackage