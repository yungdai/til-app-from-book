import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
    
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

// this is the manual way of setting a model for sqlite
//extension Acronym: Model {
//
//    // tell the fluent database to use for this model, the template is already configured for SQLite
//    typealias Database = SQLiteDatabase
//
//    // tell fluent what type the ID is
//    typealias ID = Int
//
//    // tell fluent the key path of the model's ID property.
//    public static var idKey: IDKey = \Acronym.id
//}

// you can use this way to do it quickly
extension Acronym: PostgreSQLModel {}
extension Acronym: Content {}

// add type safety for parameters
extension Acronym: Parameter {}

// add User parent relationship to Acronyms
extension Acronym {
    
    // add a computered property to acronym to get the user object of the acronym's owner.  This returns fluent's generic Parent Type
    var user: Parent<Acronym, User> {
        // Users Flurent's parent function to retreive the parent.  This take the keypath of the user reference on the acronym.
        return parent(\.userID)
    }
}

extension Acronym: Migration {
    
    
    // add a function for foreign key constraints
    // impliment prepare(on
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        // create table for Acronym in the database
        return Database.create(self, on: connection) { builder in
            
            // add all the fields to the database for acronym.
            try addProperties(to: builder)
            
            // add reference between the userID propery on Acronym and the id properly on the User
            try builder.addReference(from: \.userID, to: \User.id)
        }
    }
    
    // add a categories sibling from the pivot
    // add a computered property to Acronym to get an acronym's categories.  This returns Fluent's generic Siblin type.   It returns the siblings of an acronym that are a type of Category and held usng the AcronymCategoriesPivot
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}
