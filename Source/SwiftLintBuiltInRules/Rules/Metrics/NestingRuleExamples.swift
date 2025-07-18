// swiftlint:disable file_length

private let detectingTypes = ["actor", "class", "struct", "enum"]

internal struct NestingRuleExamples {
    static let nonTriggeringExamples = nonTriggeringTypeExamples
        + nonTriggeringFunctionExamples
        + nonTriggeringClosureAndStatementExamples
        + nonTriggeringProtocolExamples
        + nonTriggeringMixedExamples
        + nonTriggeringExamplesIgnoreCodingKeys

    private static let nonTriggeringTypeExamples =
        detectingTypes.flatMap { type -> [Example] in
            [
                // default maximum type nesting level
                .init("""
                    \(type) Example_0 {
                        \(type) Example_1 {}
                    }
                    """),

                /*
                 all variableKinds of SwiftDeclarationKind (except .varParameter which is a function parameter)
                 are flattend in a file structure so limits do not change
                */
                .init("""
                    var example: Int {
                        \(type) Example_0 {
                            \(type) Example_1 {}
                        }
                        return 5
                    }
                    """),

                // didSet is not present in file structure although there is such a swift declaration kind
                .init("""
                    var example: Int = 5 {
                        didSet {
                            \(type) Example_0 {
                                \(type) Example_1 {}
                            }
                        }
                    }
                    """),

                // extensions are counted as a type level
                .init("""
                    extension Example_0 {
                        \(type) Example_1 {}
                    }
                    """),
            ]
        }

    private static let nonTriggeringFunctionExamples: [Example] = [
        // default maximum function nesting level
        .init("""
            func f_0() {
                func f_1() {
                    func f_2() {}
                }
            }
            """),

        /*
         all variableKinds of SwiftDeclarationKind (except .varParameter which is a function parameter)
         are flattend in a file structure so level limits do not change
        */
        .init("""
            var example: Int {
                func f_0() {
                    func f_1() {
                        func f_2() {}
                    }
                }
                return 5
            }
            """),

        // didSet is not present in file structure although there is such a swift declaration kind
        .init("""
            var example: Int = 5 {
                didSet {
                    func f_0() {
                        func f_1() {
                            func f_2() {}
                        }
                    }
                }
            }
            """),

        // extensions are counted as a type level
        .init("""
            extension Example_0 {
                func f_0() {
                    func f_1() {
                        func f_2() {}
                    }
                }
            }
            """),
    ]

    private static let nonTriggeringProtocolExamples =
        detectingTypes.flatMap { type in
            [
                Example("""
                    \(type) Example_0 {
                        protocol Example_1 {}
                    }
                    """),
                Example("""
                    var example: Int {
                        \(type) Example_0 {
                            protocol Example_1 {}
                        }
                        return 5
                    }
                    """),
                Example("""
                    var example: Int = 5 {
                        didSet {
                            \(type) Example_0 {
                                protocol Example_1 {}
                            }
                        }
                    }
                    """),
                Example("""
                    extension Example_0 {
                        protocol Example_1 {}
                    }
                    """),
            ]
        }

    private static let nonTriggeringClosureAndStatementExamples =
        detectingTypes.flatMap { type -> [Example] in
            [
                // swich statement example
                .init("""
                    switch example {
                    case .exampleCase:
                        \(type) Example_0 {
                            \(type) Example_1 {}
                        }
                    default:
                        func f_0() {
                            func f_1() {
                                func f_2() {}
                            }
                        }
                    }
                    """),

                // closure var example
                .init("""
                    var exampleClosure: () -> Void = {
                        \(type) Example_0 {
                            \(type) Example_1 {}
                        }
                        func f_0() {
                            func f_1() {
                                func f_2() {}
                            }
                        }
                    }
                    """),

                // function closure parameter example
                .init("""
                    exampleFunc(closure: {
                        \(type) Example_0 {
                            \(type) Example_1 {}
                        }
                        func f_0() {
                            func f_1() {
                                func f_2() {}
                            }
                        }
                    })
                    """),
            ]
        }

