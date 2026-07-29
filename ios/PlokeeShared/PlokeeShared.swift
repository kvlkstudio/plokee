import Foundation

/// The App Group is the only thing the app, the share extension, the widget and
/// the Shortcuts intents have in common: extensions run in their own processes
/// and cannot call into the running app, so everything passes through files in
/// a shared container.
///
/// This file is compiled into every one of those targets.
public enum PlokeeShared {
    public static let appGroup = "group.com.kvlkstudio.plokee"

    /// Root of the shared container, or nil if the entitlement is missing.
    public static var container: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup)
    }

    /// Items handed to Plokee from outside the app, waiting to be picked up.
    public static var inbox: URL? {
        container?.appendingPathComponent("Inbox", isDirectory: true)
    }

    /// What the widget renders, written by the app.
    public static var stateFile: URL? {
        container?.appendingPathComponent("state.json")
    }

    /// Requests from Shortcuts that the app applies the next time it runs.
    public static var commandsFile: URL? {
        container?.appendingPathComponent("commands.json")
    }

    // MARK: - Inbox

    /// Creates a fresh directory for one shared drop.
    public static func newInboxDrop() -> URL? {
        guard let inbox else { return nil }
        let drop = inbox.appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(
                at: drop, withIntermediateDirectories: true)
            return drop
        } catch {
            return nil
        }
    }

    /// Describes a drop so the app knows what it is looking at without having
    /// to guess from file names.
    public static func writeManifest(_ manifest: [String: Any], to drop: URL) {
        guard let data = try? JSONSerialization.data(withJSONObject: manifest)
        else { return }
        try? data.write(to: drop.appendingPathComponent("item.json"),
                        options: .atomic)
    }

    // MARK: - Commands

    /// Appends a request for the app. Nothing here takes effect until the app
    /// runs — an extension cannot reach into a suspended process, and iOS gives
    /// no way around that.
    public static func appendCommand(_ command: [String: Any]) {
        guard let file = commandsFile else { return }
        var commands = readCommands()
        commands.append(command)
        // Bound it: a shortcut fired on a schedule while the app never opens
        // must not grow a file forever.
        if commands.count > 32 {
            commands.removeFirst(commands.count - 32)
        }
        if let data = try? JSONSerialization.data(withJSONObject: commands) {
            try? data.write(to: file, options: .atomic)
        }
    }

    public static func readCommands() -> [[String: Any]] {
        guard let file = commandsFile,
              let data = try? Data(contentsOf: file),
              let list = try? JSONSerialization.jsonObject(with: data)
                as? [[String: Any]]
        else { return [] }
        return list
    }

    // MARK: - State

    public static func readState() -> [String: Any] {
        guard let file = stateFile,
              let data = try? Data(contentsOf: file),
              let state = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else { return [:] }
        return state
    }
}
