//
//  AddToDoRouter.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import UIKit


// MARK: - Router

class AddToDoRouter {
    
    weak var viewController: UIViewController?
    
    static func assembleModule(rootPresenter: ToDoListPresenter) -> UIViewController {
        let view = AddToDoViewController()
        let interactor = AddToDoInteractor()
        let presenter = AddToDoPresenterImpl(view: view, interactor: interactor)
        let router = AddToDoRouter()
        
        view.presenter = presenter
        view.rootPresenter = rootPresenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}
