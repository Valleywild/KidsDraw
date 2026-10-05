import SwiftUI
import Combine
import UIKit
import PencilKit
import Photos
import PhotosUI

// MARK: - Canvas Mode (Draw vs Stamp)
enum CanvasMode: Equatable {
    case drawing // ✏️ 画笔模式
    case stamp   // 🐾 印章模式
}

// MARK: - Crayon Color Model
struct CrayonColor: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color
    let uiColor: UIColor
    let tipColor: Color

    static func == (lhs: CrayonColor, rhs: CrayonColor) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Stamp Item Model
struct StampItem: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let color: Color
    let tipColor: Color

    static func == (lhs: StampItem, rhs: StampItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Placed Stamp On Canvas
struct PlacedStamp: Identifiable, Equatable {
    let id: UUID
    let item: StampItem
    var position: CGPoint
    var rotation: Angle
    var size: CGFloat
}

// MARK: - Unified Action Stack for Undo/Redo
enum CanvasAction: Equatable {
    case stroke
    case stamp(id: UUID)
}

// MARK: - App Appearance Mode (Light / Dark / System)
enum AppAppearanceMode: String, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "浅色模式"
        case .dark: return "深色模式"
        case .system: return "跟随系统"
        }
    }

    var shortTitle: String {
        switch self {
        case .light: return "浅色"
        case .dark: return "深色"
        case .system: return "系统"
        }
    }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.stars.fill"
        case .system: return "circle.righthalf.filled"
        }
    }
}

// MARK: - Drawing Brush Types
enum DrawingBrushType: String, CaseIterable, Identifiable {
    case crayon = "crayon"
    case pencil = "pencil"
    case pen = "pen"
    case marker = "marker"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .crayon: return "蜡笔"
        case .pencil: return "铅笔"
        case .pen: return "钢笔"
        case .marker: return "马克笔"
        }
    }

    var emoji: String {
        switch self {
        case .crayon: return "🖍️"
        case .pencil: return "✏️"
        case .pen: return "✒️"
        case .marker: return "🖌️"
        }
    }

    var subtitle: String {
        switch self {
        case .crayon: return "经典蜡质涂色"
        case .pencil: return "细腻素描线条"
        case .pen: return "圆润顺滑勾线"
        case .marker: return "鲜艳涂鸦高光"
        }
    }

    var canvasToolType: CanvasToolType {
        switch self {
        case .crayon: return .crayon
        case .pencil: return .pencil
        case .pen: return .pen
        case .marker: return .marker
        }
    }
}

// MARK: - Tool Types
enum CanvasToolType: Equatable {
    case crayon
    case pencil
    case pen
    case marker
    case eraser
    case pan // ✋ 移动 / 漫游

    var isDrawingBrush: Bool {
        switch self {
        case .crayon, .pencil, .pen, .marker:
            return true
        case .eraser, .pan:
            return false
        }
    }

    var brushType: DrawingBrushType? {
        switch self {
        case .crayon: return .crayon
        case .pencil: return .pencil
        case .pen: return .pen
        case .marker: return .marker
        case .eraser, .pan: return nil
        }
    }
}

// MARK: - Stroke Width / Stamp Size Presets
enum StrokePreset: Double, CaseIterable, Identifiable {
    case small = 8.0
    case medium = 18.0
    case large = 32.0

    var id: Double { self.rawValue }

    var title: String {
        switch self {
        case .small: return "细"
        case .medium: return "中"
        case .large: return "粗"
        }
    }

    var stampTitle: String {
        switch self {
        case .small: return "小"
        case .medium: return "中"
        case .large: return "大"
        }
    }

    var dotSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 20
        case .large: return 32
        }
    }

    var stampSize: CGFloat {
        switch self {
        case .small: return 46
        case .medium: return 70
        case .large: return 100
        }
    }
}

