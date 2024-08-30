//
//  effective_mobileCoreDataManagerTests.swift
//  effective_mobileTests
//
//  Created by Vermut xxx on 30.08.2024.
//

import XCTest
@testable import effective_mobile

class CoreDataManagerTests: XCTestCase {

    var coreDataManager: CoreDataManager!

    override func setUpWithError() throws {
        coreDataManager = CoreDataManager.shared
    }

    override func tearDownWithError() throws {
        coreDataManager = nil
    }

    func testCreateToDo() throws {
        let title = "Test ToDo"
        let description = "Test Description"
        let date = Date()
        let isCompleted = false

        let expectation = self.expectation(description: "ToDo creation")

        coreDataManager.createToDo(title: title, description: description, createdDate: date, isCompleted: isCompleted) { result in
            switch result {
            case .success():
                XCTAssertTrue(true, "ToDo successfully created")
            case .failure(let error):
                XCTFail("ToDo creation failed with error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testDeleteToDo() throws {
        let title = "Test ToDo"
        let description = "Test Description"
        let date = Date()
        let isCompleted = false

        let expectation = self.expectation(description: "ToDo deletion")

        coreDataManager.createToDo(title: title, description: description, createdDate: date, isCompleted: isCompleted) { result in
            switch result {
            case .success():
                self.coreDataManager.fetchToDos { result in
                    switch result {
                    case .success(let toDos):
                        if let toDo = toDos.first(where: { $0.title == title }) {
                            self.coreDataManager.deleteToDo(toDo) { result in
                                switch result {
                                case .success():
                                    XCTAssertTrue(true, "ToDo successfully deleted")
                                case .failure(let error):
                                    XCTFail("ToDo deletion failed with error: \(error)")
                                }
                                expectation.fulfill()
                            }
                        } else {
                            XCTFail("ToDo not found")
                            expectation.fulfill()
                        }
                    case .failure(let error):
                        XCTFail("Fetching ToDos failed with error: \(error)")
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("ToDo creation failed with error: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
