import SwiftUI

// MARK: - Sticker Canvas View (Magic Stamp Layer)
struct StickerCanvasView: View {
    @ObservedObject var viewModel: DrawingViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background transparent tap area (viewport coordinate space)
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        (viewModel.canvasMode == .stamp && viewModel.selectedTool != .pan) ?
                            SpatialTapGesture()
                                .onEnded { value in
                                    let scale = max(viewModel.zoomScale, 0.001)
                                    let canvasX = (value.location.x + viewModel.contentOffset.x) / scale
                                    let canvasY = (value.location.y + viewModel.contentOffset.y) / scale
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        viewModel.addStamp(at: CGPoint(x: canvasX, y: canvasY))
                                    }
                                } : nil
                    )

                // Stamps rendering layer
                ZStack(alignment: .topLeading) {
                    ForEach(viewModel.stamps) { stamp in
                        Text(stamp.item.emoji)
                            .font(.system(size: stamp.size))
                            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                            .rotationEffect(stamp.rotation)
                            .position(x: stamp.position.x, y: stamp.position.y)
                            .transition(.scale(scale: 0.2).combined(with: .opacity))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                .scaleEffect(viewModel.zoomScale, anchor: .topLeading)
                .offset(x: -viewModel.contentOffset.x, y: -viewModel.contentOffset.y)
                .allowsHitTesting(false)
            }
        }
        .allowsHitTesting(viewModel.canvasMode == .stamp && viewModel.selectedTool != .pan)
    }
}
