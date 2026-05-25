# ALSU + Shift Register Integration Verification (UVM)

## Overview
This project extends the ALSU (Arithmetic Logic Shift Unit) verification environment by integrating a **Shift Register** as an internal module to execute **shift and rotate operations**.

The verification architecture follows **UVM methodology** using **multiple environments with Active/Passive agent configuration**.

---

## Objective
Integrate the Shift Register into the ALSU environment and verify correct behavior for shift and rotate operations while maintaining modular and reusable UVM components.

---

## Design Integration

### ALSU Modification
The ALSU environment was updated to instantiate the Shift Register.

Integration changes:

- Removed **clock** and **reset** from the Shift Register verification environment for simplicity.
- Replaced:
  ```systemverilog
  @(negedge clk)
  ```
  with:
  ```systemverilog
  #2
  ```
  in:
  - Shift Register Driver
  - Shift Register Monitor

- Removed reset sequence.

### Connections
- Shift Register **Data Input** ← ALSU Output Port
- Shift Register **Data Output** → Internal 6-bit bus:
  ```text
  out_shift_reg
  ```

- Assigned:
  ```text
  ALSU_out = out_shift_reg
  ```
  during valid shift/rotate operations.

---

## Verification Architecture

The testbench uses **two independent UVM environments**:

### 1. ALSU Environment (Active)
Responsible for:
- Driving transactions
- Controlling ALSU interface
- Generating stimulus

Components:
- Agent (Active)
- Driver
- Sequencer
- Monitor
- Scoreboard
- Coverage

---

### 2. Shift Register Environment (Passive)
Responsible for:
- Monitoring only
- Capturing DUT responses
- Sending data to:
  - Scoreboard
  - Coverage Collector

Components:
- Agent (Passive)
- Monitor
- Scoreboard
- Coverage

---

## Environment Configuration

Two configuration objects are created:

| Environment | Virtual Interface | is_active |
|------------|-------------------|----------|
| ALSU | ALSU Interface | UVM_ACTIVE |
| Shift Register | Shift Interface | UVM_PASSIVE |

Example:

```systemverilog
alsu_cfg.is_active = UVM_ACTIVE;

shift_cfg.is_active = UVM_PASSIVE;
```

---

## Agent Behavior

### Build Phase
Agents check:

```systemverilog
if(config_obj.is_active == UVM_ACTIVE)
```

If active:
- Build Driver
- Build Sequencer

---

### Connect Phase

If:

```systemverilog
config_obj.is_active == UVM_ACTIVE
```

Then:
- Connect Driver ↔ Sequencer
- Connect Virtual Interface

Passive agents only instantiate the monitor.

---

## Top-Level Integration Flow

1. Add ALSU and Shift Register interfaces.
2. Pass interfaces through `config_db`.
3. Connect DUT interfaces.
4. Instantiate two environments.
5. Create two configuration objects.
6. Assign active/passive modes.
7. Run verification.

---

## Verification Features

✔ Multi-environment UVM architecture  
✔ Active / Passive agent configuration  
✔ Interface-based communication  
✔ Functional coverage collection  
✔ Scoreboard validation  
✔ Modular and reusable verification components  

---


## Author

Mahmoud Abdelnasser
Verification Engineer
