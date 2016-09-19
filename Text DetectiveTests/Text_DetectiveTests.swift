//
//  Text_DetectiveTests.swift
//  Text DetectiveTests
//
//  Created by Jeff Kelley on 9/16/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import XCTest
@testable import Text_Detective

class Text_DetectiveTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceOfLongZalgoTextParsing() {
        guard let path = Bundle(for: Text_DetectiveTests.self)
            .url(forResource: "TestInput",
                 withExtension: "txt",
                 subdirectory: nil,
                 localization: nil)
            else { fatalError() }

        let text: String
        
        do {
            text = try String(contentsOf: path)
        }
        catch {
            fatalError()
        }
        
        self.measure {
            let _ = text.characterInspection
        }
    }
    
}
