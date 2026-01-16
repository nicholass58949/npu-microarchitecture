@echo off
REM NPU Build Script for Windows

set IVERILOG=iverilog
set VVP=vvp
set GTKWAVE=gtkwave
set RTL_DIR=rtl
set COMMON_DIR=%RTL_DIR%\common
set COMPUTE_DIR=%RTL_DIR%\compute
set MEMORY_DIR=%RTL_DIR%\memory
set CONTROL_DIR=%RTL_DIR%\control
set NETWORK_DIR=%RTL_DIR%\network
set SPECIAL_DIR=%RTL_DIR%\special_functions
set UTILS_DIR=%RTL_DIR%\utils
set ENGINES_DIR=%RTL_DIR%\engines
set DATA_OPS_DIR=%RTL_DIR%\data_ops
set SIM_DIR=sim
set BUILD_DIR=build

if "%1"=="" goto help
if "%1"=="all" goto compile
if "%1"=="compile" goto compile
if "%1"=="sim" goto sim
if "%1"=="wave" goto wave
if "%1"=="clean" goto clean
if "%1"=="help" goto help

:compile
echo Creating build directory...
if not exist %BUILD_DIR% mkdir %BUILD_DIR%

echo Compiling RTL and simulation files...
%IVERILOG% -o %BUILD_DIR%\npu_sim -I %COMMON_DIR% ^
	%COMMON_DIR%\host_interface.v ^
	%COMMON_DIR%\npu_top.v ^
	%COMPUTE_DIR%\mac_unit.v ^
	%COMPUTE_DIR%\activation_unit.v ^
	%COMPUTE_DIR%\pe_register_file.v ^
	%COMPUTE_DIR%\processing_element.v ^
	%COMPUTE_DIR%\pe_array.v ^
	%MEMORY_DIR%\global_buffer.v ^
	%MEMORY_DIR%\local_buffer.v ^
	%MEMORY_DIR%\dma_controller.v ^
	%MEMORY_DIR%\cache_controller.v ^
	%MEMORY_DIR%\memory_arbiter.v ^
	%CONTROL_DIR%\instruction_scheduler.v ^
	%CONTROL_DIR%\task_manager.v ^
	%CONTROL_DIR%\barrier_synchronizer.v ^
	%CONTROL_DIR%\instruction_decoder.v ^
	%CONTROL_DIR%\load_balancer.v ^
	%NETWORK_DIR%\network_on_chip.v ^
	%NETWORK_DIR%\noc_router.v ^
	%NETWORK_DIR%\xy_router.v ^
	%NETWORK_DIR%\virtual_channel.v ^
	%NETWORK_DIR%\flow_control.v ^
	%SPECIAL_DIR%\pooling_unit.v ^
	%SPECIAL_DIR%\batch_normalization.v ^
	%SPECIAL_DIR%\softmax_unit.v ^
	%SPECIAL_DIR%\element_wise_op.v ^
	%SPECIAL_DIR%\concat_unit.v ^
	%UTILS_DIR%\quantization_unit.v ^
	%UTILS_DIR%\dequantization_unit.v ^
	%UTILS_DIR%\data_rearrange.v ^
	%UTILS_DIR%\zero_skipping.v ^
	%UTILS_DIR%\sparse_compression.v ^
	%UTILS_DIR%\clock_gating.v ^
	%UTILS_DIR%\power_gating.v ^
	%UTILS_DIR%\performance_counter.v ^
	%UTILS_DIR%\interrupt_controller.v ^
	%UTILS_DIR%\config_register.v ^
	%ENGINES_DIR%\conv_engine.v ^
	%ENGINES_DIR%\matmul_engine.v ^
	%DATA_OPS_DIR%\reshape_unit.v ^
	%DATA_OPS_DIR%\transpose_unit.v ^
	%DATA_OPS_DIR%\reduction_unit.v ^
	%DATA_OPS_DIR%\broadcast_unit.v ^
	%DATA_OPS_DIR%\slice_unit.v ^
	%DATA_OPS_DIR%\tile_unit.v ^
	%DATA_OPS_DIR%\pad_unit.v ^
	%SIM_DIR%\npu_testbench.v

if %ERRORLEVEL% EQU 0 (
	echo Compilation successful!
) else (
	echo Compilation failed with error code %ERRORLEVEL%
)
goto end

:sim
echo Running simulation...
call :compile
if %ERRORLEVEL% EQU 0 (
	%VVP% %BUILD_DIR%\npu_sim
)
goto end

:wave
echo Viewing waveform...
start %GTKWAVE% %BUILD_DIR%\npu.vcd
goto end

:clean
echo Cleaning build directory...
if exist %BUILD_DIR% rmdir /s /q %BUILD_DIR%
echo Clean complete!
goto end

:help
echo.
echo NPU Build Script for Windows
echo.
echo Usage: build.bat [target]
echo.
echo Available targets:
echo   all      - Compile all source files (default)
echo   compile  - Compile RTL and simulation files
echo   sim      - Compile and run simulation
echo   wave     - View simulation waveform
echo   clean    - Clean build directory
echo   help     - Display this help message
echo.
echo Examples:
echo   build.bat          # Compile all files
echo   build.bat sim      # Run simulation
echo   build.bat wave     # View waveform
echo   build.bat clean    # Clean build files
echo.

:end
