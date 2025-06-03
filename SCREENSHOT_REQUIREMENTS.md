# App Store Screenshot Requirements - Domori

## 🚨 CRITICAL: MANDATORY PROPERTY DATA

**ALL screenshots featuring property data MUST show these fields filled:**

### Essential Property Information (NEVER EMPTY!)
- **💰 PRICE**: €485,000, €650,000, €1,250,000 - MOST IMPORTANT!
- **📐 SIZE**: 85 sqm, 120 sqm, 150 sqm - ESSENTIAL!  
- **🛏️ BEDROOMS**: 2, 3, 4 bedrooms - REQUIRED!
- **🚿 BATHROOMS**: 1, 2, 3 bathrooms - REQUIRED!
- **⭐ RATING**: Good, Excellent, Considering - Important for credibility
- **🏷️ TAGS**: 2-3 meaningful tags with ratings

**Empty or missing property data makes screenshots look broken and unprofessional!**

---

## 📱 Platform Requirements

### iPhone Screenshots (5 required)
- **Device**: iPhone 16 Pro
- **Orientation**: Portrait only
- **Resolution**: Native device resolution
- **Platform Prefix**: `iPhone`

### iPad Screenshots (5 required)  
- **Device**: iPad Pro 13-inch (M4)
- **Orientation**: Portrait only
- **Resolution**: Native device resolution
- **Platform Prefix**: `iPad`

### Mac Screenshots (5 required)
- **Device**: Mac (Apple Silicon)
- **Window Size**: Standard app window
- **Resolution**: Standard Mac display
- **Platform Prefix**: `Mac`

## 📸 Required Screenshots

### 01_Platform_MainScreen_ThreeListings.png
**Content Requirements:**
- Property list showing exactly 3 properties
- Each property must display:
  - Title (clear, readable)
  - Price (realistic Euro amounts)
  - Size (realistic sqm)
  - Rating indicator
  - Visible tags (2-3 per property)
- Search bar visible at top
- Add button (+) visible in navigation
- Clean, organized layout

**Example Properties:**
1. Modern City Apartment - €485,000 - 85 sqm - Milan
2. Victorian Townhouse - €750,000 - 120 sqm - Berlin  
3. Riverside Penthouse - €1,250,000 - 150 sqm - Paris

### 02_Platform_AddProperty_FilledForm.png  
**Content Requirements:**
- Add Property form completely filled
- **CRITICAL FIELDS** (all must be visible):
  - **Property Title**: "Modern City Apartment"
  - **Location**: "Via Roma 123, Milano, Italy"
  - **Price**: "485000" (no commas, numeric field)
  - **Size**: "85" (numeric field)
  - **Bedrooms**: "2" (stepper/picker control)
  - **Bathrooms**: "2" (picker control)
  - **Rating**: "Excellent" or similar
- Form should look professional and complete
- No empty fields visible
- Save/Cancel buttons visible

### 03_Platform_PropertyDetail.png
**Content Requirements:**
- Property detail view for first property
- All property information displayed:
  - Full title, location, price, size
  - Bedrooms/bathrooms count
  - Rating prominently displayed
  - Tags section with 2-3 tags
  - Add Tag button visible
- Clean, readable layout
- Professional appearance

### 04_Platform_TagAddition.png
**Content Requirements:**
- Add Tags screen/modal
- Tag name field filled with sample text: "Premium Location"
- Rating selection visible
- Available rating options displayed
- Create Tag button enabled/visible
- Cancel option available
- Form appears functional and intuitive

### 05_Platform_PropertyComparison.png
**Content Requirements:**
- Property comparison view
- At least 2 properties side by side
- Comparison of key metrics visible
- Clear visual differentiation
- Professional comparison layout
- Properties should be different (from our 3 sample properties)

## 🎯 Quality Standards

### Visual Quality
- **Sharp, clear images** - no blur or pixelation
- **Proper contrast** - text clearly readable
- **Consistent lighting** - no dark/light inconsistencies
- **Professional appearance** - app looks production-ready

