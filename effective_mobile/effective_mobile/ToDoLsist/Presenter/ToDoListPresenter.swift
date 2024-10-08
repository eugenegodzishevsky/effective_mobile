//
//  ToDoListPresenter.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import Foundation

// MARK: - Protocols

protocol ToDoListView: AnyObject {
    func showToDos(_ toDos: [ToDoItem])
    func showError(_ error: Error)
}

protocol ToDoListPresenterInput {
    func viewDidLoad()
    func fetchToDos()
    func showAddToDo()
    func showEditToDo(for toDo: ToDoItem)
    func deleteToDoItem(_ toDo: ToDoItem)
    func toggleComplete(_ toDo: ToDoItem)
}


// MARK: - Presenter

class ToDoListPresenter {
    
    weak var view: ToDoListView?
    var interactor: ToDoListInteractorInput?
    var router: ToDoListRouter?
    
    init(view: ToDoListView, interactor: ToDoListInteractorInput, router: ToDoListRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}


// MARK: - Interactor Input

extension ToDoListPresenter: ToDoListPresenterInput {
    func viewDidLoad() {
        fetchToDos()
    }
    
    func fetchToDos() {
        interactor?.fetchToDos()
    }
    
    func showAddToDo() {
        router?.navigateToAddToDo(rootPresenter: self)
    }
    
    func showEditToDo(for toDo: ToDoItem) {
        router?.navigateToEditToDo(for: toDo, rootPresenter: self)
    }
    
    func deleteToDoItem(_ toDo: ToDoItem) {
        interactor?.deleteToDoItem(toDo: toDo)
    }
    
    func toggleComplete(_ toDo: ToDoItem) {
        interactor?.toggleComplete(toDo)
    }
}


// MARK: - Interactor Output

extension ToDoListPresenter: ToDoListInteractorOutput {
    func didFailWithError(_ error: Error) {
        view?.showError(error)
    }
    
    func didFetchToDos(_ toDos: [ToDoItem]) {
        view?.showToDos(toDos)
    }
    
    func didUpdateToDo() {
        fetchToDos()
    }
}
