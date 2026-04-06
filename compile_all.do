vlib work
vmap work work

# Compile all RTL files
vlog "rtl/riscv_defs.vh"
vlog +incdir+rtl "rtl/pc_unit.v"
vlog +incdir+rtl "rtl/instruction_memory.v"
vlog +incdir+rtl "rtl/register_file.v"
vlog +incdir+rtl "rtl/data_memory.v"
vlog +incdir+rtl "rtl/imm_gen.v"
vlog +incdir+rtl "rtl/alu_control.v"
vlog +incdir+rtl "rtl/alu_unit.v"
vlog +incdir+rtl "rtl/fetch_unit.v"
vlog +incdir+rtl "rtl/branch_comparator_unit.v"
vlog +incdir+rtl "rtl/control_unit.v"
vlog +incdir+rtl "rtl/riscv_core.v"

# Compile testbench
vlog +incdir+rtl "dv/Riscv_Core_tb.v"

# Run simulation
vsim -t 1ps work.riscv_core_tb
run -all
