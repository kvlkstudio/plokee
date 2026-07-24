import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Revealing a file in Finder goes through NSWorkspace rather than spawning
    // /usr/bin/open: it is the API sanctioned for sandboxed Mac App Store apps.
    let channel = FlutterMethodChannel(
      name: "com.kvlkstudio.plokee/file_actions",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "revealInFinder":
        guard let path = call.arguments as? String, !path.isEmpty else {
          result(FlutterError(
            code: "bad_args", message: "Expected a file path", details: nil))
          return
        }
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
