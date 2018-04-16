import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
    
    var id: Int?
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
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
