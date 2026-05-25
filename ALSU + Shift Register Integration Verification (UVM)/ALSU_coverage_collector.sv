package ALSU_coverage_pkg;

  import ALSU_seq_item_pkg::*;
  import uvm_pkg::*;
  import shared_package_ALSU::*;
  `include "uvm_macros.svh"

  class ALSU_coverage extends uvm_component;
    `uvm_component_utils(ALSU_coverage)

    uvm_analysis_export #(ALSU_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(ALSU_seq_item) cov_fifo;
    ALSU_seq_item seq_item_cov;

    
    logic signed [2:0] A_cov, B_cov;
    opcode_e opcode_cov;
    logic cin_cov, red_op_A_cov, red_op_B_cov;
    logic bypass_A_cov, bypass_B_cov;
    logic direction_cov, serial_in_cov;

   
    covergroup cvr_grp;

     
      A_cp : coverpoint A_cov {
        bins A_data_0       = {0};
        bins A_data_max     = {MAXPOS};
        bins A_data_min     = {MAXNEG};
        bins A_data_default = default;
      }

     
      B_cp : coverpoint B_cov {
        bins B_data_0       = {0};
        bins B_data_max     = {MAXPOS};
        bins B_data_min     = {MAXNEG};
        bins B_data_default = default;
      }

     
      ALU_cp : coverpoint opcode_cov {
        bins bitwise[] = {OR, XOR};
        bins arith[]   = {ADD, MULT};
        bins shift[]   = {SHIFT, ROTATE};

       
        ignore_bins invalid = {INVALID_6, INVALID_7};
      }

      

      cross A_cov, B_cov, opcode_cov {
        bins arith = binsof(opcode_cov) intersect {ADD, MULT};
      }

      cross cin_cov, opcode_cov {
        bins add = binsof(opcode_cov) intersect {ADD};
      }

      cross direction_cov, opcode_cov {
        bins shift_rot = binsof(opcode_cov) intersect {SHIFT, ROTATE};
      }

      cross serial_in_cov, opcode_cov {
        bins shift = binsof(opcode_cov) intersect {SHIFT};
      }

      cross A_cov, B_cov, opcode_cov {
        bins bitwise = binsof(opcode_cov) intersect {OR, XOR};
        bins A_walk  = binsof(A_cov) intersect {3'b001,3'b010,3'b100};
        bins B_zero  = binsof(B_cov) intersect {0};
      }

      cross B_cov, A_cov, opcode_cov {
        bins bitwise = binsof(opcode_cov) intersect {OR, XOR};
        bins B_walk  = binsof(B_cov) intersect {3'b001,3'b010,3'b100};
        bins A_zero  = binsof(A_cov) intersect {0};
      }

      
      cross opcode_cov, red_op_A_cov, red_op_B_cov {

      
        ignore_bins red_invalid =
          binsof(opcode_cov) intersect {ADD, MULT, SHIFT, ROTATE} &&
          (binsof(red_op_A_cov) intersect {1} ||
           binsof(red_op_B_cov) intersect {1});

        
        bins bitwise_red =
          binsof(opcode_cov) intersect {OR, XOR};

      }

    endgroup

    
    function new(string name = "ALSU_coverage", uvm_component parent = null);
      super.new(name, parent);
      cvr_grp = new();
    endfunction

   
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cov_export = new("cov_export", this);
      cov_fifo   = new("cov_fifo", this);
    endfunction

   
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        cov_fifo.get(seq_item_cov);

       
        A_cov           = seq_item_cov.A;
        B_cov           = seq_item_cov.B;
        opcode_cov      = seq_item_cov.opcode;
        cin_cov         = seq_item_cov.cin;
        red_op_A_cov    = seq_item_cov.red_op_A;
        red_op_B_cov    = seq_item_cov.red_op_B;
        bypass_A_cov    = seq_item_cov.bypass_A;
        bypass_B_cov    = seq_item_cov.bypass_B;
        direction_cov   = seq_item_cov.direction;
        serial_in_cov   = seq_item_cov.serial_in;

        
        cvr_grp.sample();
      end
    endtask

  endclass

endpackage