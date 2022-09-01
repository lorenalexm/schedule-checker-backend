//
//  AssignmentTests.swift
//  
//
//  Created by Alex Loren on 6/8/22.
//

@testable import App
import XCTVapor
import Foundation

final class AssignmentTests: XCTestCase {
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
	/// Retrieves a newly created assignment from the database.
	/// Verifies that assignment information matches.
	func testAssignmentsCanBeRetrievedFromAPI() throws {
		let assignment = try Assignment.create(on: app.db)
		try app.test(.GET, "/api/assignments/", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let assignments = try response.content.decode([Assignment].self)
			XCTAssertEqual(assignments.count, 1)
			XCTAssertEqual(assignments[0].id, assignment.id)
			XCTAssertEqual(assignments[0].agent, assignment.agent)
		})
	}
    
    /// Retreives a limited number of assignments from the database.
    /// Verifies that the number retrieved does not excede the limit.
    func testLimitedAssignmentsRetrievedFromAPI() throws {
        var assignments: [Assignment] = []
        for _ in 0...30 {
            let date = Date.randomBetween(start: "2022-01-01", end: "2022-09-15")
            let newAssignment = try Assignment.create(submittedOn: date, scheduled: false, hidden: false, on: app.db)
            assignments.append(newAssignment)
        }
        
        try app.test(.GET, "/api/assignments", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retreived = try response.content.decode([Assignment].self)
            XCTAssertEqual(retreived.count, 25)
        })
    }
    
    /// Verifies that only unscheduled assignments are retreived from the database.
    func testUnscheduledAssignmentsRetrievedFromAPI() throws {
        var assignments: [Assignment] = []
        for index in 0...20 {
            let date = Date.randomBetween(start: "2022-01-01", end: "2022-09-15")
            let newAssignment = try Assignment.create(submittedOn: date, scheduled: index.isMultiple(of: 2), hidden: index.isMultiple(of: 3), on: app.db)
            assignments.append(newAssignment)
        }
        
        try app.test(.GET, "/api/assignments/scheduled/false", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retreived = try response.content.decode([Assignment].self)
            XCTAssertEqual(retreived.count, 7)
            let hidden = retreived.filter({ $0.hidden == true })
            XCTAssertEqual(hidden.count, 0)
        })
    }
    
    /// Verifies that only scheduled assignments are retreived from the database.
    func testScheduledAssignmentsRetrievedFromAPI() throws {
        var assignments: [Assignment] = []
        for index in 0...20 {
            let date = Date.randomBetween(start: "2022-01-01", end: "2022-09-15")
            let newAssignment = try Assignment.create(submittedOn: date, scheduled: !index.isMultiple(of: 2), hidden: index.isMultiple(of: 3), on: app.db)
            assignments.append(newAssignment)
        }
        
        try app.test(.GET, "/api/assignments/scheduled/true", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retreived = try response.content.decode([Assignment].self)
            XCTAssertEqual(retreived.count, 7)
            let hidden = retreived.filter({ $0.hidden == true })
            XCTAssertEqual(hidden.count, 0)
        })
    }
    
    /// Retreives all of the assignments from the database.
    /// Verifies the retreived assignment counts equals the created assignment count.
    func testAllAssignmentsRetreivedFromAPI() throws {
        var assignments: [Assignment] = []
        for _ in 0...20 {
            let date = Date.randomBetween(start: "2022-01-01", end: "2022-09-15")
            let newAssignment = try Assignment.create(submittedOn: date, scheduled: false, hidden: false, on: app.db)
            assignments.append(newAssignment)
        }
        
        try app.test(.GET, "/api/assignments/all", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retreived = try response.content.decode([Assignment].self)
            XCTAssertEqual(retreived.count, assignments.count)
        })
    }
    
    /// Tests creating an assignment when wrapped within a JSON array, and not a single object.
    func testCreateSingleAssignmentFromArray() throws {
        var assignments: [Assignment] = []
        let newAssignment = Assignment(agent: "Alex Loren", address: "4230 E Evergreen Drive", submittedOn: Date(), scheduled: false, hidden: false)
        assignments.append(newAssignment)
        
        try app.test(.POST, "/api/assignments/", beforeRequest: { req in
            try req.content.encode(assignments)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }
	
	/// Retrieves all hidden assignments from the database.
	/// Verifies that hidden assignment count matches.
	func testOnlyHiddenAssignmentsRetrievedFromAPI() throws {
		var assignments: [Assignment] = []
		for _ in 0...10 {
            let date = Date.randomBetween(start: "2022-01-01", end: "2022-09-15")
			let newAssignment = try Assignment.create(submittedOn: date, scheduled: false, hidden: (Int.random() % 2 == 0) ? true : false, on: app.db)
			assignments.append(newAssignment)
		}
		let hiddenCount = assignments.filter { $0.hidden == true }.count
		
		try app.test(.GET, "/api/assignments/hidden", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let assignments = try response.content.decode([Assignment].self)
			XCTAssertEqual(assignments.count, hiddenCount)
		})
	}
		
	/// Retrieves a specific assignment by a given ID.
	func testRetrievingAssignmentByID() throws {
		let assignment = try Assignment.create(on: app.db)
		
		try app.test(.GET, "/api/assignments/\(assignment.id!)", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let retrieved = try response.content.decode(Assignment.self)
			XCTAssertEqual(retrieved.id, assignment.id)
		})
	}
	
	/// Verifies that invalid JSON will not result in a newly created assignment.
	func testCreatingInvalidAssignment() throws {
		let invalidJson = #"{ "id": "DD3DDC12-7827-44F8-9D0E-F6B7A17D0305", "agent": "John Thomas Sinclair", "address": 1124, "submittedOn": "2022-06-06T17:59:47.892Z", "scheduled": 1, "hidden": false }"#
		var count = 0

		try app.test(.GET, "/api/assignments/hidden", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let assignments = try response.content.decode([Assignment].self)
			count = assignments.count
		})
		
		try app.test(.POST, "/api/assignments/", beforeRequest: { req in
			req.headers.contentType = .json
			try req.body.writeJSONEncodable(invalidJson)
		}, afterResponse: { response in
			XCTAssertEqual(response.status, .badRequest)
		})
		
		try app.test(.GET, "/api/assignments/hidden", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let assignments = try response.content.decode([Assignment].self)
			XCTAssertEqual(assignments.count, count)
		})
	}
    
    /// Creates a new assignment by posting JSON to the endpoint.
    /// Verifies the newly created assignment machtes.
    func testCreatingAssignmentWithJson() throws {
        let json = #"{ "agent": "Desiree Staples", "hidden": false, "address": "260 highland ave", "scheduled": false, "submittedOn": "2022-08-28T15:51:56.590Z" }"#
        try app.test(.POST, "/api/assignments/", beforeRequest: { req in
            req.headers.contentType = .json
            req.body.writeString(json)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retrieved = try response.content.decode(Assignment.self)
            XCTAssertNotNil(retrieved.id)
            XCTAssertEqual(retrieved.agent, "Desiree Staples")
            XCTAssertEqual(retrieved.address, "260 highland ave")
            XCTAssertEqual(retrieved.scheduled, false)
        })
        
        try app.test(.GET, "/api/assignments/", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let assignments = try response.content.decode([Assignment].self)
            XCTAssertEqual(assignments.count, 1)
        })
    }
    
    /// Verifies that the assignments are returned ordered newest to oldest.
    func testAssignmentsOrderedCorrectly() throws {
        var assignments: [Assignment] = []
        for _ in 0...10 {
            let date = Date.randomBetween(start: "2022-01-01", end: "2022-09-15")
            let newAssignment = try Assignment.create(submittedOn: date, scheduled: false, hidden: false, on: app.db)
            assignments.append(newAssignment)
        }
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: "2022-10-01T00:00:00Z")!
        let newestAssignment = try Assignment.create(submittedOn: date, scheduled: false, hidden: false, on: app.db)
        assignments.append(newestAssignment)
        assignments.shuffle()
        
        try app.test(.GET, "/api/assignments", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retreived = try response.content.decode([Assignment].self)
            XCTAssertEqual(retreived[0].submittedOn, newestAssignment.submittedOn)
        })
    }
	
	/// Creates a new assignment.
	/// Verifies the newly created assignment matches.
	func testCreatingValidAssignment() throws {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: "2022-06-06T17:59:47Z")!
		let assignment = Assignment(id: UUID(), agent: "John Thomas Sinclair", address: "317 N 19th Street, CdA", submittedOn: date, scheduled: false, hidden: false)
		
		try app.test(.POST, "/api/assignments/", beforeRequest: { req in
			try req.content.encode(assignment)
		}, afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let retrieved = try response.content.decode(Assignment.self)
			XCTAssertEqual(retrieved.id, assignment.id)
			XCTAssertEqual(retrieved.agent, assignment.agent)
			XCTAssertEqual(retrieved.address, assignment.address)
			XCTAssertEqual(retrieved.scheduled, assignment.scheduled)
		})
		
		try app.test(.GET, "/api/assignments/", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let assignments = try response.content.decode([Assignment].self)
			XCTAssertEqual(assignments.count, 1)
		})
	}
	
	/// Creates multiple new assignments through a batch processed array.
	/// Verifies all of these assignments match.
	func testCreatingMultipleAssignments() throws {
		var assignments: [Assignment] = []
		for _ in 0...10 {
			let fillerAssignment = try Assignment.create()
			assignments.append(fillerAssignment)
		}
		
		try app.test(.POST, "/api/assignments/batch/", beforeRequest: { req in
			try req.content.encode(assignments)
		}, afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let retrieved = try response.content.decode([Assignment].self)
			XCTAssertEqual(retrieved.count, assignments.count)
		})
		
		try app.test(.GET, "/api/assignments/", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
			
			let retrievedAssignments = try response.content.decode([Assignment].self)
			XCTAssertEqual(retrievedAssignments.count, assignments.count)
		})
	}
	
	/// Updates the `Assignment.hidden` status of a newly created assignment.
	/// Verifies this update is saved.
	func testUpdatingHiddenStatus() throws {
		let assignment = try Assignment.create(on: app.db)
		
		try app.test(.POST, "/api/assignments/\(assignment.id!)/hide/true", afterResponse: { response in
			XCTAssertEqual(response.status, .ok)
		})
        
        try app.test(.GET, "/api/assignments/\(assignment.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retrieved = try response.content.decode(Assignment.self)
            XCTAssertEqual(retrieved.id, assignment.id)
            XCTAssertEqual(retrieved.hidden, true)
        })
	}
    
    /// Updates the `Assignment.scheduled` status of a newly created assignment.
    /// Verifies this update is saved.
    func testUpdatingScheduledStatus() throws {
        let assignment = try Assignment.create(on: app.db)
        
        try app.test(.POST, "/api/assignments/\(assignment.id!)/schedule/true", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
        
        try app.test(.GET, "/api/assignments/\(assignment.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let retrieved = try response.content.decode(Assignment.self)
            XCTAssertEqual(retrieved.id, assignment.id)
            XCTAssertEqual(retrieved.scheduled, true)
        })
    }
}
