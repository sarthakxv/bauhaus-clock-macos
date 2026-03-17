import AppKit

struct ClockPalette {
    let bg: NSColor
    let idx: NSColor
    let num: NSColor
    let sec: NSColor
    let metalEdge: NSColor
    let metalMid: NSColor
    let metalHi: NSColor
    let border: NSColor
    let capOuter: NSColor
    let capMid: NSColor
    let capInner: NSColor
    let glow: NSColor?

    init(bg: String, idx: String, num: String, sec: String,
         metalEdge: String, metalMid: String, metalHi: String,
         border: String, capOuter: String, capMid: String, capInner: String,
         glow: String? = nil) {
        self.bg = NSColor(hex: bg)
        self.idx = NSColor(hex: idx)
        self.num = NSColor(hex: num)
        self.sec = NSColor(hex: sec)
        self.metalEdge = NSColor(hex: metalEdge)
        self.metalMid = NSColor(hex: metalMid)
        self.metalHi = NSColor(hex: metalHi)
        self.border = NSColor(hex: border)
        self.capOuter = NSColor(hex: capOuter)
        self.capMid = NSColor(hex: capMid)
        self.capInner = NSColor(hex: capInner)
        self.glow = glow != nil ? NSColor(hex: glow!) : nil
    }
}

extension NSColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)

        switch h.count {
        case 8:
            self.init(
                red: CGFloat((rgb >> 24) & 0xFF) / 255,
                green: CGFloat((rgb >> 16) & 0xFF) / 255,
                blue: CGFloat((rgb >> 8) & 0xFF) / 255,
                alpha: CGFloat(rgb & 0xFF) / 255
            )
        case 6:
            self.init(
                red: CGFloat((rgb >> 16) & 0xFF) / 255,
                green: CGFloat((rgb >> 8) & 0xFF) / 255,
                blue: CGFloat(rgb & 0xFF) / 255,
                alpha: 1.0
            )
        case 3:
            let r = CGFloat((rgb >> 8) & 0xF) / 15
            let g = CGFloat((rgb >> 4) & 0xF) / 15
            let b = CGFloat(rgb & 0xF) / 15
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        default:
            self.init(white: 0, alpha: 1)
        }
    }

    var cgC: CGColor { self.cgColor }
}

struct Palettes {
    static let dialNames: [String] = [
        "White", "Turquoise", "Glacier", "Ocean", "Tennis", "Signal Blue",
        "Salmon", "Yellow", "Beige", "Pistachio", "Lavender", "Rose",
        "Sky Blue", "Cream", "Slate", "Noir"
    ]

