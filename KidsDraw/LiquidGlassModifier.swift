import SwiftUI

// MARK: - Liquid Glass ViewModifier
public struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var hasShadow: Bool

    public init(cornerRadius: CGFloat = 24, hasShadow: Bool = true) {
        self.cornerRadius = cornerRadius
        self.hasShadow = hasShadow
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.65), location: 0.0),
                                .init(color: Color.white.opacity(0.15), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: hasShadow ? Color.black.opacity(0.08) : Color.clear,
                radius: hasShadow ? 12 : 0,
                x: 0,
                y: hasShadow ? 6 : 0
            )
    }
}

// MARK: - View Extension
public extension View {
    func liquidGlass(cornerRadius: CGFloat = 24, hasShadow: Bool = true) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, hasShadow: hasShadow))
    }
}
