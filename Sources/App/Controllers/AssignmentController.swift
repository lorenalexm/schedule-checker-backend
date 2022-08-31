//
//  AssignmentController.swift
//  
//
//  Created by Alex Loren on 6/8/22.
//

import Fluent
import Vapor

struct AssignmentController: RouteCollection {
	// MARK: - Functions
	/// Groups each `RequestController` route into a collection.
	/// - Parameter routes: A `RoutesBuilder` object.
	/// - Throws:
	func boot(routes: RoutesBuilder) throws {
		let api = routes.grouped("api")
		let assignments = api.grouped("assignments")
		assignments.get(use: get)
        assignments.get("all", use: all)
		assignments.get("hidden", use: hidden)
        assignments.get("scheduled", ":scheduled", use: scheduled)
		assignments.get(":id", use: single)
		assignments.post(use: create)
		assignments.post("batch", use: batchCreate)
		assignments.post(":id", "hide", ":hidden", use: hide)
        assignments.post(":id", "schedule", ":scheduled", use: schedule)
		//assignments.delete(":id", use: delete)
	}
    
    /// Fetches a limited number of `Assignment` objects from the database.
    /// - Parameter req: The `Request` object received.
    /// - Returns: An array of `Assignment` objects up to the given limit.
    func get(req: Request) async throws -> [Assignment] {
        return try await Assignment.query(on: req.db)
            .filter(\.$hidden == false)
            .limit(20)
            .sort(\.$submittedOn, .descending)
            .all()
    }
	
	/// Fetches all of the `Assignment` items from the database.
	/// - Parameter req: The `Request` object received.
	/// - Throws: If fails to query from the database.
	/// - Returns: An array of all the `Assignment` objects.
	func all(req: Request) async throws -> [Assignment] {
		try await Assignment.query(on: req.db)
			.filter(\.$hidden == false)
            .sort(\.$submittedOn, .descending)
			.all()
	}
	
    /// Fetches a limited number of `Assignment` objects from the database.
    /// These objects are all flagged as scheduled.
    /// - Parameter req: The `Request` object received.
    /// - Throws: If fails to query from the database.
    /// - Returns: An array of all the `Assignment` objects.
    func scheduled(req: Request) async throws -> [Assignment] {
        guard let rawScheduled = req.parameters.get("scheduled"),
            let scheduled = Bool(rawScheduled) else {
            throw Abort(.badRequest, reason: "No valid 'scheduled' parameter sent with request.")
        }
        
        return try await Assignment.query(on: req.db)
            .filter(\.$scheduled == scheduled)
            .limit(20)
            .sort(\.$submittedOn, .descending)
            .all()
    }
	
	/// Fetches all of the `Assignment` items marked as hidden.
	/// - Parameter req: The `Request` object received.
	/// - Returns: An array of all the hidden `Assignment` objects.
	func hidden(req: Request) async throws -> [Assignment] {
		try await Assignment.query(on: req.db)
			.filter(\.$hidden == true)
            .sort(\.$submittedOn, .descending)
			.all()
	}
	
	/// Fetches a signle `Assignment` object by it's `UUID`.
	/// - Parameter req: The `Request` object received.
	/// - Throws: `.badRequest` if no or invalid ID received.
	/// - Throws: `.notFound` if unable to location `Assignment` with given id.
	/// - Returns: A single `Assignment` object.
	func single(req: Request) async throws -> Assignment {
		guard let id = req.parameters.get("id"),
			  let uuid = UUID(uuidString: id) else {
			throw Abort(.badRequest, reason: "No valid 'id' parameter sent with request.")
		}
		
		let assignment = try await Assignment.find(uuid, on: req.db)
		guard let assignment = assignment else {
			throw Abort(.notFound)
		}
		
		return assignment
	}
	
	
	/// Creates a new `Assignment` object and saves it to the database.
    /// Will attempt to decode a single assignment, if failed will attempt to decode from an array.
	/// - Parameter req: The `Request` object received.
	/// - Returns: The newly created `Assignment`.
	func create(req: Request) async throws -> Assignment {
        do {
            let assignment = try req.content.decode(Assignment.self)
            try await assignment.save(on: req.db)
            return assignment
        } catch {
            do {
                let assignments = try req.content.decode([Assignment].self)
                let assignment = assignments[0]
                try await assignment.save(on: req.db)
                return assignment
            } catch {
                throw Abort(.badRequest)
            }
        }
	}
	
	
	/// Creates new `Assignment` objects and saves them into the database.
	/// - Parameter req: The `Request` object received.
	/// - Returns: An array of the newly created `Assignments`
	func batchCreate(req: Request) async throws -> [Assignment] {
		let assignments = try req.content.decode([Assignment].self)
		for (_, assignment) in assignments.enumerated() {
			try await assignment.save(on: req.db)
		}
		return assignments
	}
	
	
	/// Sets the hidden value of an `Assignment` object already within the database.
	/// - Parameter req: The `Request` object received
	/// - Returns: An `HTTPStatus` value reflecting the success of the update.
	func hide(req: Request) async throws -> HTTPStatus {
		guard let id = req.parameters.get("id"),
			  let uuid = UUID(uuidString: id) else {
			throw Abort(.badRequest, reason: "No valid 'id' parameter sent with request.")
		}
		
		guard let rawHide = req.parameters.get("hidden"),
			  let hide = Bool(rawHide) else {
			throw Abort(.badRequest, reason: "No valid 'hidden' parameter sent with request")
		}
		
		let assignment = try await Assignment.find(uuid, on: req.db)
		guard let assignment = assignment else {
			throw Abort(.notFound)
		}
		assignment.hidden = hide
		try await assignment.update(on: req.db)
        return .ok
	}
    
    /// Sets the scheduled value of an `Assignment` object already within the database.
    /// - Parameter req: The `Request` object received.
    /// - Returns: An `HTTPStatus` value reflecting the success of the update.
    func schedule(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id"),
              let uuid = UUID(uuidString: id) else {
            throw Abort(.badRequest, reason: "No valid 'id' parameter sent with request.")
        }
        
        guard let rawScheduled = req.parameters.get("scheduled"),
              let scheduled = Bool(rawScheduled) else {
            throw Abort(.badRequest, reason: "No valid 'scheduled' parameter sent with request")
        }
        
        let assignment = try await Assignment.find(uuid, on: req.db)
        guard let assignment = assignment else {
            throw Abort(.notFound)
        }
        assignment.scheduled = scheduled
        try await assignment.update(on: req.db)
        return .ok
    }
	
	/*
	/// Sets the hidden value of the `Assignment` object to `true`. Making the item appear deleted.
	/// - Parameter req: The `Request` object received.
	/// - Returns: An `HTTPStatus` value reflecting the success of the "deletion".
	func delete(req: Request) async throws -> HTTPStatus {
		guard let id = req.parameters.get("id"),
			  let uuid = UUID(uuidString: id) else {
			throw Abort(.badRequest, reason: "No valid 'id' parameter sent with request.")
		}
		
		let assignment = try await Assignment.find(uuid, on: req.db)
		guard let assignment = assignment else {
			throw Abort(.notFound)
		}
		assignment.hidden = true
		try await assignment.update(on: req.db)
		return .ok
	}
	*/
}
