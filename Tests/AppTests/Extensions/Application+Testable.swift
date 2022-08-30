//
//  Application+Testable.swift
//  
//
//  Created by Alex Loren on 6/8/22.
//

import XCTVapor
import App

extension Application {
	/// Creates an `Application` object with a `.testing` environment.
	/// Reverts and reruns database migrations when called.
	/// - Returns: The newly created `Application`.
	static func testable() throws -> Application {
		let app = Application(.testing)
		try configure(app)
		
		try app.autoRevert().wait()
		try app.autoMigrate().wait()
		
		return app
	}
}
