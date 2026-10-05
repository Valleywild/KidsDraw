import SwiftUI
import UIKit
import PencilKit

// Custom container view that notifies coordinator when layout changes occur
final class CanvasContainerView: UIView {
    var onLayout: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?()
    }
}

struct PencilKitCanvasView: UIViewRepresentable {
    @ObservedObject var viewModel: DrawingViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = CanvasContainerView()
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        containerView.overrideUserInterfaceStyle = .light

        // 1. Background Reference Line Art Image View
        let bgImageView = UIImageView()
        bgImageView.contentMode = .scaleToFill
        bgImageView.isUserInteractionEnabled = false
        bgImageView.alpha = CGFloat(viewModel.showReferenceLine ? viewModel.referenceOpacity : 0.0)
        containerView.addSubview(bgImageView)

        // 2. PencilKit Canvas View
        let canvasView = PKCanvasView()
        canvasView.overrideUserInterfaceStyle = .light
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.alwaysBounceVertical = true
        canvasView.alwaysBounceHorizontal = true
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
        canvasView.minimumZoomScale = 0.6
        canvasView.maximumZoomScale = 4.0
        canvasView.bouncesZoom = true
        canvasView.delegate = context.coordinator
        containerView.addSubview(canvasView)

        // Wire layoutSubviews callback so canvasView and bgImageView are sized immediately on first display
        let coordinator = context.coordinator
        containerView.onLayout = { [weak coordinator] in
            coordinator?.handleContainerLayout()
        }

        // Setup Coordinator references
        context.coordinator.containerView = containerView
        context.coordinator.canvasView = canvasView
        context.coordinator.backgroundImageView = bgImageView
        context.coordinator.setupViewModelBridges()
        context.coordinator.updateTool(on: canvasView)
        context.coordinator.updateReferenceImage()

        // Configure drawing gesture enabled based on mode
        canvasView.drawingGestureRecognizer.isEnabled = (viewModel.canvasMode == .drawing && viewModel.selectedTool != .pan)

        // Observe UndoManager changes
        if let undoManager = canvasView.undoManager {
            NotificationCenter.default.addObserver(
                context.coordinator,
                selector: #selector(Coordinator.undoManagerDidUndo(_:)),
                name: .NSUndoManagerDidUndoChange,
                object: undoManager
            )
            NotificationCenter.default.addObserver(
                context.coordinator,
                selector: #selector(Coordinator.undoManagerDidRedo(_:)),
                name: .NSUndoManagerDidRedoChange,
                object: undoManager
            )
        }

