# start_verification.ps1

param (
    [switch]$c,
    [switch]$gui,
    [switch]$run_multiple_tests,
    [string]$uvm_testname,
    [string]$uvm_tests_file
)

$VSIM_OPT = "-c"
$UVM_ARGS = ""

if ($gui) {
    $VSIM_OPT = "-gui"
}

if ($run_multiple_tests) {
    Write-Host "Forcing command line simulator run, as run of multiple tests was requested"
    $VSIM_OPT = "-c"
}

if ($uvm_testname) {
    $UVM_ARGS += " +UVM_TESTNAME=$uvm_testname"
}

if ($uvm_tests_file) {
    $UVM_ARGS += " -uvm_tests_file $uvm_tests_file"
}

$env:QUESTA_HOME = "C:\questasim64_2025.3\win64"

# Run vsim
$RUN_CMD = "$env:QUESTA_HOME\vsim.exe $VSIM_OPT -do `"do start.tcl $UVM_ARGS`""
Write-Host "Executing: $RUN_CMD"
Invoke-Expression $RUN_CMD

# Example of runs: 
# .\start_verification.ps1 -gui -uvm_testname my_test
# .\start_verification.ps1 -c -uvm_testname my_test
# .\start_verification.ps1 -run_multiple_tests -uvm_tests_file tests.txt