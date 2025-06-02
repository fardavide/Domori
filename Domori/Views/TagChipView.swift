import SwiftUI

struct TagChipView: View {
    let tag: PropertyTag
    let isSelected: Bool
    let onTap: (() -> Void)?
    
    init(tag: PropertyTag, isSelected: Bool = false, onTap: (() -> Void)? = nil) {
        self.tag = tag
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        Text(tag.name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? tag.swiftUiColor : tag.swiftUiColor.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : tag.swiftUiColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(tag.swiftUiColor, lineWidth: 1)
            )
            .onTapGesture {
                onTap?()
            }
            .accessibilityIdentifier("TagChip")
            .accessibilityLabel(tag.name)
    }
}

#Preview {
    VStack(spacing: 10) {
        TagChipView(tag: PropertyTag(name: "High Priority", rating: .excellent), isSelected: false)
        TagChipView(tag: PropertyTag(name: "Good Deal", rating: .good), isSelected: true)
        TagChipView(tag: PropertyTag(name: "Needs Work", rating: .considering), isSelected: false)
    }
    .padding()
} 