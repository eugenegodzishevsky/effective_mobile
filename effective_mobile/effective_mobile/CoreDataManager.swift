//
//  CoreDataManager.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import UIKit
import CoreData

public final class CoreDataManager: NSObject {

    public static let shared = CoreDataManager()
    private override init() {}
    
    private var appDelegate: AppDelegate? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Expected AppDelegate instance not found")
            return nil
        }
        return appDelegate
    }

    private var context: NSManagedObjectContext {
        return appDelegate!.persistentContainer.viewContext
    }

    public func createToDo(title: String, description: String?, createdDate: Date, isCompleted: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            guard let toDoEntityDescription = NSEntityDescription.entity(forEntityName: "ToDoItem", in: self.context) else {
                completion(.failure(NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to find entity description."])))
                return
            }

            let toDo = NSManagedObject(entity: toDoEntityDescription, insertInto: self.context) as! ToDoItem
            toDo.id = UUID()
            toDo.title = title
            toDo.todoDescription = description
            toDo.createdDate = createdDate
            toDo.isCompleted = isCompleted

            self.saveContext(completion: completion)
        }
    }

    public func firstFetchToDos(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        NetworkService.shared.fetchToDos { [weak self] result in
            switch result {
            case .success(let todos):
                DispatchQueue.main.async {
                    self?.saveFetchedToDos(todos, completion: completion)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func saveFetchedToDos(_ todos: [Todo], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        let backgroundContext = self.appDelegate!.persistentContainer.newBackgroundContext()
        
        backgroundContext.perform {
            for todo in todos {
                guard let toDoEntityDescription = NSEntityDescription.entity(forEntityName: "ToDoItem", in: backgroundContext) else { continue }
                let toDoItem = NSManagedObject(entity: toDoEntityDescription, insertInto: backgroundContext) as! ToDoItem
                toDoItem.id = UUID()
                toDoItem.title = todo.todo
                toDoItem.todoDescription = nil
                toDoItem.createdDate = Date()
                toDoItem.isCompleted = todo.completed
            }

            do {
                try backgroundContext.save()
                let fetchRequest = NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
                let toDos = try backgroundContext.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(.success(toDos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    public func fetchToDos(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        DispatchQueue.main.async {
            let fetchRequest = NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
            let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]

            do {
                let toDos = try self.context.fetch(fetchRequest)
                print("Fetched ToDos: \(toDos)")
                completion(.success(toDos))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func updateToDo(toDo: ToDoItem, title: String, description: String?, isCompleted: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            let context = self.context
            let objectID = toDo.objectID

            context.perform {
                do {
                    guard let managedObject = context.object(with: objectID) as? ToDoItem else {
                        throw NSError(domain: "CoreDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Managed object not found"])
                    }

                    managedObject.title = title
                    managedObject.todoDescription = description
                    managedObject.isCompleted = isCompleted

                    try context.save()
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func deleteToDo(_ toDo: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            let context = self.context
            let objectID = toDo.objectID

            context.perform {
                do {
                    let managedObject = context.object(with: objectID)
                    context.delete(managedObject)
                    try context.save()
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    public func fetchToDo(with id: UUID, completion: @escaping (Result<ToDoItem?, Error>) -> Void) {
        DispatchQueue.main.async {
            let fetchRequest = NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                let toDo = try self.context.fetch(fetchRequest).first
                completion(.success(toDo))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func saveContext(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            do {
                try self.context.save()
                completion(.success(()))
                print("Saved successfully")
            } catch {
                completion(.failure(error))
                print("Failed to save context: \(error)")
            }
        }
    }
}

