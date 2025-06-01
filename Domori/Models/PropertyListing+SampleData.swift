import Foundation

extension PropertyListing {
    static var sampleData: [PropertyListing] {
        // Determine if we should use metric or imperial measurements
        let isMetric = Locale.current.usesMetricSystem
        
        // Sample properties with locale-appropriate values
        let properties: [(title: String, address: String, price: Double, size: Double, bedrooms: Int, bathrooms: Double, type: PropertyType, rating: Double, notes: String, isFavorite: Bool)] = [
            (
                title: "Charming Victorian Home",
                address: "123 Oak Street, San Francisco, CA 94102",
                price: isMetric ? 1_150_000 : 1_250_000, // Adjusted for different markets
                size: isMetric ? 223 : 2400, // ~223 sqm = ~2400 sqft
                bedrooms: 3,
                bathrooms: 2.5,
                type: .house,
                rating: 4.5,
                notes: "Beautiful Victorian architecture with original hardwood floors. Great location near parks.",
                isFavorite: false
            ),
            (
                title: "Modern Downtown Condo",
                address: "456 Mission Street, Unit 1205, San Francisco, CA 94105",
                price: isMetric ? 780_000 : 850_000,
                size: isMetric ? 111 : 1200, // ~111 sqm = ~1200 sqft
                bedrooms: 2,
                bathrooms: 2,
                type: .condo,
                rating: 4.0,
                notes: "Stunning city views, modern amenities, walking distance to public transit.",
                isFavorite: true
            ),
            (
                title: "Spacious Family Home",
                address: "789 Maple Avenue, Palo Alto, CA 94301",
                price: isMetric ? 1_950_000 : 2_100_000,
                size: isMetric ? 297 : 3200, // ~297 sqm = ~3200 sqft
                bedrooms: 4,
                bathrooms: 3,
                type: .house,
                rating: 5.0,
                notes: "Perfect for families. Large backyard, excellent schools nearby, newly renovated kitchen.",
                isFavorite: false
            ),
            (
                title: "Cozy Studio Apartment",
                address: "321 Pine Street, Berkeley, CA 94704",
                price: isMetric ? 390_000 : 425_000,
                size: isMetric ? 60 : 650, // ~60 sqm = ~650 sqft
                bedrooms: 0,
                bathrooms: 1,
                type: .studio,
                rating: 3.5,
                notes: "Great starter home or investment property. Close to university campus.",
                isFavorite: false
            ),
            (
                title: "Luxury Penthouse",
                address: "555 California Street, Penthouse A, San Francisco, CA 94104",
                price: isMetric ? 3_200_000 : 3_500_000,
                size: isMetric ? 260 : 2800, // ~260 sqm = ~2800 sqft
                bedrooms: 3,
                bathrooms: 3.5,
                type: .penthouse,
                rating: 5.0,
                notes: "Incredible panoramic views, premium finishes throughout, private rooftop terrace.",
                isFavorite: true
            ),
            (
                title: "Suburban Townhouse",
                address: "888 Cedar Lane, Mountain View, CA 94040",
                price: isMetric ? 1_020_000 : 1_100_000,
                size: isMetric ? 167 : 1800, // ~167 sqm = ~1800 sqft
                bedrooms: 3,
                bathrooms: 2.5,
                type: .townhouse,
                rating: 4.2,
                notes: "Great value in excellent school district. Two-car garage, small private yard.",
                isFavorite: false
            )
        ]
        
        return properties.map { property in
            PropertyListing(
                title: property.title,
                address: property.address,
                price: property.price,
                size: property.size,
                bedrooms: property.bedrooms,
                bathrooms: property.bathrooms,
                propertyType: property.type,
                rating: property.rating,
                notes: property.notes,
                isFavorite: property.isFavorite
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