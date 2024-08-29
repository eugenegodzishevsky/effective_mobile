//
//  AddToDoInteractor.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import Foundation

// MARK: - Protocols

protocol AddToDoInteractorInput {
    func addToDoItem(title: String, description: String)
}

protocol AddToDoInteractorOutput: AnyObject {
    func didAddToDo()
    func didFailToAddToDo(with error: Error)
}


// MARK: - Interactor

class AddToDoInteractor: AddToDoInteractorInput {
    weak var output: AddToDoInteractorOutput?
    
    func addToDoItem(title: String, description: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            CoreDataManager.shared.createToDo(title: title, description: description, createdDate: Date(), isCompleted: false) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.output?.didAddToDo()
                    case .failure(let error):
                        self?.output?.didFailToAddToDo(with: error)
                    }
                }
            }
        }
    }
}
