import Foundation
import SourceKittenFramework

struct TrailingWhitespaceRule: CorrectableRule {
    var configuration = TrailingWhitespaceConfiguration()

    static let description = RuleDescription(
        identifier: "trailing_whitespace",
        name: "Trailing Whitespace",
        description: "Lines should not have trailing whitespace",
        kind: .style,
        nonTriggeringExamples: [
            Example("let name: String\n"), Example("//\n"), Example("// \n"),
            Example("let name: String //\n"), Example("let name: String // \n"),
        ],
        triggeringExamples: [
            Example("let name: String \n"), Example("/* */ let name: String \n")
        ],
        corrections: [
            Example("let name: String \n"): Example("let name: String\n"),
            Example("/* */ let name: String \n"): Example("/* */ let name: String\n"),
        ]
    )

    func validate(file: SwiftLintFile) -> [StyleViolation] {
        let filteredLines = file.lines.filter {
            guard $0.content.hasTrailingWhitespace() else { return false }

            let commentKinds = SyntaxKind.commentKinds
            if configuration.ignoresComments,
                let lastSyntaxKind = file.syntaxKindsByLines[$0.index].last,
                commentKinds.contains(lastSyntaxKind) {
                return false
            }

            return !configuration.ignoresEmptyLines ||
                    // If configured, ignore lines that contain nothing but whitespace (empty lines)
                    $0.content.trimmingCharacters(in: .whitespaces).isNotEmpty
        }

        return filteredLines.map {
            StyleViolation(ruleDescription: Self.description,
                           severity: configuration.severityConfiguration.severity,
                           location: Location(file: file.path, line: $0.index))
        }
    }

    func correct(file: SwiftLintFile) -> Int {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        var correctedLines = [String]()
        var numberOfCorrections = 0
        for line in file.lines {
            guard line.content.hasTrailingWhitespace() else {
                correctedLines.append(line.content)
                continue
            }

            let commentKinds = SyntaxKind.commentKinds
            if configuration.ignoresComments,
                let lastSyntaxKind = file.syntaxKindsByLines[line.index].last,
                commentKinds.contains(lastSyntaxKind) {
                correctedLines.append(line.content)
                continue
            }

            let correctedLine = line.content.bridge()
                .trimmingTrailingCharacters(in: whitespaceCharacterSet)

            if configuration.ignoresEmptyLines && correctedLine.isEmpty {
                correctedLines.append(line.content)
                continue
            }

            if file.ruleEnabled(violatingRanges: [line.range], for: self).isEmpty {
                correctedLines.append(line.content)
                continue
            }

            if line.content != correctedLine {
                numberOfCorrections += 1
            }
            correctedLines.append(correctedLine)
        }
        if numberOfCorrections > 0 {
            // join and re-add trailing newline
            file.write(correctedLines.joined(separator: "\n") + "\n")
        }
        return numberOfCorrections
    }
}
