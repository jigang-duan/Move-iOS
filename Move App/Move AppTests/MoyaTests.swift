//
//  MoyaTests.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import XCTest

import ObjectMapper
import Moya
import RxSwift
import RxTest
import RxBlocking
import Moya_ObjectMapper

struct Post {
    var id: Int?
    var title: String?
    var body: String?
    var userId: Int?
}

extension Post: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        body <- map["body"]
        userId <- map["userId"]
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}

enum PostService {
    case show(id: Int)
}

extension PostService: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: "http://jsonplaceholder.typicode.com")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .show(let id):
            return "/posts/\(id)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .show:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .show:
            return nil
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return URLEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .show:
            return "[{\"userId\": \"1\", \"Title\": \"Title String\", \"Body\": \"Body String\"}]".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

class MoyaTests: XCTestCase {
    
    var provider: RxMoyaProvider<PostService>!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        provider = RxMoyaProvider<PostService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let expectedResult = Post(id: 1, title: "", body: "", userId: 1)
        if let result = try? provider.request(.show(id: 1)).filterSuccessfulStatusCodes().mapObject(Post.self).toBlocking().last() {
            XCTAssertEqual(result?.id, expectedResult.id)
            XCTAssertEqual(result?.userId, expectedResult.userId)
        } else {
            XCTFail()
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
