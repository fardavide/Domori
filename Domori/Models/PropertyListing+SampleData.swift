import Foundation

extension PropertyListing {
    static var sampleData: [PropertyListing] {
        // Determine if we should use metric or imperial measurements
        let isMetric = Locale.current.measurementSystem == .metric
        
        // Sample properties with locale-appropriate values
        let properties: [(title: String, location: String, link: String, price: Double, size: Double, bedrooms: Int, bathrooms: Double, type: PropertyType, rating: PropertyRating, notes: String)] = [
            (
                title: "Charming Victorian Home",
                location: "123 Oak Street, San Francisco, CA 94102",
                link: "https://example.com/listings/victorian-home-123-oak",
                price: isMetric ? 1_150_000 : 1_250_000, // Adjusted for different markets
                size: isMetric ? 223 : 2400, // ~223 sqm = ~2400 sqft
                bedrooms: 3,
                bathrooms: 2.0,
                type: .house,
                rating: .excellent,
                notes: "Beautiful historic home with original hardwood floors and bay windows. Great location near parks."
            ),
            (
                title: "Modern Downtown Condo",
                location: "456 Market Street, #2501, San Francisco, CA 94105",
                link: "https://example.com/listings/modern-condo-456-market",
                price: isMetric ? 950_000 : 1_100_000,
                size: isMetric ? 102 : 1100, // ~102 sqm = ~1100 sqft
                bedrooms: 2,
                bathrooms: 2.0,
                type: .condo,
                rating: .good,
                notes: "High-rise condo with stunning city views and modern amenities. Walking distance to BART."
            ),
            (
                title: "Spacious Family Townhouse",
                location: "789 Pine Avenue, Oakland, CA 94610",
                link: "https://example.com/listings/townhouse-789-pine",
                price: isMetric ? 750_000 : 850_000,
                size: isMetric ? 186 : 2000, // ~186 sqm = ~2000 sqft
                bedrooms: 4,
                bathrooms: 3.0,
                type: .townhouse,
                rating: .considering,
                notes: "Great for families with excellent schools nearby. Needs some kitchen updates but has potential."
            ),
            (
                title: "Luxury Penthouse Suite",
                location: "321 California Street, #PH, San Francisco, CA 94108",
                link: "https://example.com/listings/penthouse-321-california",
                price: isMetric ? 2_800_000 : 3_200_000,
                size: isMetric ? 279 : 3000, // ~279 sqm = ~3000 sqft
                bedrooms: 3,
                bathrooms: 3.5,
                type: .penthouse,
                rating: .excluded,
                notes: "Stunning views but way over budget. Incredible amenities and rooftop terrace."
            ),
            (
                title: "Cozy Studio Apartment",
                location: "654 Mission Street, #12, San Francisco, CA 94103",
                link: "https://example.com/listings/studio-654-mission",
                price: isMetric ? 485_000 : 550_000,
                size: isMetric ? 46 : 500, // ~46 sqm = ~500 sqft
                bedrooms: 0,
                bathrooms: 1.0,
                type: .studio,
                rating: .considering,
                notes: "Perfect starter home in SOMA. Small but efficient layout with murphy bed."
            ),
            (
                title: "Suburban Family Home",
                location: "987 Elm Drive, San Mateo, CA 94403",
                link: "https://example.com/listings/family-home-987-elm",
                price: isMetric ? 1_050_000 : 1_400_000,
                size: isMetric ? 204 : 2200, // ~204 sqm = ~2200 sqft
                bedrooms: 4,
                bathrooms: 2.5,
                type: .house,
                rating: .good,
                notes: "Quiet neighborhood with large backyard. Good schools and family-friendly community."
            )
        ]
        
        return properties.map { property in
            PropertyListing(
                title: property.title,
                location: property.location,
                link: property.link,
                price: property.price,
                size: property.size,
                bedrooms: property.bedrooms,
                bathrooms: property.bathrooms,
                propertyType: property.type,
                notes: property.notes,
                propertyRating: property.rating
            )
        }
    }
    
    static func createSampleTags() -> [PropertyTag] {
        PropertyTag.createDefaultTags()
    }
    
    static func createSampleNotes(for listing: PropertyListing) -> [PropertyNote] {
        [
            PropertyNote(content: "House has great natural light throughout", category: .pros),
            PropertyNote(content: "Kitchen appliances need updating", category: .cons),
            PropertyNote(content: "How much would it cost to update the HVAC system?", category: .questions),
            PropertyNote(content: "Neighborhood is very quiet and family-friendly", category: .neighborhood),
            PropertyNote(content: "Property taxes are reasonable for the area", category: .financial)
        ]
    }
} 