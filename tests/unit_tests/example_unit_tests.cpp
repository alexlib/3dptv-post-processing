// Copyright 2024 OpenPTV
#include "gtest/gtest.h"

// Example namespace and function to be tested.
// In a real scenario, you would include headers from your main project here
// (e.g., #include "../../post_process.h" if you had a header for it)
// and test functions/classes from your actual codebase.
namespace TestableUtils {
    double multiply(double a, double b) {
        return a * b;
    } // namespace TestableUtils

    // A simple function that might interact with some logic from post_process.cpp
    // For demonstration, let's imagine it processes a line count.
    int getProcessedLineCount(int rawLineCount, bool hasHeader) {
        if (rawLineCount <= 0) {
            return 0;
        }
        return hasHeader ? rawLineCount - 1 : rawLineCount;
    }
}

// Test case for the multiply function
TEST(MathUtilsTest, Multiply) {
    ASSERT_EQ(TestableUtils::multiply(2.0, 3.0), 6.0);
    ASSERT_DOUBLE_EQ(TestableUtils::multiply(1.5, 2.5), 3.75);
    ASSERT_EQ(TestableUtils::multiply(5.0, 0.0), 0.0);
}

// Test case for the getProcessedLineCount function
TEST(LineProcessingTest, GetProcessedLineCount) {
    ASSERT_EQ(TestableUtils::getProcessedLineCount(10, true), 9);
    ASSERT_EQ(TestableUtils::getProcessedLineCount(10, false), 10);
    ASSERT_EQ(TestableUtils::getProcessedLineCount(1, true), 0);
    ASSERT_EQ(TestableUtils::getProcessedLineCount(0, true), 0);
    ASSERT_EQ(TestableUtils::getProcessedLineCount(0, false), 0);
    ASSERT_EQ(TestableUtils::getProcessedLineCount(-5, false), 0);
}

// It's common to have the main function for gtest in a separate file
// or link with gtest_main library which provides it.
// If gtest_main is not available or you prefer, you can include it here:
/*
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
*/
