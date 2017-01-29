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
class AppDelegate: NSObject, NSApplicationDelegate, PriceListener, TriggerArrayReceiver, PortfolioTrackingListener
{
    
    //portfolio tracking settings
    var portfolioIsTracked:Bool = false
    var portfolioCoinCount:Double = 0.00
    
    //global array of trigger/alert models
    var triggerList:[Trigger] = [Trigger]()
    var indexesToRemove: [Int] = [Int]()
    
    //quote models - historical and current
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

    //portfolio popover
    let portfolioPopover = NSPopover()
    @IBOutlet weak var portfolioButton: NSMenuItem!
    //portfolio view
    @IBAction func portfolioButtonClicked(_ sender: NSMenuItem) {
        
        print("XMR Ticker \(NSDate()): portfolio menu toggled")
        
        if (self.portfolioPopover.contentViewController == nil)
        {
            self.portfolioPopover.contentViewController = PortfolioViewController(nibName: "PortfolioViewController", bundle: nil)
            self.portfolioPopover.behavior = .transient
        }
        //set delegate to self
        let portfolioController = self.portfolioPopover.contentViewController as? PortfolioViewController
        portfolioController?.delegate = self
        self.portfolioPopover.show(relativeTo: statusBarItem.button!.bounds, of: statusBarItem.button!, preferredEdge: .maxY)
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
        //set delegate to self
        triggerController?.delegate = self
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
    
    //helper function to deep copy quote model
    func copyQuote (from: Quote, to: Quote) -> ()
    {
        to.baseCurrency = from.baseCurrency
        to.notionalValues = from.notionalValues
        to.quoteTime = from.quoteTime.copy() as! NSDate
    }
    
    //delegate callback for portfolio tracking
    func portfolioTrackingStatusChanged(_ status:Bool)
    {
        self.portfolioIsTracked = status
        self.priceStreamer?.restartStream()
    }
    func portfolioCoinCountChanged(_ count:Double)
    {
        self.portfolioCoinCount = count
    }
    
    //delegate callback for triggers update
    func triggerArrayUpdated(_ triggers:[Trigger])
    {
        self.triggerList = triggers
        self.priceStreamer?.restartStream()
    }
    //delegate callback for price update
    func didProcessPriceUpdate(_ updatedPriceStream:Quote)
    {
        //save into new model
        self.copyQuote(from: updatedPriceStream, to: self.currentQuote)
        
        //check against old model
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
        
        //save into old model
        self.copyQuote(from: self.currentQuote, to: self.historicalQuote)
        
        var updatedPriceString:String = String()
        
        //do ui updates on main thread gcd call
        DispatchQueue.main.async(execute: {
            switch self.displayTerms {
            case .usd:
                if (self.coinSymbolsEnabled == true)
                {
                    updatedPriceString = "ɱ $\(self.currentQuote.notionalValues!["usd"]!.string(fractionDigits: 2))"
                }
                else
                {
                    updatedPriceString = "XMR/USD $\(self.currentQuote.notionalValues!["usd"]!.string(fractionDigits: 2))"
                }
            case .btc:
                if (self.coinSymbolsEnabled == true)
                {
                    updatedPriceString = "ɱ Ƀ\(self.currentQuote.notionalValues!["btc"]!)"
                }
                else
                {
                    updatedPriceString = "XMR/BTC \(self.currentQuote.notionalValues!["btc"]!)"
                }
            }
            //process new data
            self.setAppropriateTextColor(updatedPriceString)
            self.processTriggers()
            self.processPortfolio()
        })
    }
    
    func processPortfolio()
    {
        if (self.portfolioIsTracked)
        {
            let portfolioValue = self.portfolioCoinCount*self.currentQuote.notionalValues!["usd"]!
            self.portfolioButton.title = "Portfolio ($\(portfolioValue.string(fractionDigits: 2)))"
        }
        else
        {
            self.portfolioButton.title = "Portfolio"
        }

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
        //process triggers based on array of trigger models
        let title = "XMR Ticker: Alert!"
        if (self.triggerList.count > 0)
        {
            for (index, trigger) in self.triggerList.enumerated()
            {
                switch trigger.counterCurrency {
                case .usd:
                    switch trigger.logic {
                    case .greaterThan:
                        if(self.currentQuote.notionalValues!["usd"]! > trigger.triggerValue)
                        {
                            self.postTriggerNotification(title: title, body: "\(trigger.counterCurrency.rawValue) trigger hit, \(trigger.baseCurrency.rawValue)/\(trigger.counterCurrency.rawValue) now > $\(trigger.triggerValue.string(fractionDigits: 2)). Occured @ \(NSDate())")
                            indexesToRemove.append(index)
                        }
                    case .lessThan:
                        if(self.currentQuote.notionalValues!["usd"]! < trigger.triggerValue)
                        {
                            self.postTriggerNotification(title: title, body: "\(trigger.counterCurrency.rawValue) trigger hit, \(trigger.baseCurrency.rawValue)/\(trigger.counterCurrency.rawValue) now < $\(trigger.triggerValue.string(fractionDigits: 2)). Occured @ \(NSDate())")
                            indexesToRemove.append(index)

                        }
                    case .equalTo:
                        if(self.currentQuote.notionalValues!["usd"]! == trigger.triggerValue)
                        {
                            self.postTriggerNotification(title: title, body: "\(trigger.counterCurrency.rawValue) trigger hit, \(trigger.baseCurrency.rawValue)/\(trigger.counterCurrency.rawValue) now = $\(trigger.triggerValue.string(fractionDigits: 2)). Occured @ \(NSDate())")
                            indexesToRemove.append(index)
                        }
                    }
                case .btc:
                    switch trigger.logic {
                    case .greaterThan:
                        if(self.currentQuote.notionalValues!["btc"]! > trigger.triggerValue)
                        {
                            self.postTriggerNotification(title: title, body: "\(trigger.counterCurrency.rawValue) trigger hit, \(trigger.baseCurrency.rawValue)/\(trigger.counterCurrency.rawValue) now > \(trigger.triggerValue) BTC. Occured @ \(NSDate())")
                            indexesToRemove.append(index)
                        }
                    case .lessThan:
                        if(self.currentQuote.notionalValues!["btc"]! < trigger.triggerValue)
                        {
                            self.postTriggerNotification(title: title, body: "\(trigger.counterCurrency.rawValue) trigger hit, \(trigger.baseCurrency.rawValue)/\(trigger.counterCurrency.rawValue) now < \(trigger.triggerValue) BTC. Occured @ \(NSDate())")
                            indexesToRemove.append(index)
                            
                        }
                    case .equalTo:
                        if(self.currentQuote.notionalValues!["btc"]! == trigger.triggerValue)
                        {
                            self.postTriggerNotification(title: title, body: "\(trigger.counterCurrency.rawValue) trigger hit, \(trigger.baseCurrency.rawValue)/\(trigger.counterCurrency.rawValue) now = \(trigger.triggerValue) BTC. Occured @ \(NSDate())")
                            indexesToRemove.append(index)
                        }
                    }
                }
            }
            //remove each triggered alert after sorting indexes from largest to smallest to maintain array integrity
            if(self.indexesToRemove.count > 0)
            {
                //sort largest to smallest
                self.indexesToRemove.sort(by: >)
                //loop through indexes and remove from associated elements from model array
                for index in self.indexesToRemove
                {
                    self.triggerList.remove(at: index)
                }
                //reset array of indexes to remove
                self.indexesToRemove.removeAll()
            }
        }
    }
    
    @IBAction func quit(_ sender: Any) {
        self.priceStreamer?.stopStream()
        print("XMR Ticker \(NSDate()): terminating application")
        NSApplication.shared().terminate(self)
    }

}
