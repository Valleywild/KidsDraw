import SwiftUI
import UIKit
import PhotosUI

@MainActor
struct TopBarView: View {
    @ObservedObject var viewModel: DrawingViewModel
    var isCompact: Bool = false

    var body: some View {
        let isImporting = viewModel.isImporting
        let importProgress = viewModel.importProgress

        HStack(spacing: isCompact ? 6 : 12) {
            // MARK: - Dual Mode Switcher (画笔 ✏️ vs 印章 🐾)
            HStack(spacing: isCompact ? 2 : 4) {
                // Pen Mode Button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.setCanvasMode(.drawing)
                    }
                }) {
                    HStack(spacing: isCompact ? 3 : 5) {
                        Text("✏️")
                            .font(.system(size: isCompact ? 16 : 19))
                        Text("画笔")
                            .font(.system(size: isCompact ? 13 : 15, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(viewModel.canvasMode == .drawing ? .white : Color.primary.opacity(0.7))
                    .frame(height: isCompact ? 42 : 48)
                    .padding(.horizontal, isCompact ? 9 : 12)
                    .background(
                        viewModel.canvasMode == .drawing
                            ? AnyView(
                                LinearGradient(
                                    colors: [Color(red: 0.25, green: 0.60, blue: 1.0), Color(red: 0.15, green: 0.45, blue: 0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyView(Color(UIColor.secondarySystemFill).opacity(0.6))
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: viewModel.canvasMode == .drawing ? Color.blue.opacity(0.35) : Color.clear,
                        radius: 6, x: 0, y: 2
                    )
                }
                .buttonStyle(BouncyButtonStyle())

                // Stamp Mode Button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.setCanvasMode(.stamp)
                    }
                }) {
                    HStack(spacing: isCompact ? 3 : 5) {
                        Text("🐾")
                            .font(.system(size: isCompact ? 16 : 19))
                        Text("印章")
                            .font(.system(size: isCompact ? 13 : 15, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(viewModel.canvasMode == .stamp ? .white : Color.primary.opacity(0.7))
                    .frame(height: isCompact ? 42 : 48)
                    .padding(.horizontal, isCompact ? 9 : 12)
                    .background(
                        viewModel.canvasMode == .stamp
                            ? AnyView(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.45, blue: 0.65), Color(red: 0.90, green: 0.25, blue: 0.55)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyView(Color(UIColor.secondarySystemFill).opacity(0.6))
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: viewModel.canvasMode == .stamp ? Color.pink.opacity(0.35) : Color.clear,
                        radius: 6, x: 0, y: 2
                    )
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(isCompact ? 2 : 3)
            .liquidGlass(cornerRadius: isCompact ? 22 : 26, hasShadow: false)
            .fixedSize(horizontal: true, vertical: false)

            // MARK: - Template Drawer Capsule Button
            Button(action: {
                viewModel.showTemplatePickerSheet = true
            }) {
                HStack(spacing: isCompact ? 5 : 7) {
                    Text(viewModel.currentTemplate.emoji)
                        .font(.system(size: isCompact ? 18 : 22))

                    Text(viewModel.currentTemplate.name)
                        .font(.system(size: isCompact ? 14 : 16, weight: .heavy, design: .rounded))
                        .foregroundColor(Color.primary)
                        .lineLimit(1)
                        .frame(maxWidth: isCompact ? 80 : 130)

                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: isCompact ? 13 : 15, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.45, blue: 0.85))
                }
                .frame(height: isCompact ? 44 : 52)
                .padding(.horizontal, isCompact ? 10 : 14)
                .liquidGlass(cornerRadius: isCompact ? 18 : 22, hasShadow: true)
            }
            .buttonStyle(BouncyButtonStyle())
            .fixedSize(horizontal: true, vertical: false)

            // MARK: - Batch Import PhotosPicker Button ("添加" / "批量添加")
            PhotosPicker(
                selection: $viewModel.batchPhotosSelection,
                maxSelectionCount: 100,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: isCompact ? 4 : 6) {
                    if isImporting {
                        ProgressView()
                            .scaleEffect(isCompact ? 0.75 : 0.85)
                            .tint(.white)

                        Text(importProgress)
                            .font(.system(size: isCompact ? 12 : 13, weight: .bold, design: .rounded))
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: isCompact ? 15 : 17, weight: .black))

                        Text(isCompact ? "添加" : "批量添加")
                            .font(.system(size: isCompact ? 13 : 15, weight: .heavy, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(height: isCompact ? 44 : 52)
                .padding(.horizontal, isCompact ? 10 : 14)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.58, green: 0.35, blue: 0.95), Color(red: 0.45, green: 0.20, blue: 0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.purple.opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
            .disabled(viewModel.isImporting)
            .fixedSize(horizontal: true, vertical: false)
            .onChange(of: viewModel.batchPhotosSelection) { _, newItems in
                viewModel.handleBatchPhotosImport(newItems)
            }

            Spacer(minLength: 4)

            // MARK: - Canvas Zoom Controls (🔍- / % / 🔍+)
            HStack(spacing: isCompact ? 2 : 3) {
                Button(action: {
                    viewModel.zoomOut()
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: isCompact ? 14 : 17, weight: .black))
                        .foregroundColor(Color.primary.opacity(0.85))
                        .frame(width: isCompact ? 34 : 42, height: isCompact ? 40 : 48)
                        .background(Color(UIColor.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 10 : 12, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())

                Button(action: {
                    viewModel.resetZoom()
                }) {
                    Text("\(Int(round(viewModel.zoomScale * 100)))%")
                        .font(.system(size: isCompact ? 11 : 13, weight: .black, design: .rounded))
                        .foregroundColor(
                            abs(viewModel.zoomScale - 1.0) < 0.05
                                ? Color.primary.opacity(0.85)
                                : Color.blue
                        )
                        .frame(width: isCompact ? 42 : 52, height: isCompact ? 40 : 48)
                        .background(Color(UIColor.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 10 : 12, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())

                Button(action: {
                    viewModel.zoomIn()
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: isCompact ? 14 : 17, weight: .black))
                        .foregroundColor(Color.primary.opacity(0.85))
                        .frame(width: isCompact ? 34 : 42, height: isCompact ? 40 : 48)
                        .background(Color(UIColor.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 10 : 12, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(isCompact ? 2 : 3)
            .liquidGlass(cornerRadius: isCompact ? 14 : 16, hasShadow: false)
            .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 4)

            // MARK: - Appearance Switcher Button (☀️ / 🌙 / 📱)
            Menu {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.setAppearanceMode(.light)
                    }
                }) {
                    Label {
                        Text("浅色模式")
                    } icon: {
                        Image(systemName: "sun.max.fill")
                    }
                }

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.setAppearanceMode(.dark)
                    }
                }) {
                    Label {
                        Text("深色模式")
                    } icon: {
                        Image(systemName: "moon.stars.fill")
                    }
                }

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.setAppearanceMode(.system)
                    }
                }) {
                    Label {
                        Text("跟随系统")
                    } icon: {
                        Image(systemName: "circle.righthalf.filled")
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: viewModel.appearanceMode.icon)
                        .font(.system(size: isCompact ? 16 : 16, weight: .bold))
                        .foregroundColor(
                            viewModel.appearanceMode == .dark
                                ? Color.yellow
                                : (viewModel.appearanceMode == .light ? Color.orange : Color.blue)
                        )

                    if !isCompact {
                        Text(viewModel.appearanceMode.shortTitle)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.primary)
                    }
                }
                .frame(width: isCompact ? 42 : nil, height: isCompact ? 44 : 52)
                .padding(.horizontal, isCompact ? 0 : 14)
                .liquidGlass(cornerRadius: isCompact ? 14 : 18)
            } primaryAction: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    viewModel.toggleAppearanceMode()
                }
            }
            .buttonStyle(BouncyButtonStyle())
            .fixedSize(horizontal: true, vertical: false)

            // MARK: - Reference Line Toggle
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.toggleReferenceLine()
                }
            }) {
                HStack(spacing: isCompact ? 4 : 6) {
                    Image(systemName: viewModel.showReferenceLine ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: isCompact ? 15 : 17, weight: .bold))

                    Text(isCompact ? "线稿" : (viewModel.showReferenceLine ? "线稿已开" : "线稿已关"))
                        .font(.system(size: isCompact ? 13 : 14, weight: .heavy, design: .rounded))
                }
                .foregroundColor(viewModel.showReferenceLine ? .white : Color.primary.opacity(0.7))
                .frame(height: isCompact ? 44 : 52)
                .padding(.horizontal, isCompact ? 10 : 14)
                .background(
                    viewModel.showReferenceLine
                        ? Color(red: 0.28, green: 0.72, blue: 0.45)
                        : Color(UIColor.secondarySystemFill)
                )
                .clipShape(RoundedRectangle(cornerRadius: isCompact ? 14 : 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 14 : 18, style: .continuous)
                        .stroke(
                            viewModel.showReferenceLine ? Color.clear : Color.primary.opacity(0.12),
                            lineWidth: 1.2
                        )
                )
                .shadow(
                    color: viewModel.showReferenceLine ? Color.green.opacity(0.25) : Color.black.opacity(0.04),
                    radius: 4, x: 0, y: 2
                )
            }
            .buttonStyle(BouncyButtonStyle())
            .fixedSize(horizontal: true, vertical: false)

            // MARK: - Save to Photos Button
            Button(action: {
                viewModel.saveToPhotos()
            }) {
                HStack(spacing: isCompact ? 4 : 6) {
                    if viewModel.isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                        Text(isCompact ? "保存..." : "保存中...")
                            .font(.system(size: isCompact ? 13 : 15, weight: .heavy, design: .rounded))
                    } else {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: isCompact ? 15 : 18, weight: .black))

                        Text(isCompact ? "保存" : "保存画作")
                            .font(.system(size: isCompact ? 14 : 16, weight: .black, design: .rounded))

                        if !isCompact {
                            Text("⭐")
                                .font(.system(size: 15))
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(height: isCompact ? 44 : 52)
                .padding(.horizontal, isCompact ? 12 : 18)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.65, blue: 0.0), Color(red: 0.98, green: 0.45, blue: 0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: isCompact ? 14 : 18, style: .continuous))
                .shadow(color: Color.orange.opacity(0.35), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
            .disabled(viewModel.isSaving)
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .liquidGlass(cornerRadius: 26)
    }
}