### Content Quality  
- **Realistic data** - European properties with realistic prices
- **Consistent branding** - follows app design language
- **No test/dummy data** - avoid "Test Property" or placeholder text
- **Proper formatting** - prices in euros, sizes in sqm

### Technical Quality
- **Correct naming** - follows exact naming convention
- **Proper resolution** - native device resolution
- **Complete coverage** - all 5 screenshots per platform
- **Up-to-date** - reflects current app state

## 📁 File Organization

### Directory Structure
```
AppStoreScreenshots/
├── 01_iPhone_MainScreen_ThreeListings.png
├── 02_iPhone_AddProperty_FilledForm.png  
├── 03_iPhone_PropertyDetail.png
├── 04_iPhone_TagAddition.png
├── 05_iPhone_PropertyComparison.png
├── 01_iPad_MainScreen_ThreeListings.png
├── 02_iPad_AddProperty_FilledForm.png
├── 03_iPad_PropertyDetail.png
├── 04_iPad_TagAddition.png
├── 05_iPad_PropertyComparison.png
├── 01_Mac_MainScreen_ThreeListings.png
├── 02_Mac_AddProperty_FilledForm.png
├── 03_Mac_PropertyDetail.png
├── 04_Mac_TagAddition.png
└── 05_Mac_PropertyComparison.png
```

### Naming Convention Rules
- **Format**: `{ScreenNumber}_{Platform}_{ScreenName}.png`
- **Screen Numbers**: 01, 02, 03, 04, 05 (zero-padded)
- **Platforms**: iPhone, iPad, Mac (exact case)
- **Screen Names**: Use underscore_case, descriptive
- **Extension**: .png only

### File Verification
```bash
# Check all files exist (should be 15 total)
ls -la AppStoreScreenshots/ | wc -l

# Verify latest iPhone form screenshot
ls -la AppStoreScreenshots/02_iPhone_AddProperty_FilledForm.png

# Check file sizes (should be reasonable, not empty)
du -h AppStoreScreenshots/
```

## 🇪🇺 Sample European Data

### Property 1: Milan Apartment
- **Title**: Modern City Apartment
- **Location**: Via Roma 123, Milano, Italy
- **Price**: €485,000
- **Size**: 85 sqm
- **Bedrooms**: 2
- **Bathrooms**: 2
- **Tags**: Prime Location (Excellent), Investment Grade (Good), High Price Point (Considering)

### Property 2: Berlin Townhouse  
- **Title**: Victorian Townhouse
- **Location**: Kurfürstendamm 45, Berlin, Germany
- **Price**: €750,000
- **Size**: 120 sqm
- **Bedrooms**: 3
- **Bathrooms**: 2
- **Tags**: Historic Charm (Good), Renovation Needed (Considering), Good Value (Good)

### Property 3: Paris Penthouse
- **Title**: Riverside Penthouse
- **Location**: Quai des Grands Augustins 12, Paris, France  
- **Price**: €1,250,000
- **Size**: 150 sqm
- **Bedrooms**: 4
- **Bathrooms**: 3
- **Tags**: Luxury Features (Good), Very Expensive (Excluded), Great Views (Good)

## ⚠️ Common Mistakes to Avoid

### Field Issues
- ❌ Empty price field (shows €0 or blank)
- ❌ Empty size field (shows 0 sqm or blank)
- ❌ Bedrooms/bathrooms not set (shows 0)
- ❌ Missing or placeholder property titles
- ❌ No tags visible on properties

### Technical Issues
- ❌ Wrong file names (case sensitivity matters)
- ❌ Missing screenshots (incomplete platform coverage)
- ❌ Old screenshots (not reflecting latest test run)
- ❌ Wrong device orientation (landscape instead of portrait)

### Content Issues
- ❌ Unrealistic data (prices too low/high)
- ❌ Non-European locations/currency
- ❌ Test/dummy data visible
- ❌ UI elements cut off or partially visible 