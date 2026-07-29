import Flutter
import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Connects Dart to everything that happens outside the app process: the Share
/// extension's drops, requests left by Shortcuts, and the widget's state file.
enum PlokeeBridge {
    static let channelName = "com.kvlkstudio.plokee/extensions"

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: channelName,
                                           binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "drainInbox":
                result(drainInbox())
            case "takeCommands":
                result(takeCommands())
            case "publishState":
                publishState(call.arguments as? [String: Any] ?? [:])
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Hands over everything the Share extension left, and clears the inbox.
    ///
    /// Files are moved out of the container rather than copied: they are
    /// already on this device's disk and the app is about to stream them from
    /// there, so a second copy would double the space a shared video costs.
    private static func drainInbox() -> [[String: Any]] {
        guard let inbox = PlokeeShared.inbox,
              let drops = try? FileManager.default.contentsOfDirectory(
                at: inbox, includingPropertiesForKeys: nil)
        else { return [] }

        var items: [[String: Any]] = []
        for drop in drops.sorted(by: { $0.path < $1.path }) {
            guard let data = try? Data(
                    contentsOf: drop.appendingPathComponent("item.json")),
                  var manifest = try? JSONSerialization.jsonObject(with: data)
                    as? [String: Any]
            else {
                try? FileManager.default.removeItem(at: drop)
                continue
            }
            // Hand Dart absolute paths; it has no idea where the container is.
            if let names = manifest["files"] as? [String] {
                manifest["paths"] = names.map {
                    drop.appendingPathComponent($0).path
                }
                manifest["dir"] = drop.path
            } else {
                // Nothing on disk to keep: drop the directory now.
                try? FileManager.default.removeItem(at: drop)
            }
            items.append(manifest)
        }
        return items
    }

    /// Requests left by Shortcuts since the last time the app looked.
    private static func takeCommands() -> [[String: Any]] {
        let commands = PlokeeShared.readCommands()
        if let file = PlokeeShared.commandsFile {
            try? FileManager.default.removeItem(at: file)
        }
        return commands
    }

    private static func publishState(_ state: [String: Any]) {
        guard let file = PlokeeShared.stateFile,
              let data = try? JSONSerialization.data(withJSONObject: state)
        else { return }
        try? data.write(to: file, options: .atomic)
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
}
