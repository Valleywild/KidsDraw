import SwiftUI
import UIKit

struct ColorPalettePickerSheet: View {
    @ObservedObject var viewModel: DrawingViewModel
    @Environment(\.dismiss) private var dismiss

    // 28 curated kid-friendly color swatches
    static let colorSwatches: [(name: String, color: Color, uiColor: UIColor)] = [
        // Reds & Pinks
        ("鲜红", Color(red: 0.95, green: 0.20, blue: 0.20), UIColor(red: 0.95, green: 0.20, blue: 0.20, alpha: 1.0)),
        ("西瓜红", Color(red: 0.98, green: 0.35, blue: 0.40), UIColor(red: 0.98, green: 0.35, blue: 0.40, alpha: 1.0)),
        ("深红", Color(red: 0.75, green: 0.10, blue: 0.15), UIColor(red: 0.75, green: 0.10, blue: 0.15, alpha: 1.0)),
        ("荧光粉", Color(red: 1.0, green: 0.25, blue: 0.60), UIColor(red: 1.0, green: 0.25, blue: 0.60, alpha: 1.0)),
        ("芭比粉", Color(red: 1.0, green: 0.45, blue: 0.70), UIColor(red: 1.0, green: 0.45, blue: 0.70, alpha: 1.0)),
        ("浅粉", Color(red: 1.0, green: 0.75, blue: 0.85), UIColor(red: 1.0, green: 0.75, blue: 0.85, alpha: 1.0)),

        // Oranges & Yellows
        ("蜜桔橙", Color(red: 1.0, green: 0.50, blue: 0.0), UIColor(red: 1.0, green: 0.50, blue: 0.0, alpha: 1.0)),
        ("阳光黄", Color(red: 1.0, green: 0.82, blue: 0.0), UIColor(red: 1.0, green: 0.82, blue: 0.0, alpha: 1.0)),
        ("柠檬黄", Color(red: 1.0, green: 0.95, blue: 0.20), UIColor(red: 1.0, green: 0.95, blue: 0.20, alpha: 1.0)),
        ("杏黄", Color(red: 1.0, green: 0.70, blue: 0.30), UIColor(red: 1.0, green: 0.70, blue: 0.30, alpha: 1.0)),
        ("琥珀色", Color(red: 0.90, green: 0.40, blue: 0.10), UIColor(red: 0.90, green: 0.40, blue: 0.10, alpha: 1.0)),
        ("浅桃", Color(red: 1.0, green: 0.85, blue: 0.75), UIColor(red: 1.0, green: 0.85, blue: 0.75, alpha: 1.0)),

        // Greens
        ("嫩绿", Color(red: 0.45, green: 0.85, blue: 0.25), UIColor(red: 0.45, green: 0.85, blue: 0.25, alpha: 1.0)),
        ("草绿", Color(red: 0.20, green: 0.75, blue: 0.35), UIColor(red: 0.20, green: 0.75, blue: 0.35, alpha: 1.0)),
        ("墨绿", Color(red: 0.10, green: 0.50, blue: 0.20), UIColor(red: 0.10, green: 0.50, blue: 0.20, alpha: 1.0)),
        ("薄荷绿", Color(red: 0.40, green: 0.90, blue: 0.70), UIColor(red: 0.40, green: 0.90, blue: 0.70, alpha: 1.0)),
        ("青柠", Color(red: 0.75, green: 0.90, blue: 0.20), UIColor(red: 0.75, green: 0.90, blue: 0.20, alpha: 1.0)),

        // Blues
        ("天蓝", Color(red: 0.20, green: 0.65, blue: 1.0), UIColor(red: 0.20, green: 0.65, blue: 1.0, alpha: 1.0)),
        ("青蓝", Color(red: 0.0, green: 0.75, blue: 0.90), UIColor(red: 0.0, green: 0.75, blue: 0.90, alpha: 1.0)),
        ("宝蓝", Color(red: 0.10, green: 0.35, blue: 0.90), UIColor(red: 0.10, green: 0.35, blue: 0.90, alpha: 1.0)),
        ("深海蓝", Color(red: 0.05, green: 0.15, blue: 0.50), UIColor(red: 0.05, green: 0.15, blue: 0.50, alpha: 1.0)),

        // Purples
        ("香芋紫", Color(red: 0.80, green: 0.60, blue: 0.95), UIColor(red: 0.80, green: 0.60, blue: 0.95, alpha: 1.0)),
        ("葡萄紫", Color(red: 0.60, green: 0.25, blue: 0.85), UIColor(red: 0.60, green: 0.25, blue: 0.85, alpha: 1.0)),
        ("暗紫", Color(red: 0.38, green: 0.12, blue: 0.60), UIColor(red: 0.38, green: 0.12, blue: 0.60, alpha: 1.0)),

        // Earth & Neutrals
        ("巧克力", Color(red: 0.45, green: 0.25, blue: 0.12), UIColor(red: 0.45, green: 0.25, blue: 0.12, alpha: 1.0)),
        ("咖啡棕", Color(red: 0.65, green: 0.40, blue: 0.25), UIColor(red: 0.65, green: 0.40, blue: 0.25, alpha: 1.0)),
        ("纯黑", Color(red: 0.10, green: 0.10, blue: 0.12), UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)),
        ("浅灰", Color(red: 0.75, green: 0.75, blue: 0.78), UIColor(red: 0.75, green: 0.75, blue: 0.78, alpha: 1.0))
    ]

    @State private var freeColor: Color = .pink

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("🎨 调色盘色块")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.15, green: 0.2, blue: 0.35))

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.gray.opacity(0.6))
                }
            }
            .padding(.top, 8)

            // Color block grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 7)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Self.colorSwatches, id: \.name) { swatch in
                    Button(action: {
                        viewModel.applyCustomColor(color: swatch.color, uiColor: swatch.uiColor, name: swatch.name)
                        dismiss()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(swatch.color)
                                .frame(height: 54)
                                .shadow(color: swatch.color.opacity(0.3), radius: 4, x: 0, y: 2)

                            // Selected indicator
                            if viewModel.selectedColor.uiColor == swatch.uiColor {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.4), radius: 2)
                            }
                        }
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }

            Divider()
                .padding(.vertical, 4)

            // Free color picker
            HStack(spacing: 16) {
                ColorPicker("✨ 自由颜色调配盘", selection: $freeColor, supportsOpacity: false)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.35))
                    .onChange(of: freeColor) { _, newColor in
                        let uiColor = UIColor(newColor)
                        viewModel.applyCustomColor(color: newColor, uiColor: uiColor, name: "自定义")
                    }

                Spacer()

                Button(action: {
                    let uiColor = UIColor(freeColor)
                    viewModel.applyCustomColor(color: freeColor, uiColor: uiColor, name: "自定义")
                    dismiss()
                }) {
                    Text("选定这个颜色")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 44)
                        .background(freeColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: freeColor.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
