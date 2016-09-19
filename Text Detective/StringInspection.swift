//
//  StringInspection.swift
//  Text Detective
//
//  Created by Jeff Kelley on 9/16/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import CoreFoundation
import Foundation

enum InspectionResult {
    case singleCharacter(String)
    case unicodeDescription(String)
    
    var originalString: String {
        switch self {
        case let .singleCharacter(string):
            return string
        case let .unicodeDescription(string):
            return String.convert(fromUnicodeDescription: string)
        }
    }
}

extension String {
    
    var characterInspection: [InspectionResult] {
        let cfString = NSMutableString(string: self) as CFMutableString
        
        CFStringTransform(cfString,
                          nil,
                          kCFStringTransformToUnicodeName,
                          false)
        
        let descriptionString = cfString as String
        
        let scanner = Scanner(string: descriptionString)
        
        var results: [InspectionResult] = []
        
        var buffer: NSString? = NSString()
        
        if !descriptionString.hasPrefix("\\N{") {
            if scanner.scanUpTo("\\N{", into: &buffer) {
                if let buffer = buffer {
                    results += (buffer as String)
                        .characters
                        .map { return .singleCharacter(String($0)) }
                }
            }
        }
        
        while scanner.scanString("\\N{", into: nil) {
            scanner.scanUpTo("}", into: &buffer)
            
            results.append(.unicodeDescription(buffer as? String ?? ""))
            
            scanner.scanString("}", into: nil)
            
            if scanner.scanUpTo("\\N{", into: &buffer) {
                if let buffer = buffer {
                    results += (buffer as String)
                        .characters
                        .map { return .singleCharacter(String($0)) }
                }
            }
        }
    
        return results
    }
    
    static func convert(fromUnicodeDescription description: String) -> String {
        let cfString = NSMutableString(string: "\\N{\(description)}")
            as CFMutableString
        
        CFStringTransform(cfString,
                          nil,
                          kCFStringTransformToUnicodeName,
                          true)
        
        return cfString as String
    }
    
}
