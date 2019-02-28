//
//  ResponseTest.swift
//  Network HijackTests
//
//  Created by Prince Ugwuh on 2/27/19.
//  Copyright © 2019 Prince Ugwuh. All rights reserved.
//

import XCTest

@testable import NetworkHijack

fileprivate extension Route.Path {
    static let fetchUsers = Route.Path("/users")
}

class ResponseTests: XCTestCase {
    
    let session: URLSession = {
        let configuration: URLSessionConfiguration = .default
        NetworkHijack.enable(sessionConfiguration: configuration)
        return URLSession(configuration: configuration)
    }()
    
    override func setUp() {
        
        
        NetworkHijack.default.addRoute(Route(
            baseURL: URL(string: "http://localhost:8080")!,
            path: .fetchUsers,
            httpMethod: .get,
            response: try! Response(object: [[
                    "firstName": "Prince",
                    "lastName": "Ugwuh",
                    "email": "prince.ugwuh@gmail.com"
                ]])
            )
        )
    }
    
    override func tearDown() {
        NetworkHijack.clearRoutes()
    }
    
    func testNetworkHijackRoute() {
        
        let expectation = XCTestExpectation(description: "Fetch Mock Users")
        let url = URL(string: "http://localhost:8080/users")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request) { data, response, error in
            if error != nil {
                XCTFail()
                expectation.fulfill()
                return
            }
            
            if data == nil {
                XCTFail()
                expectation.fulfill()
                return
            }
            
            guard
                let result = try! JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]],
                let firstName = result[0]["firstName"] as? String,
                let lastName = result[0]["lastName"] as? String,
                let email = result[0]["email"] as? String
                else { XCTFail() ; return }
            
            XCTAssert(result.count == 1, "Users count is equal to just 1 user")
            XCTAssert(firstName == "Prince", "First name does not equal 'Prince'")
            XCTAssert(lastName == "Ugwuh", "Last name does not equal 'Ugwuh'")
            XCTAssert(email == "prince.ugwuh@gmail.com", "email does not equal 'prince.ugwuh@gmail.com'")
            
            expectation.fulfill()
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 10.0)
    }
}
