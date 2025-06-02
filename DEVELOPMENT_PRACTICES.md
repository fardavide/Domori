# 🛠️ Development Practices Guide for Domori

## 🎯 Core Development Principles

### 1. **FAIL HARD, NOT SILENT**
- ❌ **Never allow operations to fail silently**
- ✅ **Always use explicit validation with clear error messages**
- ✅ **Fail immediately when critical operations don't work**

### 2. **Evidence-Based Development**
- ❌ **Don't assume changes work as expected** - validate visually
- ✅ **Generate evidence for every significant change**
- ✅ **Document decisions and outcomes**
- ✅ **Commit with complete validation proof**

### 3. **Incremental Quality Improvement**
- ❌ **Don't assume operations succeed** - verify explicitly
- ✅ **Validate expected state before proceeding**
- ✅ **Use comprehensive error handling**
- ✅ **Provide clear debugging information**

---

## 📱 **UI Change Development Process (MANDATORY)**

### **Every UI change, no matter how small, MUST follow this development workflow:**

#### ✅ **Required Development Steps for ANY UI Change:**

1. **🔧 Implement the UI change**
   - Make the necessary code modifications
   - Test compilation and basic functionality locally
   - Follow established code style guidelines

2. **📸 Generate visual validation**
   ```bash
   xcodebuild test -project Domori.xcodeproj -scheme Domori \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
     -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPhone
   ```

3. **🔍 Validate visual changes**
   - Check file timestamps: `ls -la AppStoreScreenshots/*iPhone*.png`
   - Verify affected screenshots show the expected changes
   - Ensure no unintended changes occurred in other screens
   - Confirm the change achieves the intended goal

4. **📚 Update development documentation**
   - Update relevant guides with latest status
   - Document any new patterns or components
   - Note validation results and design decisions
   - Update component reference documentation

5. **💾 Commit with complete evidence**
   - Commit screenshots alongside code changes
   - Include validation results in commit message
   - Reference screenshot files and validation outcomes
   - Follow established commit message format

#### ⚠️ **Why This Development Process is MANDATORY:**

- **Prevents visual regressions**: Screenshots catch unintended changes during development
- **Validates implementation quality**: Ensures changes work as designed
- **Documents application evolution**: Creates visual history for team reference
- **Enables effective code review**: Allows reviewers to see actual visual impact
- **Improves user experience**: Ensures UI changes enhance rather than degrade UX

#### 🎨 **What constitutes a UI change requiring validation:**

- **Layout modifications** (spacing, alignment, sizing, positioning)
- **New UI components or views** (custom controls, screens, sections)
- **Visual styling changes** (colors, fonts, borders, shadows)
- **Navigation flow modifications** (screen transitions, user paths)
- **Data presentation changes** (new fields, different formatting, layout)
- **Interactive element changes** (buttons, forms, gestures, controls)
- **Responsive behavior changes** (different screen sizes, orientations)

---

## 🏗️ **Code Quality Standards**

### Component Development Requirements:
- Every new UI component MUST have proper documentation
- Every component MUST handle edge cases (empty data, error states)
- Every data-driven component MUST validate input
- Every interactive component MUST provide accessibility support

### Code Quality Standards:
- Development code MUST include error handling
- Never silently ignore failed operations
- Always provide meaningful error messages with context
- Use established naming conventions (e.g., `UiModel` not `UIModel`)

### Visual Quality Standards:
- UI changes MUST improve or maintain current UX quality
- Performance impact of UI changes MUST be acceptable
- Accessibility MUST be maintained or improved
- Visual consistency MUST be preserved across the application

---

## 📊 **Development Quality Metrics**

### Required Development Validations:
- ✅ **Visual validation successful** (screenshots generated and reviewed)
- ✅ **All affected screens updated** (no unintended changes)
- ✅ **No functional regressions** (existing features still work)
- ✅ **Performance impact acceptable** (no significant slowdowns)
- ✅ **Code quality maintained** (follows established patterns)
- ✅ **Documentation updated** (changes properly documented)

### Development Performance Thresholds:
- **Screenshot generation**: < 5 minutes (for validation)
- **Build time impact**: < 10% increase
- **App startup time**: No regression after UI changes
- **Memory usage**: No significant increase

---

## 🎯 **Development Goals for Domori**

### **UI Development Standards**
1. **Visual consistency** across all screens and components
2. **Intuitive user experience** with clear navigation paths
3. **Responsive design** that works across different device sizes
4. **Accessible interface** supporting all users

### **Code Quality Standards**
1. **Maintainable code** following established patterns
2. **Comprehensive error handling** with meaningful messages
3. **Proper documentation** for all components and patterns
4. **Test coverage** for critical functionality

### **Development Workflow Standards**
1. **Visual validation** for every UI change
2. **Evidence-based commits** with screenshots and validation
3. **Comprehensive documentation** of design decisions
4. **Team collaboration** through clear code review process

---

## 📚 **Related Documentation**

- **Testing Strategy**: TESTING_STRATEGY.md
- **UI Guidelines**: UI_GUIDELINES.md
- **Code Style Guidelines**: CODE_STYLE.md
- **Visual Design Standards**: SCREENSHOT_REQUIREMENTS.md  
- **Commit Standards**: COMMIT_RULES.md
- **App Store Guidelines**: APP_STORE_SUBMISSION_GUIDE.md 