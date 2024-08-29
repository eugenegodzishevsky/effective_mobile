//
//  NetworkManager.swift
//  effective_mobile
//
//  Created by Vermut xxx on 29.08.2024.
//

import Foundation

public final class NetworkService {
    
    static let shared = NetworkService()
    private init() {}
    
    public func fetchToDos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        let url = URL(string: "https://dummyjson.com/todos")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data was nil."])))
                return
            }
            
            do {
                let todoResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                completion(.success(todoResponse.todos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
