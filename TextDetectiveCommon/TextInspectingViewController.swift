//
//  TextInspectingViewController.swift
//  Text Detective
//
//  Created by Jeff Kelley on 9/27/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import UIKit

open class TextInspectingViewController: UIViewController {

    @IBOutlet public var tableView: UITableView? {
        didSet {
            if let tableView = tableView {
                tableView.estimatedRowHeight = 44
                tableView.rowHeight = UITableViewAutomaticDimension
            }
        }
    }
    
    @IBOutlet public var textField: UITextField?
    
    @IBAction public func textFieldDidChange(_ sender: UITextField) {
        let options = String.InspectionOptions(shouldDecompose: true)
        
        characterInspectionResults = sender.text?.inspect(withOptions: options) ?? []
        tableView?.reloadData()
        
        updateBarButtonItems()
    }
    
    public var characterInspectionResults: [String.InspectionResult] = []
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        updateBarButtonItems()
    }
    
    open func updateBarButtonItems() {
        if let text = textField?.text, text.characters.count > 0 {
            editButtonItem.isEnabled = true
        }
        else {
            editButtonItem.isEnabled = false
            
            setEditing(false, animated: false)
        }
    }
    
    public func updateTextFieldText() {
        textField?.text = characterInspectionResults
            .map { $0.originalString }
            .joined(separator: "")
        
        updateBarButtonItems()
    }
    
    override open func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView?.setEditing(editing, animated: animated)
    }
    
}

class CodePointCell: UITableViewCell, StoryboardIdentifiable {
    
    @IBOutlet var codePointLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    
    static var storyboardIdentifier: String = "CodePointCell"
    
    static func dequeue(fromTableView tableView: UITableView) -> CodePointCell? {
        return tableView.dequeueReusableCell(withIdentifier: storyboardIdentifier)
            as? CodePointCell
    }
    
}

extension TextInspectingViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension TextInspectingViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView,
                          canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView,
                          canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = CodePointCell.dequeue(fromTableView: tableView)
            else { fatalError() }
        
        let inspectionResult = characterInspectionResults[indexPath.row]
        
        cell.codePointLabel?.text = inspectionResult.originalString
        cell.descriptionLabel?.text = inspectionResult.unicodeDescription
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            characterInspectionResults.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            updateTextFieldText()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          moveRowAt sourceIndexPath: IndexPath,
                          to destinationIndexPath: IndexPath) {
        let selectedResult = characterInspectionResults
            .remove(at: sourceIndexPath.row)
        
        characterInspectionResults.insert(selectedResult,
                                          at: destinationIndexPath.row)
        
        updateTextFieldText()
    }
    
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return characterInspectionResults.count
    }
    
}

extension TextInspectingViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView,
                          editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    public func tableView(_ tableView: UITableView,
                          shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView,
                          canPerformAction action: Selector,
                          forRowAt indexPath: IndexPath,
                          withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        else if action == #selector(cut(_:)) {
            return true
        }
        else if action == #selector(paste(_:)) {
            return UIPasteboard.general.textValue != nil
        }
        
        return false
    }
    
    public func tableView(_ tableView: UITableView,
                          performAction action: Selector,
                          forRowAt indexPath: IndexPath,
                          withSender sender: Any?) {
        let stringAtIndexPath = characterInspectionResults[indexPath.row]
            .originalString
        
        if action == #selector(copy(_:)) {
            UIPasteboard.general.copy(text: stringAtIndexPath)
        }
        else if action == #selector(cut(_:)) {
            UIPasteboard.general.copy(text: stringAtIndexPath)
            
            characterInspectionResults.remove(at: indexPath.row)
            updateTextFieldText()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        else if action == #selector(paste(_:)) {
            if let stringToPaste = UIPasteboard.general.textValue {
                let options = String.InspectionOptions(shouldDecompose: true)
                let resultsToInsert = stringToPaste.inspect(withOptions: options)
                
                guard resultsToInsert.count > 0 else { return }
                
                characterInspectionResults.insert(contentsOf: resultsToInsert,
                                                  at: indexPath.row)
                
                updateTextFieldText()
                
                var rowsToInsert: [IndexPath] = []
                
                for i in 0 ..< resultsToInsert.count {
                    rowsToInsert.append(IndexPath(row: indexPath.row + i,
                                                  section: 0))
                }
                
                tableView.insertRows(at: rowsToInsert, with: .automatic)
            }
        }
    }
    
}
