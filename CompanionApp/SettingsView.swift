import SwiftUI

// MARK: - Thumbnail Renderer

enum ThumbnailRenderer {
    static var displayTime: Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 10; comps.minute = 10; comps.second = 30; comps.nanosecond = 0
        return Calendar.current.date(from: comps) ?? Date()
    }

    /// Renders a zoomed-in corner of a clock face (10–12 o'clock region).
    ///
    /// Uses 2× render scale so the clock center is at (w, h) of the render —
    /// a translation of (-w * 0.12, -h * 0.08) then exposes the top-left
    /// quadrant where the 10, 11, and 12 indices live.
    static func clockCorner(palette: ClockPalette, width: CGFloat, height: CGFloat, night: Bool) -> NSImage {
        let img = NSImage(size: NSSize(width: width, height: height))
        img.lockFocusFlipped(true)
        if let ctx = NSGraphicsContext.current?.cgContext {
            let renderSize = width * 2.0
            ctx.translateBy(x: -width * 0.12, y: -height * 0.08)
            ClockRenderer.draw(in: ctx, size: CGSize(width: renderSize, height: renderSize),
                             pal: palette, now: displayTime, clockSize: "Classic",
                             showSeconds: true, night: night)
        }
        img.unlockFocus()
        return img
    }

    /// Renders a full clock face clipped to a circle.
    /// At small dial-picker sizes a complete face reads better than a corner crop.
    static func dialCircle(palette: ClockPalette, diameter: CGFloat) -> NSImage {
        let img = NSImage(size: NSSize(width: diameter, height: diameter))
        img.lockFocusFlipped(true)
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.addEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            ctx.clip()
            ClockRenderer.draw(in: ctx, size: CGSize(width: diameter, height: diameter),
                             pal: palette, now: displayTime, clockSize: "Classic",
                             showSeconds: true, night: false)
        }
        img.unlockFocus()
        return img
    }

    /// Renders a split Day/Night thumbnail for "System" appearance.
    /// Left half = day, right half = night inset with a rounded rect.
    static func systemThumbnail(dayPalette: ClockPalette, nightPalette: ClockPalette,
                                width: CGFloat, height: CGFloat) -> NSImage {
        let dayImg  = clockCorner(palette: dayPalette,   width: width, height: height, night: false)
        let nightImg = clockCorner(palette: nightPalette, width: width, height: height, night: true)

        let result = NSImage(size: NSSize(width: width, height: height))
        result.lockFocus()
        dayImg.draw(in: NSRect(x: 0, y: 0, width: width, height: height))
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.saveGState()
            let rightRect = CGRect(x: width * 0.48, y: 4, width: width * 0.52 - 4, height: height - 8)
            ctx.addPath(CGPath(roundedRect: rightRect, cornerWidth: 8, cornerHeight: 8, transform: nil))
            ctx.clip()
            nightImg.draw(in: NSRect(x: 0, y: 0, width: width, height: height))
            ctx.restoreGState()
        }
        result.unlockFocus()
        return result
    }
}

// MARK: - Main Settings View

struct SettingsView: View {
    @ObservedObject var vm: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            // ── Light Section ──
            VStack(alignment: .leading, spacing: 20) {
                AppearanceSection(vm: vm)
                ClockDialSection(vm: vm)
                HStack(alignment: .top, spacing: 12) {
                    SizeSection(vm: vm)
                    MovementSection(vm: vm)
                }
            }
            .padding(24)

            // ── Dark Section ──
            VStack(alignment: .leading, spacing: 16) {
                LumeSection(vm: vm)
                Spacer().frame(height: 8)
                FooterRow(onCancel: { NSApp.terminate(nil) },
                          onOK: { vm.save(); NSApp.terminate(nil) })
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black)
        }
        .frame(width: 560)
    }
}

// MARK: - Appearance Section

struct AppearanceSection: View {
    @ObservedObject var vm: SettingsViewModel

    private let cardW: CGFloat = 160
    private let cardH: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Appearance").font(.system(size: 14, weight: .bold))

