//
//  Models+Testable.swift
//  
//
//  Created by Alex Loren on 6/13/22.
//

@testable import App
import Fluent
import Fakery
import Foundation

extension Assignment {
	/// Attempts to create an `Assignment` object with faked information. Does *not* save to database.
	/// - Parameters:
	///   - submittedOn: The date and time when the assignment was submitted.
	///   - scheduled: Is this assignment scheduled?
	///   - hidden: Should this assignment be hidden?
	///   - database: The database to save the `Assignment` object to.
	/// - Returns: The newly created `Assignment`.
	static func create(
        submittedOn: Date = ISO8601DateFormatter().date(from: "2022-01-31T02:22:40Z")!,
		scheduled: Bool = false,
		hidden: Bool = false
	) throws -> Assignment {
		let faker = Faker(locale: "en-US")
		let assignment = Assignment(agent: faker.name.name(),
									address: "\(faker.address.streetAddress(includeSecondary: false)) \(faker.address.city()) \(faker.address.stateAbbreviation())",
									submittedOn: submittedOn,
									scheduled: scheduled,
									hidden: hidden)
		
		return assignment
	}
	
	/// Attempts to create an `Assignment` object with faked information and save it to the database.
	/// - Parameters:
	///   - submittedOn: The date and time when the assignment was submitted.
	///   - scheduled: Is this assignment scheduled?
	///   - hidden: Should this assignment be hidden?
	///   - database: The database to save the `Assignment` object to.
	/// - Returns: The newly created `Assignment`.
	static func create(
		submittedOn: Date = ISO8601DateFormatter().date(from: "2022-01-31T02:22:40Z")!,
		scheduled: Bool = false,
		hidden: Bool = false,
		on database: Database
	) throws -> Assignment {
		let faker = Faker(locale: "en-US")
		let assignment = Assignment(agent: faker.name.name(),
									address: "\(faker.address.streetAddress(includeSecondary: false)) \(faker.address.city()) \(faker.address.stateAbbreviation())",
									submittedOn: submittedOn,
									scheduled: scheduled,
									hidden: hidden)
		
		try assignment.save(on: database).wait()
		return assignment
	}
	
	/// Attempts to create an `Assignment` object and save it to the database.
	/// - Parameters:
	///   - agent: The agent name.
	///   - address: The address of the property.
	///   - submittedOn: The date and time when the assignment was submitted.
	///   - scheduled: Is this assignment scheduled?
	///   - hidden: Should this assignment be hidden?
	///   - database: The database to save the `Assignment` object to.
	/// - Returns: The newly created `Assignment`.
	static func create(
		agent: String,
		address: String,
		submittedOn: Date = ISO8601DateFormatter().date(from: "2022-01-31T02:22:40Z")!,
		scheduled: Bool = false,
		hidden: Bool = false,
		on database: Database
	) throws -> Assignment {
		let assignment = Assignment(agent: agent,
									address: address,
									submittedOn: submittedOn,
									scheduled: scheduled,
									hidden: hidden)
		
		try assignment.save(on: database).wait()
		return assignment
	}
}
