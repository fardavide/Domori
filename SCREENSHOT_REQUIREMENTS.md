# 📱 App Store Screenshots Requirements - DEFINITIVE SPECIFICATION

## 🎯 **MANDATORY REQUIREMENTS FOR DOMORI APP SCREENSHOTS**

> **⚠️ CRITICAL**: This document contains the FINAL, AUTHORITATIVE requirements for Domori app screenshots. 
> All future screenshot generation MUST follow these exact specifications.

---

## 📱 **SUPPORTED PLATFORMS & TECHNICAL SPECS**

### ✅ **iPhone (Completed)**
- **Device**: iPhone 16 Pro (6.3" display)
- **Simulator**: iPhone 16 Pro in portrait mode
- **Format**: PNG files
- **Quality**: High resolution, production-ready
- **Test**: `testAppStoreScreenshots_iPhone()`

### ✅ **iPad (Completed)**
- **Device**: iPad Pro 13" (13" display)  
- **Simulator**: iPad Pro 13" in portrait mode
- **Format**: PNG files
- **Quality**: High resolution, optimized for tablet layout
- **Test**: `testAppStoreScreenshots_iPad()`

### 🚧 **Mac (Future - Requires macOS Target)**
- **Platform**: macOS Catalyst or native macOS
- **Requirements**: Would need macOS app target to implement
- **Test**: `testAppStoreScreenshots_Mac()` (prepared but not active)
- **Status**: Currently iOS-only app, macOS support requires platform expansion

---

## 📸 **SCREENSHOT SPECIFICATIONS**

### **REQUIRED Screenshots per Platform (5 Total):**
1. **Main Screen** - Show property listings with European data **WITH TAGS VISIBLE**
2. **Add Property Form** - Filled form with realistic European property data  
3. **Property Detail** - Detailed view of a selected property **WITH TAGS VISIBLE**
4. **Tag Addition View** - Add Tags screen showing tag creation interface
5. **Property Comparison** - Comparison view showing multiple properties side-by-side

### **Naming Convention:**
- iPhone: `01_iPhone_MainScreen_ThreeListings.png`, `02_iPhone_AddProperty_FilledForm.png`, `03_iPhone_PropertyDetail.png`, `04_iPhone_TagAddition.png`, `05_iPhone_PropertyComparison.png`
- iPad: `01_iPad_MainScreen_ThreeListings.png`, `02_iPad_AddProperty_FilledForm.png`, `03_iPad_PropertyDetail.png`, `04_iPad_TagAddition.png`, `05_iPad_PropertyComparison.png`
- Mac: `01_Mac_MainScreen_ThreeListings.png`, `02_Mac_AddProperty_FilledForm.png`, `03_Mac_PropertyDetail.png`, `04_Mac_TagAddition.png`, `05_Mac_PropertyComparison.png`

---

## 🏷️ **CRITICAL TAG REQUIREMENTS**

### **MANDATORY Tag Display:**
- **Properties in screenshots 01 & 03 MUST show tags** ✅ **IMPLEMENTED**
- **Tags should be diverse** with realistic variety ✅ **IMPLEMENTED** 
- **Tags should have different colors/styles** ✅ **IMPLEMENTED** (Blue/Green/Orange/Red/Gray)
- **Tag functionality is a KEY FEATURE** ✅ **SUCCESSFULLY DEMONSTRATED**

### **Tag Addition Process:**
- **Screenshot 04** must show the tag addition interface ✅ **IMPLEMENTED**
- **Must demonstrate** how users add tags to properties ✅ **IMPLEMENTED**
- **Should show** realistic tag names being entered ✅ **IMPLEMENTED**

### **Tag Rating Variety (SUCCESSFULLY IMPLEMENTED):**
- **Property 1** (Excellent overall): Prime Location (Excellent/Blue) + Investment Grade (Good/Green) + High Price Point (Considering/Orange)
- **Property 2** (Good overall): Historic Charm (Good/Green) + Renovation Needed (Considering/Orange) + Good Value (Good/Green)
- **Property 3** (Considering overall): Luxury Features (Good/Green) + Very Expensive (Excluded/Red) + Great Views (Good/Green)

---

## 🇪🇺 **EUROPEAN DATA REQUIREMENTS**

