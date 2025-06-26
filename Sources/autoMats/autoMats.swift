/// ### autoMats macros
// import autoMatsMacros

@attached(memberAttribute)
public macro CleanTest(param: Int = 10) = #externalMacro(module: "autoMatsMacros", type: "CleanTest")

@freestanding(expression)
public macro expectMultilineEqual(
    _ actual: String,
    _ expected: String,
    trimWhitespace: Bool = false
) = #externalMacro(module: "autoMatsMacros", type: "ExpectMultilineEqualMacro")
