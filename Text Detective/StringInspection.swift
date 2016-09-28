//
//  StringInspection.swift
//  Text Detective
//
//  Created by Jeff Kelley on 9/16/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import CoreFoundation
import Foundation

extension String {
    
    public struct InspectionOptions {
        let shouldDecompose: Bool
        
        init(shouldDecompose: Bool = false) {
            self.shouldDecompose = shouldDecompose
        }
    }
    
    public enum InspectionResult {
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
    
    private var cfString: CFString {
        return self as CFString
    }
    
    private var mutableCFString: CFMutableString {
        return NSMutableString(string: self) as CFMutableString
    }
    
    public func inspect(withOptions options: InspectionOptions = InspectionOptions()) -> [InspectionResult] {
        let cfString = self.mutableCFString
        
        if options.shouldDecompose {
            CFStringNormalize(cfString,
                              CFStringNormalizationForm.D)
        }
        
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
    
    private static func convert(fromUnicodeDescription description: String) -> String {
        let cfString = "\\N{\(description)}".mutableCFString
        
        CFStringTransform(cfString,
                          nil,
                          kCFStringTransformToUnicodeName,
                          true)
        
        return cfString as String
    }
    
}