    static let dials: [String: ClockPalette] = [
        "White": ClockPalette(bg:"#edecea",idx:"#2a2a28",num:"#222220",sec:"#b83828",metalEdge:"#8a8884",metalMid:"#e8e6e2",metalHi:"#faf9f6",border:"#a09890",capOuter:"#666666",capMid:"#dddddd",capInner:"#999999"),
        "Turquoise": ClockPalette(bg:"#7cc8c2",idx:"#186862",num:"#1a6e68",sec:"#d4a040",metalEdge:"#78b0a8",metalMid:"#e4f0ec",metalHi:"#f8fcfa",border:"#4a9a90",capOuter:"#2a7a72",capMid:"#c0e8e0",capInner:"#4a9a90"),
        "Glacier": ClockPalette(bg:"#d0dce6",idx:"#3a5468",num:"#2c4458",sec:"#b83028",metalEdge:"#8898a8",metalMid:"#e4eaf0",metalHi:"#f6f8fa",border:"#688090",capOuter:"#4a6878",capMid:"#c8d8e4",capInner:"#4a6878"),
        "Ocean": ClockPalette(bg:"#1a2e4a",idx:"#5a88a8",num:"#78a8c8",sec:"#d4a040",metalEdge:"#4878a0",metalMid:"#b8d4e8",metalHi:"#dceaf4",border:"#3868a0",capOuter:"#3060a0",capMid:"#90b8d8",capInner:"#3060a0"),
        "Tennis": ClockPalette(bg:"#bcd040",idx:"#2e4210",num:"#2a3a0c",sec:"#a82820",metalEdge:"#5a7828",metalMid:"#c8dc88",metalHi:"#e0ecb0",border:"#4a6820",capOuter:"#3a5818",capMid:"#a8c860",capInner:"#3a5818"),
        "Signal Blue": ClockPalette(bg:"#1c4078",idx:"#5888b8",num:"#78a8d0",sec:"#d4a040",metalEdge:"#4070a0",metalMid:"#a8c8e4",metalHi:"#d0e0f0",border:"#3060a0",capOuter:"#2858a0",capMid:"#88b0d0",capInner:"#2858a0"),
        "Salmon": ClockPalette(bg:"#d89888",idx:"#5c2c20",num:"#4a2018",sec:"#2c3e50",metalEdge:"#a06858",metalMid:"#f0d0c4",metalHi:"#f8e8e0",border:"#886050",capOuter:"#704838",capMid:"#d8b0a0",capInner:"#704838"),
        "Yellow": ClockPalette(bg:"#e0c430",idx:"#3c3210",num:"#2e2608",sec:"#a82820",metalEdge:"#8c7c28",metalMid:"#e8dc88",metalHi:"#f4ecb0",border:"#7a6c20",capOuter:"#5a5018",capMid:"#c8b860",capInner:"#5a5018"),
        "Beige": ClockPalette(bg:"#d0c8b0",idx:"#5c4e3a",num:"#4a3e2c",sec:"#a82820",metalEdge:"#8c8068",metalMid:"#e8dcc8",metalHi:"#f4ece0",border:"#7a7058",capOuter:"#5a5040",capMid:"#c8b8a0",capInner:"#5a5040"),
        "Pistachio": ClockPalette(bg:"#a0c49c",idx:"#2c422a",num:"#203420",sec:"#a82820",metalEdge:"#5c8858",metalMid:"#c8e0c4",metalHi:"#e0f0dc",border:"#4a7848",capOuter:"#3a6838",capMid:"#a8c8a4",capInner:"#3a6838"),
        "Lavender": ClockPalette(bg:"#aca0c4",idx:"#3c2c58",num:"#30224c",sec:"#a82820",metalEdge:"#6858a0",metalMid:"#c8bce0",metalHi:"#e0d8f0",border:"#584898",capOuter:"#483888",capMid:"#a898c8",capInner:"#483888"),
        "Rose": ClockPalette(bg:"#cc98a8",idx:"#4c1c2c",num:"#3e1424",sec:"#2c3e50",metalEdge:"#985068",metalMid:"#e8c0d0",metalHi:"#f4d8e4",border:"#884060",capOuter:"#703050",capMid:"#c8a0b0",capInner:"#703050"),
        "Sky Blue": ClockPalette(bg:"#84b4d0",idx:"#1c3c58",num:"#143050",sec:"#a82820",metalEdge:"#4888b0",metalMid:"#b8d8ec",metalHi:"#d8ecf8",border:"#3878a8",capOuter:"#2868a0",capMid:"#90c0d8",capInner:"#2868a0"),
        "Cream": ClockPalette(bg:"#ddd0b4",idx:"#5a4c34",num:"#4a3e28",sec:"#a82820",metalEdge:"#8c7c60",metalMid:"#e8dcc0",metalHi:"#f4ecd8",border:"#7a6c50",capOuter:"#5a5038",capMid:"#c8b898",capInner:"#5a5038"),
        "Slate": ClockPalette(bg:"#4c5258",idx:"#8c949c",num:"#a8b0b8",sec:"#d4a040",metalEdge:"#68707c",metalMid:"#b8c4d0",metalHi:"#d4dce4",border:"#586068",capOuter:"#484e58",capMid:"#98a4b0",capInner:"#484e58"),
        "Noir": ClockPalette(bg:"#1a1a1a",idx:"#555555",num:"#888888",sec:"#b83828",metalEdge:"#606060",metalMid:"#c8c8c8",metalHi:"#eaeaea",border:"#484848",capOuter:"#444444",capMid:"#bbbbbb",capInner:"#555555"),
    ]

    static let lumeNames: [String] = [
        "Tritium Green", "Amber", "Swiss BGW9", "Ice Blue",
        "Red", "Lavender", "Rose", "Seafoam", "White"
    ]

    static let lumeColors: [String: String] = [
        "Tritium Green": "#3df03d", "Amber": "#ffa828", "Swiss BGW9": "#c0ecc8",
        "Ice Blue": "#78ccff", "Red": "#ff3838", "Lavender": "#b898ff",
        "Rose": "#ff78a0", "Seafoam": "#58e0b8", "White": "#dcdcdc",
    ]

    static func nightPalette(lume: String) -> ClockPalette {
        let c = lumeColors[lume] ?? "#3df03d"
        return ClockPalette(
            bg: "#080808", idx: "#1a1a1a", num: c, sec: c,
            metalEdge: c + "50", metalMid: c, metalHi: c,
            border: c + "40", capOuter: c + "60", capMid: c, capInner: c + "80",
            glow: c
        )
    }
}
