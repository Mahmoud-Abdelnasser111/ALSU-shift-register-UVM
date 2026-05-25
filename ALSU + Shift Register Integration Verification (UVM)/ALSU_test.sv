package ALSU_test_pkg;
import shift_reg_cfg_pkg::*;
import ALSU_cfg_pkg::*;
import ALSU_env_pkg::*;
import shift_reg_agent_pkg::*;  
import uvm_pkg::*;
import ALSU_main_sequence_pkg::*;
`include "uvm_macros.svh"

class ALSU_test extends uvm_test;

  `uvm_component_utils(ALSU_test)

  ALSU_env env;

 
  ALSU_config  ALSU_cfg;
  shift_reg_config shift_cfg;  


  virtual ALSU_if ALSU_vif;
  virtual shift_reg_if shift_vif;  

 
  ALSU_main_sequence main_seq;
  ALSU_reset_sequence reset_seq;

  function new(string name = "ALSU_env", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

  
    env = ALSU_env::type_id::create("env", this);

   
    ALSU_cfg  = ALSU_config::type_id::create("ALSU_cfg");
    shift_cfg = shift_reg_config::type_id::create("shift_cfg");

  
    main_seq  = ALSU_main_sequence::type_id::create("main_seq", this);
    reset_seq = ALSU_reset_sequence::type_id::create("reset_seq", this);

    
    if(!uvm_config_db #(virtual ALSU_if)::get(this, "", "ALSU_if", ALSU_cfg.ALSU_vif))
      `uvm_fatal("build_phase", "Cannot get ALSU_if")

    if(!uvm_config_db #(virtual shift_reg_if)::get(this, "", "shift_reg_if", shift_vif))
      `uvm_fatal("build_phase", "Cannot get shift_reg_if")

   
    shift_cfg.shift_reg_vif = shift_vif;
    shift_cfg.is_active = UVM_PASSIVE;   

   
    uvm_config_db #(ALSU_config)::set(this, "*", "CFG", ALSU_cfg);
    uvm_config_db #(shift_reg_config)::set(this, "*", "SHIFT_CFG", shift_cfg);

  endfunction

  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);

    `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
    reset_seq.start(env.agt.sqr);

    `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_seq.start(env.agt.sqr);

    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass

endpackage