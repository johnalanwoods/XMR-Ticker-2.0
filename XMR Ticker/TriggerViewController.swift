//
//  TriggerViewController.swift
//  XMR Ticker
//
//  Created by John Woods on 21/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Cocoa

class TriggerViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var triggerListTableView: NSTableView!
    
    var localTriggerList:[Trigger] = [Trigger]()

    
    
    @IBAction func doneButtonClicked(_ sender: NSButton) {
        self.view.window?.close()
    }

    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillDisappear() {
    }
}
