import Vapor
import FluentPostgreSQL

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let userRoutes = router.grouped("api", "users")
        
        userRoutes.post(User.self, use: createHandler)
        userRoutes.get(use: getAllHandler)
        userRoutes.get(User.parameter, use: getHandler)
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
    
}
