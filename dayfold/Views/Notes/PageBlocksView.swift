import SwiftUI
import DayfoldCore

/// Renders parsed page blocks. Links go through the environment's `openURL`; checkbox taps call `onToggle(line)`.
struct PageBlocksView: View {
    let blocks: [PageBlock]
    let onToggle: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                row(block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func row(_ block: PageBlock) -> some View {
        switch block {
        case .heading(let level, let text):
            Self.inline(text)
                .font(.system(Self.headingStyle(level), design: .serif, weight: .semibold))
                .padding(.top, level <= 2 ? 8 : 2)
                .accessibilityAddTraits(.isHeader)
        case .paragraph(let text):
            Self.inline(text)
        case .bullet(let text, let indent):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("•").foregroundStyle(.secondary).accessibilityHidden(true)
                Self.inline(text)
            }
            .padding(.leading, CGFloat(indent) * 16)
        case .checkbox(let checked, let text, let line, let indent):
            HStack(spacing: 4) {
                Button { onToggle(line) } label: {
                    Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(checked ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.leading, -12)   // keep the mark aligned with text while the target stays 44pt
                .accessibilityLabel("Toggle")
                .accessibilityValue(checked ? "Checked" : "Not checked")
                // Stays its own VoiceOver element so links inside it are reachable.
                Self.inline(text)
                    .foregroundStyle(checked ? .secondary : .primary)
                    .strikethrough(checked, color: .secondary)
            }
            .padding(.vertical, -5)   // 44pt rows sit flush (not 54pt apart), so a checklist reads like the bullets
            .padding(.leading, CGFloat(indent) * 16)
        case .quote(let text):
            Self.inline(text)
                .foregroundStyle(.secondary)
                .padding(.leading, 12)
                .overlay(alignment: .leading) {
                    Rectangle().fill(.tint).frame(width: 3)
                }
        case .code(let text):
            ScrollView(.horizontal) {
                Text(text)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card, in: RoundedRectangle(cornerRadius: 8))
        case .divider:
            Divider().padding(.vertical, 4)
        }
    }

    private static func headingStyle(_ level: Int) -> Font.TextStyle {
        switch level {
        case 1: .title
        case 2: .title2
        case 3: .title3
        default: .headline
        }
    }

    /// Bold/italic/code/links via `AttributedString(markdown:)`; `[[links]]` become `dayfold-page:` URLs first.
    static func inline(_ text: String) -> Text {
        styled(text).map(Text.init) ?? Text(verbatim: text)
    }

    private static func styled(_ text: String) -> AttributedString? {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return try? AttributedString(markdown: PageLinks.inlineMarkdown(text), options: options)
    }
}
