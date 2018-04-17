import Vapor
import FluentPostgreSQL

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let userRoutes = router.grouped("api", "users")
        
        userRoutes.post(User.self, use: createHandler)
        userRoutes.get(use: getAllHandler)
        userRoutes.get(User.parameter, use: getHandler)
        userRoutes.get(User.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    // CREATE
    func createHandler(_ request: Request, user: User) throws -> Future<User> {
        return user.save(on: request)
    }
    
    // GET ALL
    func getAllHandler(_ request: Request) throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    // GET
    func getHandler(_ request: Request) throws -> Future<User> {
        return try request.parameter(User.self)
    }
    
    // GET Acronym from User
    func getAcronymsHandler(_ request: Request) throws -> Future<[Acronym]> {
        //  Feth the user specified in the request's paramaters and unwarp the returned future.
        return try request.parameter(User.self)
            .flatMap(to: [Acronym].self) { user in
                try user.acronyms.query(on: request).all()
        }
    }
}
