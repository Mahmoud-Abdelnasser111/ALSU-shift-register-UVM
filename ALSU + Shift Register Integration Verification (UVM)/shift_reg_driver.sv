package shift_reg_driver_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import shift_reg_cfg_pkg::*;
import shift_reg_seq_item_pkg::*;

class shift_reg_driver extends uvm_driver #(shift_reg_seq_item);

  `uvm_component_utils(shift_reg_driver)

  shift_reg_seq_item stim_seq_item;
  virtual shift_reg_if shift_reg_vif;
  shift_reg_config shift_reg_cfg;

  function new(string name = "shift_reg_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(shift_reg_config)::get(this, "", "SHIFT_CFG", shift_reg_cfg)) begin
      `uvm_fatal("build_phase", "Unable to get shift_reg config")
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    shift_reg_vif = shift_reg_cfg.shift_reg_vif;
  endfunction

  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin

      seq_item_port.get_next_item(stim_seq_item);

      // drive signals
      shift_reg_vif.direction = stim_seq_item.direction;
      shift_reg_vif.mode      = stim_seq_item.mode;
      shift_reg_vif.datain    = stim_seq_item.datain;
      shift_reg_vif.serial_in = stim_seq_item.serial_in;

      

      #2;

      seq_item_port.item_done();

      `uvm_info("DRIVER",
        stim_seq_item.convert2string_stimulus(),
        UVM_HIGH)

    end
  endtask

endclass

endpackage
