//
//  StringClipboard.swift
//  Text Detective
//
//  Created by Jeff Kelley on 9/18/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import UIKit
import MobileCoreServices

extension UIPasteboard {
    
    var textValue: String? {
        return value(forPasteboardType: kUTTypeText as String) as? String
    }
    
    func copy(text value: String) {
        setValue(value, forPasteboardType: kUTTypeText as String)
    }
    
}
