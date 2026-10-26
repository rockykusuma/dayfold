import UIKit
import Social
import UniformTypeIdentifiers
import DayfoldCore

/// "Add to Dayfold" in the share sheet: the shared text (editable) plus the page's link become today's entries
/// the next time Dayfold opens (`ShareInbox`). Never touches the store.
class ShareViewController: SLComposeServiceViewController {
    private var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dayfold"
        placeholder = "Add to today"
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Add"
        let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? []).flatMap { $0.attachments ?? [] }
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) else { return }
        _ = provider.loadObject(ofClass: URL.self) { [weak self] url, _ in
            DispatchQueue.main.async { self?.url = url; self?.validateContent() }
        }
    }

    override func isContentValid() -> Bool {
        ShareInbox.compose(text: contentText ?? "", url: url) != nil
    }

    override func didSelectPost() {
        if let text = ShareInbox.compose(text: contentText ?? "", url: url), let dir = ShareInbox.directory {
            try? ShareInbox.add(text, in: dir)
        }
        extensionContext?.completeRequest(returningItems: [])
    }

    override func configurationItems() -> [Any]! { [] }
}
