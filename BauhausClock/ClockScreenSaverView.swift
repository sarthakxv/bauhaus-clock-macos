import ScreenSaver

@objc(ClockScreenSaverView)
class ClockScreenSaverView: ScreenSaverView {

    private var displayTimer: Timer?
    private var driftX: CGFloat = 0
    private var driftY: CGFloat = 0
    private var lastDriftTime: Date = Date()

    private lazy var defaults: ScreenSaverDefaults? = {
        guard let id = Bundle(for: type(of: self)).bundleIdentifier else { return nil }
        let d = ScreenSaverDefaults(forModuleWithName: id)
        d?.register(defaults: [
            "dial": "Noir",
            "movement": "Mechanical",
            "size": "Classic",
            "night": false,
            "lume": "Tritium Green",
            "seconds": true,
        ])
        return d
    }()

    // MARK: - Settings Accessors

    private var dialName: String { defaults?.string(forKey: "dial") ?? "Noir" }
    private var movement: String { defaults?.string(forKey: "movement") ?? "Mechanical" }
    private var clockSize: String { defaults?.string(forKey: "size") ?? "Classic" }
    private var isNight: Bool { defaults?.bool(forKey: "night") ?? false }
    private var lumeName: String { defaults?.string(forKey: "lume") ?? "Tritium Green" }
    private var showSeconds: Bool { defaults?.bool(forKey: "seconds") ?? true }

    private var palette: ClockPalette {
        if isNight {
            return Palettes.nightPalette(lume: lumeName)
        }
        return Palettes.dials[dialName] ?? Palettes.dials["Noir"]!
    }

    // Flip coordinate system to match SVG (Y goes down from top-left)
    override var isFlipped: Bool { true }

    // MARK: - Init

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        // Use a fast timer for smooth animation (target ~60fps)
        animationTimeInterval = 1.0 / 60.0
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    // MARK: - Lifecycle

    override func startAnimation() {
        super.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    // MARK: - Drawing

    override func draw(_ rect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        // Update burn-in drift every 45 seconds
        let now = Date()
        if now.timeIntervalSince(lastDriftTime) > 45 {
            driftX = CGFloat.random(in: -4...4)
            driftY = CGFloat.random(in: -4...4)
            lastDriftTime = now
        }

        let pal = palette

        // Fill background
        ctx.setFillColor(pal.bg.cgC)
        ctx.fill(bounds)

        // Apply drift offset
        ctx.saveGState()
        ctx.translateBy(x: driftX, y: driftY)

        ClockRenderer.draw(
            in: ctx,
            size: bounds.size,
            pal: pal,
            now: now,
            movement: movement,
            clockSize: clockSize,
            showSeconds: showSeconds,
            night: isNight
        )

        ctx.restoreGState()
    }

    override func animateOneFrame() {
        setNeedsDisplay(bounds)
    }

    // MARK: - Configure Sheet

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
