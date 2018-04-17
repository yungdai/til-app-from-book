import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    // set up the fluent PostgreSQLProvider
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // to create a new docker database for postgress use the following line
    // docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
    
    
    /// Info about deployment
    //    app: TIL
    //    git: https://github.com/yungdai/til-app-from-book.git
    //    env: production
    //    branch: master
    //    db: yes

    /// Configure the database for deployment on vapor cloud
    /// Register the configured SQLite database to the database config.
    
    // use database config to set up the database
    var databases = DatabaseConfig()
    
    // fetch environement variables set by Vapor Cloud.  If it's nil return the coalescing values
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    // user properties to create the config
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                                  port: 5432,
                                                  username: username,
                                                  database: databaseName,
                                                  password: password)
    
    // create a postgreSQL database using the configuration
    let database = PostgreSQLDatabase(config: databaseConfig)

    // add the dtabase object to the DatabaseConfig using the Configuration
    databases.add(database: database, as: .psql)
    
    // register the databaseConfig services
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    
    // changed to postgreSQL
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    services.register(migrations)
}
