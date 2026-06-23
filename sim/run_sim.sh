#!/bin/bash

# ============================================================================
# Simulation Script for Five-Stage Pipeline Datapath
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}================================================${NC}"
echo -e "${YELLOW}Five-Stage Pipeline Datapath Simulator${NC}"
echo -e "${YELLOW}================================================${NC}\n"

# Check if Icarus Verilog is installed
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}Error: Icarus Verilog (iverilog) not found${NC}"
    echo "Please install it with: sudo apt-get install iverilog gtkwave"
    exit 1
fi

# Create output directory
mkdir -p ../sim_output

echo -e "${YELLOW}[1/3] Compiling Verilog files...${NC}"
iverilog -o ../sim_output/pipeline_sim \
    ../rtl/pipeline_datapath.v \
    ../rtl/alu.v \
    ../rtl/control_unit.v \
    ../rtl/register_file.v \
    ../rtl/memory.v \
    ../rtl/pipeline_registers.v \
    ../tb/pipeline_datapath_tb.v

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Compilation successful${NC}\n"
else
    echo -e "${RED}[✗] Compilation failed${NC}\n"
    exit 1
fi

echo -e "${YELLOW}[2/3] Running simulation...${NC}"
vvp ../sim_output/pipeline_sim -vcd

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Simulation completed successfully${NC}\n"
else
    echo -e "${RED}[✗] Simulation failed${NC}\n"
    exit 1
fi

echo -e "${YELLOW}[3/3] Generating waveform...${NC}"
if [ -f ../sim_output/wave.vcd ]; then
    echo -e "${GREEN}[✓] Waveform file generated: ../sim_output/wave.vcd${NC}\n"
    echo -e "${YELLOW}To view the waveform, run:${NC}"
    echo -e "${GREEN}  gtkwave ../sim_output/wave.vcd${NC}\n"
else
    echo -e "${RED}[✗] Waveform generation failed${NC}\n"
fi

echo -e "${YELLOW}================================================${NC}"
echo -e "${GREEN}Simulation complete!${NC}"
echo -e "${YELLOW}================================================${NC}\n"