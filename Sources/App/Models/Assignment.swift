//
//  Assignment.swift
//  
//
//  Created by Alex Loren on 6/7/22.
//

import Fluent
import Vapor

final class Assignment: Model, Content {
	static let schema = "assignments"
	
	// MARK: - Properties
	@ID(key: .id)
	var id: UUID?
	@Field(key: "agent")
	var agent: String
	@Field(key: "address")
	var address: String
	@Field(key: "submittedOn")
	var submittedOn: Date
	@Field(key: "scheduled")
	var scheduled: Bool
	@Field(key: "hidden")
	var hidden: Bool
	
	// MARK: - Class initializers
	init() { }
	init(id: UUID? = nil, agent: String, address: String, submittedOn: Date,
		 scheduled: Bool, hidden: Bool) {
		self.id = id
		self.agent = agent
		self.address = address
		self.submittedOn = submittedOn
		self.scheduled = scheduled
		self.hidden = hidden
	}
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case agent = "agent"
		case address = "address"
		case submittedOn = "submittedOn"
		case scheduled = "scheduled"
		case hidden = "hidden"
	}
}
