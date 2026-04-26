#!/usr/bin/env bash

clear
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

TEST_LIST="${1:-test_lib/test_list}"
OUTPUT_FILE="${2:-output.txt}"
LOG_DIR="${3:-automatic_test_logs}"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
RESET=$'\033[0m'

run_with_spinner() {
    local pid="$1"
    local message="$2"
    local total_tests="$3"
    local frames=(
        "[=         ]"
        "[==        ]"
        "[===       ]"
        "[ ===      ]"
        "[  ===     ]"
        "[   ===    ]"
        "[    ===   ]"
        "[     ===  ]"
        "[      === ]"
        "[       ===]"
        "[        ==]"
        "[         =]"
        "[        ==]"
        "[       ===]"
        "[      === ]"
        "[     ===  ]"
        "[    ===   ]"
        "[   ===    ]"
        "[  ===     ]"
        "[ ===      ]"
        "[===       ]"
        "[==        ]"
    )
    local dots=("" "." ".." "...")
    local i=0
    local start_time
    local elapsed
    local mins
    local secs

    start_time=$(date +%s)

    while kill -0 "$pid" 2>/dev/null; do
        elapsed=$(($(date +%s) - start_time))
        mins=$((elapsed / 60))
        secs=$((elapsed % 60))
        printf "\r%s %s %-3s tests=%d elapsed=%02d:%02d" \
            "${frames[i % ${#frames[@]}]}" \
            "$message" \
            "${dots[i % ${#dots[@]}]}" \
            "$total_tests" \
            "$mins" \
            "$secs"
        i=$((i + 1))
        sleep 0.2
    done

    elapsed=$(($(date +%s) - start_time))
    mins=$((elapsed / 60))
    secs=$((elapsed % 60))
    printf "\r[==========] %s done   tests=%d elapsed=%02d:%02d\n" \
        "$message" \
        "$total_tests" \
        "$mins" \
        "$secs"
}

if [ ! -f "$TEST_LIST" ]; then
    echo "${RED}ERROR${RESET}: test list '$TEST_LIST' not found"
    return 1 2>/dev/null || exit 1
fi

mkdir -p "$LOG_DIR"

: > "$OUTPUT_FILE"
FILTERED_TEST_LIST="$LOG_DIR/test_list.filtered"
FULL_LOG="$LOG_DIR/full_run.log"

tests=()
: > "$FILTERED_TEST_LIST"
while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | tr -d '\r' | xargs)"
    if [ -n "$line" ]; then
        tests+=("$line")
        echo "$line" >> "$FILTERED_TEST_LIST"
    fi
done < "$TEST_LIST"

total=${#tests[@]}
passed=0
warning=0
failed=0

failed_tests=()
warning_tests=()

printf "%sRunning %d tests from %s in one Questa session%s\n" "$BLUE" "$total" "$TEST_LIST" "$RESET"
printf "Full log: %s\n" "$FULL_LOG"
printf "Per-test logs: %s\n\n" "$LOG_DIR"

bash ./start_verification.sh -run_multiple_tests -uvm_tests_file "$FILTERED_TEST_LIST" > "$FULL_LOG" 2>&1 &
run_pid=$!
run_with_spinner "$run_pid" "Questa regression is running" "$total"
wait "$run_pid"
cmd_status=$?

printf "\n"

for test_name in "${tests[@]}"; do
    log_file="$LOG_DIR/${test_name}.log"

    awk -v test="$test_name" '
        index($0, "Running test " test "...") { capture = 1 }
        capture && index($0, "Running test ") && !index($0, "Running test " test "...") { exit }
        capture { print }
    ' "$FULL_LOG" > "$log_file"

    printf "%-36s" "$test_name"

    uvm_errors="$(awk '/UVM_ERROR[[:space:]]*:/ {print $NF}' "$log_file" | tail -n 1)"
    uvm_fatals="$(awk '/UVM_FATAL[[:space:]]*:/ {print $NF}' "$log_file" | tail -n 1)"
    uvm_warnings="$(awk '/UVM_WARNING[[:space:]]*:/ {print $NF}' "$log_file" | tail -n 1)"

    uvm_errors="${uvm_errors:-0}"
    uvm_fatals="${uvm_fatals:-0}"
    uvm_warnings="${uvm_warnings:-0}"

    if [ ! -s "$log_file" ]; then
        failed=$((failed + 1))
        failed_tests+=("$test_name")
        printf "%sFAILED%s   test output not found in full log\n" "$RED" "$RESET"
    elif [ "$uvm_errors" -gt 0 ] || [ "$uvm_fatals" -gt 0 ] || grep -q "VERIFICATION is FAIL" "$log_file"; then
        failed=$((failed + 1))
        failed_tests+=("$test_name")
        printf "%sFAILED%s   UVM_ERROR=%s UVM_FATAL=%s log=%s\n" "$RED" "$RESET" "$uvm_errors" "$uvm_fatals" "$log_file"
    elif [ "$uvm_warnings" -gt 0 ]; then
        warning=$((warning + 1))
        warning_tests+=("$test_name")
        printf "%sWARNING%s  UVM_WARNING=%s log=%s\n" "$YELLOW" "$RESET" "$uvm_warnings" "$log_file"
    else
        passed=$((passed + 1))
        printf "%sPASSED%s   log=%s\n" "$GREEN" "$RESET" "$log_file"
    fi
done

if [ "$cmd_status" -ne 0 ] && [ "$failed" -eq 0 ]; then
    failed=1
    failed_tests+=("multiple_test_command")
fi

{
    echo "Automatic test run summary"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "Test list: $TEST_LIST"
    echo "Filtered test list: $FILTERED_TEST_LIST"
    echo "Full log: $FULL_LOG"
    echo
    echo "Total:   $total"
    echo "Passed:  $passed"
    echo "Warning: $warning"
    echo "Failed:  $failed"
    echo
    echo "Failed tests:"
    if [ "${#failed_tests[@]}" -eq 0 ]; then
        echo "  none"
    else
        for test_name in "${failed_tests[@]}"; do
            echo "  $test_name"
        done
    fi
    echo
    echo "Warning tests:"
    if [ "${#warning_tests[@]}" -eq 0 ]; then
        echo "  none"
    else
        for test_name in "${warning_tests[@]}"; do
            echo "  $test_name"
        done
    fi
} > "$OUTPUT_FILE"

printf "\n%sSummary%s: total=%d passed=%d warning=%d failed=%d\n" "$BLUE" "$RESET" "$total" "$passed" "$warning" "$failed"
printf "Output written to %s\n" "$OUTPUT_FILE"

if [ "$failed" -gt 0 ]; then
    return 1 2>/dev/null || exit 1
fi

return 0 2>/dev/null || exit 0
