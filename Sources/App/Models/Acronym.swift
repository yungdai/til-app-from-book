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
extension Acronym: Migration {}
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
