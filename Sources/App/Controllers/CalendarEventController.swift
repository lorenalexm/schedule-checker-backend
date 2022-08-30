//
//  CalendarEventController.swift
//  
//
//  Created by Alex Loren on 6/13/22.
//

import Fluent
import Vapor
import Fuse

struct CalendarEventController: RouteCollection {
	enum CalendarEventErrors: Error {
		case notFound
	}
	
	// MARK: - Functions
	/// Groups each `RequestController` route into a collection.
	/// - Parameter routes: A `RoutesBuilder` object.
	/// - Throws:
	func boot(routes: RoutesBuilder) throws {
		let api = routes.grouped("api")
		let events = api.grouped("events")
		events.post(use: update)
	}
	
	
	/// Updates the status of a `Assignment` with a matching location.
	/// - Parameter req: The `Request` object received.
	func update(req: Request) async throws -> Assignment {
		var event: CalendarEvent
		do {
			event = try req.content.decode(CalendarEvent.self)
		} catch {
			throw Abort(.badRequest, reason: "Did not receive a valid CalendarEvent!")
		}
		
		let assignments = try await Assignment.query(on: req.db).all()
		let addresses = assignments.map { $0.address }
		let assignmentIndex = await search(for: event.address, in: addresses)
		
		guard let assignment = assignments[optional: assignmentIndex] else {
			throw Abort(.notFound, reason: "Unable to find Assignment within the Database!")
		}
		
		switch event.status {
		case "confirmed":
			assignment.scheduled = true
		default:
			assignment.scheduled = false
		}
		
		try await assignment.update(on: req.db)
		return assignment
	}
	
	
	/// Searches for a string within an array using fuzzy matching
	/// - Parameters:
	///   - address: The address to be searched for.
	///   - addresses: An array of addresses to be iterated through.
	/// - Returns: The index of the matched address within the array.
	func search(for address: String, in addresses: [String]) async -> Int {
		return await withCheckedContinuation { continuation in
			var highestScore = 0.0
			var addressIndex = -1
			let fuse = Fuse()
			let results = fuse.search(address, in: addresses)
			results.forEach { result in
				if result.score > highestScore {
					highestScore = result.score
					addressIndex = result.index
				}
			}
			continuation.resume(returning: addressIndex)
		}
	}
	
	// MARK: EventLoopFuture
	/*
	func find(req: Request) throws -> EventLoopFuture<Assignment> {
		var event: CalendarEvent
		do {
			event = try req.content.decode(CalendarEvent.self)
		} catch {
			throw Abort(.badRequest, reason: "Did not receive a valid CalendarEvent!")
		}
		
		return Assignment.query(on: req.db).all().flatMap { (assignments: [Assignment]) -> EventLoopFuture<Assignment> in
			let addresses = assignments.map { $0.address }

			return search(for: event.address, within: addresses, on: req.eventLoop).flatMapThrowing { (result: Int) -> Assignment in
				guard let assignment = assignments[optional: result] else {
					throw Abort(.notFound, reason: "Unable to find Assignment within the database.")
				}
				
				switch event.status {
				case "confirmed":
					assignment.scheduled = true
				default:
					assignment.scheduled = false
				}
				
				let _ = assignment.update(on: req.db)
				return assignment
			}
		}
	}
	
	func search(for eventAddress: String, within addresses: [String], on eventLoop: EventLoop) -> EventLoopFuture<Int> {
		let promise: EventLoopPromise<Int> = eventLoop.makePromise()
		var highestScore = 0
		var addressIndex = -1
		
		print("### Address to search for: \(eventAddress)")
		for (index, address) in addresses.enumerated() {
			print("### Address from database to compare: \(address)")
			print("### The match: \(bestMatch(query: eventAddress, input: address))")
			if let alignment = bestMatch(query: eventAddress, input: address) {
				print("## The score for \(address) is: \(alignment.score.value)")
				if alignment.score.value > highestScore {
					highestScore = alignment.score.value
					addressIndex = index
				}
			} else {
				print("### No alignment!")
			}
		}
		promise.succeed(addressIndex)
		
		return promise.futureResult
	}
	*/
}
