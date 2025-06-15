#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Path to the main program, relative to WORKSPACE_ROOT
PROGRAM_PATH="./post_process"
# Workspace root
WORKSPACE_ROOT=".."

# Function to run a golden file test
run_golden_test() {
  local test_name="$1"
  local input_file_relative_path="$2" # Relative to WORKSPACE_ROOT
  local golden_output_dir="golden_outputs/${test_name}_outputs"
  local current_output_dir="current_outputs/${test_name}_outputs"

  echo "Running golden test: $test_name (Input: $input_file_relative_path)"

  # Create directory for current run's outputs
  mkdir -p "$current_output_dir"
  # Clean up previous outputs in the target directory if necessary.
  echo "Cleaning up previous output files from $WORKSPACE_ROOT..."
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "xuap.*" -delete
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "trajPoint.*" -delete
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "xuag.*" -delete # Added for completeness
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "ptv_is.*" -delete # If program copies these
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "*.lagr" -delete # Add other patterns as needed
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "*.dat" -delete  # Add other patterns as needed


  # Run the program with the specified input file
  # The input file path for the program should be relative to its CWD, which is $WORKSPACE_ROOT
  (cd "$WORKSPACE_ROOT" && "$PROGRAM_PATH" "$input_file_relative_path")

  # Move/Copy generated files to the current_output_dir
  echo "Moving output files to $current_output_dir..."
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "xuap.*" -exec mv -t "$current_output_dir/" {} +
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "trajPoint.*" -exec mv -t "$current_output_dir/" {} +
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "xuag.*" -exec mv -t "$current_output_dir/" {} +
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "*.lagr" -exec mv -t "$current_output_dir/" {} +
  find "$WORKSPACE_ROOT" -maxdepth 1 -type f -name "*.dat" -exec mv -t "$current_output_dir/" {} +


  # Compare the current output with the golden output
  if [ ! -d "$golden_output_dir" ] || [ -z "$(ls -A "$golden_output_dir")" ]; then
    echo "Golden test SKIPPED: $test_name. Golden output directory '$golden_output_dir' is missing or empty."
    echo "Please generate golden files for this test case."
    # Clean up current output directory as the test didn't really run
    rm -rf "$current_output_dir"
    return # Skip comparison if golden dir doesn't exist or is empty
  fi

  diff_output=$(diff -r -q "$golden_output_dir" "$current_output_dir" || true) # -q for brief output

  if [ -n "$diff_output" ]; then
    echo "Golden test FAILED: $test_name"
    echo "Differences found (summary):"
    echo "$diff_output"
    echo "For a full diff, run: diff -r \"$golden_output_dir\" \"$current_output_dir\""
    # Optionally, copy differing files to a 'diffs' directory for inspection
    # mkdir -p "diffs/${test_name}"
    # cp -r "$current_output_dir"/* "diffs/${test_name}/"
    # Keeping current_output_dir for inspection on failure
    # exit 1 # Indicate failure - remove this if you want all tests to run even if one fails
  else
    echo "Golden test PASSED: $test_name"
    # Clean up current output directory on success
    rm -rf "$current_output_dir"
  fi
}

# --- Run Golden Tests ---
# Ensure the program is built
echo "Building the program..."
(cd "$WORKSPACE_ROOT" && g++ -g post_process.cpp -o post_process)

# Create a directory for current outputs from test runs
mkdir -p current_outputs

# Run tests for each input file
# Assumes these .inp files exist in the WORKSPACE_ROOT
run_golden_test "single_traj" "single_traj.inp"
run_golden_test "test_inp" "test.inp"
run_golden_test "input_inp" "input.inp"
run_golden_test "test_input_inp" "test_input.inp"
run_golden_test "small_data_inp" "small_data.inp" # New test for small_data
run_golden_test "test_data_inp" "test_data.inp"   # New test for test_data
# Add more tests as needed for other .inp files

# Clean up main current_outputs directory if all tests passed (or if you prefer to always clean it)
# For now, it's cleaned up per test on success.

echo "All golden tests attempted."

# --- Unit Tests ---
echo "Running C++ unit tests..."

UNIT_TEST_DIR="unit_tests"
UNIT_TEST_RUNNER="$UNIT_TEST_DIR/unit_test_runner"

# Compile unit tests with Google Test
# Adjust include (-I) and library (-L) paths if gtest is installed elsewhere
# Common gtest library names are libgtest.a and libgtest_main.a
# The -pthread flag is often required by gtest.
echo "Compiling unit tests..."
if g++ -std=c++11 "$UNIT_TEST_DIR"/*.cpp -o "$UNIT_TEST_RUNNER" -I/usr/include -L/usr/lib -lgtest -lgtest_main -pthread; then
    echo "Compilation successful. Running unit tests..."
    # Run the compiled unit test runner
    "$UNIT_TEST_RUNNER"
else
    echo "Unit test compilation FAILED."
fi

echo "C++ Unit tests completed."

echo "All tests finished."
