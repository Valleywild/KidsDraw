import SwiftUI
import UIKit

struct BottomBarView: View {
    @ObservedObject var viewModel: DrawingViewModel

    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Undo & Redo Group
            HStack(spacing: 10) {
                // Undo Button
                Button(action: {
                    viewModel.undo()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 20, weight: .black))
                        Text("撤销")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(viewModel.canUndo ? Color(red: 0.2, green: 0.25, blue: 0.35) : Color.gray.opacity(0.4))
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(viewModel.canUndo ? 0.9 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.0)
                    )
                    .shadow(color: Color.black.opacity(viewModel.canUndo ? 0.06 : 0.0), radius: 6, x: 0, y: 3)
                }
                .disabled(!viewModel.canUndo)
                .buttonStyle(BouncyButtonStyle())

                // Redo Button
                Button(action: {
                    viewModel.redo()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 20, weight: .black))
                        Text("重做")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(viewModel.canRedo ? Color(red: 0.2, green: 0.25, blue: 0.35) : Color.gray.opacity(0.4))
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(viewModel.canRedo ? 0.9 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.0)
                    )
                    .shadow(color: Color.black.opacity(viewModel.canRedo ? 0.06 : 0.0), radius: 6, x: 0, y: 3)
                }
                .disabled(!viewModel.canRedo)
                .buttonStyle(BouncyButtonStyle())
            }

            Spacer()

            // MARK: - Central Tool Group (Drawing vs Stamp Mode)
            if viewModel.canvasMode == .drawing {
                // Brush / Eraser & Stroke Width
                HStack(spacing: 12) {
                    // Brush / Crayon Toggle Button
                    Button(action: {
                        viewModel.selectTool(.crayon)
                    }) {
                        HStack(spacing: 8) {
                            Text("🖍️")
                                .font(.system(size: 24))
                            Text("蜡笔")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(viewModel.selectedTool != .eraser ? .white : Color(red: 0.3, green: 0.35, blue: 0.45))
                        .frame(height: 56)
                        .padding(.horizontal, 18)
                        .background(
                            viewModel.selectedTool != .eraser
                                ? viewModel.selectedColor.color
                                : Color.white.opacity(0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(viewModel.selectedTool != .eraser ? Color.white : Color.black.opacity(0.08), lineWidth: 2)
                        )
                        .shadow(
                            color: viewModel.selectedTool != .eraser ? viewModel.selectedColor.color.opacity(0.4) : Color.black.opacity(0.06),
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())

                    // Stroke Width Switchers (细 / 中 / 粗)
                    HStack(spacing: 8) {
                        ForEach(StrokePreset.allCases) { preset in
                            Button(action: {
                                viewModel.setStrokePreset(preset)
                            }) {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(
                                            viewModel.strokePreset == preset
                                                ? viewModel.selectedColor.color
                                                : Color.gray.opacity(0.5)
                                        )
                                        .frame(width: preset.dotSize, height: preset.dotSize)

                                    Text(preset.title)
                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                        .foregroundColor(
                                            viewModel.strokePreset == preset
                                                ? Color(red: 0.15, green: 0.2, blue: 0.3)
                                                : Color.gray
                                        )
                                }
                                .frame(width: 54, height: 56)
                                .background(
                                    viewModel.strokePreset == preset
                                        ? Color.white
                                        : Color.white.opacity(0.6)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                    .padding(4)
                    .background(Color.black.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    // Eraser Button
                    Button(action: {
                        viewModel.selectTool(.eraser)
                    }) {
                        HStack(spacing: 8) {
                            Text("🧽")
                                .font(.system(size: 24))
                            Text("橡皮")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(viewModel.selectedTool == .eraser ? .white : Color(red: 0.3, green: 0.35, blue: 0.45))
                        .frame(height: 56)
                        .padding(.horizontal, 18)
                        .background(
                            viewModel.selectedTool == .eraser
                                ? Color(red: 0.4, green: 0.7, blue: 1.0)
                                : Color.white.opacity(0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(viewModel.selectedTool == .eraser ? Color.white : Color.black.opacity(0.08), lineWidth: 2)
                        )
                        .shadow(
                            color: viewModel.selectedTool == .eraser ? Color.blue.opacity(0.35) : Color.black.opacity(0.06),
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())

                    // Pan / Move Canvas Button
                    Button(action: {
                        viewModel.selectTool(viewModel.selectedTool == .pan ? .crayon : .pan)
                    }) {
                        HStack(spacing: 8) {
                            Text("✋")
                                .font(.system(size: 24))
                            Text("移动")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(viewModel.selectedTool == .pan ? .white : Color(red: 0.3, green: 0.35, blue: 0.45))
                        .frame(height: 56)
                        .padding(.horizontal, 18)
                        .background(
                            viewModel.selectedTool == .pan
                                ? Color(red: 1.0, green: 0.65, blue: 0.15)
                                : Color.white.opacity(0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(viewModel.selectedTool == .pan ? Color.white : Color.black.opacity(0.08), lineWidth: 2)
                        )
                        .shadow(
                            color: viewModel.selectedTool == .pan ? Color.orange.opacity(0.35) : Color.black.opacity(0.06),
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            } else {
                // Stamp Mode: Active Stamp Indicator & Stamp Size Switcher
                HStack(spacing: 12) {
                    // Active Stamp Badge
                    HStack(spacing: 8) {
                        Text(viewModel.selectedStamp.emoji)
                            .font(.system(size: 28))
                        Text(viewModel.selectedStamp.name)
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 18)
                    .background(viewModel.selectedStamp.color)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: viewModel.selectedStamp.color.opacity(0.4), radius: 8, x: 0, y: 3)

                    // Stamp Size Switchers (小 / 中 / 大)
                    HStack(spacing: 8) {
                        ForEach(StrokePreset.allCases) { preset in
                            Button(action: {
                                viewModel.setStrokePreset(preset)
                            }) {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(
                                            viewModel.strokePreset == preset
                                                ? viewModel.selectedStamp.color
                                                : Color.gray.opacity(0.5)
                                        )
                                        .frame(width: preset.dotSize, height: preset.dotSize)

                                    Text(preset.stampTitle)
                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                        .foregroundColor(
                                            viewModel.strokePreset == preset
                                                ? Color(red: 0.15, green: 0.2, blue: 0.3)
                                                : Color.gray
                                        )
                                }
                                .frame(width: 54, height: 56)
                                .background(
                                    viewModel.strokePreset == preset
                                        ? Color.white
                                        : Color.white.opacity(0.6)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                    .padding(4)
                    .background(Color.black.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    // Pan / Move Canvas Button (Stamp mode)
                    Button(action: {
                        viewModel.selectTool(viewModel.selectedTool == .pan ? .crayon : .pan)
                    }) {
                        HStack(spacing: 8) {
                            Text("✋")
                                .font(.system(size: 22))
                            Text("移动")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(viewModel.selectedTool == .pan ? .white : Color(red: 0.3, green: 0.35, blue: 0.45))
                        .frame(height: 56)
                        .padding(.horizontal, 16)
                        .background(
                            viewModel.selectedTool == .pan
                                ? Color(red: 1.0, green: 0.65, blue: 0.15)
                                : Color.white.opacity(0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(viewModel.selectedTool == .pan ? Color.white : Color.black.opacity(0.08), lineWidth: 2)
                        )
                        .shadow(
                            color: viewModel.selectedTool == .pan ? Color.orange.opacity(0.35) : Color.black.opacity(0.06),
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }

            Spacer()

            // MARK: - Clear Canvas Button
            Button(action: {
                viewModel.requestClear()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("清屏")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(height: 56)
                .padding(.horizontal, 20)
                .background(Color(red: 0.95, green: 0.32, blue: 0.32))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .liquidGlass(cornerRadius: 32)
    }
}
