package ALSU_driver_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import ALSU_cfg_pkg::*;
import shared_package_ALSU ::*;
 import ALSU_seq_item_pkg ::*;
class ALSU_driver extends uvm_driver #(ALSU_seq_item);
`uvm_component_utils (ALSU_driver) 
ALSU_seq_item stim_seq_item ;
virtual ALSU_if ALSU_vif ;
ALSU_config ALSU_cfg ;
function new (string name = "ALSU_driver" ,uvm_component parent= null) ;
super.new(name , parent ) ;
endfunction

function void build_phase (uvm_phase phase ) ;
super.build_phase(phase ) ;
if(!uvm_config_db #(ALSU_config):: get(this, "" ,"CFG",ALSU_cfg)) begin
`uvm_fatal("build_phase" , "unable to get config")
end
endfunction
function void connect_phase (uvm_phase phase);
super.connect_phase (phase);

ALSU_vif = ALSU_cfg.ALSU_vif ;
endfunction
task run_phase(uvm_phase phase);
  super.run_phase(phase);
  forever begin
    stim_seq_item = ALSU_seq_item::type_id::create("stim_seq_item");
    seq_item_port.get_next_item(stim_seq_item);

    ALSU_vif.direction = direction_e'(stim_seq_item.direction);
    ALSU_vif.cin       = stim_seq_item.cin;
    ALSU_vif.red_op_A  = stim_seq_item.red_op_A;
    ALSU_vif.red_op_B  = stim_seq_item.red_op_B;
    ALSU_vif.bypass_A  = stim_seq_item.bypass_A;
    ALSU_vif.bypass_B  = stim_seq_item.bypass_B;
    ALSU_vif.opcode    = opcode_e'(stim_seq_item.opcode);
    ALSU_vif.serial_in = stim_seq_item.serial_in;
    ALSU_vif.A         = stim_seq_item.A;
    ALSU_vif.B         = stim_seq_item.B;
    ALSU_vif.rst       = stim_seq_item.rst;

    @(negedge ALSU_vif.clk);
    seq_item_port.item_done();

    `uvm_info("run_phase", stim_seq_item.convert2string_stimulus(), UVM_HIGH)
  end
endtask
endclass
endpackage