### **MANDATORY European Property Data:**
- **Addresses**: Use realistic European addresses (Italian, German, French cities)
- **Currency**: Euro (€) format - NEVER show "€0"
- **Size**: Square meters (sqm) - NEVER show "0 sqm" 
- **Price per sqm**: Calculate dynamically - NEVER show "NaN/sqm"

### **Sample Data Used:**
1. **Modern City Apartment** - Via Roma 123, Milano, Italy - €485,000 - 85 sqm
2. **Victorian Townhouse** - Kurfürstendamm 45, Berlin, Germany - €750,000 - 120 sqm  
3. **Riverside Penthouse** - Quai des Grands Augustins 12, Paris, France - €1,250,000 - 150 sqm

---

## ❌ **CRITICAL PROHIBITIONS**

**These values MUST NEVER appear in screenshots:**
- "€0" or "0 EUR" 
- "0 sqm" or "0 m²"
- "NaN/sqm" or "NaN €/m²"
- Any placeholder or zero values
- Non-European addresses or currency
- **Properties without any tags** (tags are a key feature to showcase)

---

## 🧪 **TESTING FRAMEWORK**

### **Multi-Platform Test Structure:**
```swift
// Main entry points
testAppStoreScreenshots_iPhone()  // ✅ Active - Must generate all 5 screenshots
testAppStoreScreenshots_iPad()    // ✅ Active - Must generate all 5 screenshots
testAppStoreScreenshots_Mac()     // 🚧 Prepared for future

// Core platform-agnostic logic
generateScreenshotsForPlatform(platform: .iPhone/.iPad/.Mac, deviceName: String)
```

### **Platform Optimization:**
- **iPhone**: Standard mobile layout, keyboard dismissal, vertical scrolling
- **iPad**: Enhanced tablet layout, larger form display, master-detail optimization
- **Mac**: Desktop layout optimization (prepared for future implementation)

### **Performance:**
- iPhone: ~175 seconds 
- iPad: ~199 seconds (slightly longer due to larger interface)
- All tests use optimized timing with `usleep()` and `XCTWaiter` for reliability

---

## 🔄 **AUTOMATION STATUS**

### **Current Implementation:**
- ✅ **Fully automated** screenshot generation for iPhone and iPad
- ✅ **Multi-platform** test architecture ready for expansion
- ✅ **Apple guidelines compliance** with proper form filling and navigation
- ✅ **European data validation** prevents placeholder values
- ✅ **Optimized performance** with reduced delays and smart waiting
- ✅ **Tag rating variety** with different colors working correctly
- ✅ **ALL 5 screenshots generated** including PropertyComparison
- ✅ **Tag addition to properties** working with realistic variety
- ✅ **Efficient navigation** reducing test execution time to ~3.5 minutes

### **Screenshot Generation Commands:**
```bash
# iPhone screenshots (all 5)
xcodebuild test -project Domori.xcodeproj -scheme Domori \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPhone

# iPad screenshots (all 5)
xcodebuild test -project Domori.xcodeproj -scheme Domori \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPad
```

---

## 📋 **VALIDATION CHECKLIST**

Before submitting screenshots, verify:
- [x] All prices show realistic Euro amounts (never €0)
- [x] All sizes show realistic square meters (never 0 sqm)
- [x] All addresses are European locations 
- [x] Price per sqm is calculated correctly (never NaN/sqm)
- [x] **Properties have tags visible in screenshots 01 and 03** ✅ **IMPLEMENTED**
- [x] **All 5 screenshots are generated** (including PropertyComparison) ✅ **IMPLEMENTED**
- [x] Screenshots are high resolution and production-ready
- [x] Both iPhone and iPad variants are generated
- [x] File naming follows the established convention
- [x] Screenshots showcase the app's property management AND tagging features effectively ✅ **SUCCESSFULLY DEMONSTRATED**
- [x] **Tag ratings show correct colors** (Blue/Green/Orange/Red/Gray) ✅ **WORKING PERFECTLY**

---

**Last Updated**: June 2025 - **✅ COMPLETE SUCCESS**: Multi-platform screenshot automation with full tag rating variety implemented. All 5 screenshots generating correctly with realistic European data and diverse tag colors demonstrating the full feature set. 