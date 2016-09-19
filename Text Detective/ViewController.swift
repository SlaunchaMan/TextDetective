//
//  ViewController.swift
//  Text Detective
//
//  Created by Jeff Kelley on 9/16/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var shareButton: UIBarButtonItem?
    
    @IBOutlet var tableView: UITableView? {
        didSet {
            if let tableView = tableView {
                tableView.estimatedRowHeight = 44
                tableView.rowHeight = UITableViewAutomaticDimension
            }
        }
    }
    
    @IBOutlet var textField: UITextField?
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        characterInspectionResults = sender.text?.characterInspection ?? []
        tableView?.reloadData()
        
        updateBarButtonItems()
    }
    
    var characterInspectionResults: [InspectionResult] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        shareButton = UIBarButtonItem(barButtonSystemItem: .action,
                                      target: self,
                                      action: #selector(shareButtonPressed(_:)))
        
        navigationItem.rightBarButtonItem = shareButton
        
        updateBarButtonItems()
    }
    
    func updateBarButtonItems() {
        if let text = textField?.text, text.characters.count > 0 {
            editButtonItem.isEnabled = true
            shareButton?.isEnabled = true
        }
        else {
            editButtonItem.isEnabled = false
            shareButton?.isEnabled = false
            setEditing(false, animated: false)
        }
    }
    
    func updateTextFieldText() {
        textField?.text = characterInspectionResults
            .map { $0.originalString }
            .joined(separator: "")
        
        updateBarButtonItems()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView?.setEditing(editing, animated: animated)
    }
    
    func shareButtonPressed(_ sender: UIBarButtonItem) {
        guard let textToShare = textField?.text,
            textToShare.characters.count > 0
            else { fatalError() }
        
        let controller = UIActivityViewController(activityItems: [textToShare],
                                                  applicationActivities: nil)
        
        present(controller, animated: true, completion: nil)
        
        controller.popoverPresentationController?.barButtonItem = sender
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

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = CodePointCell.dequeue(fromTableView: tableView)
            else { fatalError() }
        
        let unicodeDescription = characterInspectionResults[indexPath.row]
        
        cell.codePointLabel?.text = unicodeDescription.originalString
        
        switch unicodeDescription {
        case let .singleCharacter(string):
            cell.descriptionLabel?.text = string
        case let .unicodeDescription(string):
            cell.descriptionLabel?.text = string
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            characterInspectionResults.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            updateTextFieldText()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let selectedResult = characterInspectionResults
            .remove(at: sourceIndexPath.row)
        
        characterInspectionResults.insert(selectedResult,
                                          at: destinationIndexPath.row)
        
        updateTextFieldText()
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return characterInspectionResults.count
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView,
                   shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
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
    
    func tableView(_ tableView: UITableView,
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
                let resultsToInsert = stringToPaste.characterInspection
                
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
