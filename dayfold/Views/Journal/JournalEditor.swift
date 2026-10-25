import SwiftUI
import SwiftData
import PhotosUI
import DayfoldCore

/// Edits a draft; nothing is written until Done. `entry == nil` starts a new entry dated `date`.
struct JournalEditor: View {
    let entry: JournalEntry?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // ponytail: every Entry; `JournalSuggestions.make` filters. Add a predicate if logs get huge.
    @Query private var tasks: [Entry]
    @State private var date: Date
    @State private var title: String
    @State private var text: String
    @State private var isBookmarked: Bool
    @State private var photos: [DraftPhoto]
    @State private var picked: [PhotosPickerItem] = []
    /// Picked photos still loading/downscaling. While > 0, Done and the picker are disabled.
    @State private var importing = 0
    @State private var confirmingDiscard = false
    @State private var confirmingDelete = false
    @FocusState private var bodyFocused: Bool
    @ScaledMetric private var bodyHeight: CGFloat = 180   // ~8 lines of body text
    private let initial: Snapshot

    static let maxPhotos = 4

    /// An existing photo (kept) or newly imported, already-downscaled data.
    struct DraftPhoto: Identifiable {
        let id = UUID()
        var model: JournalPhoto?
        var data: Data?
    }

    /// The fields that count as "changes" for Cancel.
    private struct Snapshot: Equatable {
        var date: Date, title: String, text: String, isBookmarked: Bool, photos: [PersistentIdentifier?]
    }

    init(entry: JournalEntry?, date: Date = Date()) {
        self.entry = entry
        let photos = entry?.sortedPhotos.map { DraftPhoto(model: $0, data: $0.data) } ?? []
        let start = Snapshot(date: entry?.date ?? date, title: entry?.title ?? "", text: entry?.text ?? "",
                             isBookmarked: entry?.isBookmarked ?? false, photos: photos.map { $0.model?.persistentModelID })
        initial = start
        _date = State(initialValue: start.date)
        _title = State(initialValue: start.title)
        _text = State(initialValue: start.text)
        _isBookmarked = State(initialValue: start.isBookmarked)
        _photos = State(initialValue: photos)
    }

