import Cocoa

struct Hotkey: Codable {
    let keyCode: UInt16
    let modifiers: UInt
    let characters: String

    var displayString: String {
        var parts: [String] = []
        let flags = NSEvent.ModifierFlags(rawValue: modifiers)
        if flags.contains(.command) { parts.append("\u2318") }
        if flags.contains(.option) { parts.append("\u2325") }
        if flags.contains(.shift) { parts.append("\u21E7") }
        if flags.contains(.control) { parts.append("\u2303") }
        parts.append(characters.uppercased())
        return parts.joined()
    }

    static let defaultsKey = "Hotkey"

    static func load() -> Hotkey? {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return nil }
        return try? JSONDecoder().decode(Hotkey.self, from: data)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Hotkey.defaultsKey)
    }
}
