# 3D-PTV post processing C++ code   

Date: October 2007
Last modified: April 2015

The principle of the following software is described in pages 6-9 of [Luthi et al., JFM (2005)](http://journals.cambridge.org/action/displayAbstract?fromPage=online&aid=291420&fileId=S0022112004003283), and the core for the derivatives is described on page 3 of [Luthi et al., JoT (2007)](http://www.tandfonline.com/doi/abs/10.1080/14685240701522927) .


Download here: 

http://github.com/3dptv/3d-ptv-post-process


This is a command line version, written in C++. It uses a sinlge ASCII input file ( input.inp) and as output has ASCII files with filtered properties. For the full list of columns in the output see the snapshot:

![snapshot of the output file](list_of_output_columns.jpg)

It can be used to create the necessary turbulent properties to plot, for instance, the so-called *RQ* plots from `ptv_is.####` files:

![RQ plot](RQ.jpg)


## How to use it

Compile post_process.cpp on your platform using stdafx.cpp

    g++ -o post_process post_process.cpp stdafx.cpp

Type

    post_process input.inp 

The output looks like:

![output snapshot](how_to_run_post_process.jpg)

## What is in the configuration `input.inp` file

![snapshot of the input file](snapshot_input_file.png)

When producing xuap.* files along trajectories moving cubic polynomials of 3d order are fitted to the raw particle positions. From this filtered positions, velocities, and accelerations are produced and written into xuap.* files. 21 is the possible maximum of points that can be used for such a fit. The minimum is 4. It will crash with less than 4 and more than 21.
Min left/right determines how much centered such a fit should be.
Max vel is hardly used, but acts as a safety measure. Typically it should be 3-5 times larger than r.m.s u.
Radius of interpolation is a very important parameter. It determines how large the interpolation domain around a point x should be. As a rule of thumb the radius should not exceed 5 Kolmogorov units. Anything from from 7-12 points per interpolation sphere is enough.
Depending on the weights the result aims to improve quality of relative error of diva=-4Q and relative acceleration error of Du/Dt=du/dt+u du/dx.
When running the trajPoint part you should see something like the following (make sure that points per sphere are around 7-10, that the number of good points are around 40% or better, and that the values for r.m.s. u and dissipation are plausible).

## How the output looks like? 

The output is in two kinds of files. For each `ptv_is.###` there will be a `xuap.###` containing column by column the following (r=raw, f=filtered):
link_past, link_future, ```x_r,y_r,z_r,x_f,y_f,z_f,u_f,v_f,w_f,ax_f,ay_f,az_f,sucessfull```


The main result is stored in the `trajPoint.###` files. Each trajectory that starts at frame `###` will be stored in `trajPoint.###`. This explains why the second `trajPoint.###` is so much larger than all the others. The format is best explained with a screen shot of where the output is written to file:

![snapshot of the output code](list_of_output_columns.jpg)

## How to proceed with the `xuap.###` and `trajPoint.###` files

See Matlab or Python post-post-processing and graphics tools on Github, for instance from Alex:

http://github.com/alexlib/alexlib_openptv_post_processing/

## Testing the Software

This project includes a test suite to help ensure code correctness and prevent regressions. The tests are located in the `tests/` directory.

### Test Structure

*   **`tests/run_tests.sh`**: This is the main script to execute all tests. It will:
    1.  Build the `post_process` executable.
    2.  Run a series of "golden file" tests.
    3.  (Placeholder for) Run C++ unit tests.
*   **`tests/golden_outputs/`**: This directory stores the "known good" output files for various test cases. When a golden file test is run, the program's current output is compared against these files.
    *   Subdirectories like `single_traj_inp_outputs/`, `small_data_inp_outputs/`, etc., correspond to specific input `.inp` files.
*   **`tests/current_outputs/`**: A temporary directory created during test execution to store the output from the current run before comparison with golden files.
*   **`tests/unit_tests/`**: This directory is intended for C++ unit test source files.

### Input Files for Testing

The test suite relies on several `.inp` files located in the main project directory:

*   `single_traj.inp`: Uses data from the `single_traj/` directory.
*   `test.inp`: General test input.
*   `input.inp`: Default input.
*   `test_input.inp`: Another test input.
*   `small_data.inp`: Uses data from the `small_data/` directory.
*   `test_data.inp`: Uses data from the `test_data/` directory.

Ensure these `.inp` files are correctly configured to point to their respective data directories and have appropriate `firstFile` and `lastFile` settings.

### Running the Tests

1.  **Make the script executable (one-time setup)**:
    ```bash
    chmod +x tests/run_tests.sh
    ```
2.  **Navigate to the tests directory and run the script**:
    ```bash
    cd tests
    ./run_tests.sh
    ```

### Generating Golden Files

If you modify the code in a way that intentionally changes the output for a given input, or if you add a new test case, you will need to update or generate the corresponding golden output files:

1.  Ensure your `.inp` file (e.g., `my_new_test.inp`) is correctly configured in the project root.
2.  Run the `post_process` program manually with this input:
    ```bash
    ./post_process my_new_test.inp
    ```
3.  Carefully verify that all generated output files (e.g., `xuap.*`, `trajPoint.*`) are correct.
4.  Create a corresponding golden output directory if it doesn't exist (e.g., `tests/golden_outputs/my_new_test_inp_outputs/`).
5.  Copy the verified output files into this new directory.

### Debugging Test Failures

*   If a golden test fails, the `run_tests.sh` script will indicate which files differ. You can manually run `diff -r tests/golden_outputs/<test_name>_outputs/ tests/current_outputs/<test_name>_outputs/` for a detailed comparison.
*   If the program crashes (e.g., segmentation fault) during a test, use a debugger (like GDB, configured via `.vscode/launch.json` if using VS Code) to diagnose the issue in the C++ code. The test script will indicate which input file caused the crash.

### C++ Unit Tests with Google Test

This project uses the [Google Test](https://github.com/google/googletest) framework for C++ unit tests. Unit tests are located in `tests/unit_tests/`.

**1. Installing Google Test**

   You need to have the Google Test development libraries installed on your system. The method varies by operating system:

   *   **Debian/Ubuntu-based Linux:**
       ```bash
       sudo apt-get update
       sudo apt-get install libgtest-dev cmake
       # Compile the gtest library (usually needed on Debian/Ubuntu)
       cd /usr/src/googletest
       sudo cmake CMakeLists.txt
       sudo make
       # Copy the libraries to a standard location
       sudo cp lib/*.a /usr/lib/ # For older gtest versions
       sudo cp lib/libgtest.a /usr/lib/
       sudo cp lib/libgtest_main.a /usr/lib/
       cd -
       ```
       *Note: The exact commands for compiling and installing gtest after `apt-get install libgtest-dev` can sometimes vary slightly between distributions or gtest versions. If the above doesn't work, consult your distribution's documentation or the Google Test documentation.*

   *   **Fedora/RHEL-based Linux:**
       ```bash
       sudo dnf install gtest-devel
       ```

   *   **macOS (using Homebrew):**
       ```bash
       brew install googletest
       ```

   *   **Windows:** Installation on Windows often involves building from source using CMake, or using a package manager like vcpkg. Please refer to the [Google Test documentation](https://github.com/google/googletest/blob/main/googletest/README.md) for detailed instructions.

**2. Writing Unit Tests**

   *   Create your test files (e.g., `my_feature_tests.cpp`) in the `tests/unit_tests/` directory.
   *   Include the gtest header: `#include "gtest/gtest.h"`.
   *   Write your tests using the `TEST(TestSuiteName, TestName) { ... }` macro and gtest assertions (e.g., `ASSERT_EQ`, `EXPECT_TRUE`).
   *   Refer to `tests/unit_tests/example_unit_tests.cpp` for a basic example.
   *   To test functions from your main `post_process.cpp` or `stdafx.cpp` code, you'll need to structure your main project to be testable. This often involves:
       *   Moving function declarations into header files (e.g., `post_process.h`).
       *   Including these headers in your unit test files.
       *   Compiling your main project source files (or the relevant parts) alongside your test files, or linking against an object file/library created from your main project.

**3. Compiling and Running Unit Tests**

   The `tests/run_tests.sh` script has a section for compiling and running unit tests. It will attempt to:
   *   Compile all `.cpp` files in `tests/unit_tests/` along with `gtest` and `gtest_main` libraries.
   *   Create an executable (e.g., `unit_test_runner`) in the `tests/unit_tests/` directory.
   *   Run this executable.

   The compilation command in `run_tests.sh` is:
   ```bash
   g++ -std=c++11 tests/unit_tests/*.cpp -o tests/unit_tests/unit_test_runner -I/usr/include -L/usr/lib -lgtest -lgtest_main -pthread
   ```
   You might need to adjust `-I/usr/include` (include path for gtest headers) and `-L/usr/lib` (library path for gtest libraries) if gtest is installed in a non-standard location on your system.

