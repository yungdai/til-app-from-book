import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        // create an acronym router that is gouped, so you don't always have to type ("api", "acronyms") for the route
        let acronymRoutes = router.grouped("api", "acronyms")
        
        acronymRoutes.post(Acronym.self, use: createHandler)
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.get(Acronym.parameter, use: getHandler)
        acronymRoutes.put(Acronym.parameter, use: updateHandler)
        acronymRoutes.delete(Acronym.parameter, use: deleteHandler)
        acronymRoutes.get("search", use: searchHandler)
        acronymRoutes.get("first", use: getFirstHandler)
        acronymRoutes.get("sort", use: sortHandler)
        acronymRoutes.get(Acronym.parameter, "user", use: getUserHandler)
    }
    
    // CREATE
    func createHandler(_ request: Request, acronym: Acronym) throws -> Future<Acronym> {

        return acronym.save(on: request)
    }

    // GET ALL
    // register a route that will return an [Acronym] to finish the asynch call
    func getAllHandler(_ request: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: request).all()
    }
    
    // GET Single Acronym by ID
    // register a router that will return a single Acronym via ID at /api/acronyms/#id
    func getHandler(_ request: Request) throws -> Future<Acronym> {
        return try request.parameter(Acronym.self)
    }
    
    // UPDATE
    // register a route for a PUT to request to /api/acronym/#id that returns a Future<Acronym>
    func updateHandler(_ request: Request) throws -> Future<Acronym> {
        
        // dual future version of flatMap to wait both the parameter extraction, and decoding of the content we are sending to it, it will give us two data variables of the found acronym and the updated acronym objects
        return try flatMap(to:Acronym.self, request.parameter(Acronym.self), request.content.decode(Acronym.self)) {
            acronym, updatedAcronym in
            
            // update the found acronym with the updated model for saved acronym
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            
            return acronym.save(on: request)
        }
    }
    
    // DELETE
    // register a route for a DELETE reqeust to /api/acronyms/#id that returns a future,<HTTPStatus>
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        
        // extract the acronym from the request parameter (#id)
        return try request.parameter(Acronym.self)
            .flatMap(to: HTTPStatus.self) { acronym in
                
                // delete the acronym using the .delete(on:) fuction and transform the response to a 204 No Content answer since it's successfully deleted and no longer there.
                return acronym.delete(on: request)
                    .transform(to: HTTPStatus.noContent)
        }
    }
    
    // SEARCH
    // register a router for a GET at /api/acronyms/search  returns a Future<[Acronym]>
    func searchHandler(_ request: Request) throws -> Future<[Acronym]> {
        
        // retrieve the search term from the URL query string.  You can do this with any Codable object by calling request.query.decode(_:).  If there is a failure it will throw a 400 Bad Request Error
        guard let searchTerm = request.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        // using the group(.or) to group the query together to querey several different paramters in Acronym
        return try Acronym.query(on: request).group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
            }.all()
    }
    
    // GET FIRST
    // register a router for a get command at /api/acronyms/first that returns an acronym from the first acronym
    func getFirstHandler(_ request: Request) throws -> Future<Acronym> {
        
        // perform a querey for the first acronym and then use map to unwrap the result of the query which will return a acronym.
        return Acronym.query(on: request).first().map(to: Acronym.self) { acronym in
            
            // if the there is no acronym (because acronym is a nil) then throw a 404 Not Found Error
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            
            // return the found acronym
            return acronym
        }
    }
    
    // SORT RESULTS
    // register a router to /api/acronyms/sorted that returns a Future<[Acronym]>
    func sortHandler(_ request: Request) throws -> Future<[Acronym]> {
        
        // create a query that sorts all short properties in .ascending order
        return try Acronym.query(on: request)
        .sort(\.short, .ascending)
        .all()
    }
    
    // GET User
    func getUserHandler(_ request: Request) throws -> Future<User> {
        
        
        // find a Acronym by number
        return try request.parameter(Acronym.self)
            .flatMap(to: User.self) { acronym in
                // return a user from the retrieved acronym
                try acronym.user.get(on: request)
        }
    }
}
