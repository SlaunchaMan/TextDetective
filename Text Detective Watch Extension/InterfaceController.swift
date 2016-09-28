//
//  InterfaceController.swift
//  Text Detective Watch Extension
//
//  Created by Jeff Kelley on 9/28/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import WatchKit
import Foundation

import TextDetectiveCommon

class CodePointRowController: NSObject, StoryboardIdentifiable {
    
    static var storyboardIdentifier: String = "CodePointRowController"

    @IBOutlet weak var codePointLabel: WKInterfaceLabel?
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel?
    
}

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable?
    
    public var characterInspectionResults: [String.InspectionResult] = []
    
    @IBAction func enterTextButtonPressed() {
        presentTextInputController(withSuggestions: ["👨‍👩‍👧‍👦", "👩‍❤️‍💋‍👩", "👨‍👧", "👩‍👧‍👦"],
                                   allowedInputMode: .plain) { [weak self] results in
                                    guard let table = self?.table else { return }
                                    
                                    guard let results = results else { return }
                                    
                                    let result = results
                                        .filter { x in return x is String }
                                        .flatMap { x in return x as? String }
                                        .first
                                    
                                    guard let string = result else {
                                        self?.characterInspectionResults = []
                                        table.setNumberOfRows(0,
                                                              withRowType: CodePointRowController.storyboardIdentifier)
                                        
                                        return
                                    }
                                    
                                    self?.populate(with: string)
        }
    }
    
    func populate(with string: String) {
        guard let table = table else { return }
        
        characterInspectionResults = string.inspect()
        
        table.setNumberOfRows(characterInspectionResults.count,
                              withRowType: CodePointRowController.storyboardIdentifier)
        
        for row in 0 ..< characterInspectionResults.count {
            if let rowController = table.rowController(at: row) as? CodePointRowController {
                let inspectionResult = characterInspectionResults[row]
                
                rowController.codePointLabel?.setText(inspectionResult.originalString)
                
                switch inspectionResult {
                case .singleCharacter(let string):
                    rowController.descriptionLabel?.setText(string)
                case .unicodeDescription(let string):
                    rowController.descriptionLabel?.setText(string)
                }
            }
        }
    }
    
}
