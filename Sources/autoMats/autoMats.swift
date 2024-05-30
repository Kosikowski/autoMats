/// ### autoMats macros

@attached(memberAttribute)
public macro CleanTest(param: Int = 10) = #externalMacro(module: "autoMatsMacros", type: "CleanTest")

@attached(preamble)
public macro Skip() = #externalMacro(module: "autoMatsMacros", type: "Skip")

@attached(memberAttribute)
public macro SkipAll() = #externalMacro(module: "autoMatsMacros", type: "SkipAll")
