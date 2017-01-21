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
class AppDelegate: NSObject, NSApplicationDelegate, PriceListener
{
    
    //global array of triggers
    var triggerList:[Trigger] = [Trigger]()
    
    //quote
    var historicalQuote = Quote(baseCurrency: .xmr, notionalValues: nil, quoteTime: NSDate())
    var currentQuote = Quote(baseCurrency: .xmr, notionalValues: nil, quoteTime: NSDate())

    //trend settings
    enum Trend {
        case bullish
        case bearish
        case neutral
    }
    
    var trend:Trend = .neutral
    
    //terms settings
    enum Terms {
        case usd
        case btc
    }
    
    var displayTerms:Terms = .usd
    
    @IBOutlet weak var usdTermsButton: NSMenuItem!
    @IBOutlet weak var btcTermsButton: NSMenuItem!
    
    @IBAction func updateTermsChanged(_ sender: NSMenuItem)
    {
        print("XMR Ticker \(NSDate()): terms toggled")
        
        switch sender.title {
        case "USD":
            self.displayTerms = .usd
            self.usdTermsButton.state = NSOnState
            self.btcTermsButton.state = NSOffState
        case "BTC":
            self.displayTerms = .btc
            self.usdTermsButton.state = NSOffState
            self.btcTermsButton.state = NSOnState
        default:
            self.displayTerms = .usd
            self.usdTermsButton.state = NSOnState
            self.btcTermsButton.state = NSOffState
        }
        self.priceStreamer?.restartStream()
    }
    
