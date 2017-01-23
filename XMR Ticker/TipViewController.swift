//
//  TipViewController.swift
//  XMR Ticker
//
//  Created by John Woods on 15/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Cocoa

class TipViewController: NSViewController {
    
    //ui elements
    @IBOutlet weak var copyAddressButton: NSButton!
    @IBOutlet weak var moneroTipAddress: NSTextField!
    
    //make it easy to copy address to pasteboard
    @IBAction func copyAddressButtonClicked(_ sender: NSButtonCell) {
        NSPasteboard.general().clearContents()
        NSPasteboard.general().setString(self.moneroTipAddress.stringValue, forType:NSPasteboardTypeString)
        self.copyAddressButton.title = "Done!"
        self.copyAddressButton.isEnabled = false
    }
    
    //reset button when view appears
    override func viewWillAppear()
    {
        self.copyAddressButton.title = "Copy Address!"
        self.copyAddressButton.isEnabled = true
    }

}
