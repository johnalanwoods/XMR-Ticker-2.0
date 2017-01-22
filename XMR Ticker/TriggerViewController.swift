//
//  TriggerViewController.swift
//  XMR Ticker
//
//  Created by John Woods on 21/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Cocoa


class TriggerViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {

    @IBOutlet weak var triggerListTableView: NSTableView!

    
    var localTriggerList:[Trigger] = [Trigger]()
    @IBOutlet weak var triggerCurrencyBox: NSComboBox!
    @IBOutlet weak var triggerLogicSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var triggerValueTextField: NSTextField!
    
    @IBAction func removeButtonClicked(_ sender: NSButton) {
        if(self.triggerListTableView.selectedRow != -1)
        {
            self.localTriggerList.remove(at: self.triggerListTableView.selectedRow)
            self.triggerListTableView.reloadData()
        }
    }
    
    @IBAction func clearButtonClicked(_ sender: NSButton) {
        if(self.triggerListTableView.numberOfRows > 0)
        {
            self.localTriggerList.removeAll()
            self.triggerListTableView.reloadData()
        }
    }
    @IBAction func doneButtonClicked(_ sender: NSButton) {

        self.view.window?.close()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.localTriggerList.count
    }
    
    override func viewDidLoad() {
        self.triggerListTableView.delegate = self
        self.triggerListTableView.dataSource = self
        
        self.triggerValueTextField.delegate = self
        
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        self.triggerListTableView.reloadData()
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellText: String = ""
        var cellIdentifier: String = ""

        if tableColumn == tableView.tableColumns[0] {
            cellText = self.localTriggerList[row].counterCurrency.rawValue
            cellIdentifier = "CurrencyCell"
        } else if tableColumn == tableView.tableColumns[1] {
            cellText = self.localTriggerList[row].logic.rawValue
            cellIdentifier = "LogicCell"
        } else if tableColumn == tableView.tableColumns[2] {
            cellText = "\(self.localTriggerList[row].triggerValue)"
            cellIdentifier = "TriggerCell"
        }
        
        let cell = tableView.make(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        cell.textField?.stringValue = cellText
        cell.textField?.textColor = NSColor.white
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {

    }
    
    @IBAction func addButtonClicked(_ sender: NSButton) {

        let baseCurrency = Trigger.BaseCurrency.xmr
        var counterCurrency:Trigger.CounterCurrency
        var logic:Trigger.Logic
        
        switch self.triggerCurrencyBox.stringValue {
        case "USD":
            counterCurrency = Trigger.CounterCurrency.usd
        case "BTC":
            counterCurrency = Trigger.CounterCurrency.btc
        default:
            counterCurrency = Trigger.CounterCurrency.usd
        }
        switch self.triggerLogicSegmentedControl.label(forSegment: self.triggerLogicSegmentedControl.selectedSegment)! {
        case ">":
            logic = Trigger.Logic.greaterThan
        case "<":
            logic = Trigger.Logic.lessThan
        case "=":
            logic = Trigger.Logic.equalTo
        default:
            logic = Trigger.Logic.equalTo
        }
        
        
        let trigger = Trigger(baseCurrency: baseCurrency, counterCurrency: counterCurrency, logic: logic, triggerValue: Double(self.triggerValueTextField.stringValue) ?? 0.00, quoteTime: NSDate())
        self.localTriggerList.append(trigger)

        self.triggerListTableView.reloadData()
        if(self.triggerListTableView.numberOfRows > 0)
        {
            self.triggerListTableView.scrollRowToVisible(self.triggerListTableView.numberOfRows-1)
        }
    }
    override func viewWillDisappear() {
        //pass back array
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let charSet = NSCharacterSet(charactersIn: "1234567890.").inverted
        let chars = self.triggerValueTextField.stringValue.components(separatedBy: charSet)
        self.triggerValueTextField.stringValue = chars.joined()
    }
    
}