        return containerView
    }

    func updateUIView(_ containerView: UIView, context: Context) {
        context.coordinator.parent = self
        guard let canvasView = context.coordinator.canvasView else { return }

        // Layout canvas inside container
        if canvasView.frame != containerView.bounds {
            canvasView.frame = containerView.bounds
        }

        if containerView.overrideUserInterfaceStyle != .light {
            containerView.overrideUserInterfaceStyle = .light
        }
        if canvasView.overrideUserInterfaceStyle != .light {
            canvasView.overrideUserInterfaceStyle = .light
        }

        // Disable PK drawing interaction when in Stamp mode or Pan tool
        let shouldEnableDrawing = (viewModel.canvasMode == .drawing && viewModel.selectedTool != .pan)
        if canvasView.drawingGestureRecognizer.isEnabled != shouldEnableDrawing {
            canvasView.drawingGestureRecognizer.isEnabled = shouldEnableDrawing
        }

        context.coordinator.updateTool(on: canvasView)
        context.coordinator.updateReferenceImage()
    }

    // MARK: - Coordinator
    @MainActor
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilKitCanvasView
        weak var containerView: UIView?
        weak var canvasView: PKCanvasView?
        weak var backgroundImageView: UIImageView?
        private var previousStrokesCount: Int = 0
        private var lastToolType: CanvasToolType?
        private var lastColor: UIColor?
        private var lastStrokeWidth: CGFloat?

        // Canonical paper and geometry definitions
        static let canonicalCanvasSize = CGSize(width: 1400, height: 1400)
        static let canonicalTemplateBox = CGRect(x: 360, y: 360, width: 680, height: 680)

        // Canvas geometry tracking in unscaled coordinate space
        private(set) var baseCanvasSize: CGSize = .zero
        private(set) var unscaledTemplateRect: CGRect = .zero
        private var lastViewportSize: CGSize = .zero

        init(_ parent: PencilKitCanvasView) {
            self.parent = parent
        }

        func setupViewModelBridges() {
            let vm = parent.viewModel

            vm.undoCanvas = { [weak self] in
                guard let self = self, let canvasView = self.canvasView else { return }
                canvasView.undoManager?.undo()
                self.previousStrokesCount = canvasView.drawing.strokes.count
                self.updateUndoState()
            }

            vm.redoCanvas = { [weak self] in
                guard let self = self, let canvasView = self.canvasView else { return }
                canvasView.undoManager?.redo()
                self.previousStrokesCount = canvasView.drawing.strokes.count
                self.updateUndoState()
            }

            vm.clearCanvas = { [weak self] in
                guard let self = self, let canvasView = self.canvasView else { return }
                let oldDrawing = canvasView.drawing
                canvasView.undoManager?.registerUndo(withTarget: canvasView) { target in
                    target.drawing = oldDrawing
                }
                canvasView.drawing = PKDrawing()
                self.previousStrokesCount = 0
                self.updateUndoState()
            }

            vm.captureCanvasImage = { [weak self] includeBackground in
                guard let self = self, let canvasView = self.canvasView else { return nil }
                return self.renderImage(from: canvasView, includeBackground: includeBackground)
            }

            vm.zoomInCanvas = { [weak self] in
                self?.zoom(by: 1.25, animated: true)
            }

            vm.zoomOutCanvas = { [weak self] in
                self?.zoom(by: 0.8, animated: true)
            }

            vm.getCanvasDrawing = { [weak self] in
                return self?.canvasView?.drawing ?? PKDrawing()
            }

            vm.setCanvasDrawing = { [weak self] newDrawing in
                guard let self = self, let canvasView = self.canvasView else { return }
                canvasView.drawing = newDrawing
                self.previousStrokesCount = newDrawing.strokes.count
                canvasView.undoManager?.removeAllActions()
                self.updateUndoState()
            }

            vm.resetZoomCanvas = { [weak self] in
                self?.resetToCenter(animated: true)
            }
        }

        func zoom(by factor: CGFloat, animated: Bool) {
            guard let canvasView = canvasView else { return }
            let oldScale = canvasView.zoomScale
            guard oldScale > 0 else { return }
            let newScale = min(max(oldScale * factor, canvasView.minimumZoomScale), canvasView.maximumZoomScale)
            guard abs(newScale - oldScale) > 0.001 else { return }

            let viewportWidth = canvasView.bounds.width
            let viewportHeight = canvasView.bounds.height
            guard viewportWidth > 0, viewportHeight > 0 else { return }

            let viewportCenter = CGPoint(x: viewportWidth / 2, y: viewportHeight / 2)
            let contentCenterX = (canvasView.contentOffset.x + viewportCenter.x) / oldScale
            let contentCenterY = (canvasView.contentOffset.y + viewportCenter.y) / oldScale

            let targetOffset = CGPoint(
                x: contentCenterX * newScale - viewportCenter.x,
                y: contentCenterY * newScale - viewportCenter.y
            )

            if animated {
                UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
                    canvasView.zoomScale = newScale
                    canvasView.contentOffset = targetOffset
                    self.updateBackgroundPosition()
                }
            } else {
                canvasView.zoomScale = newScale
                canvasView.contentOffset = targetOffset
                self.updateBackgroundPosition()
            }

            parent.viewModel.zoomScale = newScale
            parent.viewModel.contentOffset = targetOffset
        }

        func resetToCenter(animated: Bool) {
            guard let canvasView = canvasView else { return }
            let targetScale: CGFloat = 1.0
            let targetOffset = CGPoint(
                x: (Self.canonicalCanvasSize.width - canvasView.bounds.width) / 2,
                y: (Self.canonicalCanvasSize.height - canvasView.bounds.height) / 2
            )

            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                    canvasView.zoomScale = targetScale
                    canvasView.contentOffset = targetOffset
                    self.updateBackgroundPosition()
                }
            } else {
                canvasView.zoomScale = targetScale
                canvasView.contentOffset = targetOffset
                self.updateBackgroundPosition()
            }

            parent.viewModel.zoomScale = targetScale
            parent.viewModel.contentOffset = targetOffset
        }

        func updateTool(on canvasView: PKCanvasView) {
            let vm = parent.viewModel
            let toolType = vm.selectedTool

            if toolType == .pan {
                canvasView.drawingGestureRecognizer.isEnabled = false
                canvasView.panGestureRecognizer.minimumNumberOfTouches = 1
                lastToolType = .pan
                return
            }

            let shouldEnableDrawing = (vm.canvasMode == .drawing)
            if canvasView.drawingGestureRecognizer.isEnabled != shouldEnableDrawing {
                canvasView.drawingGestureRecognizer.isEnabled = shouldEnableDrawing
            }
            canvasView.panGestureRecognizer.minimumNumberOfTouches = shouldEnableDrawing ? 2 : 1

            let uiColor = vm.selectedColor.uiColor
            let width = vm.selectedStrokeWidth

            if toolType == lastToolType && uiColor == lastColor && width == lastStrokeWidth {
                return
            }

            lastToolType = toolType
            lastColor = uiColor
            lastStrokeWidth = width

            let tool: PKTool
            switch toolType {
            case .pan:
                return
            case .eraser:
                tool = PKEraserTool(.vector)
            case .crayon:
                tool = PKInkingTool(.crayon, color: uiColor, width: width)
            case .pencil:
                tool = PKInkingTool(.pencil, color: uiColor, width: width)
            case .pen:
                tool = PKInkingTool(.pen, color: uiColor, width: width)
            case .marker:
                tool = PKInkingTool(.marker, color: uiColor, width: width)
            }

            canvasView.tool = tool
        }

        func handleContainerLayout() {
            guard let containerView = containerView, let canvasView = canvasView else { return }
            let newViewportSize = containerView.bounds.size
            guard newViewportSize.width > 0, newViewportSize.height > 0 else { return }

            if canvasView.frame != containerView.bounds {
                canvasView.frame = containerView.bounds
            }

            let isFirstLayout = (baseCanvasSize == .zero)
            let oldViewportSize = lastViewportSize

            if isFirstLayout {
                baseCanvasSize = Self.canonicalCanvasSize
                canvasView.contentSize = Self.canonicalCanvasSize
                updateContentInsets()
                recalculateTemplateRect()

                // Center the canonical canvas initially in the viewport
                let initialOffsetX = (Self.canonicalCanvasSize.width - newViewportSize.width) / 2
                let initialOffsetY = (Self.canonicalCanvasSize.height - newViewportSize.height) / 2
                canvasView.zoomScale = 1.0
                canvasView.contentOffset = CGPoint(x: initialOffsetX, y: initialOffsetY)
                parent.viewModel.zoomScale = 1.0
                parent.viewModel.contentOffset = canvasView.contentOffset
            } else if oldViewportSize != newViewportSize && oldViewportSize.width > 0 && oldViewportSize.height > 0 {
                // Viewport size changed due to device rotation (e.g. portrait <-> landscape)
                updateContentInsets()

                // Seamlessly retain the visible focal center point across rotation
                let currentScale = canvasView.zoomScale
                let currentOffset = canvasView.contentOffset
                let focalPointInCanvas = CGPoint(
                    x: (currentOffset.x + oldViewportSize.width / 2) / currentScale,
                    y: (currentOffset.y + oldViewportSize.height / 2) / currentScale
                )

                let newOffsetX = focalPointInCanvas.x * currentScale - newViewportSize.width / 2
                let newOffsetY = focalPointInCanvas.y * currentScale - newViewportSize.height / 2
                canvasView.contentOffset = CGPoint(x: newOffsetX, y: newOffsetY)
                parent.viewModel.contentOffset = canvasView.contentOffset
            }

            lastViewportSize = newViewportSize
            updateReferenceImage()
        }

        func updateContentInsets() {
            guard let canvasView = canvasView else { return }
            let viewportWidth = canvasView.bounds.width > 0 ? canvasView.bounds.width : 820
            let viewportHeight = canvasView.bounds.height > 0 ? canvasView.bounds.height : 1180

            let padW = viewportWidth * 0.85
            let padH = viewportHeight * 0.85
            let targetInsets = UIEdgeInsets(top: padH, left: padW, bottom: padH, right: padW)
            if canvasView.contentInset != targetInsets {
                canvasView.contentInset = targetInsets
            }
        }

        private func recalculateTemplateRect() {
            guard let image = backgroundImageView?.image else {
                unscaledTemplateRect = Self.canonicalTemplateBox
                return
            }
            // Fit template inside canonicalTemplateBox, keeping its center rigidly locked at (700, 700)
            unscaledTemplateRect = Self.aspectFit(imageSize: image.size, in: Self.canonicalTemplateBox)
        }

        func updateReferenceImage() {
            guard let bgImageView = backgroundImageView else { return }
            let vm = parent.viewModel

            let currentImg = vm.currentTemplateImage
            if bgImageView.image !== currentImg {
                bgImageView.image = currentImg
                recalculateTemplateRect()
            } else if unscaledTemplateRect == .zero {
                recalculateTemplateRect()
            }

            let targetAlpha: CGFloat = (vm.showReferenceLine && currentImg != nil)
                ? CGFloat(vm.referenceOpacity)
                : 0.0

            if abs(bgImageView.alpha - targetAlpha) > 0.01 {
                UIView.animate(withDuration: 0.25) {
                    bgImageView.alpha = targetAlpha
                }
            }

            updateBackgroundPosition()
        }

        func updateBackgroundPosition() {
            guard let canvasView = canvasView,
                  let bgImageView = backgroundImageView,
                  bgImageView.image != nil,
                  unscaledTemplateRect.width > 0,
                  unscaledTemplateRect.height > 0 else { return }

            let scale = canvasView.zoomScale
            let offset = canvasView.contentOffset

            bgImageView.frame = CGRect(
                x: unscaledTemplateRect.origin.x * scale - offset.x,
                y: unscaledTemplateRect.origin.y * scale - offset.y,
                width: unscaledTemplateRect.size.width * scale,
                height: unscaledTemplateRect.size.height * scale
            )
        }

        // MARK: - UIScrollViewDelegate (Synchronized Zooming & Scrolling)
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            updateBackgroundPosition()
            parent.viewModel.zoomScale = scrollView.zoomScale
            parent.viewModel.contentOffset = scrollView.contentOffset
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            updateBackgroundPosition()
            parent.viewModel.zoomScale = scrollView.zoomScale
            parent.viewModel.contentOffset = scrollView.contentOffset
        }

        func updateUndoState() {
            guard let undoManager = canvasView?.undoManager else { return }
            parent.viewModel.syncPKUndoState(canUndo: undoManager.canUndo, canRedo: undoManager.canRedo)
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let currentCount = canvasView.drawing.strokes.count
            let isUndoing = canvasView.undoManager?.isUndoing ?? false
            let isRedoing = canvasView.undoManager?.isRedoing ?? false

            if currentCount > previousStrokesCount && !isUndoing && !isRedoing {
                parent.viewModel.registerStrokeAction()
            }
            previousStrokesCount = currentCount
            updateUndoState()
        }

        @objc func undoManagerDidUndo(_ notification: Notification) {
            if let canvasView = canvasView {
                previousStrokesCount = canvasView.drawing.strokes.count
            }
            updateUndoState()
        }

        @objc func undoManagerDidRedo(_ notification: Notification) {
            if let canvasView = canvasView {
                previousStrokesCount = canvasView.drawing.strokes.count
            }
            updateUndoState()
        }

        private func renderImage(from canvasView: PKCanvasView, includeBackground: Bool) -> UIImage? {
            let baseSize = Self.canonicalCanvasSize
            let exportBounds = CGRect(origin: .zero, size: baseSize)

            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale

            let renderer = UIGraphicsImageRenderer(bounds: exportBounds, format: format)
            return renderer.image { ctx in
                // 1. Pure white paper background
                UIColor.white.setFill()
                ctx.fill(exportBounds)

                // 2. Reference line art if visible (strictly drawn in the exact same unscaledTemplateRect)
                let vm = parent.viewModel
                if includeBackground && vm.showReferenceLine, let outlineImage = vm.currentTemplateImage {
                    outlineImage.draw(in: unscaledTemplateRect, blendMode: .normal, alpha: CGFloat(vm.referenceOpacity))
                }

                // 3. User drawing strokes rendered in high resolution
                let strokeImage = canvasView.drawing.image(from: exportBounds, scale: UIScreen.main.scale)
                strokeImage.draw(in: exportBounds)

                // 4. User placed Stamp stickers
                for stamp in vm.stamps {
                    let fontSize = stamp.size
                    let font = UIFont.systemFont(ofSize: fontSize)
                    let attributes: [NSAttributedString.Key: Any] = [.font: font]
                    let str = NSString(string: stamp.item.emoji)
                    let strSize = str.size(withAttributes: attributes)

                    let cgContext = ctx.cgContext
                    cgContext.saveGState()
                    cgContext.translateBy(x: stamp.position.x, y: stamp.position.y)
                    cgContext.rotate(by: CGFloat(stamp.rotation.radians))

                    str.draw(at: CGPoint(x: -strSize.width / 2, y: -strSize.height / 2), withAttributes: attributes)
                    cgContext.restoreGState()
                }
            }
        }

        static func aspectFit(imageSize: CGSize, in targetRect: CGRect) -> CGRect {
            guard imageSize.width > 0, imageSize.height > 0, targetRect.width > 0, targetRect.height > 0 else { return targetRect }
            let scale = min(targetRect.width / imageSize.width, targetRect.height / imageSize.height)
            let w = imageSize.width * scale
            let h = imageSize.height * scale
            let x = targetRect.midX - w / 2
            let y = targetRect.midY - h / 2
            return CGRect(x: x, y: y, width: w, height: h)
        }
    }
}
