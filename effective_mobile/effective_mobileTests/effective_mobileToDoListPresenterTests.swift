//
//  effective_mobileToDoListPresenterTests.swift
//  effective_mobileTests
//
//  Created by Vermut xxx on 30.08.2024.
//

import XCTest
@testable import effective_mobile
import CoreData

class ToDoListPresenterTests: XCTestCase {

    var presenter: ToDoListPresenter!
    var viewMock: ToDoListViewMock!
    var interactorMock: ToDoListInteractorMock!
    var routerMock: ToDoListRouterMock!
    var mockContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        let container = NSPersistentContainer(name: "effective_mobile")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        mockContext = container.newBackgroundContext()
        
        viewMock = ToDoListViewMock()
        interactorMock = ToDoListInteractorMock(context: mockContext)
        routerMock = ToDoListRouterMock()

        presenter = ToDoListPresenter(view: viewMock, interactor: interactorMock, router: routerMock)
        interactorMock.output = presenter // Устанавливаем output для interactorMock
    }

    override func tearDownWithError() throws {
        presenter = nil
        viewMock = nil
        interactorMock = nil
        routerMock = nil
        mockContext = nil
    }

    func testFetchToDosSuccess() {
        let todos = createMockToDoItems()
        interactorMock.toDos = todos
        
        presenter.fetchToDos()
        
        XCTAssertTrue(viewMock.didShowToDos, "View should show todos")
        XCTAssertEqual(viewMock.toDos.count, todos.count, "Fetched todos should match")
        
        guard let firstTodo = viewMock.toDos.first else {
            XCTFail("No todos were fetched")
            return
        }
        
        XCTAssertEqual(firstTodo.title, "Test", "Fetched todo title should match")
        XCTAssertEqual(firstTodo.todoDescription, "Test Description", "Fetched todo description should match")
    }

    private func createMockToDoItems() -> [ToDoItem] {
        let item1 = ToDoItem(context: mockContext)
        item1.id = UUID()
        item1.title = "Test"
        item1.todoDescription = "Test Description"
        item1.isCompleted = false
        
        let item2 = ToDoItem(context: mockContext)
        item2.id = UUID()
        item2.title = "Another Test"
        item2.todoDescription = "Another Description"
        item2.isCompleted = true
        
        // Ensure changes are saved
        do {
            try mockContext.save()
        } catch {
            XCTFail("Failed to save mock context: \(error)")
        }
        
        return [item1, item2]
    }
}

class ToDoListViewMock: ToDoListView {
    var didShowToDos = false
    var didShowError = false
    var toDos = [ToDoItem]()
    var error: Error?

    func showToDos(_ toDos: [ToDoItem]) {
        didShowToDos = true
        self.toDos = toDos
    }

    func showError(_ error: Error) {
        didShowError = true
        self.error = error
    }
}

class ToDoListInteractorMock: ToDoListInteractorInput {
    var toDos: [ToDoItem] = []
    var error: Error?
    weak var output: ToDoListInteractorOutput?
    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchToDos() {
        if let error = error {
            output?.didFailWithError(error)
        } else {
            output?.didFetchToDos(toDos)
        }
    }

    func addToDoItem(title: String, description: String, isCompleted: Bool) {}
    func updateToDoItem(toDo: ToDoItem, title: String, description: String, isCompleted: Bool) {}
    func deleteToDoItem(toDo: ToDoItem) {}
    func toggleComplete(_ toDo: ToDoItem) {}
}

class ToDoListRouterMock: ToDoListRouter {}
