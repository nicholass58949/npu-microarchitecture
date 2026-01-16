# NPU Makefile

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
NETWORK_DIR = $(RTL_DIR)/network
SPECIAL_DIR = $(RTL_DIR)/special_functions
UTILS_DIR = $(RTL_DIR)/utils
ENGINES_DIR = $(RTL_DIR)/engines
DATA_OPS_DIR = $(RTL_DIR)/data_ops
SIM_DIR = sim
BUILD_DIR = build

# Source files
RTL_SOURCES = \
	$(COMMON_DIR)/host_interface.v \
	$(COMMON_DIR)/npu_top.v \
	$(COMPUTE_DIR)/mac_unit.v \
	$(COMPUTE_DIR)/activation_unit.v \
	$(COMPUTE_DIR)/pe_register_file.v \
	$(COMPUTE_DIR)/processing_element.v \
	$(COMPUTE_DIR)/pe_array.v \
	$(MEMORY_DIR)/global_buffer.v \
	$(MEMORY_DIR)/local_buffer.v \
	$(MEMORY_DIR)/dma_controller.v \
	$(MEMORY_DIR)/cache_controller.v \
	$(MEMORY_DIR)/memory_arbiter.v \
	$(CONTROL_DIR)/instruction_scheduler.v \
	$(CONTROL_DIR)/task_manager.v \
	$(CONTROL_DIR)/barrier_synchronizer.v \
	$(CONTROL_DIR)/instruction_decoder.v \
	$(CONTROL_DIR)/load_balancer.v \
	$(NETWORK_DIR)/network_on_chip.v \
	$(NETWORK_DIR)/noc_router.v \
	$(NETWORK_DIR)/xy_router.v \
	$(NETWORK_DIR)/virtual_channel.v \
	$(NETWORK_DIR)/flow_control.v \
	$(SPECIAL_DIR)/pooling_unit.v \
	$(SPECIAL_DIR)/batch_normalization.v \
	$(SPECIAL_DIR)/softmax_unit.v \
	$(SPECIAL_DIR)/element_wise_op.v \
	$(SPECIAL_DIR)/concat_unit.v \
	$(UTILS_DIR)/quantization_unit.v \
	$(UTILS_DIR)/dequantization_unit.v \
	$(UTILS_DIR)/data_rearrange.v \
	$(UTILS_DIR)/zero_skipping.v \
	$(UTILS_DIR)/sparse_compression.v \
	$(UTILS_DIR)/clock_gating.v \
	$(UTILS_DIR)/power_gating.v \
	$(UTILS_DIR)/performance_counter.v \
	$(UTILS_DIR)/interrupt_controller.v \
	$(UTILS_DIR)/config_register.v \
	$(ENGINES_DIR)/conv_engine.v \
	$(ENGINES_DIR)/matmul_engine.v \
	$(DATA_OPS_DIR)/reshape_unit.v \
	$(DATA_OPS_DIR)/transpose_unit.v \
	$(DATA_OPS_DIR)/reduction_unit.v \
	$(DATA_OPS_DIR)/broadcast_unit.v \
	$(DATA_OPS_DIR)/slice_unit.v \
	$(DATA_OPS_DIR)/tile_unit.v \
	$(DATA_OPS_DIR)/pad_unit.v

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
	$(IVERILOG) -o $(OUTPUT) -I $(COMMON_DIR) $(RTL_SOURCES) $(SIM_SOURCES)

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
