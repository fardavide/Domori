# 📸 Manual Screenshot Generation Guide for Domori

## 🎯 Goal: Create 3-5 compelling App Store screenshots with dummy data

### Current Status:
✅ **App is running on iPhone 16 Pro**  
✅ **First screenshot taken**: `01_iPhone16Pro_EmptyState.png`

---

## 📱 **Manual Steps to Add Sample Data**

### Sample Property 1: "Modern Downtown Apartment"
1. **Tap the "+" (Add) button** in the navigation bar
2. **Fill in the form**:
   - **Title**: `Modern Downtown Apartment`
   - **Location**: `123 Main St, San Francisco, CA`
   - **Price**: `2,850,000`
   - **Link**: `https://example.com/property1`
3. **Tap "Save"**
4. **Take screenshot**: 
   ```bash
   xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/02_iPhone16Pro_OneProperty.png
   ```

### Sample Property 2: "Victorian Family Home"
1. **Tap the "+" (Add) button** again
2. **Fill in the form**:
   - **Title**: `Victorian Family Home`
   - **Location**: `456 Oak Avenue, Berkeley, CA`
   - **Price**: `1,250,000`
   - **Link**: `https://example.com/property2`
3. **Tap "Save"**

### Sample Property 3: "Luxury Penthouse Suite"
1. **Tap the "+" (Add) button** again
2. **Fill in the form**:
   - **Title**: `Luxury Penthouse Suite`
   - **Location**: `789 Hill Street, Nob Hill, CA`
   - **Price**: `4,200,000`
   - **Link**: `https://example.com/property3`
3. **Tap "Save"**
4. **Take screenshot**: 
   ```bash
   xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/03_iPhone16Pro_ThreeProperties.png
   ```

### Additional Screenshots
5. **Tap on first property** to open detail view
6. **Take screenshot of detail view**:
   ```bash
   xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/04_iPhone16Pro_PropertyDetail.png
   ```
7. **Navigate back** and take final overview:
   ```bash
   xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/05_iPhone16Pro_FinalView.png
   ```

---

## 🚀 **Quick Screenshot Commands**

After adding each property, run these commands from terminal:

```bash
# After 1st property
xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/02_iPhone16Pro_OneProperty.png

# After all 3 properties  
xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/03_iPhone16Pro_ThreeProperties.png

# Property detail view
xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/04_iPhone16Pro_PropertyDetail.png

# Final overview
xcrun simctl io "iPhone 16 Pro" screenshot --type=png AppStoreScreenshots/05_iPhone16Pro_FinalView.png
```

---

## 📋 **Expected Final Screenshots:**

1. `01_iPhone16Pro_EmptyState.png` ✅ - Clean empty state
2. `02_iPhone16Pro_OneProperty.png` ⏳ - One sample property added
3. `03_iPhone16Pro_ThreeProperties.png` ⏳ - Three properties in list
4. `04_iPhone16Pro_PropertyDetail.png` ⏳ - Property detail view
5. `05_iPhone16Pro_FinalView.png` ⏳ - Final polished view

**Next Steps**: Follow the manual steps above to complete the screenshot collection! 