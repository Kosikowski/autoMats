# autoMats Package
The autoMats package provides a collection of macros designed to automate and streamline common tasks related to test code organization and cleanliness in Swift projects. These macros help developers maintain consistency, readability, and quality in their test suites, ultimately leading to more effective testing practices.

## Features

## CleanTests Macro:

* Enforces consistent structure and naming conventions for test methods.
* Organizes test code within test classes or test case files.
* Detects and reports potential issues or violations of coding conventions.

## SkipAll Macro:

Automatically skips the execution of all test methods within a class or extension.
Simplifies the process of excluding specific test cases from execution.

## Skip Macro:

Automatically skips the execution of a specific test methods.

## Usage

Installation
Include the autoMats package in your Swift project using Swift Package Manager (SPM).

Apply Macros

```
@CleanTest
public class MyTestCase: XCTestCase {
    // Test methods...
}
```

## Benefits
1. Consistency: Ensure consistent structure, naming conventions, and organization across your test codebase.
2. Readability: Improve readability and understanding of test suites by enforcing clear and descriptive naming conventions.
3. Automation: Automates work normally done during a code review.
4. Quality: Detect potential issues or violations of coding conventions early in the development process, leading to higher code quality and consistency.
