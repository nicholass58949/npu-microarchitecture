# NPU Makefile - Simplified Version

# Compiler settings
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Directory settings
RTL_DIR = rtl
COMMON_DIR = $(RTL_DIR)/common
COMPUTE_DIR = $(RTL_DIR)/compute
MEMORY_DIR = $(RTL_DIR)/memory
CONTROL_DIR = $(RTL_DIR)/control
SIM_DIR = sim
BUILD_DIR = build

# Core source files only
RTL_SOURCES = \
	$(COMMON_DIR)/npu_definitions.vh \
	$(COMMON_DIR)/host_interface.v \
	$(COMMON_DIR)/npu_top.v \
	$(COMPUTE_DIR)/mac_unit.v \
	$(COMPUTE_DIR)/activation_unit.v \
	$(COMPUTE_DIR)/pe_register_file.v \
	$(COMPUTE_DIR)/processing_element.v \
	$(COMPUTE_DIR)/pe_array.v \
	$(MEMORY_DIR)/global_buffer.v \
	$(MEMORY_DIR)/dma_controller.v \
	$(CONTROL_DIR)/instruction_decoder.v \
	$(CONTROL_DIR)/instruction_scheduler.v \
	$(CONTROL_DIR)/task_manager.v \
	rtl/utils/interrupt_controller.v

# Simulation files
SIM_SOURCES = $(SIM_DIR)/npu_testbench.v

# Output files
OUTPUT = $(BUILD_DIR)/npu_sim
VCD_FILE = $(BUILD_DIR)/npu.vcd

# Default target
all: compile

# Create build directory
$(BUILD_DIR):
	@if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)

# Compile
compile: $(BUILD_DIR) $(RTL_SOURCES) $(SIM_SOURCES)
	$(IVERILOG) -g2012 -o $(OUTPUT) -I $(COMMON_DIR) $(RTL_SOURCES) $(SIM_SOURCES)

# Simulate
sim: compile
	$(VVP) $(OUTPUT)

# View waveform
wave: $(VCD_FILE)
	$(GTKWAVE) $(VCD_FILE) &

# Clean
clean:
	@if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR)

# Help
help:
	@echo NPU Makefile
	@echo.
	@echo Available targets:
	@echo   all      - Compile all source files (default)
	@echo   compile  - Compile RTL and simulation files
	@echo   sim      - Compile and run simulation
	@echo   wave     - View simulation waveform
	@echo   clean    - Clean build directory
	@echo   help     - Display this help message
	@echo.
	@echo Examples:
	@echo   make          # Compile all files
	@echo   make sim      # Run simulation
	@echo   make wave     # View waveform
	@echo   make clean    # Clean build files

.PHONY: all compile sim wave clean help
