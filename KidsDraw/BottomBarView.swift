import SwiftUI
import UIKit

struct BottomBarView: View {
    @ObservedObject var viewModel: DrawingViewModel
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: isCompact ? 8 : 16) {
            // MARK: - Undo & Redo Group
            HStack(spacing: isCompact ? 6 : 10) {
                // Undo Button
                Button(action: {
                    viewModel.undo()
                }) {
                    HStack(spacing: isCompact ? 4 : 6) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: isCompact ? 16 : 20, weight: .black))
                        Text("撤销")
                            .font(.system(size: isCompact ? 14 : 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(viewModel.canUndo ? Color.primary : Color.secondary.opacity(0.4))
                    .frame(height: isCompact ? 46 : 56)
                    .padding(.horizontal, isCompact ? 10 : 16)
                    .background(Color(UIColor.secondarySystemFill).opacity(viewModel.canUndo ? 0.9 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1.0)
                    )
                    .shadow(color: Color.black.opacity(viewModel.canUndo ? 0.06 : 0.0), radius: 6, x: 0, y: 3)
                }
                .disabled(!viewModel.canUndo)
                .buttonStyle(BouncyButtonStyle())
                .fixedSize(horizontal: true, vertical: false)

                // Redo Button
                Button(action: {
                    viewModel.redo()
                }) {
                    HStack(spacing: isCompact ? 4 : 6) {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: isCompact ? 16 : 20, weight: .black))
                        Text("重做")
                            .font(.system(size: isCompact ? 14 : 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(viewModel.canRedo ? Color.primary : Color.secondary.opacity(0.4))
                    .frame(height: isCompact ? 46 : 56)
                    .padding(.horizontal, isCompact ? 10 : 16)
                    .background(Color(UIColor.secondarySystemFill).opacity(viewModel.canRedo ? 0.9 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1.0)
                    )
                    .shadow(color: Color.black.opacity(viewModel.canRedo ? 0.06 : 0.0), radius: 6, x: 0, y: 3)
                }
                .disabled(!viewModel.canRedo)
                .buttonStyle(BouncyButtonStyle())
                .fixedSize(horizontal: true, vertical: false)
            }

            Spacer(minLength: 4)

            // MARK: - Central Tool Group (Drawing vs Stamp Mode)
            if viewModel.canvasMode == .drawing {
                // Brush / Eraser & Stroke Width
                HStack(spacing: isCompact ? 6 : 12) {
                    // Brush Switcher Capsule Button (蜡笔 🖍️ / 铅笔 ✏️ / 钢笔 ✒️ / 马克笔 🖌️)
                    HStack(spacing: 0) {
                        // Left: Tap to Activate or Cycle to Next Brush
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                if !viewModel.selectedTool.isDrawingBrush {
                                    viewModel.selectBrush(viewModel.currentBrush)
                                } else {
                                    viewModel.cycleNextBrush()
                                }
                            }
                        }) {
                            HStack(spacing: isCompact ? 4 : 6) {
                                Text(viewModel.currentBrush.emoji)
                                    .font(.system(size: isCompact ? 18 : 22))

                                Text(viewModel.currentBrush.title)
                                    .font(.system(size: isCompact ? 14 : 17, weight: .heavy, design: .rounded))
                            }
                            .padding(.leading, isCompact ? 10 : 16)
                            .padding(.trailing, isCompact ? 6 : 8)
                            .frame(height: isCompact ? 46 : 56)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(BouncyButtonStyle())

                        // Vertical Subtle Divider Line
                        Rectangle()
                            .fill(viewModel.selectedTool.isDrawingBrush ? Color.white.opacity(0.35) : Color.primary.opacity(0.15))
                            .frame(width: 1.2, height: isCompact ? 22 : 26)

                        // Right: Dropdown Menu to Directly Pick Any Brush
                        Menu {
                            ForEach(DrawingBrushType.allCases) { brush in
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        viewModel.selectBrush(brush)
                                    }
                                }) {
                                    HStack {
                                        Text("\(brush.emoji) \(brush.title) (\(brush.subtitle))")
                                        if viewModel.currentBrush == brush && viewModel.selectedTool.isDrawingBrush {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: isCompact ? 11 : 13, weight: .bold))
                                .frame(width: isCompact ? 28 : 36, height: isCompact ? 46 : 56)
                                .contentShape(Rectangle())
                        }
                    }
                    .foregroundColor(viewModel.selectedTool.isDrawingBrush ? .white : Color.primary.opacity(0.8))
                    .frame(height: isCompact ? 46 : 56)
                    .background(
                        viewModel.selectedTool.isDrawingBrush
                            ? viewModel.selectedColor.color
                            : Color(UIColor.secondarySystemFill)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous)
                            .stroke(viewModel.selectedTool.isDrawingBrush ? Color.white : Color.primary.opacity(0.12), lineWidth: 2)
                    )
                    .shadow(
                        color: viewModel.selectedTool.isDrawingBrush ? viewModel.selectedColor.color.opacity(0.4) : Color.black.opacity(0.06),
                        radius: 8, x: 0, y: 3
                    )
                    .fixedSize(horizontal: true, vertical: false)

                    // Stroke Width Switchers (细 / 中 / 粗)
                    HStack(spacing: isCompact ? 4 : 8) {
                        ForEach(StrokePreset.allCases) { preset in
                            Button(action: {
                                viewModel.setStrokePreset(preset)
                            }) {
                                VStack(spacing: isCompact ? 2 : 4) {
                                    Circle()
                                        .fill(
                                            viewModel.strokePreset == preset
                                                ? viewModel.selectedColor.color
                                                : Color.secondary.opacity(0.5)
                                        )
                                        .frame(
                                            width: isCompact ? max(preset.dotSize * 0.75, 4) : preset.dotSize,
                                            height: isCompact ? max(preset.dotSize * 0.75, 4) : preset.dotSize
                                        )

                                    Text(preset.title)
                                        .font(.system(size: isCompact ? 11 : 13, weight: .heavy, design: .rounded))
                                        .foregroundColor(
                                            viewModel.strokePreset == preset
                                                ? Color.primary
                                                : Color.secondary
                                        )
                                }
                                .frame(width: isCompact ? 42 : 54, height: isCompact ? 46 : 56)
                                .background(
                                    viewModel.strokePreset == preset
                                        ? Color(UIColor.secondarySystemFill)
                                        : Color(UIColor.secondarySystemFill).opacity(0.4)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: isCompact ? 12 : 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: isCompact ? 12 : 16, style: .continuous)
                                        .stroke(
                                            viewModel.strokePreset == preset
                                                ? viewModel.selectedColor.color
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                    )
                                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                    }
                    .padding(isCompact ? 3 : 4)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                    .fixedSize(horizontal: true, vertical: false)

                    // Eraser Button
                    Button(action: {
                        viewModel.selectTool(.eraser)
                    }) {
                        HStack(spacing: isCompact ? 5 : 8) {
                            Text("🧽")
                                .font(.system(size: isCompact ? 18 : 24))
                            Text("橡皮")
                                .font(.system(size: isCompact ? 14 : 17, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(viewModel.selectedTool == .eraser ? .white : Color.primary.opacity(0.8))
                        .frame(height: isCompact ? 46 : 56)
                        .padding(.horizontal, isCompact ? 10 : 18)
                        .background(
                            viewModel.selectedTool == .eraser
                                ? Color(red: 0.4, green: 0.7, blue: 1.0)
                                : Color(UIColor.secondarySystemFill)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous)
                                .stroke(viewModel.selectedTool == .eraser ? Color.white : Color.primary.opacity(0.12), lineWidth: 2)
                        )
                        .shadow(
                            color: viewModel.selectedTool == .eraser ? Color.blue.opacity(0.35) : Color.black.opacity(0.06),
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .fixedSize(horizontal: true, vertical: false)

                    // Pan / Move Canvas Button
                    Button(action: {
                        viewModel.selectTool(viewModel.selectedTool == .pan ? viewModel.currentBrush.canvasToolType : .pan)
                    }) {
                        HStack(spacing: isCompact ? 5 : 8) {
                            Text("✋")
                                .font(.system(size: isCompact ? 18 : 24))
                            Text("移动")
                                .font(.system(size: isCompact ? 14 : 17, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(viewModel.selectedTool == .pan ? .white : Color.primary.opacity(0.8))
                        .frame(height: isCompact ? 46 : 56)
                        .padding(.horizontal, isCompact ? 10 : 18)
                        .background(
                            viewModel.selectedTool == .pan
                                ? Color(red: 1.0, green: 0.65, blue: 0.15)
                                : Color(UIColor.secondarySystemFill)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous)
                                .stroke(viewModel.selectedTool == .pan ? Color.white : Color.primary.opacity(0.12), lineWidth: 2)
                        )
                        .shadow(
                            color: viewModel.selectedTool == .pan ? Color.orange.opacity(0.35) : Color.black.opacity(0.06),
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .fixedSize(horizontal: true, vertical: false)
                }
            } else {
                // Stamp Mode: Active Stamp Indicator & Stamp Size Switcher
                HStack(spacing: isCompact ? 6 : 12) {
                    // Active Stamp Badge
                    HStack(spacing: isCompact ? 5 : 8) {
                        Text(viewModel.selectedStamp.emoji)
                            .font(.system(size: isCompact ? 22 : 28))
                        Text(viewModel.selectedStamp.name)
                            .font(.system(size: isCompact ? 14 : 17, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(height: isCompact ? 46 : 56)
                    .padding(.horizontal, isCompact ? 12 : 18)
                    .background(viewModel.selectedStamp.color)
                    .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: viewModel.selectedStamp.color.opacity(0.4), radius: 8, x: 0, y: 3)
                    .fixedSize(horizontal: true, vertical: false)

                    // Stamp Size Switchers (小 / 中 / 大)
                    HStack(spacing: isCompact ? 4 : 8) {
                        ForEach(StrokePreset.allCases) { preset in
                            Button(action: {
                                viewModel.setStrokePreset(preset)
                            }) {
                                VStack(spacing: isCompact ? 2 : 4) {
                                    Circle()
                                        .fill(
                                            viewModel.strokePreset == preset
                                                ? viewModel.selectedStamp.color
                                                : Color.secondary.opacity(0.5)
                                        )
                                        .frame(
                                            width: isCompact ? max(preset.dotSize * 0.75, 4) : preset.dotSize,
                                            height: isCompact ? max(preset.dotSize * 0.75, 4) : preset.dotSize
                                        )

                                    Text(preset.stampTitle)
                                        .font(.system(size: isCompact ? 11 : 13, weight: .heavy, design: .rounded))
                                        .foregroundColor(
                                            viewModel.strokePreset == preset
                                                ? Color.primary
                                                : Color.secondary
                                        )
                                }
                                .frame(width: isCompact ? 42 : 54, height: isCompact ? 46 : 56)
                                .background(
                                    viewModel.strokePreset == preset
                                        ? Color(UIColor.secondarySystemFill)
                                        : Color(UIColor.secondarySystemFill).opacity(0.4)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: isCompact ? 12 : 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: isCompact ? 12 : 16, style: .continuous)
                                        .stroke(
                                            viewModel.strokePreset == preset
                                                ? viewModel.selectedStamp.color
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                    }
                    .padding(isCompact ? 3 : 4)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                    .fixedSize(horizontal: true, vertical: false)

                    // Pan / Move Canvas Button (Stamp mode)
                    Button(action: {
                        viewModel.selectTool(viewModel.selectedTool == .pan ? viewModel.currentBrush.canvasToolType : .pan)
                    }) {
                        HStack(spacing: isCompact ? 5 : 8) {
                            Text("✋")
                                .font(.system(size: isCompact ? 18 : 22))
                            Text("移动")
                                .font(.system(size: isCompact ? 14 : 16, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(viewModel.selectedTool == .pan ? .white : Color.primary.opacity(0.8))
                        .frame(height: isCompact ? 46 : 56)
                        .padding(.horizontal, isCompact ? 10 : 16)
                        .background(
                            viewModel.selectedTool == .pan
                                ? Color(red: 1.0, green: 0.65, blue: 0.15)
                                : Color(UIColor.secondarySystemFill)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous)
                                .stroke(viewModel.selectedTool == .pan ? Color.white : Color.primary.opacity(0.12), lineWidth: 2)
                        )
                        .shadow(
                            color: viewModel.selectedTool == .pan ? Color.orange.opacity(0.35) : Color.black.opacity(0.06),
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                    .fixedSize(horizontal: true, vertical: false)
                }
            }

            Spacer(minLength: 4)

            // MARK: - Clear Canvas Button
            Button(action: {
                viewModel.requestClear()
            }) {
                HStack(spacing: isCompact ? 4 : 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: isCompact ? 16 : 20, weight: .bold))
                    Text("清屏")
                        .font(.system(size: isCompact ? 14 : 17, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(height: isCompact ? 46 : 56)
                .padding(.horizontal, isCompact ? 12 : 20)
                .background(Color(red: 0.95, green: 0.32, blue: 0.32))
                .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20, style: .continuous))
                .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, isCompact ? 10 : 16)
        .padding(.vertical, isCompact ? 6 : 8)
        .liquidGlass(cornerRadius: isCompact ? 24 : 32)
    }
}
