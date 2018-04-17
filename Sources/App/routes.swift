import Routing
import Vapor
import Fluent

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // CREATE
    // register a new route at /api/acronyms that accepts a post request and return a Future<Acronym>, it will return an acronym once it is saved
    router.post("api", "acronyms") { request -> Future<Acronym> in
        
        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            
            // save the model using fluent and returning the acronym model once it is saved
            return acronym.save(on: request)
        }
    }
    
    // GET ALL
    // register a route that will return an [Acronym] to finish the asynch call
    router.get("api", "acronyms") { request -> Future<[Acronym]> in
        
        // get all acronyms and return it
        return Acronym.query(on: request).all()
    }
    
    // GET Single Acronym by ID
    // register a router that will return a single Acronym via ID at /api/acronyms/#id
    router.get("api", "acronyms", Acronym.parameter) { request -> Future<Acronym> in
        
        return try request.parameter(Acronym.self)
    }
    
    // UPDATE
    // register a route for a PUT to request to /api/acronym/#id that returns a Future<Acronym>
    router.put("api","acronyms", Acronym.parameter) { request -> Future<Acronym> in
        
        // dual future version of flatMap to wait both the parameter extraction, and decoding of the content we are sending to it, it will give us two data variables of the found acronym and the updated acronym objects
        return try flatMap(to:Acronym.self, request.parameter(Acronym.self), request.content.decode(Acronym.self)) {
            acronym, updatedAcronym in
            
            // update the found acronym with the updated model for saved acronym
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            
            return acronym.save(on: request)
        }
    }
    
    // DELETE
    // register a route for a DELETE reqeust to /api/acronyms/#id that returns a future,<HTTPStatus>
    router.delete("api", "acronyms", Acronym.parameter) { request -> Future<HTTPStatus> in
        
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
    router.get("api", "acronyms", "search") { request -> Future<[Acronym]> in
        
        // retrieve the search term from the URL query string.  You can do this with any Codable object by calling request.query.decode(_:).  If there is a failure it will throw a 400 Bad Request Error
        guard let searchTerm = request.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return try Acronym.query(on: request).group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
            }.all()
    }
    
    // SEARCH First
    // register a router for a get command at /api/acronyms/first that returns an acronym from the first acronym
    router.get("api", "acronyms", "first") { request -> Future<Acronym> in
        
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
    
    // SORTING RESULTS
    // register a router to /api/acronyms/sorted that returns a Future<[Acronym]>
    router.get("api", "acronyms", "sorted") { request -> Future<[Acronym]> in
        
        // create a query that sorts all short properties in .ascending order
        return try Acronym.query(on: request)
        .sort(\.short, .ascending)
        .all()
    }
}