    private static let nonTriggeringMixedExamples =
        detectingTypes.flatMap { type -> [Example] in
            [
                // default maximum nesting level for both type and function (nesting order is arbitrary)
                .init("""
                    \(type) Example_0 {
                        func f_0() {
                            \(type) Example_1 {
                                func f_1() {
                                    func f_2() {}
                                }
                            }
                            protocol P {}
                        }
                    }
                    """),

                // default maximum nesting level for both type and function within closures and statements
                .init("""
                    \(type) Example_0 {
                        func f_0() {
                            switch example {
                            case .exampleCase:
                                \(type) Example_1 {
                                    func f_1() {
                                        func f_2() {}
                                    }
                                }
                                protocol P {}
                            default:
                                exampleFunc(closure: {
                                    \(type) Example_1 {
                                        func f_1() {
                                            func f_2() {}
                                        }
                                    }
                                    protocol P {}
                                })
                            }
                        }
                    }
                    """),
            ]
        }

    private static let nonTriggeringExamplesIgnoreCodingKeys: [Example] = [
        Example(
            """
            struct Outer {
                struct Inner {
                    enum CodingKeys: String, CodingKey {
                        case id
                    }
                }
            }
            """,
            configuration: ["ignore_coding_keys": true]
        ),
    ]
}

extension NestingRuleExamples {
    static let triggeringExamples = triggeringTypeExamples
        + triggeringFunctionExamples
        + triggeringClosureAndStatementExamples
        + triggeringProtocolExamples
        + triggeringMixedExamples
        + triggeringExamplesCodingKeys
        + triggeringExamplesIgnoreCodingKeys

    private static let triggeringTypeExamples =
        detectingTypes.flatMap { type -> [Example] in
            [
                // violation of default maximum type nesting level
                .init("""
                    \(type) Example_0 {
                        \(type) Example_1 {
                            ↓\(type) Example_2 {}
                        }
                    }
                    """),

                /*
                 all variableKinds of SwiftDeclarationKind (except .varParameter which is a function parameter)
                 are flattend in a file structure so limits do not change
                 */
                .init("""
                    var example: Int {
                        \(type) Example_0 {
                            \(type) Example_1 {
                                ↓\(type) Example_2 {}
                            }
                        }
                        return 5
                    }
                    """),

                // didSet is not present in file structure although there is such a swift declaration kind
                .init("""
                    var example: Int = 5 {
                        didSet {
                            \(type) Example_0 {
                                \(type) Example_1 {
                                    ↓\(type) Example_2 {}
                                }
                            }
                        }
                    }
                    """),

                // extensions are counted as a type level, violation of default maximum type nesting level
                .init("""
                    extension Example_0 {
                        \(type) Example_1 {
                            ↓\(type) Example_2 {}
                        }
                    }
                    """),
            ]
        }

    private static let triggeringFunctionExamples: [Example] = [
        // violation of default maximum function nesting level
        .init("""
            func f_0() {
                func f_1() {
                    func f_2() {
                        ↓func f_3() {}
                    }
                }
            }
            """),

        /*
         all variableKinds of SwiftDeclarationKind (except .varParameter which is a function parameter)
         are flattend in a file structure so level limits do not change
         */
        .init("""
            var example: Int {
                func f_0() {
                    func f_1() {
                        func f_2() {
                            ↓func f_3() {}
                        }
                    }
                }
                return 5
            }
            """),

        // didSet is not present in file structure although there is such a swift declaration kind
        .init("""
            var example: Int = 5 {
                didSet {
                    func f_0() {
                        func f_1() {
                            func f_2() {
                                ↓func f_3() {}
                            }
                        }
                    }
                }
            }
            """),

        // extensions are counted as a type level, violation of default maximum function nesting level
        .init("""
            extension Example_0 {
                func f_0() {
                    func f_1() {
                        func f_2() {
                            ↓func f_3() {}
                        }
                    }
                }
            }
            """),
    ]

