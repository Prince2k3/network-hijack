import XCTest
import Foundation

@testable import Network_Hijack

fileprivate extension Route.Path {
    static let fetchUsers = Route.Path("/users")
}

struct User: Codable {
    var firstName: String
    var lastName: String
    var email: String
}

class EncodableResponseTests: XCTestCase {
    
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
            response: try! EncodableResponse(
                model: [User(
                        firstName: "Prince",
                        lastName: "Ugwuh",
                        email: "prince.ugwuh@gmail.com"
                    )]
                )
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
            
            let decoder = JSONDecoder()
            let users = try! decoder.decode([User].self, from: data!)
            XCTAssert(users.count == 1, "Users count is equal to just 1 user")
            XCTAssert(users[0].firstName == "Prince", "First name does not equal 'Prince'")
            XCTAssert(users[0].lastName == "Ugwuh", "Last name does not equal 'Ugwuh'")
            XCTAssert(users[0].email == "prince.ugwuh@gmail.com", "email does not equal 'prince.ugwuh@gmail.com'")
            
            expectation.fulfill()
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 10.0)
    }
}
