//
//  CalendarEvent.swift
//  
//
//  Created by Alex Loren on 6/13/22.
//

import Fluent
import Vapor

final class CalendarEvent: Content {
	static let schema = "calendarEvent"
	
	// MARK: - Properties
	// Possible values for status are "confirmed", "tentative", and "cancelled"
	var status: String
	var address: String
	
	// MARK: - Class initializers
	init(status: String, address: String) {
		self.status = status
		self.address = address
	}
}
