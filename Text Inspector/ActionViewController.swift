//
//  ActionViewController.swift
//  Text Inspector
//
//  Created by Jeff Kelley on 9/19/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import UIKit
import MobileCoreServices

import TextDetectiveCommon

class ActionViewController: TextInspectingViewController {
    
    @IBOutlet var navigationBar: UINavigationBar? {
        didSet {
            if let bar = navigationBar {
                bar.topItem?.leftBarButtonItem = editButtonItem
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateTextFromExtensionContext()
    }
    
    func populateTextFromExtensionContext() {
        outerLoop: for item in extensionContext?.inputItems as? [NSExtensionItem] ?? [] {
            for itemProvider in item.attachments as? [NSItemProvider] ?? [] {
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String,
                                          options: nil) { [weak self] (text, error) in
                                            if let text = text as? String {
                                                OperationQueue.main.addOperation {
                                                    self?.characterInspectionResults = text.inspect()
                                                    self?.updateTextFieldText()
                                                    self?.tableView?.reloadData()
                                                }
                                            }
                    }
                    
                    break outerLoop
                }
            }
        }
    }

    @IBAction func done() {
        let items: [NSExtensionItem]?
        
        if let text = textField?.text {
            let item = NSExtensionItem()
            let attachment = NSItemProvider(item: text as NSSecureCoding?,
                                            typeIdentifier: kUTTypeText as String)
            
            item.attachments = [attachment]
            
            items = [item]
        }
        else {
            items = extensionContext?.inputItems as? [NSExtensionItem]
        }
        
        extensionContext?.completeRequest(returningItems: items,
                                          completionHandler: nil)
    }

}
