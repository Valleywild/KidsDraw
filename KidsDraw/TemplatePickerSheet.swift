import SwiftUI
import UIKit

struct TemplatePickerSheet: View {
    @ObservedObject var viewModel: DrawingViewModel
    @Environment(\.dismiss) private var dismiss

    // 3 Columns Grid for 3*3 layout
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // Header Subtitle
                        Text("点击喜欢的卡片，马上开始画画啦 ✨")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 18)

                        // 3*3 Template Grid
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.templateManager.allTemplates) { template in
                                TemplateCardView(
                                    template: template,
                                    isSelected: viewModel.selectedTemplateId == template.id,
                                    previewImage: viewModel.templateManager.image(for: template),
                                    onSelect: {
                                        viewModel.selectTemplate(template)
                                        dismiss()
                                    },
                                    onDelete: template.isCustom ? {
                                        viewModel.deleteTemplate(template)
                                    } : nil
                                )
                                .id(template.id)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 8)
                }
                .onAppear {
                    proxy.scrollTo(viewModel.selectedTemplateId, anchor: .center)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(viewModel.selectedTemplateId, anchor: .center)
                        }
                    }
                }
            }
            .background(Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea())
            .navigationTitle("🖼️ 选择画画底稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
    }
}

// MARK: - Individual 3*3 Grid Card View with Liquid Glass Touch
struct TemplateCardView: View {
    let template: DrawingTemplateItem
    let isSelected: Bool
    let previewImage: UIImage?
    let onSelect: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Line Art Thumbnail Preview
                ZStack {
                    Color.white.opacity(0.85)

                    if let img = previewImage {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(10)
                    } else {
                        // Blank canvas icon
                        VStack(spacing: 6) {
                            Text("✨")
                                .font(.system(size: 34))
                            Text("纯白画板")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Checkmark Badge when Selected
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.35))
                                    .background(Circle().fill(Color.white))
                                    .shadow(color: Color.black.opacity(0.15), radius: 3)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }

                    // Delete Button for Custom Templates
                    if let onDelete = onDelete {
                        VStack {
                            HStack {
                                Button(action: onDelete) {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color.red.opacity(0.8))
                                        .background(Circle().fill(Color.white))
                                }
                                .padding(8)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 118)

                // Divider line
                Rectangle()
                    .fill(Color.black.opacity(0.06))
                    .frame(height: 1)

                // Bottom Title Card
                HStack(spacing: 5) {
                    Text(template.emoji)
                        .font(.system(size: 18))

                    Text(template.name)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.2, blue: 0.35))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color(red: 1.0, green: 0.96, blue: 0.88) : Color.white.opacity(0.95))
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? Color(red: 1.0, green: 0.65, blue: 0.0)
                            : Color.white.opacity(0.8),
                        lineWidth: isSelected ? 3.5 : 1.2
                    )
            )
            .shadow(
                color: isSelected ? Color.orange.opacity(0.3) : Color.black.opacity(0.06),
                radius: isSelected ? 10 : 6,
                x: 0,
                y: 3
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}
