import SwiftUI
import UIKit
import PhotosUI

@MainActor
struct TopBarView: View {
    @ObservedObject var viewModel: DrawingViewModel

    var body: some View {
        let isImporting = viewModel.isImporting
        let importProgress = viewModel.importProgress

        HStack(spacing: 12) {
            // MARK: - Dual Mode Switcher (画笔 ✏️ vs 印章 🐾)
            HStack(spacing: 4) {
                // Pen Mode Button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.setCanvasMode(.drawing)
                    }
                }) {
                    HStack(spacing: 5) {
                        Text("✏️")
                            .font(.system(size: 19))
                        Text("画笔")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(viewModel.canvasMode == .drawing ? .white : Color(red: 0.25, green: 0.3, blue: 0.45))
                    .frame(height: 48)
                    .padding(.horizontal, 12)
                    .background(
                        viewModel.canvasMode == .drawing
                            ? AnyView(
                                LinearGradient(
                                    colors: [Color(red: 0.25, green: 0.60, blue: 1.0), Color(red: 0.15, green: 0.45, blue: 0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyView(Color.white.opacity(0.4))
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
                    HStack(spacing: 5) {
                        Text("🐾")
                            .font(.system(size: 19))
                        Text("印章")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(viewModel.canvasMode == .stamp ? .white : Color(red: 0.25, green: 0.3, blue: 0.45))
                    .frame(height: 48)
                    .padding(.horizontal, 12)
                    .background(
                        viewModel.canvasMode == .stamp
                            ? AnyView(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.45, blue: 0.65), Color(red: 0.90, green: 0.25, blue: 0.55)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyView(Color.white.opacity(0.4))
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: viewModel.canvasMode == .stamp ? Color.pink.opacity(0.35) : Color.clear,
                        radius: 6, x: 0, y: 2
                    )
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(3)
            .liquidGlass(cornerRadius: 26, hasShadow: false)

            // MARK: - Template Drawer Capsule Button
            Button(action: {
                viewModel.showTemplatePickerSheet = true
            }) {
                HStack(spacing: 7) {
                    Text(viewModel.currentTemplate.emoji)
                        .font(.system(size: 22))

                    Text(viewModel.currentTemplate.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.2, blue: 0.35))
                        .lineLimit(1)

                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.45, blue: 0.85))
                }
                .frame(height: 52)
                .padding(.horizontal, 14)
                .liquidGlass(cornerRadius: 22, hasShadow: true)
            }
            .buttonStyle(BouncyButtonStyle())

            // MARK: - Batch Import PhotosPicker Button ("+ 批量添加")
            PhotosPicker(
                selection: $viewModel.batchPhotosSelection,
                maxSelectionCount: 100,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: 6) {
                    if isImporting {
                        ProgressView()
                            .scaleEffect(0.85)
                            .tint(.white)

                        Text(importProgress)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 17, weight: .black))

                        Text("批量添加")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(height: 52)
                .padding(.horizontal, 14)
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
            .onChange(of: viewModel.batchPhotosSelection) { _, newItems in
                viewModel.handleBatchPhotosImport(newItems)
            }

            Spacer()

            // MARK: - Canvas Zoom Controls (🔍- / % / 🔍+)
            HStack(spacing: 3) {
                Button(action: {
                    viewModel.zoomOut()
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                        .frame(width: 42, height: 48)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())

                Button(action: {
                    viewModel.resetZoom()
                }) {
                    Text("\(Int(round(viewModel.zoomScale * 100)))%")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(
                            abs(viewModel.zoomScale - 1.0) < 0.05
                                ? Color(red: 0.25, green: 0.35, blue: 0.5)
                                : Color.blue
                        )
                        .frame(width: 52, height: 48)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())

                Button(action: {
                    viewModel.zoomIn()
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                        .frame(width: 42, height: 48)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(3)
            .liquidGlass(cornerRadius: 16, hasShadow: false)

            Spacer()

            // MARK: - Reference Line Toggle
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.toggleReferenceLine()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.showReferenceLine ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 17, weight: .bold))

                    Text(viewModel.showReferenceLine ? "线稿已开" : "线稿已关")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                }
                .foregroundColor(viewModel.showReferenceLine ? .white : Color(red: 0.35, green: 0.4, blue: 0.5))
                .frame(height: 52)
                .padding(.horizontal, 14)
                .background(
                    viewModel.showReferenceLine
                        ? Color(red: 0.28, green: 0.72, blue: 0.45)
                        : Color.white.opacity(0.7)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            viewModel.showReferenceLine ? Color.clear : Color.white.opacity(0.5),
                            lineWidth: 1.2
                        )
                )
                .shadow(
                    color: viewModel.showReferenceLine ? Color.green.opacity(0.25) : Color.black.opacity(0.04),
                    radius: 4, x: 0, y: 2
                )
            }
            .buttonStyle(BouncyButtonStyle())

            // MARK: - Save to Photos Button
            Button(action: {
                viewModel.saveToPhotos()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 18, weight: .black))

                    Text("保存画作")
                        .font(.system(size: 16, weight: .black, design: .rounded))

                    Text("⭐")
                        .font(.system(size: 15))
                }
                .foregroundColor(.white)
                .frame(height: 52)
                .padding(.horizontal, 18)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.65, blue: 0.0), Color(red: 0.98, green: 0.45, blue: 0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.orange.opacity(0.35), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .liquidGlass(cornerRadius: 26)
    }
}
