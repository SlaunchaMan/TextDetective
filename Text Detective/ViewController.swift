//
//  ViewController.swift
//  Text Detective
//
//  Created by Jeff Kelley on 9/16/16.
//  Copyright © 2016 Detroit Labs. All rights reserved.
//

import UIKit

import TextDetectiveCommon

class ViewController: TextInspectingViewController {
    
    var shareButton: UIBarButtonItem?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        shareButton = UIBarButtonItem(barButtonSystemItem: .action,
                                      target: self,
                                      action: #selector(shareButtonPressed(_:)))
        
        navigationItem.rightBarButtonItem = shareButton
        
        updateBarButtonItems()
    }
    
    override func updateBarButtonItems() {
        super.updateBarButtonItems()
        
        if let text = textField?.text, text.characters.count > 0 {
            shareButton?.isEnabled = true
        }
        else {
            shareButton?.isEnabled = false
        }
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
