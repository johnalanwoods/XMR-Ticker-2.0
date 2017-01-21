//
//  TipViewController.swift
//  XMR Ticker
//
//  Created by John Woods on 15/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Cocoa

class TipViewController: NSViewController {
    
    @IBOutlet weak var copyAddressButton: NSButton!
    @IBOutlet weak var moneroTipAddress: NSTextField!
    
    @IBAction func copyAddressButtonClicked(_ sender: NSButtonCell) {
        NSPasteboard.general().clearContents()
        NSPasteboard.general().setString(self.moneroTipAddress.stringValue, forType:NSPasteboardTypeString)
        self.copyAddressButton.title = "Done!"
        self.copyAddressButton.isEnabled = false
    }
    
    override func viewWillAppear()
    {
        self.copyAddressButton.title = "Copy Address!"
        self.copyAddressButton.isEnabled = true
    }

}
