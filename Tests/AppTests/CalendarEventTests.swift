//
//  CalendarEventTests.swift
//  
//
//  Created by Alex Loren on 6/14/22.
//

@testable import App
import XCTVapor
import XCTest

final class CalendarEventTests: XCTestCase {
	// MARK: - Properties
	var app: Application!
	
	// MARK: - Overrides
	/// Prior to each test being ran, creates a new `Application` object.
	override func setUpWithError() throws {
		app = try Application.testable()
	}
	
	/// Shuts down the `Application` object after each test.
	override func tearDownWithError() throws {
		app.shutdown()
	}
	
	// MARK: - Functions
	/// Finds an existing assignment through a fuzzy search and sends a *confirmed* message.
	/// Verifies the correct assignment is found, and `Assignment.scheduled` is now `true`.
	func testConfirmedFuzzySearch() throws {
		var assignments: [Assignment] = []
		for _ in 0...10 {
			let fillerAssignment = try Assignment.create(on: app.db)
			assignments.append(fillerAssignment)
		}
		let assignment = try Assignment.create(agent: "Alex Loren", address: "317 North 19th Street", on: app.db)
		assignments.append(assignment)
		assignments.shuffle()
		let event = CalendarEvent(status: "confirmed", address: "317 N 19th St")
		
		try app.test(.POST, "/api/events/", beforeRequest: { req in
			try req.content.encode(event)
		}, afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let retrieved = try response.content.decode(Assignment.self)
			XCTAssertEqual(retrieved.id, assignment.id)
			XCTAssertEqual(retrieved.address, "317 North 19th Street")
			XCTAssertEqual(retrieved.scheduled, true)
		})
	}
	
	/// Finds an existing assignment through a fuzzy search, and sends a *deleted* message.
	/// Verifies the correct assignment is found, and `Assignment.scheduled` is now `false`.
	func testRescheduledFuzzySearch() throws {
		var assignments: [Assignment] = []
		for _ in 0...10 {
			let fillerAssignment = try Assignment.create(on: app.db)
			assignments.append(fillerAssignment)
		}
		let assignment = try Assignment.create(agent: "Alex Loren", address: "317 North 19th Street", on: app.db)
		assignments.append(assignment)
		assignments.shuffle()
		let event = CalendarEvent(status: "deleted", address: "317 N 19th St")
		
		try app.test(.POST, "/api/events/", beforeRequest: { req in
			try req.content.encode(event)
		}, afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let retrieved = try response.content.decode(Assignment.self)
			XCTAssertEqual(retrieved.id, assignment.id)
			XCTAssertEqual(retrieved.address, "317 North 19th Street")
			XCTAssertEqual(retrieved.scheduled, false)
		})
	}
}
