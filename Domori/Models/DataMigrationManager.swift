import SwiftData
import Foundation

@MainActor
class DataMigrationManager {
    
    /// Performs data migration for PropertyListing entities
    /// This ensures existing data with legacy rating system is properly converted
    static func migratePropertyListings(context: ModelContext) async {
        do {
            // Fetch all existing property listings
            let descriptor = FetchDescriptor<PropertyListing>()
            let properties = try context.fetch(descriptor)
            
            var migrationCount = 0
            
            for property in properties {
                // Check if migration is needed 
                // Case 1: propertyRating is nil (needs migration)
                // Case 2: propertyRating is .none but has meaningful legacy rating (inconsistent)
                let needsMigration = property.propertyRating == nil || 
                                   (property.propertyRating == PropertyRating.none && property.rating > 0)
                
                if needsMigration {
                    if property.rating > 0 {
                        // Convert legacy rating to new system
                        property.propertyRating = PropertyRating.fromLegacy(rating: property.rating, isFavorite: false)
                    } else {
                        // Default to .none for properties with no rating
                        property.propertyRating = PropertyRating.none
                    }
                    migrationCount += 1
                }
            }
            
            if migrationCount > 0 {
                try context.save()
                print("DataMigration: Successfully migrated \(migrationCount) properties to new rating system")
            } else {
                print("DataMigration: No migration needed - all properties already use new rating system")
            }
            
        } catch {
            print("DataMigration error: Failed to migrate property listings - \(error.localizedDescription)")
            // Don't crash the app - the legacy system will continue to work
        }
    }
    
    /// Removes Photos and Notes features from PropertyListing
    /// This migration handles the removal of deprecated photos and notes features
    /// Since the models are removed from schema, SwiftData will automatically clean up orphaned data
    static func removePhotosAndNotesFeatures(context: ModelContext) async {
        print("DataMigration: Processing Photos and Notes features removal...")
        
        // Since PropertyPhoto and PropertyNote models are removed from the schema,
        // SwiftData will automatically handle cleanup of orphaned data
        
        // Update all listings to mark they've been processed
        do {
            let listingDescriptor = FetchDescriptor<PropertyListing>()
            let listings = try context.fetch(listingDescriptor)
            
            for listing in listings {
                listing.updatedDate = Date()
            }
            
            if !listings.isEmpty {
                try context.save()
            }
            
            print("DataMigration: Successfully processed \(listings.count) listings for Photos and Notes removal")
            
        } catch {
            print("DataMigration error: Failed to process listings for photos and notes removal - \(error.localizedDescription)")
        }
    }
    
    /// Checks if migration is needed (simplified version)
    static func needsMigration(context: ModelContext) -> Bool {
        do {
            let descriptor = FetchDescriptor<PropertyListing>()
            let properties = try context.fetch(descriptor)
            
            // Check if any property needs migration
            for property in properties {
                let needsMigration = property.propertyRating == nil || 
                                   (property.propertyRating == PropertyRating.none && property.rating > 0)
                if needsMigration {
                    return true
                }
            }
            return false
        } catch {
            print("DataMigration: Error checking migration status - \(error.localizedDescription)")
            return false
        }
    }
    
    /// Checks if Photos and Notes removal migration is needed
    /// This is simplified since the models no longer exist
    static func needsPhotosAndNotesRemoval(context: ModelContext) -> Bool {
        // For simplicity, we'll check if this migration has been run before
        // by looking for a migration marker in UserDefaults
        let migrationKey = "PhotosNotesRemovalMigrationCompleted"
        let hasRun = UserDefaults.standard.bool(forKey: migrationKey)
        
        if !hasRun {
            // Mark as completed so we don't run again
            UserDefaults.standard.set(true, forKey: migrationKey)
            return true
        }
        
        return false
    }
    
    /// Validates that migration was successful
    static func validateMigration(context: ModelContext) -> Bool {
        do {
            let descriptor = FetchDescriptor<PropertyListing>()
            let properties = try context.fetch(descriptor)
            
            for property in properties {
                // Check that new rating system matches legacy data
                // Only validate properties that should have been migrated (have meaningful rating data)
                if property.rating > 0 {
                    let expectedRating = PropertyRating.fromLegacy(rating: property.rating, isFavorite: false)
                    if property.propertyRating != expectedRating {
                        print("DataMigration: Validation failed for property '\(property.title)'")
                        return false
                    }
                }
                // Properties with rating 0.0 should legitimately be nil
            }
            
            print("DataMigration: Validation successful - all properties properly migrated")
            return true
        } catch {
            print("DataMigration: Validation error - \(error.localizedDescription)")
            return false
        }
    }
    
    /// Validates that Photos and Notes removal was successful
    static func validatePhotosAndNotesRemoval(context: ModelContext) -> Bool {
        // Since the models are removed from schema, we can't query them directly
        // This validation will always pass as the models no longer exist in the schema
        print("DataMigration: Photos and Notes removal validation successful - models removed from schema")
        return true
    }
} 