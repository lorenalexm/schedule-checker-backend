//
//  CreateAssignment.swift
//  
//
//  Created by Alex Loren on 6/7/22.
//

import Fluent

struct CreateAssignment: AsyncMigration {
	// MARK: - Functions
	/// Creates the base `Assignment` schema within the database.
	/// - Parameter database: The database the migration will take place on.
	/// - Throws: Any errors thrown while creating the schema.
	func prepare(on database: Database) async throws {
		try await database.schema("assignments")
			.id()
			.field("agent", .string, .required)
			.field("address", .string, .required)
            .field("submittedOn", .datetime, .required)
			.field("scheduled", .bool, .required)
			.field("hidden", .bool, .required)
			.create()
	}
	
	
	/// Removes the `Assignment` schema from the database.
	/// - Parameter database: The database the migration will take place on.
	/// - Throws: Any errors thrown while creating the schema.
	func revert(on database: Database) async throws {
		try await database.schema("assignments").delete()
	}
}