            HStack(spacing: 12) {
                appearanceCard(label: "Day", value: "day",
                               image: dayThumbnail)
                appearanceCard(label: "Night", value: "night",
                               image: nightThumbnail)
                appearanceCard(label: "System", value: "system",
                               image: systemThumbnail)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private var dayPalette: ClockPalette {
        Palettes.dials[vm.dial] ?? Palettes.dials["Noir"]!
    }
    private var nightPalette: ClockPalette {
        Palettes.nightPalette(lume: vm.lume)
    }

    private var dayThumbnail: NSImage {
        ThumbnailRenderer.clockCorner(palette: dayPalette, width: cardW, height: cardH, night: false)
    }
    private var nightThumbnail: NSImage {
        ThumbnailRenderer.clockCorner(palette: nightPalette, width: cardW, height: cardH, night: true)
    }
    private var systemThumbnail: NSImage {
        ThumbnailRenderer.systemThumbnail(dayPalette: dayPalette, nightPalette: nightPalette,
                                          width: cardW, height: cardH)
    }

    private func appearanceCard(label: String, value: String, image: NSImage) -> some View {
        let selected = vm.appearance == value
        return Button(action: { vm.appearance = value }) {
            VStack(spacing: 6) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardW, height: cardH)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selected ? Color.primary : Color.clear, lineWidth: 2.5)
                    )
                Text(label)
                    .font(.system(size: 12, weight: selected ? .bold : .regular))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Clock Dial Section

struct ClockDialSection: View {
    @ObservedObject var vm: SettingsViewModel
    private let visibleCount = 5
    private let circleDiameter: CGFloat = 88

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Clock Dial").font(.system(size: 14, weight: .bold))
                Spacer()
                Button(action: scrollLeft) {
                    Image(systemName: "chevron.left")
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))
                }
                .buttonStyle(.plain)
                .disabled(vm.dialScrollOffset <= 0)
                Button(action: scrollRight) {
                    Image(systemName: "chevron.right")
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))
                }
                .buttonStyle(.plain)
                .disabled(vm.dialScrollOffset >= Palettes.dialNames.count - visibleCount)
            }

            HStack(spacing: 10) {
                ForEach(visibleDialNames, id: \.self) { name in
                    dialCircleView(name: name)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .animation(.easeInOut(duration: 0.2), value: vm.dialScrollOffset)
        }
    }

    private var visibleDialNames: [String] {
        let start = vm.dialScrollOffset
        let end = min(start + visibleCount, Palettes.dialNames.count)
        return Array(Palettes.dialNames[start..<end])
    }

    private func scrollLeft() {
        vm.dialScrollOffset = max(0, vm.dialScrollOffset - 1)
    }
    private func scrollRight() {
        vm.dialScrollOffset = min(Palettes.dialNames.count - visibleCount, vm.dialScrollOffset + 1)
    }

    private func dialCircleView(name: String) -> some View {
        let selected = vm.dial == name
        let palette = Palettes.dials[name] ?? Palettes.dials["Noir"]!
        let img = ThumbnailRenderer.dialCircle(palette: palette, diameter: circleDiameter)

        return Button(action: { vm.dial = name }) {
            VStack(spacing: 6) {
                Image(nsImage: img)
                    .resizable()
                    .frame(width: circleDiameter, height: circleDiameter)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(selected ? Color.primary : Color.clear, lineWidth: 2.5)
                    )
                Text(name)
                    .font(.system(size: 11, weight: selected ? .bold : .regular))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Size Section

struct SizeSection: View {
    @ObservedObject var vm: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Size").font(.system(size: 14, weight: .bold))

            HStack(spacing: 10) {
                sizeCard(label: "Classic", value: "Classic", lineCount: 12, radius: 28)
                sizeCard(label: "Compact", value: "Compact", lineCount: 12, radius: 20)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private func sizeCard(label: String, value: String, lineCount: Int, radius: CGFloat) -> some View {
        let selected = vm.size == value
        return Button(action: { vm.size = value }) {
            VStack(spacing: 6) {
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    for i in 0..<lineCount {
                        let angle = CGFloat(i) * (360.0 / CGFloat(lineCount)) - 90
                        let rad = angle * .pi / 180
                        let innerR = radius * 0.45
                        let outerR = radius
                        let p1 = CGPoint(x: center.x + cos(rad) * innerR,
                                         y: center.y + sin(rad) * innerR)
                        let p2 = CGPoint(x: center.x + cos(rad) * outerR,
                                         y: center.y + sin(rad) * outerR)
                        var path = Path()
                        path.move(to: p1)
                        path.addLine(to: p2)
                        context.stroke(path, with: .color(.primary.opacity(0.6)),
                                       lineWidth: 2)
                    }
                }
                .frame(width: 70, height: 70)

                Text(label)
                    .font(.system(size: 11, weight: selected ? .bold : .regular))
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? Color.primary : Color.clear, lineWidth: 2.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Movement Section

struct MovementSection: View {
    @ObservedObject var vm: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Text("Movement").font(.system(size: 14, weight: .bold))
                Text("\u{00B7}")
                    .foregroundColor(.secondary)
                Text(vm.movementDescription)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 10) {
                movementCard(label: "Quartz", value: "Quartz", steps: 5, spread: 30)
                movementCard(label: "Mechanical", value: "Mechanical", steps: 10, spread: 25)
                movementCard(label: "Digital", value: "Digital", steps: 20, spread: 20)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private func movementCard(label: String, value: String, steps: Int, spread: CGFloat) -> some View {
        let selected = vm.movement == value
        return Button(action: { vm.movement = value }) {
            VStack(spacing: 6) {
                Canvas { context, size in
                    // Draw a fan of second-hand positions from bottom center
                    let pivot = CGPoint(x: size.width / 2, y: size.height * 0.85)
                    let handLen = size.height * 0.75

                    for i in 0..<steps {
                        let t = steps == 1 ? 0.5 : CGFloat(i) / CGFloat(steps - 1)
                        let angle = (-90 - spread / 2 + spread * t) * .pi / 180
                        let tip = CGPoint(x: pivot.x + cos(angle) * handLen,
                                          y: pivot.y + sin(angle) * handLen)
                        let alpha = 0.15 + 0.5 * (1.0 - abs(t - 0.5) * 2)
                        var path = Path()
                        path.move(to: pivot)
                        path.addLine(to: tip)
                        context.stroke(path, with: .color(.primary.opacity(alpha)),
                                       lineWidth: 1.2)
                    }
                }
                .frame(width: 70, height: 70)

                Text(label)
                    .font(.system(size: 11, weight: selected ? .bold : .regular))
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? Color.primary : Color.clear, lineWidth: 2.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lume Color Section

struct LumeSection: View {
    @ObservedObject var vm: SettingsViewModel
    private let circleSize: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lume Color")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                ForEach(Palettes.lumeNames, id: \.self) { name in
                    lumeCircle(name: name)
                }
            }

            Text(vm.lume)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }

    private func lumeCircle(name: String) -> some View {
        let selected = vm.lume == name
        let hexColor = Palettes.lumeColors[name] ?? "#3df03d"
        let color = Color(nsColor: NSColor(hex: hexColor))

        return Button(action: { vm.lume = name }) {
            ZStack {
                // Selection ring sits outside the filled circle
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: circleSize + 6, height: circleSize + 6)
                    .opacity(selected ? 1 : 0)
                Circle()
                    .fill(color)
                    .frame(width: circleSize, height: circleSize)
            }
            .frame(width: circleSize + 8, height: circleSize + 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Footer

struct FooterRow: View {
    let onCancel: () -> Void
    let onOK: () -> Void

    var body: some View {
        HStack {
            if let url = URL(string: "https://x.com/_atilla1") {
                Link(destination: url) {
                    HStack(spacing: 2) {
                        Text("Made with care by Atilla")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            Button("Cancel", action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.large)

            Button("OK", action: onOK)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.gray)
        }
    }
}
