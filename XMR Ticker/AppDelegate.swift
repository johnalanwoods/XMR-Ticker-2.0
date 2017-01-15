//
//  AppDelegate.swift
//  XMR Ticker
//
//  Created by John Woods on 14/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PriceListener {

    //coin symbols settings
    var coinSymbolsEnabled = false
    @IBOutlet weak var coinSymbolButton: NSMenuItem!
    @IBAction func coinSymbolButtonClicked(_ sender: NSMenuItem) {
        if(sender.state  == NSOffState)
        {
            self.coinSymbolsEnabled  = true
            sender.state = NSOnState
            self.priceStreamer?.restartStream()
        }
        else{
            self.coinSymbolsEnabled = false
            sender.state = NSOffState
            self.priceStreamer?.restartStream()
        }
    }
    

    //tip popover
    let tipPopover = NSPopover()
    @IBOutlet weak var tipButton: NSMenuItem!
    
    //frequecy settings
    @IBOutlet weak var fifteenSecondFreqButton: NSMenuItem!
    @IBOutlet weak var thirtySecondFreqButton: NSMenuItem!
    @IBOutlet weak var sixtySecondFreqButton: NSMenuItem!
    
    @IBAction func updateFrequencyChanged(_ sender: NSMenuItem)
    {
        switch sender.title {
        case "15 Seconds":
            self.priceStreamer?.frequencyInSeconds = 15
            self.fifteenSecondFreqButton.state = NSOnState
            self.thirtySecondFreqButton.state = NSOffState
            self.sixtySecondFreqButton.state = NSOffState
        case "30 Seconds":
            self.priceStreamer?.frequencyInSeconds = 30
            self.fifteenSecondFreqButton.state = NSOffState
            self.thirtySecondFreqButton.state = NSOnState
            self.sixtySecondFreqButton.state = NSOffState
        case "60 Seconds":
            self.priceStreamer?.frequencyInSeconds = 60
            self.fifteenSecondFreqButton.state = NSOffState
            self.thirtySecondFreqButton.state = NSOffState
            self.sixtySecondFreqButton.state = NSOnState
        default:
            self.priceStreamer?.frequencyInSeconds = 30
            self.fifteenSecondFreqButton.state = NSOffState
            self.thirtySecondFreqButton.state = NSOnState
            self.sixtySecondFreqButton.state = NSOffState
        }
    }

    //terms settings
    @IBOutlet weak var usdTermsButton: NSMenuItem!
    @IBOutlet weak var btcTermsButton: NSMenuItem!
    
    @IBAction func updateTermsChanged(_ sender: NSMenuItem)
    {
        switch sender.title {
        case "USD":
            self.priceStreamer?.terms = .usd
            self.usdTermsButton.state = NSOnState
            self.btcTermsButton.state = NSOffState
        case "BTC":
            self.priceStreamer?.terms = .btc
            self.usdTermsButton.state = NSOffState
            self.btcTermsButton.state = NSOnState
        default:
            self.priceStreamer?.terms = .usd
            self.usdTermsButton.state = NSOnState
            self.btcTermsButton.state = NSOffState
        }
    }
    
    
    @IBAction func tipButtonClicked(_ sender: Any) {
        if (self.tipPopover.contentViewController == nil)
        {
            self.tipPopover.contentViewController = TipViewController(nibName: "TipViewController", bundle: nil)
            self.tipPopover.behavior = .transient
        }
        self.tipPopover.show(relativeTo: statusBarItem.button!.bounds, of: statusBarItem.button!, preferredEdge: .maxY)
    }

    
    
    let statusBarItem = NSStatusBar.system().statusItem(withLength:NSVariableStatusItemLength) // statusbar
    @IBOutlet weak var tickerMenu: NSMenu! //overall menu object
    
    var priceStreamer:PriceStreamer?

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusBarItem.menu = tickerMenu
        self.statusBarItem.title = "XMR Ticker"
        self.priceStreamer = PriceStreamer(delegate:self)
        self.priceStreamer?.startStream()
    }

    //delegate callback for price update
    func didProcessPriceUpdate(_ updatedPrice:Quote)
    {
        DispatchQueue.main.async(execute: {
            
            switch updatedPrice.terms {
            case .usd:
                if (self.coinSymbolsEnabled == true)
                {
                    self.statusBarItem.title = "ɱ $\(updatedPrice.notional)"
                }
                else{
                    self.statusBarItem.title = "USD/XMR \(updatedPrice.notional)"
                }
            case .btc:
                if (self.coinSymbolsEnabled == true)
                {
                    self.statusBarItem.title = "ɱ Ƀ\(updatedPrice.notional)"
                }
                else{
                    self.statusBarItem.title = "BTC/XMR \(updatedPrice.notional)"
                }
            }
        })
    }
    
    @IBAction func quit(_ sender: Any) {
        self.priceStreamer?.stopStream()
        NSApplication.shared().terminate(self)
    }

}

