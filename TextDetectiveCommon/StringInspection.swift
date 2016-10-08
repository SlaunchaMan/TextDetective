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
    
    public struct InspectionResult {
        public let unicodeDescription: String
        
        public var originalString: String {
            return String.convert(fromUnicodeDescription: unicodeDescription)
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
                          "Any-Name".cfString,
                          false)
        
        let descriptionString = cfString as String
        
        let scanner = Scanner(string: descriptionString)
        
        var results: [InspectionResult] = []
        
        var buffer: NSString? = NSString()
        
        while scanner.scanString("\\N{", into: nil) {
            scanner.scanUpTo("}", into: &buffer)
            
            if let buffer = buffer as? String {
                results.append(InspectionResult(unicodeDescription: buffer))
            }
            
            scanner.scanUpTo("\\N{", into: &buffer)
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
