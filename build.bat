@echo off
REM NPU Build Script for Windows - Simplified Version

set IVERILOG=iverilog
set VVP=vvp
set GTKWAVE=gtkwave
set RTL_DIR=rtl
set COMMON_DIR=%RTL_DIR%\common
set COMPUTE_DIR=%RTL_DIR%\compute
set MEMORY_DIR=%RTL_DIR%\memory
set CONTROL_DIR=%RTL_DIR%\control
set SIM_DIR=sim
set BUILD_DIR=build

if "%1"=="" goto compile
if "%1"=="all" goto compile
if "%1"=="compile" goto compile
if "%1"=="sim" goto sim
if "%1"=="wave" goto wave
if "%1"=="clean" goto clean
if "%1"=="help" goto help
goto help

:compile
echo Creating build directory...
if not exist %BUILD_DIR% mkdir %BUILD_DIR%

echo Compiling RTL and simulation files...
%IVERILOG% -g2005-sv -o %BUILD_DIR%\npu_sim -I %COMMON_DIR% ^
	%COMMON_DIR%\npu_definitions.vh ^
	%COMMON_DIR%\host_interface.v ^
	%COMMON_DIR%\npu_top.v ^
	%COMPUTE_DIR%\mac_unit.v ^
	%COMPUTE_DIR%\activation_unit.v ^
	%COMPUTE_DIR%\pe_register_file.v ^
	%COMPUTE_DIR%\processing_element.v ^
	%COMPUTE_DIR%\pe_array.v ^
	%MEMORY_DIR%\global_buffer.v ^
	%MEMORY_DIR%\dma_controller.v ^
	%CONTROL_DIR%\instruction_decoder.v ^
	%CONTROL_DIR%\instruction_scheduler.v ^
	%CONTROL_DIR%\task_manager.v ^
	rtl\utils\interrupt_controller.v ^
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
echo NPU Build Script for Windows - Simplified
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

:end
