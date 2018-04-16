import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    
    // register a new route at /api/acronyms that accepts a post request and return a Future<Acronym>, it will return an acronym once it is saved
    router.post("api", "acronyms") { request -> Future<Acronym> in
        
        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            
            // save the model using fluent and returning the acronym model once it is saved
            return acronym.save(on: request)
        }
    }

}
