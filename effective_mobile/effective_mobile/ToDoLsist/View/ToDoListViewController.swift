//
//  ToDoListViewController.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import UIKit

class ToDoListViewController: UIViewController {
    
    var presenter: ToDoListPresenter?
    var toDos: [ToDoItem] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ToDoTableViewCell.self, forCellReuseIdentifier: ToDoTableViewCell.identifier)
        return table
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ToDo List"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        presenter?.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToDo))
        navigationItem.rightBarButtonItem = addButton
        
        fetchToDos()
    }
    
    @objc private func fetchToDos() {
        activityIndicator.startAnimating()
        presenter?.fetchToDos()
    }
    
    @objc private func addToDo() {
        presenter?.showAddToDo()
    }
    
    private func stopLoading() {
        activityIndicator.stopAnimating()
    }
}

// MARK: - ToDoListView

extension ToDoListViewController: ToDoListView {
    func showToDos(_ toDos: [ToDoItem]) {
        self.toDos = toDos
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            self.stopLoading()
        }
    }
    
    func showError(_ error: Error) {
        DispatchQueue.main.async {
            self.stopLoading()
            print("Error showing todos: \(error.localizedDescription)")
        }
    }
}


// MARK: -  UITableViewDataSource

extension ToDoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTableViewCell.identifier, for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let todo = toDos[indexPath.row]
        cell.configure(with: todo)
        return cell
    }
}


// MARK: - UITableViewDelegate

extension ToDoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedToDo = toDos[indexPath.row]
        presenter?.showEditToDo(for: selectedToDo)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let toDoToDelete = self.toDos[indexPath.row]
            self.presenter?.deleteToDoItem(toDoToDelete)
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}


extension ToDoListViewController {
    func didAddToDo() {
        presenter?.fetchToDos()
    }
}
