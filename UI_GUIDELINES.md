# 🎨 UI Guidelines for Domori

## 🎯 Visual Design Principles

### 1. **Consistency**
- Use consistent spacing, typography, and color schemes
- Follow established component patterns throughout the app
- Maintain visual hierarchy and alignment

### 2. **Clarity**
- Prioritize readability and user comprehension
- Use appropriate contrast ratios
- Ensure interactive elements are clearly identifiable

### 3. **Efficiency**
- Optimize visual density without overwhelming users
- Minimize cognitive load through progressive disclosure
- Use whitespace effectively to guide attention

---

## 🧩 **Component Guidelines**

### **TagFlowLayout Component**
Current optimized specifications for tag display:
- **Spacing**: 3px between tags (optimized for visual density)
- **Horizontal padding**: 4px (compact but touchable)
- **Vertical padding**: 2px (minimal vertical space usage)
- **Corner radius**: 3px (subtle rounding)
- **Background**: Tag color at 15% opacity
- **Text**: Tag color at full opacity

```swift
// Reference implementation
FlexibleWrapView(data: tags, spacing: 3) { tag in
    Text(tag.name)
        .font(.caption2)
        .fontWeight(.medium)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(tag.swiftUiColor.opacity(0.15))
        .foregroundColor(tag.swiftUiColor)
        .cornerRadius(3)
        .lineLimit(1)
}
```

### **Property List Row Component**
- **Vertical spacing**: 8px between rows
- **Selection indicator**: 24x24px circle with blue accent
- **Property type icon**: 16x16px, secondary color
- **Rating indicator**: 12x12px colored circle
- **Content alignment**: Leading alignment with consistent indentation

### **Property Detail Badges**
- **Icon size**: caption2 font, secondary color
- **Spacing**: 4px between icon and text
- **Layout**: Horizontal flow with 16px spacing between badges

### **TagAddition Screen**
Component for creating custom property tags with rating:
- **Interface**: Modal presentation with clear title "Add Tags"
- **Input Field**: Text field with "Enter tag name" placeholder 
- **Rating Selection**: Responsive 3-column grid layout with visual rating buttons
  - **Grid**: LazyVGrid with 3 flexible columns, 8px spacing
  - **Buttons**: Minimum 50px height, compact padding (6px vertical, 4px horizontal)
  - **Text**: Caption font with medium weight, 2-line limit, auto-scaling
  - **Icons**: Title3 font size for proper visibility
  - **States**: 15% opacity background for selected, 1.5px stroke width
- **Actions**: Clear "Create Tag" and "Cancel" buttons
- **Validation**: Real-time input validation and error handling
- **Accessibility**: Proper identifiers for UI testing (rating_\{rawValue\})

**Rating Button Specifications:**
```swift
// Responsive rating selection layout
LazyVGrid(columns: [
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8), 
    GridItem(.flexible(), spacing: 8)
], spacing: 8) {
    // Each rating button with compact, readable design
    VStack(spacing: 3) {
        Image(systemName: rating.systemImage)
            .font(.title3)
        Text(rating.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.8)
    }
    .frame(maxWidth: .infinity, minHeight: 50)
}
```

### **Comparison Screen**  
Side-by-side property analysis interface:
- **Selection Model**: Multi-select checkbox interface on property list
- **Compare Button**: Appears dynamically when 2+ properties selected
- **Layout**: Optimized side-by-side comparison with clear visual hierarchy
- **Highlighting**: Best value indicators and visual differentiation
- **Navigation**: Clear entry/exit paths with proper state management

---

## 🎨 **Color System**

### **Tag Colors by Rating**
- **None**: Gray (`Color.gray`)
- **Excluded**: Red (`Color.red`)
- **Considering**: Orange (`Color.orange`)
- **Good**: Green (`Color.green`)
- **Excellent**: Blue (`Color.blue`)

### **Interactive States**
- **Selected**: Blue accent (`Color.blue`)
- **Unselected**: Gray at 40% opacity (`Color.gray.opacity(0.4)`)
- **Secondary text**: System secondary (`Color.secondary`)

---

## 📐 **Spacing Standards**

### **Component Spacing**
- **Between tags**: 3px (optimized)
- **Between property rows**: 8px
- **Between detail badges**: 16px
- **Section spacing**: 12px

### **Padding Standards**
- **Tag horizontal**: 4px
- **Tag vertical**: 2px
- **Row vertical**: 8px
- **Content margins**: 12-16px

---

## 📱 **Responsive Design**

### **Screen Adaptability**
- Components should adapt gracefully to different screen sizes
- Tag flow layout automatically wraps based on available width
- Maintain consistent spacing ratios across device sizes

### **Typography Scaling**
- Use system typography scales (caption2, subheadline, headline)
- Ensure text remains readable at all accessibility settings
- Maintain font weight hierarchy for visual emphasis

---

## ♿ **Accessibility Standards**

### **Interactive Elements**
- Minimum touch target: 44x44 points
- Clear visual focus indicators
- Appropriate accessibility labels

### **Color and Contrast**
- Maintain WCAG AA contrast ratios
- Don't rely solely on color to convey information
- Use semantic colors consistently

### **Screen Reader Support**
- Provide meaningful accessibility identifiers
- Use semantic markup for proper navigation
- Ensure all interactive elements are accessible

---

## 🔍 **Visual Density Optimization**

### **Current Optimizations**
- **Tag spacing reduced**: From 6px to 3px for better density
- **Padding minimized**: Horizontal and vertical padding reduced
- **Corner radius reduced**: From 4px to 3px for subtle appearance

### **Future Considerations**
- Monitor user feedback on visual density
- A/B test different spacing configurations
- Consider adaptive spacing based on content volume

---

## 📋 **UI Change Validation Checklist**

### **Visual Consistency**
- [ ] New components follow established patterns
- [ ] Spacing adheres to documented standards
- [ ] Colors match the defined color system
- [ ] Typography follows hierarchy rules

### **Functionality**
- [ ] Interactive elements respond appropriately
- [ ] Navigation flows work smoothly
- [ ] Animations and transitions feel natural
- [ ] Performance impact is minimal

### **Accessibility**
- [ ] Touch targets meet minimum size requirements
- [ ] Color contrast meets accessibility standards
- [ ] Screen reader navigation works correctly
- [ ] Component labels are descriptive

---

## 🛠️ **Component Development Guidelines**

### **Creating New Components**
1. Follow established naming conventions (e.g., `UiModel` not `UIModel`)
2. Implement proper error handling for edge cases
3. Provide comprehensive accessibility support
4. Document component usage and parameters
5. Include visual examples in documentation

### **Modifying Existing Components**
1. Maintain backward compatibility where possible
2. Update all instances consistently
3. Validate changes with screenshot testing
4. Document breaking changes clearly
5. Update related documentation

---

## 📚 **Related Documentation**

- **Development Practices**: DEVELOPMENT_PRACTICES.md
- **Testing Strategy**: TESTING_STRATEGY.md
- **Screenshot Guide**: AppStoreScreenshots/SCREENSHOT_GUIDE.md
- **Code Style**: CODE_STYLE.md
- **App Store Requirements**: SCREENSHOT_REQUIREMENTS.md 