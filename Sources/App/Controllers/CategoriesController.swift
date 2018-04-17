import Vapor

struct CategoriesController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let categoriesRoute = router.grouped("api", "categories")
        
        categoriesRoute.post(Category.self, use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
    }
    
    // CREATE
    func createHandler(_ request: Request, category: Category) throws -> Future<Category> {
        return category.save(on: request)
    }
    
    // GET ALL
    func getAllHandler(_ request: Request) throws -> Future<[Category]> {
        return Category.query(on: request).all()
    }
    
    // GET by ID
    func getHandler(_ request: Request) throws -> Future<Category> {
        return try request.parameter(Category.self)
    }
}