// MARK: - Main ViewModel
@MainActor
final class DrawingViewModel: ObservableObject {
    // 9 Standard Crayon Colors: 红橙黄绿蓝深蓝紫黑粉
    static let standardColors: [CrayonColor] = [
        CrayonColor(
            id: "red",
            name: "红",
            color: Color(red: 0.95, green: 0.22, blue: 0.21),
            uiColor: UIColor(red: 0.95, green: 0.22, blue: 0.21, alpha: 1.0),
            tipColor: Color(red: 0.82, green: 0.14, blue: 0.14)
        ),
        CrayonColor(
            id: "orange",
            name: "橙",
            color: Color(red: 1.0, green: 0.58, blue: 0.0),
            uiColor: UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0),
            tipColor: Color(red: 0.88, green: 0.46, blue: 0.0)
        ),
        CrayonColor(
            id: "yellow",
            name: "黄",
            color: Color(red: 1.0, green: 0.84, blue: 0.04),
            uiColor: UIColor(red: 1.0, green: 0.84, blue: 0.04, alpha: 1.0),
            tipColor: Color(red: 0.92, green: 0.72, blue: 0.0)
        ),
        CrayonColor(
            id: "green",
            name: "绿",
            color: Color(red: 0.22, green: 0.78, blue: 0.35),
            uiColor: UIColor(red: 0.22, green: 0.78, blue: 0.35, alpha: 1.0),
            tipColor: Color(red: 0.16, green: 0.65, blue: 0.28)
        ),
        CrayonColor(
            id: "blue",
            name: "蓝",
            color: Color(red: 0.12, green: 0.62, blue: 1.0),
            uiColor: UIColor(red: 0.12, green: 0.62, blue: 1.0, alpha: 1.0),
            tipColor: Color(red: 0.08, green: 0.48, blue: 0.85)
        ),
        CrayonColor(
            id: "dark_blue",
            name: "深蓝",
            color: Color(red: 0.08, green: 0.18, blue: 0.55),
            uiColor: UIColor(red: 0.08, green: 0.18, blue: 0.55, alpha: 1.0),
            tipColor: Color(red: 0.05, green: 0.12, blue: 0.42)
        ),
        CrayonColor(
            id: "purple",
            name: "紫",
            color: Color(red: 0.68, green: 0.32, blue: 0.88),
            uiColor: UIColor(red: 0.68, green: 0.32, blue: 0.88, alpha: 1.0),
            tipColor: Color(red: 0.55, green: 0.22, blue: 0.75)
        ),
        CrayonColor(
            id: "black",
            name: "黑",
            color: Color(red: 0.08, green: 0.08, blue: 0.08),
            uiColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            tipColor: Color.black
        ),
        CrayonColor(
            id: "pink",
            name: "粉",
            color: Color(red: 1.0, green: 0.45, blue: 0.66),
            uiColor: UIColor(red: 1.0, green: 0.45, blue: 0.66, alpha: 1.0),
            tipColor: Color(red: 0.90, green: 0.30, blue: 0.52)
        )
    ]

    // 10 Child-Friendly Magic Stamp Crayons
    static let standardStamps: [StampItem] = [
        StampItem(
            id: "cat",
            name: "小猫",
            emoji: "🐱",
            color: Color(red: 1.0, green: 0.55, blue: 0.65),
            tipColor: Color(red: 0.9, green: 0.4, blue: 0.5)
        ),
        StampItem(
            id: "flower",
            name: "小花",
            emoji: "🌸",
            color: Color(red: 0.98, green: 0.45, blue: 0.65),
            tipColor: Color(red: 0.88, green: 0.35, blue: 0.55)
        ),
        StampItem(
            id: "sun",
            name: "太阳",
            emoji: "☀️",
            color: Color(red: 1.0, green: 0.78, blue: 0.1),
            tipColor: Color(red: 0.9, green: 0.65, blue: 0.0)
        ),
        StampItem(
            id: "tree",
            name: "大树",
            emoji: "🌳",
            color: Color(red: 0.22, green: 0.75, blue: 0.35),
            tipColor: Color(red: 0.16, green: 0.62, blue: 0.28)
        ),
        StampItem(
            id: "house",
            name: "房子",
            emoji: "🏠",
            color: Color(red: 0.95, green: 0.45, blue: 0.25),
            tipColor: Color(red: 0.82, green: 0.35, blue: 0.18)
        ),
        StampItem(
            id: "car",
            name: "汽车",
            emoji: "🚗",
            color: Color(red: 0.20, green: 0.60, blue: 0.95),
            tipColor: Color(red: 0.12, green: 0.48, blue: 0.82)
        ),
        StampItem(
            id: "butterfly",
            name: "蝴蝶",
            emoji: "🦋",
            color: Color(red: 0.68, green: 0.38, blue: 0.92),
            tipColor: Color(red: 0.55, green: 0.25, blue: 0.78)
        ),
        StampItem(
            id: "dinosaur",
            name: "恐龙爪",
            emoji: "🐾",
            color: Color(red: 0.15, green: 0.45, blue: 0.75),
            tipColor: Color(red: 0.10, green: 0.35, blue: 0.60)
        ),
        StampItem(
            id: "star",
            name: "星星",
            emoji: "⭐",
            color: Color(red: 1.0, green: 0.85, blue: 0.15),
            tipColor: Color(red: 0.92, green: 0.72, blue: 0.05)
        ),
        StampItem(
            id: "heart",
            name: "爱心",
            emoji: "❤️",
            color: Color(red: 0.95, green: 0.22, blue: 0.28),
            tipColor: Color(red: 0.82, green: 0.15, blue: 0.20)
        )
    ]

    // Mode Switcher State
    @Published var canvasMode: CanvasMode = .drawing

    // Template Manager integration
    @Published var templateManager = TemplateManager.shared
    @Published var selectedTemplateId: String = "bear"
    @Published var showTemplatePickerSheet: Bool = false
    @Published var batchPhotosSelection: [PhotosPickerItem] = []

    // Active tool state (Drawing mode)
    @Published var selectedColor: CrayonColor = DrawingViewModel.standardColors[0]
    @Published var currentBrush: DrawingBrushType = {
        let saved = UserDefaults.standard.string(forKey: "app_active_brush") ?? DrawingBrushType.crayon.rawValue
        return DrawingBrushType(rawValue: saved) ?? .crayon
    }() {
        didSet {
            UserDefaults.standard.set(currentBrush.rawValue, forKey: "app_active_brush")
        }
    }
    @Published var selectedTool: CanvasToolType = .crayon
    @Published var strokePreset: StrokePreset = .medium

    // Active Stamp state (Stamp mode)
    @Published var selectedStamp: StampItem = DrawingViewModel.standardStamps[0]
    @Published var stamps: [PlacedStamp] = []

    // Unified Action Stack
    private var actionHistory: [CanvasAction] = []
    private var redoHistory: [CanvasAction] = []
    private var removedStampsCache: [PlacedStamp] = []
    var pkCanUndo: Bool = false
    var pkCanRedo: Bool = false

    // Custom Color Palette state
    @Published var showColorPickerSheet: Bool = false
    @Published var customCrayon: CrayonColor? = nil

    // Reference outline state
    @Published var showReferenceLine: Bool = true
    @Published var referenceOpacity: Double = 0.22

    // Zoom state
    @Published var zoomScale: CGFloat = 1.0
    @Published var contentOffset: CGPoint = .zero

    // Canvas state
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    @Published var showClearConfirmation: Bool = false

    // Appearance Mode State
    @Published var appearanceMode: AppAppearanceMode = {
        let saved = UserDefaults.standard.string(forKey: "app_appearance_mode") ?? AppAppearanceMode.light.rawValue
        return AppAppearanceMode(rawValue: saved) ?? .light
    }() {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "app_appearance_mode")
        }
    }

    var colorScheme: ColorScheme? {
        switch appearanceMode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    func setAppearanceMode(_ mode: AppAppearanceMode) {
        guard appearanceMode != mode else { return }
        appearanceMode = mode
        playHapticFeedback()
    }

    func toggleAppearanceMode() {
        switch appearanceMode {
        case .light:
            setAppearanceMode(.dark)
        case .dark:
            setAppearanceMode(.light)
        case .system:
            setAppearanceMode(.dark)
        }
    }

    // Save Feedback
    @Published var isSaving: Bool = false
    @Published var showSaveSuccessBanner: Bool = false
    @Published var saveErrorMessage: String? = nil

    // Canvas Bridge Closures
    var undoCanvas: (() -> Void)?
    var redoCanvas: (() -> Void)?
    var clearCanvas: (() -> Void)?
    var getCanvasDrawing: (() -> PKDrawing)?
    var setCanvasDrawing: ((PKDrawing) -> Void)?
    var captureCanvasImage: ((_ includeBackground: Bool) -> UIImage?)?
    var zoomInCanvas: (() -> Void)?
    var zoomOutCanvas: (() -> Void)?
    var resetZoomCanvas: (() -> Void)?

    // Multi-Artwork Drawing Storage per Template
    private var templateDrawings: [String: PKDrawing] = [:]
    private var templateStamps: [String: [PlacedStamp]] = [:]

    var currentTemplate: DrawingTemplateItem {
        templateManager.template(for: selectedTemplateId) ?? TemplateManager.builtInTemplates[0]
    }

    var currentTemplateImage: UIImage? {
        templateManager.image(for: currentTemplate)
    }

    var isImporting: Bool {
        templateManager.isImporting
    }

    var importProgress: String {
        templateManager.importProgress
    }

    var selectedStrokeWidth: CGFloat {
        let base = CGFloat(strokePreset.rawValue)
        switch currentBrush {
        case .crayon:
            return base
        case .pencil:
            return max(3, base * 0.65)
        case .pen:
            return max(3, base * 0.55)
        case .marker:
            return base * 1.25
        }
    }

    // MARK: - Actions

    func setCanvasMode(_ mode: CanvasMode) {
        guard canvasMode != mode else { return }
        canvasMode = mode
        playHapticFeedback()
    }

    func selectTemplate(_ template: DrawingTemplateItem) {
        guard selectedTemplateId != template.id else { return }

        // 1. Save current template's drawing and stamps
        if let currentDrawing = getCanvasDrawing?() {
            templateDrawings[selectedTemplateId] = currentDrawing
        }
        templateStamps[selectedTemplateId] = stamps

        // 2. Switch template ID
        selectedTemplateId = template.id
        showReferenceLine = true

        // 3. Load target template's drawing (empty by default for new canvas)
        let targetDrawing = templateDrawings[template.id] ?? PKDrawing()
        let targetStamps = templateStamps[template.id] ?? []

        stamps = targetStamps
        setCanvasDrawing?(targetDrawing)

        // 4. Reset action history for the new template
        actionHistory.removeAll()
        redoHistory.removeAll()
        removedStampsCache.removeAll()
        pkCanUndo = false
        pkCanRedo = false
        updateUndoRedoState()

        // 5. Reset zoom and center
        resetZoom()
        playHapticFeedback()
    }

    func deleteTemplate(_ template: DrawingTemplateItem) {
        templateDrawings.removeValue(forKey: template.id)
        templateStamps.removeValue(forKey: template.id)
        if selectedTemplateId == template.id {
            if let fallback = TemplateManager.builtInTemplates.first(where: { $0.id != template.id }) {
                selectTemplate(fallback)
            } else {
                selectedTemplateId = "bear"
            }
        }
        templateManager.deleteCustomTemplate(template)
        playHapticFeedback()
    }

    func selectBrush(_ brush: DrawingBrushType) {
        currentBrush = brush
        selectedTool = brush.canvasToolType
        playHapticFeedback()
    }

    func cycleNextBrush() {
        let all = DrawingBrushType.allCases
        if let idx = all.firstIndex(of: currentBrush) {
            let nextIndex = (idx + 1) % all.count
            selectBrush(all[nextIndex])
        } else {
            selectBrush(.crayon)
        }
    }

    func selectCrayonColor(_ crayon: CrayonColor) {
        selectedColor = crayon
        if selectedTool == .eraser || selectedTool == .pan {
            selectedTool = currentBrush.canvasToolType
        }
        playHapticFeedback()
    }

    func selectStamp(_ stamp: StampItem) {
        selectedStamp = stamp
        playHapticFeedback()
    }

    func applyCustomColor(color: Color, uiColor: UIColor, name: String) {
        let custom = CrayonColor(
            id: "custom_\(UUID().uuidString.prefix(6))",
            name: name,
            color: color,
            uiColor: uiColor,
            tipColor: color
        )
        customCrayon = custom
        selectedColor = custom
        if selectedTool == .eraser || selectedTool == .pan {
            selectedTool = currentBrush.canvasToolType
        }
        playHapticFeedback()
    }

    func selectTool(_ tool: CanvasToolType) {
        selectedTool = tool
        playHapticFeedback()
    }

    func setStrokePreset(_ preset: StrokePreset) {
        strokePreset = preset
        playHapticFeedback()
    }

    func toggleReferenceLine() {
        showReferenceLine.toggle()
        playHapticFeedback()
    }

    // MARK: - Stamp Placement
    func addStamp(at position: CGPoint) {
        let stampId = UUID()
        let randomAngle = Angle.degrees(Double.random(in: -12.0...12.0))
        let stamp = PlacedStamp(
            id: stampId,
            item: selectedStamp,
            position: position,
            rotation: randomAngle,
            size: strokePreset.stampSize
        )

        stamps.append(stamp)
        actionHistory.append(.stamp(id: stampId))
        redoHistory.removeAll()
        removedStampsCache.removeAll()
        updateUndoRedoState()
        playHapticFeedback()
    }

    // Called by PencilKit coordinator when a drawing stroke completes
    func registerStrokeAction() {
        actionHistory.append(.stroke)
        redoHistory.removeAll()
        removedStampsCache.removeAll()
        updateUndoRedoState()
    }

    func syncPKUndoState(canUndo: Bool, canRedo: Bool) {
        guard self.pkCanUndo != canUndo || self.pkCanRedo != canRedo else { return }
        self.pkCanUndo = canUndo
        self.pkCanRedo = canRedo
        updateUndoRedoState()
    }

    private func updateUndoRedoState() {
        let newCanUndo = !actionHistory.isEmpty || pkCanUndo
        let newCanRedo = !redoHistory.isEmpty || pkCanRedo
        if canUndo != newCanUndo {
            canUndo = newCanUndo
        }
        if canRedo != newCanRedo {
            canRedo = newCanRedo
        }
    }

    // MARK: - Unified Undo / Redo
    func undo() {
        guard canUndo else { return }

        if let lastAction = actionHistory.popLast() {
            switch lastAction {
            case .stamp(let stampId):
                if let idx = stamps.firstIndex(where: { $0.id == stampId }) {
                    let removed = stamps.remove(at: idx)
                    removedStampsCache.append(removed)
                    redoHistory.append(.stamp(id: stampId))
                }
            case .stroke:
                redoHistory.append(.stroke)
                undoCanvas?()
            }
        } else if pkCanUndo {
            undoCanvas?()
        }

        updateUndoRedoState()
        playHapticFeedback()
    }

    func redo() {
        guard canRedo else { return }

        if let lastRedo = redoHistory.popLast() {
            switch lastRedo {
            case .stamp(let stampId):
                if let cached = removedStampsCache.first(where: { $0.id == stampId }) {
                    stamps.append(cached)
                    removedStampsCache.removeAll(where: { $0.id == stampId })
                    actionHistory.append(.stamp(id: stampId))
                }
            case .stroke:
                actionHistory.append(.stroke)
                redoCanvas?()
            }
        } else if pkCanRedo {
            redoCanvas?()
        }

        updateUndoRedoState()
        playHapticFeedback()
    }

    func requestClear() {
        showClearConfirmation = true
        playHapticFeedback()
    }

    func confirmClear() {
        templateDrawings.removeValue(forKey: selectedTemplateId)
        templateStamps.removeValue(forKey: selectedTemplateId)
        stamps.removeAll()
        actionHistory.removeAll()
        redoHistory.removeAll()
        removedStampsCache.removeAll()
        clearCanvas?()
        showClearConfirmation = false
        updateUndoRedoState()
        playHapticFeedback()
    }

    // MARK: - Zoom Actions
    func zoomIn() {
        zoomInCanvas?()
        playHapticFeedback()
    }

    func zoomOut() {
        zoomOutCanvas?()
        playHapticFeedback()
    }

    func resetZoom() {
        resetZoomCanvas?()
        playHapticFeedback()
    }

    // MARK: - Batch Photos Import
    func handleBatchPhotosImport(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }

        Task {
            let newIds = await templateManager.importBatchPhotos(items: items)
            if let lastId = newIds.last, let newTemplate = templateManager.template(for: lastId) {
                selectTemplate(newTemplate)
                playSuccessHaptic()
            }
            batchPhotosSelection = []
        }
    }

    // MARK: - Save to Photos
    func saveToPhotos() {
        guard !isSaving else { return }
        isSaving = true

        guard let image = captureCanvasImage?(true) else {
            saveErrorMessage = "画作生成失败"
            isSaving = false
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .authorized, .limited:
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { [weak self] success, error in
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.isSaving = false
                            if success {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    self.showSaveSuccessBanner = true
                                }
                                self.playSuccessHaptic()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        self?.showSaveSuccessBanner = false
                                    }
                                }
                            } else {
                                self.saveErrorMessage = error?.localizedDescription ?? "保存失败，请稍后重试"
                            }
                        }
                    }
                case .denied, .restricted:
                    self.isSaving = false
                    self.saveErrorMessage = "请在“设置”中允许 KidsDraw 访问相册"
                case .notDetermined:
                    self.isSaving = false
                @unknown default:
                    self.isSaving = false
                }
            }
        }
    }

    private func playHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
    }

    private func playSuccessHaptic() {
        let notif = UINotificationFeedbackGenerator()
        notif.prepare()
        notif.notificationOccurred(.success)
    }
}
