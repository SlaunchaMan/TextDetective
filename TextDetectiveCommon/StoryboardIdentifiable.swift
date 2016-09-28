//
//  StoryboardIdentifiable.swift
//  Text Detective
//
//  Created by Jeff Kelley on 9/18/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import Foundation

public protocol StoryboardIdentifiable {
    
    static var storyboardIdentifier: String { get }
    
}
