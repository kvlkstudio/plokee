import AppIntents
import Foundation

/// Shortcuts and Siri support.
///
/// An intent cannot reach into a suspended app, so each one writes a request
/// into the App Group and the app carries it out the next time it runs.
/// "Send clipboard" opens the app on purpose rather than as a workaround: iOS
/// only allows reading the pasteboard in the foreground, so a version that
/// stayed in the background could not do the one thing it promises.
@available(iOS 16.0, *)
struct SendClipboardIntent: AppIntent {
    static var title: LocalizedStringResource = "Send clipboard"
    static var description = IntentDescription(
        "Sends what is on this device's clipboard to your paired devices.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        PlokeeShared.appendCommand([
            "command": "sendClipboard",
            "time": Date().timeIntervalSince1970 * 1000,
        ])
        return .result()
    }
}

@available(iOS 16.0, *)
struct SetSyncIntent: AppIntent {
    static var title: LocalizedStringResource = "Set clipboard sync"
    static var description = IntentDescription(
        "Pauses or resumes clipboard sync. Takes effect the next time Plokee runs.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Enabled")
    var enabled: Bool

    func perform() async throws -> some IntentResult {
        PlokeeShared.appendCommand([
            "command": "setSync",
            "enabled": enabled,
            "time": Date().timeIntervalSince1970 * 1000,
        ])
        return .result()
    }
}

@available(iOS 16.0, *)
struct PlokeeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendClipboardIntent(),
            phrases: ["Send my clipboard with \(.applicationName)"],
            shortTitle: "Send clipboard",
            systemImageName: "doc.on.clipboard")
        AppShortcut(
            intent: SetSyncIntent(),
            phrases: ["Set clipboard sync in \(.applicationName)"],
            shortTitle: "Set sync",
            systemImageName: "arrow.triangle.2.circlepath")
    }
}
