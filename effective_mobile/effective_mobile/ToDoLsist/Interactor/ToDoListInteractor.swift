//
//  ToDoListInteractor.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import Foundation

// MARK: - Protocols

protocol ToDoListInteractorInput {
    func fetchToDos()
    func addToDoItem(title: String, description: String, isCompleted: Bool)
    func updateToDoItem(toDo: ToDoItem, title: String, description: String, isCompleted: Bool)
    func deleteToDoItem(toDo: ToDoItem)
    func toggleComplete(_ toDo: ToDoItem)
}

protocol ToDoListInteractorOutput: AnyObject {
    func didFetchToDos(_ toDos: [ToDoItem])
    func didUpdateToDo()
    func didFailWithError(_ error: Error)
}

// MARK: - ToDoListInteractor

class ToDoListInteractor: ToDoListInteractorInput {
    weak var output: ToDoListInteractorOutput?

    func fetchToDos() {
        performBackgroundTask {
            if !UserDefaults.standard.bool(forKey: "hasFetchedToDos") {
                self.fetchFromAPI()
            } else {
                self.fetchFromCoreData()
            }
        }
    }

    func addToDoItem(title: String, description: String, isCompleted: Bool) {
        performBackgroundTask {
            CoreDataManager.shared.createToDo(
                title: title,
                description: description,
                createdDate: Date(),
                isCompleted: isCompleted,
                completion: self.handleCoreDataResult(_:))
        }
    }

    func updateToDoItem(toDo: ToDoItem, title: String, description: String, isCompleted: Bool) {
        performBackgroundTask {
            CoreDataManager.shared.updateToDo(
                toDo: toDo,
                title: title,
                description: description,
                isCompleted: isCompleted,
                completion: self.handleCoreDataResult(_:))
        }
    }

    func deleteToDoItem(toDo: ToDoItem) {
        performBackgroundTask {
            CoreDataManager.shared.deleteToDo(toDo, completion: self.handleCoreDataResult(_:))
        }
    }

    func toggleComplete(_ toDo: ToDoItem) {
        performBackgroundTask {
            CoreDataManager.shared.fetchToDo(with: toDo.id!) { result in
                switch result {
                case .success(let updatedToDo):
                    guard let updatedToDo = updatedToDo else { return }
                    updatedToDo.isCompleted.toggle()
                    CoreDataManager.shared.updateToDo(
                        toDo: updatedToDo,
                        title: updatedToDo.title ?? "",
                        description: updatedToDo.todoDescription ?? "",
                        isCompleted: updatedToDo.isCompleted,
                        completion: self.handleCoreDataResult(_:))
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }

    // MARK: - Private Helpers
    
    private func fetchFromAPI() {
        CoreDataManager.shared.firstFetchToDos { result in
            switch result {
            case .success(_):
                UserDefaults.standard.set(true, forKey: "hasFetchedToDos")
                self.outputOnMain {
//                    self.output?.didFetchToDos(todos)
                    self.output?.didUpdateToDo()
                }
            case .failure(let error):
                self.fetchFromCoreData(fallbackError: error)
            }
        }
    }
    
    private func fetchFromCoreData(fallbackError: Error? = nil) {
        CoreDataManager.shared.fetchToDos { result in
            switch result {
            case .success(let toDos):
                self.outputOnMain { self.output?.didFetchToDos(toDos) }
            case .failure(let error):
                if let fallbackError = fallbackError {
                    self.handleError(fallbackError)
                } else {
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleCoreDataResult(_ result: Result<Void, Error>) {
        outputOnMain {
            switch result {
            case .success:
                self.output?.didUpdateToDo()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }

    private func handleError(_ error: Error) {
        outputOnMain {
            self.output?.didFailWithError(error)
        }
    }

    private func outputOnMain(_ task: @escaping () -> Void) {
        DispatchQueue.main.async(execute: task)
    }

    private func performBackgroundTask(_ task: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async(execute: task)
    }
}

