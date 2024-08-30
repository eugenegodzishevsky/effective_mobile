//
//  effective_mobileNetworkManagerTests.swift
//  effective_mobileTests
//
//  Created by Vermut xxx on 30.08.2024.
//

import XCTest
@testable import effective_mobile

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var error: Error?

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionDataTaskMock {
            completionHandler(self.data, nil, self.error)
        }
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    var urlSession: URLSessionProtocol = URLSession.shared
    
    func fetchToDos(completion: @escaping (Result<[ToDo], Error>) -> Void) {
        let url = URL(string: "https://example.com/todos")!
        urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let todos = try JSONDecoder().decode([ToDo].self, from: data)
                completion(.success(todos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct ToDo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}

class NetworkServiceTests: XCTestCase {

    var networkService: NetworkService!
    var urlSessionMock: URLSessionMock!

    override func setUpWithError() throws {
        urlSessionMock = URLSessionMock()
        networkService = NetworkService.shared
        networkService.urlSession = urlSessionMock
    }

    override func tearDownWithError() throws {
        networkService = nil
        urlSessionMock = nil
    }

    func testFetchToDosSuccess() throws {
        let json = """
        [
            {"id": 1, "todo": "Test Todo 1", "completed": false},
            {"id": 2, "todo": "Test Todo 2", "completed": true}
        ]
        """.data(using: .utf8)!

        urlSessionMock.data = json

        let expectation = self.expectation(description: "Fetching ToDos from network")

        networkService.fetchToDos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 2, "Should fetch 2 ToDos")
                XCTAssertEqual(todos[0].todo, "Test Todo 1")
                XCTAssertEqual(todos[1].todo, "Test Todo 2")
            case .failure(let error):
                XCTFail("Fetching ToDos failed with error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
