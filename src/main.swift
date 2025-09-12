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

func pasteboardPlainText() -> String? {
    let pb = NSPasteboard.general
    if let s = pb.string(forType: .string) {
        return s
    }
    // Fallback: try reading attributed string and drop formatting.
    if let data = pb.data(forType: .rtf),
       let attr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
        return attr.string
    }
    return nil
}

func pasteboardHTMLString() -> String? {
    let pb = NSPasteboard.general
    if let html = pb.string(forType: .html) {
        return html
    }
    if let data = pb.data(forType: .html), let s = String(data: data, encoding: .utf8) {
        return s
    }
    return nil
}

func normalizeNewlines(_ s: String) -> String {
    // Replace CRLF/CR with LF to standardize file content.
    var out = s.replacingOccurrences(of: "\r\n", with: "\n")
    out = out.replacingOccurrences(of: "\r", with: "\n")
    return out
}

func extractCodeFromFencedBlock(_ s: String) -> (code: String, lang: String?)? {
    // Very lightweight parser for triple-backtick fenced blocks.
    let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
    guard t.hasPrefix("```") else { return nil }
    let afterTicks = t.index(t.startIndex, offsetBy: 3)
    guard let firstNewline = t[afterTicks...].firstIndex(of: "\n") else { return nil }
    let langPart = String(t[afterTicks..<firstNewline]).trimmingCharacters(in: .whitespacesAndNewlines)
    // Find the closing fence
    guard let closingRange = t.range(of: "```", options: .backwards), closingRange.lowerBound > firstNewline else { return nil }
    let contentStart = t.index(after: firstNewline)
    let code = String(t[contentStart..<closingRange.lowerBound])
    return (code, langPart.isEmpty ? nil : langPart.lowercased())
}

func looksLikePython(_ s: String, hintedLang: String?) -> Bool {
    // If explicitly hinted by a fenced block language, trust it.
    if let lang = hintedLang, ["python", "py"].contains(lang) { return true }

    let text = s
    if text.contains("#!/usr/bin/env python") || text.contains("#!/usr/bin/python") || text.contains("#!/bin/python") {
        return true
    }
    if text.contains("if __name__ == \"__main__\":") { return true }

    // Count strong Python-indicative line starters.
    let lines = text.components(separatedBy: .newlines)
    var score = 0
    for line in lines.prefix(200) { // scan up to 200 lines
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
        if trimmed.hasPrefix("def ") || trimmed.hasPrefix("class ") { score += 2 }
        if trimmed.hasPrefix("import ") || trimmed.hasPrefix("from ") { score += 1 }
        if trimmed.hasSuffix(":") && (trimmed.hasPrefix("if ") || trimmed.hasPrefix("for ") || trimmed.hasPrefix("while ") || trimmed.hasPrefix("try") || trimmed.hasPrefix("except") || trimmed.hasPrefix("with ") || trimmed.hasPrefix("elif ")) {
            score += 1
        }
        if score >= 3 { return true }
    }
    return false
}

func displayNotification(title: String, body: String, sound: Bool = true) {
    // Use AppleScript 'display notification' to avoid setting up UNUserNotifications.
    let safeTitle = title.replacingOccurrences(of: "\"", with: "\\\"")
    let safeBody = body.replacingOccurrences(of: "\"", with: "\\\"")
    let soundPart = sound ? " sound name \"default\"" : ""
    let script = "display notification \"\(safeBody)\" with title \"\(safeTitle)\"\(soundPart)"
    _ = runAppleScript(script)
}

func nextEnumeratedURL(in dir: URL, prefix: String, ext: String) -> URL {
    // ext may be with or without leading dot
    let dotExt = ext.hasPrefix(".") ? ext : "." + ext
    var n = 1
    let fm = FileManager.default
    while true {
        let name = "\(prefix)\(n)\(dotExt)"
        let url = dir.appendingPathComponent(name)
        if !fm.fileExists(atPath: url.path) {
            return url
        }
        n += 1
        if n == Int.max { return url } // extremely unlikely fallback
    }
}

func main() {
    let dir = frontFinderDirectory()

    // 1) Prefer image if present
    if let data = pasteboardImagePNGData() {
        let url = nextEnumeratedURL(in: dir, prefix: "Clip-Img-", ext: "png")
        do {
            try data.write(to: url, options: .atomic)
            displayNotification(title: "Saved Clipboard Image", body: url.path)
            return
        } catch {
            displayNotification(title: "Save Failed", body: error.localizedDescription)
            exit(1)
        }
    }

    // 2) Otherwise, check for text variants
    // 2a) If plain text present, detect Python first
    if var text = pasteboardPlainText() {
        text = normalizeNewlines(text)

        var hintedLang: String? = nil
        if let fenced = extractCodeFromFencedBlock(text) {
            text = fenced.code
            hintedLang = fenced.lang
        }

        if looksLikePython(text, hintedLang: hintedLang) {
            let url = nextEnumeratedURL(in: dir, prefix: "Clip-Py-", ext: "py")
            let finalText = text.hasSuffix("\n") ? text : text + "\n"
            do {
                try finalText.write(to: url, atomically: true, encoding: .utf8)
                displayNotification(title: "Saved Python Code", body: url.path)
                return
            } catch {
                displayNotification(title: "Save Failed", body: error.localizedDescription)
                exit(1)
            }
        }
        // Not Python: if HTML exists on the pasteboard, save as .html; otherwise save as Markdown.
        if let html = pasteboardHTMLString() {
            let url = nextEnumeratedURL(in: dir, prefix: "Clip-Html-", ext: "html")
            do {
                try html.write(to: url, atomically: true, encoding: .utf8)
                displayNotification(title: "Saved HTML", body: url.path)
                return
            } catch {
                displayNotification(title: "Save Failed", body: error.localizedDescription)
                exit(1)
            }
        }
        let url = nextEnumeratedURL(in: dir, prefix: "Clip-Md-", ext: "md")
        let finalText = text.hasSuffix("\n") ? text : text + "\n"
        do {
            try finalText.write(to: url, atomically: true, encoding: .utf8)
            displayNotification(title: "Saved Markdown", body: url.path)
            return
        } catch {
            displayNotification(title: "Save Failed", body: error.localizedDescription)
            exit(1)
        }
    }

    // 3) Nothing useful on the clipboard
    displayNotification(title: "Save Clipboard", body: "No image or text on clipboard.")
    exit(2)
}

main()
