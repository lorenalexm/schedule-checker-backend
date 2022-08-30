//
//  Configure.swift
//  
//
//  Created by Alex Loren on 6/8/22.
//

import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import Leaf
import Vapor

/// Configuration of the application environment.
/// - Parameter app: The `Application` object to be configured
/// - Throws: If fails to configure each `RouteCollection`.
public func configure(_ app: Application) throws {
    // Decoder configuration.
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            return date
        }
        throw DateError.invalidDate
    })
    ContentConfiguration.global.use(decoder: decoder, for: .json)
    
	// Database configuration.
	if app.environment == .testing {
		app.databases.use(.sqlite(.memory), as: .sqlite)
	} else {
        guard let host = Environment.get("DATABASE_HOST"),
              let port = Environment.get("DATABASE_PORT").flatMap(Int.init),
              let username = Environment.get("DATABASE_USERNAME"),
              let password = Environment.get("DATABASE_PASSWORD"),
              let database = Environment.get("DATABASE_NAME") else {
            fatalError("!!! Unable to get environmental variables for database.")
        }
        app.databases.use(.postgres(
            hostname: host,
            port: port,
            username: username,
            password: password,
            database: database
        ), as: .psql)
	}
	app.migrations.add(CreateAssignment())
	
	// Configure view renderer.
	app.views.use(.leaf)
	
	// Configure middleware.
	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
	
	// Register the routes.
	try app.register(collection: AssignmentController())
	try app.register(collection: CalendarEventController())
}