    private var current: Snapshot {
        Snapshot(date: date, title: title, text: text, isBookmarked: isBookmarked,
                 photos: photos.map { $0.model?.persistentModelID })
    }
    private var hasChanges: Bool { importing > 0 || current != initial }
    private var isBlank: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && photos.isEmpty
    }
    private var suggestions: [JournalSuggestion] {
        entry == nil && title.isEmpty && text.isEmpty ? JournalSuggestions.make(tasks: tasks, day: date) : []
    }

    var body: some View {
        NavigationStack {
            Form {
                let suggestions = suggestions
                suggestionSection("From your day", suggestions.filter { $0.kind == .fromYourDay })
                suggestionSection("Prompts", suggestions.filter { $0.kind == .prompt })
                Section {
                    DatePicker("Date", selection: $date)
                        .datePickerStyle(.compact)
                    TextField("Title", text: $title)
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .submitLabel(.next)
                        .onSubmit { bodyFocused = true }
                    TextEditor(text: $text)
                        .focused($bodyFocused)
                        .frame(minHeight: bodyHeight)
                        .scrollContentBackground(.hidden)
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("Write about your day…")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel("Write about your day…")
                }
                Section { photoRow }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle(entry == nil ? "New Entry" : "")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { hasChanges ? (confirmingDiscard = true) : dismiss() }
                        .confirmationDialog("Discard changes?", isPresented: $confirmingDiscard, titleVisibility: .visible) {
                            Button("Discard", role: .destructive) { dismiss() }
                            Button("Keep Editing", role: .cancel) {}
                        }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isBookmarked.toggle()
                    } label: {
                        Label(isBookmarked ? "Remove bookmark" : "Bookmark",
                              systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                    .sensoryFeedback(.selection, trigger: isBookmarked)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: done)
                        .disabled(importing > 0)
                        .confirmationDialog("Delete this entry?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                if let entry { context.delete(entry) }
                                dismiss()
                            }
                        }
                }
            }
            .keyboardDismissButton()
            .interactiveDismissDisabled(hasChanges)   // swipe-down never drops writing; Cancel asks
            .onChange(of: picked) { importPicked() }
        }
        .journalLockCover()   // relocked while open: hidden, but the draft in @State survives until unlocked
        #if os(macOS)
        .frame(minWidth: 520, minHeight: 560)
        #endif
    }

    @ViewBuilder
    private func suggestionSection(_ header: LocalizedStringKey, _ items: [JournalSuggestion]) -> some View {
        if !items.isEmpty {
            Section(header) {
                ForEach(items) { s in
                    Button {
                        withAnimation(reduceMotion ? nil : .snappy) { title = s.title }
                        bodyFocused = true
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.title).font(.system(.body, design: .serif)).foregroundStyle(.primary)
                            if !s.detail.isEmpty {
                                Text(s.detail).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.card)
                }
            }
        }
    }

    @ViewBuilder
    private var photoRow: some View {
        if !photos.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(photos) { photo in
                        PhotoThumbnail(data: photo.data, size: 72)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    withAnimation(reduceMotion ? nil : .snappy) { photos.removeAll { $0.id == photo.id } }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .offset(x: 12, y: -12)
                                .accessibilityLabel("Remove photo")
                            }
                            .padding(.top, 12).padding(.trailing, 12)   // room for the offset button
                    }
                }
            }
        }
        if photos.count + importing < Self.maxPhotos || importing > 0 {
            HStack {
                PhotosPicker(selection: $picked, maxSelectionCount: max(1, Self.maxPhotos - photos.count - importing),
                             matching: .images) {
                    Label("Add Photos", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .disabled(importing > 0)
                if importing > 0 { ProgressView().controlSize(.small) }
            }
        }
    }

    /// Loads each picked item in order, downscales off the main thread, appends up to the 4-photo cap.
    private func importPicked() {
        let items = picked
        guard !items.isEmpty else { return }
        picked = []
        importing += items.count
        Task {
            for item in items {
                defer { importing -= 1 }
                guard let raw = try? await item.loadTransferable(type: Data.self),
                      let small = await Task.detached(operation: { PhotoImport.downscaled(raw) }).value,
                      photos.count < Self.maxPhotos   // re-checked right before the append
                else { continue }
                photos.append(DraftPhoto(data: small))
            }
        }
    }

    private func done() {
        if let entry {
            if isBlank { confirmingDelete = true; return }
            if hasChanges { apply(to: entry, now: Date()) }
        } else if !isBlank {
            let now = Date()
            let new = JournalEntry(date: date, createdAt: now, updatedAt: now)
            context.insert(new)
            apply(to: new, now: now)
        }
        dismiss()
    }

    private func apply(to entry: JournalEntry, now: Date) {
        // A reflection moved to another day becomes an ordinary entry, so it never merges into that day's reflection.
        if entry.isReflection && !Calendar.current.isDate(date, inSameDayAs: entry.date) { entry.isReflection = false }
        entry.date = date
        entry.title = title
        entry.text = text
        entry.isBookmarked = isBookmarked
        entry.updatedAt = now
        let kept = Set(photos.compactMap { $0.model?.persistentModelID })
        for old in entry.photos ?? [] where !kept.contains(old.persistentModelID) {
            entry.photos?.removeAll { $0 === old }
            context.delete(old)
        }
        for (i, draft) in photos.enumerated() {
            if let model = draft.model {
                if model.order != Double(i) { model.order = Double(i) }
            } else {
                let photo = JournalPhoto(data: draft.data, order: Double(i), createdAt: now)
                context.insert(photo)
                photo.entry = entry
            }
        }
    }
}

#if DEBUG
#Preview {
    JournalEditor(entry: nil)
        .modelContainer(DemoData.container())
}
#endif
