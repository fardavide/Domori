# 📱 App Store Screenshots Requirements - DEFINITIVE SPECIFICATION

## 🎯 **MANDATORY REQUIREMENTS FOR DOMORI APP SCREENSHOTS**

> **⚠️ CRITICAL**: This document contains the FINAL, AUTHORITATIVE requirements for Domori app screenshots. 
> All future screenshot generation MUST follow these exact specifications.

---

## 📱 **TARGET DEVICE & TECHNICAL SPECS**
- **Device**: iPhone 16 Pro (6.3" display)
- **Simulator**: iPhone 16 Pro in portrait mode
- **Format**: PNG files
- **Quality**: High resolution, production-ready
- **Currency**: Euro (€) symbol
- **Area Unit**: Square meters (sqm)

---

## 🏠 **REQUIRED SCREENSHOTS (EXACTLY 3)**

### 📷 **Screenshot 1: `01_MainScreen_ThreeListings.png`**
**Content**: Main properties list showing exactly 3 European properties

**Required Data Per Property**:
- ✅ **Title**: European property names (e.g., "Modern City Apartment")
- ✅ **Location**: Full European addresses (e.g., "Via Roma 123, Milano, Italy")
- ✅ **Price**: Realistic Euro amounts (e.g., "€485,000" - NO "€0" or "NaN")
- ✅ **Size**: Real square meters (e.g., "85 sqm" - NO "0 sqm")
- ✅ **Price per sqm**: Calculated value (e.g., "€5,706/sqm" - NO "NaN/sqm")
- ✅ **Bedrooms**: Real numbers (e.g., "2" - NO "0")
- ✅ **Rating**: One of: "Excellent", "Good", "Considering", "Excluded" (NOT "Not Rated")

**Visual Requirements**:
- Clean property cards with all data visible
- Proper spacing and formatting
- Search bar visible at top
- Add (+) button visible in navigation
- NO placeholder zeros or NaN values anywhere

### 📷 **Screenshot 2: `02_AddProperty_FilledForm.png`**
**Content**: Add Property form completely filled with sample data

**Required Form Fields** (ALL must be filled):
- ✅ **Property Title**: "Elegant Apartment" or similar
- ✅ **Location**: European address (e.g., "Via del Corso 156, Roma, Italy")
- ✅ **Property Link**: Valid URL (e.g., "https://example.com/roma-apartment")
- ✅ **Price**: Euro amount (e.g., "€425,000" - NO "€0")
- ✅ **Size**: Square meters (e.g., "75 sqm" - NO "0")
- ✅ **Bedrooms**: Number (e.g., "2" - NO "0")
- ✅ **Rating**: Selected rating visible

**Visual Requirements**:
- Form scrolled to TOP (not middle or bottom)
- Keyboard completely DISMISSED
- All fields clearly filled with realistic data
- Save/Cancel buttons visible
- NO "0" values anywhere in form

### 📷 **Screenshot 3: `03_PropertyDetail.png`**
**Content**: Detail view of a single property with complete information

**Required Elements**:
- ✅ **Property title** prominently displayed
- ✅ **Full address** with European location
- ✅ **Price in Euros** (large, formatted amount - NO "€0")
- ✅ **Size in sqm** (clear formatting - NO "0 sqm")
- ✅ **Price per sqm** calculation (NO "NaN/sqm")
- ✅ **Bedrooms count** (NO "0")
- ✅ **Property link** visible
- ✅ **Rating indicator** showing selected rating
- ✅ **Notes section** (if applicable)

**Visual Requirements**:
- Professional, clean layout
- All data properly formatted
- Back button visible for navigation
- Scrolled to show key information
- NO missing or zero values

---

## 🚫 **ABSOLUTELY FORBIDDEN**

### ❌ **Data Issues That Must NOT Appear**:
- ✅ NO "€0" prices anywhere
- ✅ NO "0 sqm" sizes anywhere  
- ✅ NO "0" bedrooms anywhere
- ✅ NO "NaN/sqm" calculations anywhere
- ✅ NO "Not Rated" ratings (must show actual rating)
- ✅ NO empty or placeholder text fields
- ✅ NO partially filled forms in screenshots

### ❌ **Visual Issues That Must NOT Appear**:
- Keyboards visible in screenshots
- Forms scrolled to middle/bottom (must be at top)
- Truncated or cut-off text
- Missing navigation elements
- Debug text or developer artifacts

---

## 🏠 **SAMPLE PROPERTY DATA TO USE**

### Property 1:
- **Title**: "Modern City Apartment"
- **Location**: "Via Roma 123, Milano, Italy"
- **Price**: "€485,000"
- **Size**: "85 sqm"
- **Bedrooms**: "2"
- **Rating**: "Excellent"
- **Link**: "https://example.com/milano-apartment"

### Property 2:
- **Title**: "Victorian Townhouse"
- **Location**: "Kurfürstendamm 45, Berlin, Germany"
- **Price**: "€750,000"
- **Size**: "120 sqm"
- **Bedrooms**: "3"
- **Rating**: "Good"
- **Link**: "https://example.com/berlin-townhouse"

### Property 3:
- **Title**: "Riverside Penthouse"
- **Location**: "Quai des Grands Augustins 12, Paris, France"
- **Price**: "€1,250,000"
- **Size**: "150 sqm"
- **Bedrooms**: "4"
- **Rating**: "Considering"
- **Link**: "https://example.com/paris-penthouse"

---

## 🧪 **TESTING REQUIREMENTS**

### ✅ **Before Taking Screenshots**:
1. Verify ALL properties have non-zero prices and sizes
2. Confirm price/sqm calculations are working (no NaN)
3. Check that all form fields accept and display data correctly
4. Ensure rating system is functional
5. Test navigation between screens

### ✅ **Screenshot Validation Checklist**:
- [ ] No "€0" values visible anywhere
- [ ] No "0 sqm" values visible anywhere
- [ ] No "NaN/sqm" calculations visible anywhere
- [ ] All properties have realistic European data
- [ ] All rating indicators show actual ratings
- [ ] Forms are properly filled with realistic data
- [ ] Navigation elements are visible and functional

---

## 🔧 **IMPLEMENTATION NOTES**

### **For UI Test Automation**:
- Use multiple strategies to find and fill form fields
- Implement proper text clearing before entering new values
- Add validation to ensure data was actually entered
- Include debugging output to track field filling success
- Use realistic delays to allow UI updates

### **For Manual Screenshot Generation**:
- Create properties in the exact order specified above
- Double-check all numeric values before taking screenshots
- Ensure proper data formatting (€ symbol, sqm units)
- Take screenshots from top of screens, not middle

---

## 📊 **SUCCESS CRITERIA**

Screenshots are acceptable ONLY when:
1. ✅ All 3 screenshots generated successfully
2. ✅ All properties show realistic, non-zero data
3. ✅ European addresses and Euro currency used throughout
4. ✅ No technical artifacts (NaN, 0 values, placeholders) visible
5. ✅ Professional presentation suitable for App Store submission

---

**⚠️ IMPORTANT**: This document supersedes all previous requirements. Any conflicting information in other documents should be ignored in favor of these specifications. 