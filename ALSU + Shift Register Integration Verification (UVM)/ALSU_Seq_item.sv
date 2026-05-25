package ALSU_seq_item_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;
import shared_package_ALSU::*;

class ALSU_seq_item extends uvm_sequence_item;
  `uvm_object_utils(ALSU_seq_item)

  // Signals
  rand bit clk, rst, cin, red_op_A, red_op_B, bypass_B, bypass_A, serial_in;
  rand direction_e direction;
  rand bit signed [2:0] A, B;
  rand opcode_e opcode;

  logic [5:0] out;
  logic [15:0] leds;

  // Extra randoms
  rand corner_case_e corner_case;
  rand bit signed [2:0] other;
  rand one_bit_high_e one_bit_high;
  rand opcode_e arr_opcode[6];

  function new(string name = "ALSU_seq_item");
    super.new(name);
  endfunction

 
  function string convert2string();
    return $sformatf("%s reset = 0b%b, cin = 0b%b, red_op_A = 0b%b, red_op_B = 0b%b, bypass_A = 0b%b, bypass_B = 0b%b, serial_in = 0b%b, direction = %s, opcode = %s, A = 0b%b, B = 0b%b, leds = 0b%b, out = 0b%b",
                     super.convert2string(), rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, serial_in, direction, opcode, A, B, leds, out);
  endfunction

  function string convert2string_stimulus();
    return $sformatf("%s reset = 0b%b, cin = 0b%b, red_op_A = 0b%b, red_op_B = 0b%b, bypass_A = 0b%b, bypass_B = 0b%b, serial_in = 0b%b, direction = %s, opcode = %s, A = 0b%b, B = 0b%b",
                     super.convert2string(), rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, serial_in, direction, opcode, A, B);
  endfunction

 
  // Reset distribution
  constraint c_reset {
    rst dist {1 := 5, 0 := 95};
  }

  // Arithmetic operations
  constraint C_arth {
    if (opcode == ADD || opcode == MULT) {
      A dist {MAXPOS := 40, ZERO := 40, MAXNEG := 40, other := 20};
      B dist {MAXPOS := 40, ZERO := 40, MAXNEG := 40, other := 20};
    }
  }

  // Reduction operations
  constraint C_read_A_B {
    if (opcode == OR || opcode == XOR) {
      if (red_op_A) {
        A dist {0 := 20, one_bit_high := 80};
        B == 0;
      }
      else if (red_op_B) {
        B dist {0 := 20, one_bit_high := 80};
        A == 0;
      }
    }
  }

  // Opcode distribution
  constraint c_opcode {
    opcode dist {
      OR := 15, XOR := 15,
      ADD := 20, MULT := 20,
      SHIFT := 10, ROTATE := 10,
      INVALID_6 := 5, INVALID_7 := 5
    };
  }

  // Bypass behavior
  constraint c_bypass {
    bypass_A dist {1 := 10, 0 := 90};
    bypass_B dist {1 := 10, 0 := 90};
  }

  // Invalid reduction usage
  constraint c_invalid_red_op_A_B {
    if (opcode != OR && opcode != XOR) {
      red_op_A dist {0 := 80, 1 := 20};
      red_op_B dist {0 := 80, 1 := 20};
    }
  }

  // Unique opcode array
  constraint unique_opcode {
    foreach (arr_opcode[i]) {
      arr_opcode[i] inside {[OR:ROTATE]};
      foreach (arr_opcode[j]) {
        if (i != j)
          arr_opcode[i] != arr_opcode[j];
      }
    }
  }

endclass

endpackage