import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = DrawingViewModel()

    var body: some View {
        ZStack {
            // 1. Dual-Layer Canvas:
            // Under layer: PencilKit Drawing Canvas (Synchronized Zoomable Reference Line Art & Paper)
            PencilKitCanvasView(viewModel: viewModel)
                .ignoresSafeArea()

            // Over layer: Magic Stamp Layer (Sticker Canvas)
            StickerCanvasView(viewModel: viewModel)
                .ignoresSafeArea()

            // 2. Overlaid Interface Controls
            VStack(spacing: 0) {
                // Top Toolbar (Liquid Glass style)
                TopBarView(viewModel: viewModel)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                Spacer()

                // Bottom Floating Island Bar (Liquid Glass style)
                BottomBarView(viewModel: viewModel)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 16)
            }

            // 3. Right-Side Chunky Crayon Palette (Liquid Glass style, vertically centered)
            HStack(spacing: 0) {
                Spacer()

                VStack {
                    Spacer()
                    CrayonPaletteView(viewModel: viewModel)
                    Spacer()
                }
                .padding(.top, 74)
                .padding(.bottom, 84)
                .padding(.trailing, 10)
            }

            // 4. Batch Importing Photos Loading Indicator
            if viewModel.isImporting {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()

                    VStack(spacing: 18) {
                        ProgressView()
                            .scaleEffect(1.8)
                            .tint(.white)

                        Text("正在生成简笔画... 🎨")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        Text(viewModel.importProgress)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(32)
                    .liquidGlass(cornerRadius: 24)
                }
                .transition(.opacity)
            }

            // 5. Accidental Clear Protection Dialog
            if viewModel.showClearConfirmation {
                ClearConfirmOverlay(viewModel: viewModel)
                    .transition(.scale.combined(with: .opacity))
            }

            // 6. Save Celebration Banner
            if viewModel.showSaveSuccessBanner {
                SaveSuccessCelebrationBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .statusBarHidden(true)
        .sheet(isPresented: $viewModel.showColorPickerSheet) {
            ColorPalettePickerSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showTemplatePickerSheet) {
            TemplatePickerSheet(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .alert("温馨提示", isPresented: Binding(
            get: { viewModel.saveErrorMessage != nil },
            set: { if !$0 { viewModel.saveErrorMessage = nil } }
        )) {
            Button("好的", role: .cancel) { viewModel.saveErrorMessage = nil }
        } message: {
            Text(viewModel.saveErrorMessage ?? "")
        }
    }
}

// MARK: - Save Celebration Banner
struct SaveSuccessCelebrationBanner: View {
    var body: some View {
        VStack {
            HStack(spacing: 14) {
                Text("🌟")
                    .font(.system(size: 38))

                VStack(alignment: .leading, spacing: 2) {
                    Text("画得太棒啦！")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.2, blue: 0.3))

                    Text("画作已经成功保存到相册啦 ⭐")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.secondary)
                }

                Text("🎉")
                    .font(.system(size: 38))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 28)
            .liquidGlass(cornerRadius: 24)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.yellow, lineWidth: 3)
            )
            .padding(.top, 84)

            Spacer()
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Clear Confirm Overlay
struct ClearConfirmOverlay: View {
    @ObservedObject var viewModel: DrawingViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showClearConfirmation = false
                }

            VStack(spacing: 24) {
                Text("🗑️")
                    .font(.system(size: 56))

                Text("要擦干净重新画吗？")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.15, green: 0.2, blue: 0.35))

                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.showClearConfirmation = false
                    }) {
                        Text("不小心按错了")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.35, blue: 0.45))
                            .frame(width: 160, height: 56)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(BouncyButtonStyle())

                    Button(action: {
                        viewModel.confirmClear()
                    }) {
                        Text("重新画一张")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 160, height: 56)
                            .background(Color(red: 0.95, green: 0.32, blue: 0.32))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.red.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            .padding(32)
            .liquidGlass(cornerRadius: 32)
        }
    }
}

#Preview {
    ContentView()
}
