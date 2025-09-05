import AppKit
import Foundation

func runAppleScript(_ source: String) -> NSAppleEventDescriptor? {
    var error: NSDictionary?
    guard let script = NSAppleScript(source: source) else { return nil }
    let result = script.executeAndReturnError(&error)
    if let error = error {
        // Print for debugging; the app is ephemeral so avoid noisy logs.
        // print("AppleScript error: \(error)")
        _ = error
    }
    return result
}

func frontFinderDirectory() -> URL {
    // Ask Finder for the front window's target path; fall back to Desktop.
    let script = """
    tell application "Finder"
      if (count of windows) is 0 then
        return POSIX path of (path to desktop)
      else
        try
          return POSIX path of (target of front window as alias)
        on error
          return POSIX path of (path to desktop)
        end try
      end if
    end tell
    """
    if let desc = runAppleScript(script), let path = desc.stringValue {
        return URL(fileURLWithPath: path, isDirectory: true)
    }
    // Last resort: Desktop.
    let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    return desktop
}

func pasteboardImagePNGData() -> Data? {
    let pb = NSPasteboard.general
    // Prefer PNG if present directly
    if let png = pb.data(forType: .png) {
        return png
    }
    // Fallback to TIFF -> PNG conversion
    if let tiff = pb.data(forType: .tiff), let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
        return png
    }
    // Try reading NSImage objects
    if let images = pb.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage], let image = images.first {
        if let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
            return png
        }
    }
    return nil
}

func displayNotification(title: String, body: String, sound: Bool = true) {
    // Use AppleScript 'display notification' to avoid setting up UNUserNotifications.
    let safeTitle = title.replacingOccurrences(of: "\"", with: "\\\"")
    let safeBody = body.replacingOccurrences(of: "\"", with: "\\\"")
    let soundPart = sound ? " sound name \"default\"" : ""
    let script = "display notification \"\(safeBody)\" with title \"\(safeTitle)\"\(soundPart)"
    _ = runAppleScript(script)
}

func timestampedFilename() -> String {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
    return "Clipboard Shot \(df.string(from: Date())).png"
}

func main() {
    guard let data = pasteboardImagePNGData() else {
        displayNotification(title: "Save Image", body: "No image on clipboard.")
        exit(2)
    }

    let dir = frontFinderDirectory()
    let filename = timestampedFilename()
    let url = dir.appendingPathComponent(filename)
    do {
        try data.write(to: url, options: .atomic)
        displayNotification(title: "Saved Clipboard Image", body: url.path)
    } catch {
        displayNotification(title: "Save Failed", body: error.localizedDescription)
        exit(1)
    }
}

main()

