import FluentPostgreSQL
import Foundation

// new class that conformed to PostgreSQLUUIDPivot
final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
    
    // a pivot must have a UUID
    var id: UUID?
    
    // define two properties to link to the ID's of the two tables we want to link with a pivot
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    // define Left and Right types required by the pivot protocol
    typealias Left = Acronym
    typealias Right = Category
    
    // tell fluent the key path of the two ID properties for each side of the relationship
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

extension AcronymCategoryPivot: Migration {}
