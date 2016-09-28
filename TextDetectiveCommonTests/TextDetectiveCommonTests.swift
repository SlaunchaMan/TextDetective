//
//  TextDetectiveCommonTests.swift
//  TextDetectiveCommonTests
//
//  Created by Jeff Kelley on 9/27/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import XCTest
@testable import TextDetectiveCommon

class TextDetectiveCommonTests: XCTestCase {
    
    func testPerformanceOfLongZalgoTextParsing() {
        guard let path = Bundle(for: TextDetectiveCommonTests.self)
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
            let _ = text.inspect()
        }
    }
    
}
