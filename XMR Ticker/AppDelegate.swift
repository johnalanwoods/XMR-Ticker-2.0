//
//  AppDelegate.swift
//  XMR Ticker
//
//  Created by John Woods on 14/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Cocoa

@NSApplicationMain
//adhere to delegate protocol as PriceListener
class AppDelegate: NSObject, NSApplicationDelegate, PriceListener {

    //store last quote
    var historicalQuote = Quote()
    
    //coin symbols settings
    var coinSymbolsEnabled = false
    @IBOutlet weak var coinSymbolButton: NSMenuItem!
    @IBAction func coinSymbolButtonClicked(_ sender: NSMenuItem) {
        print("XMR Ticker \(NSDate()): coin symbols toggled")
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
    
    //colored symbols settings
    var coloredSymbolsEnabled = false
    @IBOutlet weak var coloredSymbolsButton: NSMenuItem!
    @IBAction func coloredSymbolsButtonClicked(_ sender: NSMenuItem) {
        print("XMR Ticker \(NSDate()): color symbols toggled")
        
        if(sender.state  == NSOffState)
        {
            self.coloredSymbolsEnabled  = true
            sender.state = NSOnState
            self.priceStreamer?.restartStream()
        }
        else{
            self.coloredSymbolsEnabled = false
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
        print("XMR Ticker \(NSDate()): update frequency toggled")
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
        print("XMR Ticker \(NSDate()): terms toggled")

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
        print("XMR Ticker \(NSDate()): tipping menu toggled")

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
        print("XMR Ticker \(NSDate()): application launched")

        self.statusBarItem.menu = tickerMenu
        self.statusBarItem.title = "XMR Ticker"
        self.priceStreamer = PriceStreamer(delegate:self)
        self.priceStreamer?.startStream()
        let notificationName = Notification.Name("AppleInterfaceThemeChangedNotification")
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(colorModeChange), name:notificationName, object: nil)

    }
    
    func colorModeChange ()
    {
        print("XMR Ticker \(NSDate()): OS level color toggled")
        self.priceStreamer?.restartStream()
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
                    self.statusBarItem.title = "USD/XMR $\(updatedPrice.notional)"
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
            self.setAppropriateTextColor(updatedPrice)
        })
    }
    
    func setAppropriateTextColor(_ currentQuote: Quote)
    {
        let attribute = NSMutableAttributedString.init(string: self.statusBarItem.title!)
        let appearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        if (self.coloredSymbolsEnabled)
        {

            if(self.historicalQuote.notional > currentQuote.notional)
            {
                attribute.addAttribute(NSForegroundColorAttributeName, value: NSColor.red , range: NSMakeRange(0, attribute.length))
            }
            else if(self.historicalQuote.notional < currentQuote.notional)
            {
                attribute.addAttribute(NSForegroundColorAttributeName, value: NSColor.green , range: NSMakeRange(0, attribute.length))
            }
            else
            {
                if (appearance == "Light")
                {
                    attribute.addAttribute(NSForegroundColorAttributeName, value: NSColor.black , range: NSMakeRange(0, attribute.length))
                }
                else
                {
                    attribute.addAttribute(NSForegroundColorAttributeName, value: NSColor.white , range: NSMakeRange(0, attribute.length))
                }
            }
        }
        else
        {
            if (appearance == "Light")
            {
                attribute.addAttribute(NSForegroundColorAttributeName, value: NSColor.black , range: NSMakeRange(0, attribute.length))
            }
            else
            {
                attribute.addAttribute(NSForegroundColorAttributeName, value: NSColor.white , range: NSMakeRange(0, attribute.length))
            }
        }
        
        //print(Unmanaged.passUnretained(historicalQuote).toOpaque())

        self.statusBarItem.attributedTitle = attribute
        self.historicalQuote.notional = currentQuote.notional
        self.historicalQuote.terms = currentQuote.terms
    }
    

    
    @IBAction func quit(_ sender: Any) {
        self.priceStreamer?.stopStream()
        print("XMR Ticker \(NSDate()): terminating application")
        NSApplication.shared().terminate(self)
    }

}

