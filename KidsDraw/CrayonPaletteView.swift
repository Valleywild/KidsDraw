import SwiftUI
import UIKit

struct CrayonPaletteView: View {
    @ObservedObject var viewModel: DrawingViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 4) {
                if viewModel.canvasMode == .drawing {
                    // MARK: - Drawing Mode: 9 Standard Crayons
                    ForEach(DrawingViewModel.standardColors) { crayon in
                        CrayonButton(
                            crayon: crayon,
                            isSelected: viewModel.selectedTool.isDrawingBrush && viewModel.selectedColor.id == crayon.id
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectCrayonColor(crayon)
                            }
                        }
                    }

                    // Custom active Crayon (if user picked one from the color palette)
                    if let custom = viewModel.customCrayon {
                        CrayonButton(
                            crayon: custom,
                            isSelected: viewModel.selectedTool.isDrawingBrush && viewModel.selectedColor.id == custom.id
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectCrayonColor(custom)
                            }
                        }
                    }

                    Rectangle()
                        .fill(Color.primary.opacity(0.12))
                        .frame(width: 60, height: 1.5)
                        .padding(.vertical, 2)

                    // More Colors / Custom Color Palette Button
                    Button(action: {
                        viewModel.showColorPickerSheet = true
                    }) {
                        VStack(spacing: 2) {
                            Text("🎨")
                                .font(.system(size: 20))
                            Text("调色盘")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundColor(Color.primary)
                        }
                        .frame(width: 76, height: 42)
                        .background(Color(UIColor.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(BouncyButtonStyle())

                } else {
                    // MARK: - Stamp Mode: 10 Pattern Stamp Crayons
                    ForEach(DrawingViewModel.standardStamps) { stamp in
                        StampCrayonButton(
                            stamp: stamp,
                            isSelected: viewModel.selectedStamp.id == stamp.id
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectStamp(stamp)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .frame(width: 98)
        .frame(maxHeight: 580)
        .liquidGlass(cornerRadius: 26)
    }
}

// MARK: - Individual Color Crayon Button
struct CrayonButton: View {
    let crayon: CrayonColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Pointed Crayon Tip (pointing left towards canvas)
                CrayonTipShape()
                    .fill(crayon.tipColor)
                    .frame(width: 14, height: 28)

                // Crayon Body
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(crayon.color)

                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.white.opacity(0.28))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 4)

                    Text(crayon.name)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(width: 58, height: 38)

                // Right rounded end of crayon
                CrayonEndShape()
                    .fill(crayon.color)
                    .frame(width: 8, height: 38)
            }
            .frame(height: 42)
            .offset(x: isSelected ? -5 : 4)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3.5)
                    .offset(x: isSelected ? -5 : 4)
                    .shadow(color: isSelected ? Color.yellow.opacity(0.6) : Color.clear, radius: 6)
            )
        }
        .buttonStyle(BouncyButtonStyle())
        .accessibilityLabel(Text("\(crayon.name) 蜡笔"))
    }
}

// MARK: - Individual Pattern Stamp Crayon Button
struct StampCrayonButton: View {
    let stamp: StampItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Pointed Tip
                CrayonTipShape()
                    .fill(stamp.tipColor)
                    .frame(width: 14, height: 28)

                // Crayon Body with Icon & Stamp Name
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(stamp.color)

                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.white.opacity(0.3))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 3)

                    HStack(spacing: 2) {
                        Text(stamp.emoji)
                            .font(.system(size: 16))

                        Text(stamp.name)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                .frame(width: 58, height: 38)

                // Right rounded end
                CrayonEndShape()
                    .fill(stamp.color)
                    .frame(width: 8, height: 38)
            }
            .frame(height: 42)
            .offset(x: isSelected ? -5 : 4)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3.5)
                    .offset(x: isSelected ? -5 : 4)
                    .shadow(color: isSelected ? Color.yellow.opacity(0.6) : Color.clear, radius: 6)
            )
        }
        .buttonStyle(BouncyButtonStyle())
        .accessibilityLabel(Text("\(stamp.name) 魔术印章"))
    }
}

// MARK: - Custom Crayon Shapes
struct CrayonTipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control1: CGPoint(x: rect.maxX - rect.width * 0.4, y: rect.minY + 2),
            control2: CGPoint(x: rect.minX + 3, y: rect.midY - 4)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.minX + 3, y: rect.midY + 4),
            control2: CGPoint(x: rect.maxX - rect.width * 0.4, y: rect.maxY - 2)
        )
        path.closeSubpath()
        return path
    }
}

struct CrayonEndShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - 4, y: rect.minY + 4),
            radius: 4,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 4))
        path.addArc(
            center: CGPoint(x: rect.maxX - 4, y: rect.maxY - 4),
            radius: 4,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Bouncy Button Style for kids
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
