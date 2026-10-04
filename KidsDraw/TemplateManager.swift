import SwiftUI
import Combine
import UIKit
import PhotosUI

// MARK: - Unified Template Item Model
struct DrawingTemplateItem: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let isCustom: Bool
    let assetName: String?
    let localFilename: String?

    static func == (lhs: DrawingTemplateItem, rhs: DrawingTemplateItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Custom Template Metadata for JSON Persistence
struct CustomTemplateMetadata: Codable {
    let id: String
    let name: String
    let emoji: String
    let filename: String
    let createdAt: Date
}

// MARK: - Template Manager
@MainActor
final class TemplateManager: ObservableObject {
    static let shared = TemplateManager()

    // Built-in Templates (Curated from user line-art collection)
    static let builtInTemplates: [DrawingTemplateItem] = [
        // MARK: - Ultraman Heroes (超萌奥特曼系列)
        DrawingTemplateItem(id: "ultra_father", name: "奥特之父", emoji: "🦸‍♂️", isCustom: false, assetName: "outline_ultra_father", localFilename: nil),
        DrawingTemplateItem(id: "ultra_jack", name: "捷克奥特曼", emoji: "⚡", isCustom: false, assetName: "outline_ultra_jack", localFilename: nil),
        DrawingTemplateItem(id: "ultra_ginga", name: "银河奥特曼", emoji: "🌌", isCustom: false, assetName: "outline_ultra_ginga", localFilename: nil),
        DrawingTemplateItem(id: "ultra_cosmos", name: "高斯奥特曼", emoji: "🌸", isCustom: false, assetName: "outline_ultra_cosmos", localFilename: nil),
        DrawingTemplateItem(id: "ultra_group", name: "奥特曼合影", emoji: "🌟", isCustom: false, assetName: "outline_ultra_group", localFilename: nil),

        // MARK: - Dinosaur Kingdom (恐龙乐园系列)
        DrawingTemplateItem(id: "dino_trex", name: "霸王龙", emoji: "🦖", isCustom: false, assetName: "outline_dino_trex", localFilename: nil),
        DrawingTemplateItem(id: "dino_triceratops", name: "三角龙", emoji: "🛡️", isCustom: false, assetName: "outline_dino_triceratops", localFilename: nil),
        DrawingTemplateItem(id: "dino_brachio", name: "长颈腕龙", emoji: "🦕", isCustom: false, assetName: "outline_dino_brachio", localFilename: nil),
        DrawingTemplateItem(id: "dino_stegosaurus", name: "可爱剑龙", emoji: "🦴", isCustom: false, assetName: "outline_dino_stegosaurus", localFilename: nil),
        DrawingTemplateItem(id: "dino_ankylosaurus", name: "装甲甲龙", emoji: "🐢", isCustom: false, assetName: "outline_dino_ankylosaurus", localFilename: nil),
        DrawingTemplateItem(id: "dino_diplodocus", name: "憨厚雷龙", emoji: "🦕", isCustom: false, assetName: "outline_dino_diplodocus", localFilename: nil),
        DrawingTemplateItem(id: "dino_raptor", name: "迅猛龙", emoji: "🏃", isCustom: false, assetName: "outline_dino_raptor", localFilename: nil),
        DrawingTemplateItem(id: "dino_pterosaur_baby", name: "小翼龙", emoji: "🦅", isCustom: false, assetName: "outline_dino_pterosaur_baby", localFilename: nil),
        DrawingTemplateItem(id: "dino_pterosaur_giant", name: "巨型翼龙", emoji: "✈️", isCustom: false, assetName: "outline_dino_pterosaur_giant", localFilename: nil),
        DrawingTemplateItem(id: "dino_group", name: "恐龙乐园", emoji: "🌴", isCustom: false, assetName: "outline_dino_group", localFilename: nil),

        // Animals & Cute Characters
        DrawingTemplateItem(id: "bear", name: "可爱小熊", emoji: "🧸", isCustom: false, assetName: "outline_bear", localFilename: nil),
        DrawingTemplateItem(id: "cat", name: "小花猫", emoji: "🐱", isCustom: false, assetName: "outline_cat", localFilename: nil),
        DrawingTemplateItem(id: "dog", name: "可爱小狗", emoji: "🐶", isCustom: false, assetName: "outline_dog", localFilename: nil),
        DrawingTemplateItem(id: "pig", name: "小萌猪", emoji: "🐷", isCustom: false, assetName: "outline_pig", localFilename: nil),
        DrawingTemplateItem(id: "mouse", name: "小老鼠", emoji: "🐭", isCustom: false, assetName: "outline_mouse", localFilename: nil),
        DrawingTemplateItem(id: "rooster", name: "大公鸡", emoji: "🐔", isCustom: false, assetName: "outline_rooster", localFilename: nil),
        DrawingTemplateItem(id: "fish", name: "游水小鱼", emoji: "🐟", isCustom: false, assetName: "outline_fish", localFilename: nil),
        DrawingTemplateItem(id: "bee", name: "小蜜蜂", emoji: "🐝", isCustom: false, assetName: "outline_bee", localFilename: nil),
        DrawingTemplateItem(id: "butterfly", name: "小蝴蝶", emoji: "🦋", isCustom: false, assetName: "outline_butterfly", localFilename: nil),
        DrawingTemplateItem(id: "dino", name: "快乐恐龙", emoji: "🦖", isCustom: false, assetName: "outline_dino", localFilename: nil),

        // Vehicles & Toys
        DrawingTemplateItem(id: "car", name: "小汽车", emoji: "🚗", isCustom: false, assetName: "outline_car", localFilename: nil),
        DrawingTemplateItem(id: "rocket", name: "太空火箭", emoji: "🚀", isCustom: false, assetName: "outline_rocket", localFilename: nil),
        DrawingTemplateItem(id: "ship", name: "大轮船", emoji: "🚢", isCustom: false, assetName: "outline_ship", localFilename: nil),
        DrawingTemplateItem(id: "balloon", name: "快乐气球", emoji: "🎈", isCustom: false, assetName: "outline_balloon", localFilename: nil),
        DrawingTemplateItem(id: "blocks", name: "积木城堡", emoji: "🧱", isCustom: false, assetName: "outline_blocks", localFilename: nil),

        // Food & Treats
        DrawingTemplateItem(id: "apple", name: "大苹果", emoji: "🍎", isCustom: false, assetName: "outline_apple", localFilename: nil),
        DrawingTemplateItem(id: "strawberry", name: "红草莓", emoji: "🍓", isCustom: false, assetName: "outline_strawberry", localFilename: nil),
        DrawingTemplateItem(id: "corn", name: "甜玉米", emoji: "🌽", isCustom: false, assetName: "outline_corn", localFilename: nil),
        DrawingTemplateItem(id: "avocado", name: "牛油果", emoji: "🥑", isCustom: false, assetName: "outline_avocado", localFilename: nil),
        DrawingTemplateItem(id: "pizza", name: "美味披萨", emoji: "🍕", isCustom: false, assetName: "outline_pizza", localFilename: nil),
        DrawingTemplateItem(id: "cake", name: "生日蛋糕", emoji: "🎂", isCustom: false, assetName: "outline_cake", localFilename: nil),
        DrawingTemplateItem(id: "icecream", name: "甜冰淇淋", emoji: "🍦", isCustom: false, assetName: "outline_icecream", localFilename: nil),
        DrawingTemplateItem(id: "lollipop", name: "棒棒糖", emoji: "🍭", isCustom: false, assetName: "outline_lollipop", localFilename: nil),

        // Nature & Everyday Fun
        DrawingTemplateItem(id: "sun", name: "温暖太阳", emoji: "☀️", isCustom: false, assetName: "outline_sun", localFilename: nil),
        DrawingTemplateItem(id: "star", name: "闪亮星星", emoji: "⭐", isCustom: false, assetName: "outline_star", localFilename: nil),
        DrawingTemplateItem(id: "rain", name: "下雨云朵", emoji: "🌧️", isCustom: false, assetName: "outline_rain", localFilename: nil),
        DrawingTemplateItem(id: "tree", name: "小松树", emoji: "🌲", isCustom: false, assetName: "outline_tree", localFilename: nil),
        DrawingTemplateItem(id: "flower", name: "太阳花", emoji: "🌻", isCustom: false, assetName: "outline_flower", localFilename: nil),
        DrawingTemplateItem(id: "umbrella", name: "小雨伞", emoji: "☂️", isCustom: false, assetName: "outline_umbrella", localFilename: nil),
        DrawingTemplateItem(id: "house", name: "温馨小家", emoji: "🏠", isCustom: false, assetName: "outline_house", localFilename: nil),
        DrawingTemplateItem(id: "heart", name: "温暖爱心", emoji: "❤️", isCustom: false, assetName: "outline_heart", localFilename: nil),
        DrawingTemplateItem(id: "smiley", name: "开心笑脸", emoji: "😊", isCustom: false, assetName: "outline_smiley", localFilename: nil),
        DrawingTemplateItem(id: "easter_egg", name: "彩色蛋", emoji: "🥚", isCustom: false, assetName: "outline_easter_egg", localFilename: nil),

        // Free Drawing Canvas
        DrawingTemplateItem(id: "blank", name: "自由画布", emoji: "✨", isCustom: false, assetName: nil, localFilename: nil)
    ]

    @Published private(set) var customTemplates: [DrawingTemplateItem] = []
    @Published var isImporting: Bool = false
    @Published var importProgress: String = ""

    // In-memory image cache for fast rendering
    private var imageCache: [String: UIImage] = [:]

    private var templatesFolderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("CustomTemplates", isDirectory: true)
    }

    private var metadataFileURL: URL {
        templatesFolderURL.appendingPathComponent("templates_meta.json")
    }

    init() {
        ensureDirectoryExists()
        loadPersistedTemplates()
    }

    // All templates combined: Built-in + Custom
    var allTemplates: [DrawingTemplateItem] {
        Self.builtInTemplates + customTemplates
    }

    func template(for id: String) -> DrawingTemplateItem? {
        allTemplates.first(where: { $0.id == id })
    }

    // MARK: - Image Accessor
    func image(for template: DrawingTemplateItem) -> UIImage? {
        if let cached = imageCache[template.id] {
            return cached
        }

        if template.isCustom, let filename = template.localFilename {
            let fileURL = templatesFolderURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: fileURL), let img = UIImage(data: data) {
                imageCache[template.id] = img
                return img
            }
        } else if let assetName = template.assetName, !assetName.isEmpty {
            if let img = UIImage(named: assetName) {
                imageCache[template.id] = img
                return img
            }
        }
        return nil
    }

    // MARK: - Batch Import Photos & Persistence
    func importBatchPhotos(items: [PhotosPickerItem]) async -> [String] {
        guard !items.isEmpty else { return [] }

        isImporting = true
        importProgress = "准备导入 0 / \(items.count)"
        var newIds: [String] = []

        let total = items.count
        var count = 0

        for item in items {
            count += 1
            importProgress = "正在转换 \(count) / \(total)..."

            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let rawImage = UIImage(data: data) {

                    // Run line art conversion in background
                    let lineArt = await withCheckedContinuation { continuation in
                        DispatchQueue.global(qos: .userInitiated).async {
                            let converted = LineArtConverter.convertToLineArt(image: rawImage)
                            continuation.resume(returning: converted)
                        }
                    }

                    if let finalImage = lineArt ?? rawImage.grayscale() {
                        let id = "custom_\(UUID().uuidString.prefix(8))"
                        let filename = "\(id).png"
                        let fileURL = templatesFolderURL.appendingPathComponent(filename)

                        // Save PNG data to sandbox
                        if let pngData = finalImage.pngData() {
                            try pngData.write(to: fileURL)

                            let name = "简笔画 \(customTemplates.count + 1)"
                            let templateItem = DrawingTemplateItem(
                                id: id,
                                name: name,
                                emoji: "📸",
                                isCustom: true,
                                assetName: nil,
                                localFilename: filename
                            )

                            customTemplates.append(templateItem)
                            imageCache[id] = finalImage
                            newIds.append(id)
                        }
                    }
                }
            } catch {
                print("Error loading photo: \(error)")
            }
        }

        // Persist metadata
        saveMetadata()
        isImporting = false
        importProgress = ""
        return newIds
    }

    // MARK: - Delete Custom Template
    func deleteCustomTemplate(_ template: DrawingTemplateItem) {
        guard template.isCustom else { return }
        customTemplates.removeAll(where: { $0.id == template.id })
        imageCache.removeValue(forKey: template.id)

        if let filename = template.localFilename {
            let fileURL = templatesFolderURL.appendingPathComponent(filename)
            try? FileManager.default.removeItem(at: fileURL)
        }
        saveMetadata()
    }

    // MARK: - Persistence Internals
    private func ensureDirectoryExists() {
        let fm = FileManager.default
        if !fm.fileExists(atPath: templatesFolderURL.path) {
            try? fm.createDirectory(at: templatesFolderURL, withIntermediateDirectories: true)
        }
    }

    private func saveMetadata() {
        let metas = customTemplates.compactMap { item -> CustomTemplateMetadata? in
            guard let filename = item.localFilename else { return nil }
            return CustomTemplateMetadata(
                id: item.id,
                name: item.name,
                emoji: item.emoji,
                filename: filename,
                createdAt: Date()
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(metas) {
            try? data.write(to: metadataFileURL, options: .atomic)
        }
    }

    private func loadPersistedTemplates() {
        guard FileManager.default.fileExists(atPath: metadataFileURL.path),
              let data = try? Data(contentsOf: metadataFileURL) else { return }

        let decoder = JSONDecoder()
        guard let metas = try? decoder.decode([CustomTemplateMetadata].self, from: data) else { return }

        self.customTemplates = metas.map { meta in
            DrawingTemplateItem(
                id: meta.id,
                name: meta.name,
                emoji: meta.emoji,
                isCustom: true,
                assetName: nil,
                localFilename: meta.filename
            )
        }
    }
}

// MARK: - UIImage Grayscale Fallback Extension
extension UIImage {
    func grayscale() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0.0, forKey: kCIInputSaturationKey)
        guard let output = filter?.outputImage else { return nil }
        let ctx = CIContext(options: nil)
        guard let cgImage = ctx.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
