//
//  TriggerViewController.swift
//  XMR Ticker
//
//  Created by John Woods on 21/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Cocoa

//protocol for array pass back
protocol TriggerArrayReceiver:class
{
    func triggerArrayUpdated(_ triggers:[Trigger])
}

class TriggerViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    //delegate
    weak var delegate:TriggerArrayReceiver?
    
    //model
    var localTriggerList:[Trigger] = [Trigger]()
    //tableview
    @IBOutlet weak var triggerListTableView: NSTableView!
    //ui elements
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


    override func viewDidLoad() {
        self.triggerListTableView.delegate = self
        self.triggerListTableView.dataSource = self
        
        self.triggerValueTextField.delegate = self
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        self.triggerListTableView.reloadData()
    }
    
    //tableview delegate methods
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.localTriggerList.count
    }
    
    //fill out tableview
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellText: String = ""
        var cellIdentifier: String = ""

        if tableColumn == tableView.tableColumns[0] {
            cellText = "XMR/\(self.localTriggerList[row].counterCurrency.rawValue)"
            cellIdentifier = "CurrencyCell"
        } else if tableColumn == tableView.tableColumns[1] {
            cellText = self.localTriggerList[row].logic.rawValue
            cellIdentifier = "LogicCell"
        } else if tableColumn == tableView.tableColumns[2] {
            if(self.localTriggerList[row].counterCurrency == .btc)
            {
                cellText = "\(self.localTriggerList[row].triggerValue) BTC"
            }
            else{
                cellText = "$\(self.localTriggerList[row].triggerValue.string(fractionDigits: 2))"
            }
            cellIdentifier = "TriggerCell"
        }
        
        let cell = tableView.make(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        cell.textField?.stringValue = cellText
        cell.textField?.textColor = NSColor(red: 232/255.0, green: 77/255.0, blue: 37/255.0, alpha: 1.0)
        return cell
    }

    
    //create new trigger/alert
    @IBAction func addButtonClicked(_ sender: NSButton) {

        //parse model from ui
        let baseCurrency = Trigger.BaseCurrency.xmr
        var counterCurrency:Trigger.CounterCurrency
        var logic:Trigger.Logic
        
        switch self.triggerCurrencyBox.stringValue {
        case let switchString where switchString.contains("USD"):
            counterCurrency = Trigger.CounterCurrency.usd
        case let switchString where switchString.contains("BTC"):
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
        
        //create new model
        let trigger = Trigger(baseCurrency: baseCurrency, counterCurrency: counterCurrency, logic: logic, triggerValue: Double(self.triggerValueTextField.stringValue) ?? 0.00, quoteTime: NSDate())
        //append to model array
        self.localTriggerList.append(trigger)

        //reload tableview
        self.triggerListTableView.reloadData()
        if(self.triggerListTableView.numberOfRows > 0)
        {
            self.triggerListTableView.scrollRowToVisible(self.triggerListTableView.numberOfRows-1)
        }
    }
    
    //update global array of models in app delegate
    override func viewDidDisappear() {
        self.delegate?.triggerArrayUpdated(self.localTriggerList)
    }
    

    override func controlTextDidChange(_ obj: Notification) {
        let charSet = NSCharacterSet(charactersIn: "1234567890.").inverted
        let chars = self.triggerValueTextField.stringValue.components(separatedBy: charSet)
        self.triggerValueTextField.stringValue = chars.joined()
    }
    
}