    //coin symbols settings
    var coinSymbolsEnabled = false
    @IBOutlet weak var coinSymbolButton: NSMenuItem!
    @IBAction func coinSymbolButtonClicked(_ sender: NSMenuItem) {
        print("XMR Ticker \(NSDate()): coin symbols toggled")
        if(sender.state  == NSOffState)
        {
            self.coinSymbolsEnabled  = true
            sender.state = NSOnState
        }
        else{
            self.coinSymbolsEnabled = false
            sender.state = NSOffState
        }
        self.priceStreamer?.restartStream()
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
        }
        else{
            self.coloredSymbolsEnabled = false
            sender.state = NSOffState
        }
        self.priceStreamer?.restartStream()
    }


    
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


    //tip popover
    let tipPopover = NSPopover()
    @IBOutlet weak var tipButton: NSMenuItem!
    //tip view
    @IBAction func tipButtonClicked(_ sender: Any) {
        print("XMR Ticker \(NSDate()): tipping menu toggled")

        if (self.tipPopover.contentViewController == nil)
        {
            self.tipPopover.contentViewController = TipViewController(nibName: "TipViewController", bundle: nil)
            self.tipPopover.behavior = .transient
        }
        self.tipPopover.show(relativeTo: statusBarItem.button!.bounds, of: statusBarItem.button!, preferredEdge: .maxY)
    }


    //trigger popover
    let triggerPopover = NSPopover()
    @IBOutlet weak var triggerButton: NSMenuItem!
    //trigger view
    @IBAction func triggerButtonClicked(_ sender: Any) {
        print("XMR Ticker \(NSDate()): trigger menu toggled")
        
        if (self.triggerPopover.contentViewController == nil)
        {
            self.triggerPopover.contentViewController = TriggerViewController(nibName: "TriggerViewController", bundle: nil)
            self.triggerPopover.behavior = .transient
        }
        let triggerController = self.triggerPopover.contentViewController as? TriggerViewController
        triggerController?.localTriggerList = self.triggerList
        self.triggerPopover.show(relativeTo: statusBarItem.button!.bounds, of: statusBarItem.button!, preferredEdge: .maxY)
    }
    
    
    //main status bar control
    let statusBarItem = NSStatusBar.system().statusItem(withLength:NSVariableStatusItemLength) // statusbar
    @IBOutlet weak var tickerMenu: NSMenu! //overall menu object
    
    //pricestreamer object
    var priceStreamer:PriceStreamer?

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("XMR Ticker \(NSDate()): application launched")
        self.statusBarItem.menu = tickerMenu
        self.statusBarItem.title = "XMR Ticker"
        //perfect alignment adjustment
        self.statusBarItem.button?.frame = CGRect(x:0.0, y:1.0, width:self.statusBarItem.button!.frame.width, height:self.statusBarItem.button!.frame.height)
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
    
    func copyQuote (from: Quote, to: Quote) -> ()
    {
        to.baseCurrency = from.baseCurrency
        to.notionalValues = from.notionalValues
        to.quoteTime = from.quoteTime.copy() as! NSDate
    }

    //delegate callback for price update
    func didProcessPriceUpdate(_ updatedPriceStream:Quote)
    {
        //save into new
        self.copyQuote(from: updatedPriceStream, to: self.currentQuote)
        
        //check against old
        if(self.historicalQuote.notionalValues != nil)
        {
            switch self.displayTerms{
            case .usd:
                if(self.currentQuote.notionalValues!["usd"]! > self.historicalQuote.notionalValues!["usd"]!)
                {
                    self.trend = .bullish
                }
                else if(self.currentQuote.notionalValues!["usd"]! < self.historicalQuote.notionalValues!["usd"]!)
                {
                    self.trend = .bearish
                }
                else
                {
                    self.trend = .neutral
                }
            case .btc:
                if(self.currentQuote.notionalValues!["btc"]! > self.historicalQuote.notionalValues!["btc"]!)
                {
                    self.trend = .bullish
                }
                else if(self.currentQuote.notionalValues!["btc"]! < self.historicalQuote.notionalValues!["btc"]!)
                {
                    self.trend = .bearish
                }
                else
                {
                    self.trend = .neutral
                }
            }
        }
        else
        {
            self.trend = .neutral
        }
        
        //save into old
        self.copyQuote(from: self.currentQuote, to: self.historicalQuote)
        
        var updatedPriceString:String = String()
        
        DispatchQueue.main.async(execute: {
            switch self.displayTerms {
            case .usd:
                if (self.coinSymbolsEnabled == true)
                {
                    updatedPriceString = "ɱ $\(updatedPriceStream.notionalValues!["usd"]!)"
                }
                else
                {
                    updatedPriceString = "XMR/USD $\(updatedPriceStream.notionalValues!["usd"]!)"
                }
            case .btc:
                if (self.coinSymbolsEnabled == true)
                {
                    updatedPriceString = "ɱ Ƀ\(updatedPriceStream.notionalValues!["btc"]!)"
                }
                else
                {
                    updatedPriceString = "XMR/BTC \(updatedPriceStream.notionalValues!["btc"]!)"
                }
            }
            self.setAppropriateTextColor(updatedPriceString)
            self.processTriggers()
        })
    }
    
    func setAppropriateTextColor(_ forText: String)
    {
        let fontAttribute = [ NSFontAttributeName: NSFont.systemFont(ofSize: 14) ]
        let attributedString = NSMutableAttributedString(string: forText, attributes: fontAttribute)
        let appearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        if (self.coloredSymbolsEnabled)
        {

            switch self.trend {
            case .bullish:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.green , range: NSMakeRange(0, attributedString.length))
            case .bearish:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.red , range: NSMakeRange(0, attributedString.length))
            case .neutral:
                if (appearance == "Light")
                {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.black , range: NSMakeRange(0, attributedString.length))
                }
                else
                {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.white , range: NSMakeRange(0, attributedString.length))
                }
            }
        }
        else
        {
            if (appearance == "Light")
            {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.black , range: NSMakeRange(0, attributedString.length))
            }
            else
            {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.white , range: NSMakeRange(0, attributedString.length))
            }
        }
        //update the bar
        self.statusBarItem.attributedTitle = attributedString
        //self.postTriggerNotification(title: "Warning", body: forText)
    }
    
    func postTriggerNotification (title: String, body: String)
    {
        //create a User Notification
        let notification = NSUserNotification()
        
        //set the title and the informative text
        notification.title =  title
        notification.informativeText = body
        
        // use the default sound for a notification
        notification.soundName = NSUserNotificationDefaultSoundName
        
        // if the user chooses to display the notification as an alert, give it an action button called "View"
        notification.hasActionButton = false
        
        // Deliver the notification through the User Notification Center
        NSUserNotificationCenter.default.deliver(notification)
    }

    func processTriggers ()
    {
        if (self.triggerList.count > 0)
        {
            print("XMR Ticker \(NSDate()): Processing triggers")
        }
        else
        {
            print("XMR Ticker \(NSDate()): No triggers to process")

        }
    }
    
    @IBAction func quit(_ sender: Any) {
        self.priceStreamer?.stopStream()
        print("XMR Ticker \(NSDate()): terminating application")
        NSApplication.shared().terminate(self)
    }

}
