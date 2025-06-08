import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct FlowLayout: View {
    let spacing: CGFloat
    let data: [PropertyTag]
    let content: (PropertyTag) -> TagChipView
    
    init(spacing: CGFloat = 8, data: [PropertyTag], content: @escaping (PropertyTag) -> TagChipView) {
        self.spacing = spacing
        self.data = data
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: calculateHeight(for: screenWidth - 32)) // Approximate container width
    }
    
    private var screenWidth: CGFloat {
        #if os(macOS)
        return NSScreen.main?.frame.width ?? 800
        #else
        return UIScreen.main.bounds.width
        #endif
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var currentRowHeight = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(0..<data.count, id: \.self) { index in
                content(data[index])
                    .alignmentGuide(.leading, computeValue: { dimensions in
                        if (abs(width - dimensions.width) > geometry.size.width) {
                            width = 0
                            height -= currentRowHeight + spacing
                            currentRowHeight = dimensions.height
                        } else {
                            currentRowHeight = max(currentRowHeight, dimensions.height)
                        }
                        let result = width
                        if index == data.count - 1 {
                            width = 0
                        } else {
                            width -= dimensions.width + spacing
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { dimensions in
                        let result = height
                        if index == data.count - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
    
    private func calculateHeight(for containerWidth: CGFloat) -> CGFloat {
        var width = CGFloat.zero
        var height = CGFloat(40) // Approximate chip height
        
        for tag in data {
            let chipWidth = estimateChipWidth(for: tag.name)
            
            if width + chipWidth > containerWidth {
                // New row needed
                width = chipWidth + spacing
                height += 40 + spacing // Add row height + spacing
            } else {
                width += chipWidth + spacing
            }
        }
        
        return max(height, 40) // Minimum height for at least one row
    }
    
    private func estimateChipWidth(for text: String) -> CGFloat {
        // Rough estimation: 8 points per character + padding
        return CGFloat(text.count) * 8 + 24
    }
} 