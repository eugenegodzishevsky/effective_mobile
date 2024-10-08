//
//  ToDoListRouter.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import UIKit


// MARK: - Router

class ToDoListRouter {
    
    weak var viewController: UIViewController?
    
    static func assembleModule() -> UIViewController {
        let view = ToDoListViewController()
        let interactor = ToDoListInteractor()
        let router = ToDoListRouter()
        let presenter = ToDoListPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToAddToDo(rootPresenter: ToDoListPresenter) {
        let addToDoVC = AddToDoRouter.assembleModule(rootPresenter: rootPresenter)
        addToDoVC.modalPresentationStyle = .pageSheet
        viewController?.present(addToDoVC, animated: true, completion: nil)
    }
    
    func navigateToEditToDo(for toDo: ToDoItem, rootPresenter: ToDoListPresenter) {
        let editToDoVC = EditToDoRouter.assembleModule(toDoItem: toDo, rootPresenter: rootPresenter)
        editToDoVC.modalPresentationStyle = .pageSheet
        viewController?.present(editToDoVC, animated: true, completion: nil)
    }
}
