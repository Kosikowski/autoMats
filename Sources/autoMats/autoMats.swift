/// ### autoMats macros

@attached(memberAttribute)
public macro CleanTest(param: Int = 10) = #externalMacro(module: "autoMatsMacros", type: "CleanTest")