    private static let triggeringClosureAndStatementExamples =
        detectingTypes.flatMap { type -> [Example] in
            [
                // swich statement example
                .init("""
                    switch example {
                    case .exampleCase:
                        \(type) Example_0 {
                            \(type) Example_1 {
                                ↓\(type) Example_2 {}
                            }
                        }
                    default:
                        func f_0() {
                            func f_1() {
                                func f_2() {
                                    ↓func f_3() {}
                                }
                            }
                        }
                    }
                    """),

                // closure var example
                .init("""
                    var exampleClosure: () -> Void = {
                        \(type) Example_0 {
                            \(type) Example_1 {
                                ↓\(type) Example_2 {}
                            }
                            }
                        func f_0() {
                            func f_1() {
                                func f_2() {
                                    ↓func f_3() {}
                                }
                            }
                        }
                    }
                    """),

                // function closure parameter example
                .init("""
                    exampleFunc(closure: {
                        \(type) Example_0 {
                            \(type) Example_1 {}
                        }
                        func f_0() {
                            func f_1() {
                                func f_2() {
                                    ↓func f_3() {}
                                }
                            }
                        }
                    })
                    """),
            ]
        }

    private static let triggeringProtocolExamples =
        detectingTypes.flatMap { type in
            [
                Example("""
                    \(type) Example_0 {
                        \(type) Example_1 {
                            ↓protocol Example_2 {}
                        }
                    }
                    """),
                Example("""
                    var example: Int {
                        \(type) Example_0 {
                            \(type) Example_1 {
                                ↓protocol Example_2 {}
                            }
                        }
                        return 5
                    }
                    """),
                Example("""
                    var example: Int = 5 {
                        didSet {
                            \(type) Example_0 {
                                \(type) Example_1 {
                                    ↓protocol Example_2 {}
                                }
                            }
                        }
                    }
                    """),
                Example("""
                    extension Example_0 {
                        \(type) Example_1 {
                            ↓protocol Example_2 {}
                        }
                    }
                    """),
            ]
        }

    private static let triggeringMixedExamples =
        detectingTypes.flatMap { type -> [Example] in
            [
                // violation of default maximum nesting level for both type and function (nesting order is arbitrary)
                .init("""
                    \(type) Example_0 {
                        func f_0() {
                            \(type) Example_1 {
                                func f_1() {
                                    func f_2() {
                                        ↓\(type) Example_2 {}
                                        ↓func f_3() {}
                                        ↓protocol P {}
                                    }
                                }
                            }
                        }
                    }
                    """),

                // violation of default maximum nesting level for both type and function within closures and statements
                .init("""
                    \(type) Example_0 {
                        func f_0() {
                            switch example {
                            case .exampleCase:
                                \(type) Example_1 {
                                    func f_1() {
                                        func f_2() {
                                            ↓\(type) Example_2 {}
                                            ↓func f_3() {}
                                            ↓protocol P {}
                                        }
                                    }
                                }
                            default:
                                exampleFunc(closure: {
                                    \(type) Example_1 {
                                        func f_1() {
                                            func f_2() {
                                                ↓\(type) Example_2 {}
                                                ↓func f_3() {}
                                                ↓protocol P {}
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                    """),
            ]
        }

    private static let triggeringExamplesCodingKeys: [Example] = [
        Example("""
                struct Outer {
                    struct Inner {
                        ↓enum CodingKeys: String, CodingKey {
                            case id
                        }
                    }
                }
        """),
    ]

    private static let triggeringExamplesIgnoreCodingKeys: [Example] = [
        Example(
            """
            struct Outer {
                struct Inner {
                    ↓enum Example: String, CodingKey {
                        case id
                    }
                }
            }
            """,
            configuration: ["ignore_coding_keys": true]
        ),
        Example(
            """
            struct Outer {
              enum CodingKeys: String, CodingKey {
                case id
                ↓struct S {}
              }
            }
            """,
            configuration: ["ignore_coding_keys": true]
        ),
    ]
}
