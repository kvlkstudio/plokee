import UIKit

/// Type identifiers as plain strings rather than `UTType`, which needs iOS 14 —
/// the app itself runs on 13, and there is no reason for the share sheet entry
/// to disappear on a device that can otherwise use it.
private enum ItemType {
    static let fileURL = "public.file-url"
    static let image = "public.image"
    static let movie = "public.movie"
    static let data = "public.data"
    static let url = "public.url"
    static let text = "public.text"
}

/// The Share sheet entry for Plokee.
///
/// The extension cannot sync anything itself — it has no network stack, no
/// pairing secrets and a few seconds to live. What it does is copy whatever was
/// shared into the App Group container; the app picks it up the next time it is
/// in the foreground and sends it on like anything else copied locally.
///
/// There is no UI: sharing to Plokee is a one-tap action, so the extension
/// completes as soon as the items are stored.
final class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        Task { await handleItems() }
    }

    private func handleItems() async {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem],
              let drop = PlokeeShared.newInboxDrop()
        else {
            finish()
            return
        }

        var text: String?
        var files: [String] = []

        for item in items {
            for provider in item.attachments ?? [] {
                if let url = await loadFile(provider) {
                    if let name = copy(url, into: drop) { files.append(name) }
                } else if let shared = await loadText(provider) {
                    // Several text attachments in one share are rare; joining
                    // them keeps the clipboard a single coherent clip.
                    text = text.map { "\($0)\n\(shared)" } ?? shared
                }
            }
        }

        if files.isEmpty && text == nil {
            try? FileManager.default.removeItem(at: drop)
            finish()
            return
        }

        var manifest: [String: Any] = [
            "kind": files.isEmpty ? "text" : "files",
            "time": Date().timeIntervalSince1970 * 1000,
        ]
        if let text { manifest["text"] = text }
        if !files.isEmpty { manifest["files"] = files }
        PlokeeShared.writeManifest(manifest, to: drop)
        finish()
    }

    /// A file or image attachment, resolved to a URL on disk.
    private func loadFile(_ provider: NSItemProvider) async -> URL? {
        for type in [ItemType.fileURL, ItemType.image, ItemType.movie,
                     ItemType.data] {
            guard provider.hasItemConformingToTypeIdentifier(type) else {
                continue
            }
            if let url = await loadItem(provider, type: type) as? URL {
                return url
            }
        }
        return nil
    }

    private func loadText(_ provider: NSItemProvider) async -> String? {
        if provider.hasItemConformingToTypeIdentifier(ItemType.url),
           let url = await loadItem(provider, type: ItemType.url) as? URL {
            return url.absoluteString
        }
        if provider.hasItemConformingToTypeIdentifier(ItemType.text) {
            let value = await loadItem(provider, type: ItemType.text)
            if let string = value as? String { return string }
            if let data = value as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }

    private func loadItem(_ provider: NSItemProvider,
                          type: String) async -> NSSecureCoding? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: type, options: nil) { value, _ in
                continuation.resume(returning: value)
            }
        }
    }

    /// Copies a shared file into the drop. The originals live in sandboxes that
    /// disappear with the extension, so a reference would be worthless.
    private func copy(_ source: URL, into drop: URL) -> String? {
        let name = source.lastPathComponent.isEmpty
            ? UUID().uuidString
            : source.lastPathComponent
        let target = drop.appendingPathComponent(name)
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        do {
            if FileManager.default.fileExists(atPath: target.path) {
                try FileManager.default.removeItem(at: target)
            }
            try FileManager.default.copyItem(at: source, to: target)
            return name
        } catch {
            return nil
        }
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
