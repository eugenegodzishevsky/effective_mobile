//
//  AddToDoPresenter.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import Foundation

// MARK: - Protocols

protocol AddToDoPresenterInput: AnyObject {
    func saveToDo(title: String, description: String)
}


// MARK: - Presenter

class AddToDoPresenterImpl: AddToDoPresenterInput {
    
    private weak var view: AddToDoView?
    private let interactor: AddToDoInteractorInput
    
    init(view: AddToDoView, interactor: AddToDoInteractorInput) {
        self.view = view
        self.interactor = interactor
    }
    
    func saveToDo(title: String, description: String) {
        interactor.addToDoItem(title: title, description: description)
    }
}


// MARK: - AddToDoInteractorOutput

extension AddToDoPresenterImpl: AddToDoInteractorOutput {
    func didAddToDo() {
        view?.displaySuccess()
    }
    
    func didFailToAddToDo(with error: Error) {
        view?.displayError(error.localizedDescription)
    }
}
