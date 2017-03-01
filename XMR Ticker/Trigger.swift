//
//  Trigger.swift
//  XMR Ticker
//
//  Created by John Woods on 21/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Foundation

class Trigger: NSObject, NSCoding
{
    enum BaseCurrency:String {
        case xmr = "XMR" //monero
    }
    enum CounterCurrency:String {
        case btc = "BTC" //bitcoin
        case usd = "USD" //us dollar
    }
    enum Logic:String {
        case greaterThan = ">"
        case lessThan = "<"
        case equalTo = "="
    }
    
    var baseCurrency:BaseCurrency
    var counterCurrency:CounterCurrency
    var triggerValue:Double
    var quoteTime:NSDate
    var logic:Logic
    
    
    required init(coder decoder: NSCoder) {
        
        self.baseCurrency = BaseCurrency(rawValue: (decoder.decodeObject(forKey: "baseCurrency" ) as! String)) ?? BaseCurrency.xmr
        self.counterCurrency = CounterCurrency(rawValue: (decoder.decodeObject(forKey: "counterCurrency" ) as! String)) ?? CounterCurrency.btc
        self.triggerValue = decoder.decodeDouble(forKey: "triggerValue")
        self.quoteTime = decoder.decodeObject(forKey: "quoteTime") as? NSDate ?? NSDate()
        self.logic = Logic(rawValue: (decoder.decodeObject(forKey: "logic" ) as! String)) ?? Logic.equalTo

    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.baseCurrency.rawValue, forKey: "baseCurrency")
        coder.encode(self.counterCurrency.rawValue, forKey: "counterCurrency")
        coder.encode(self.triggerValue, forKey: "triggerValue")
        coder.encode(self.quoteTime, forKey: "quoteTime")
        coder.encode(self.logic.rawValue, forKey: "logic")
    }
    
    //init
    init(baseCurrency:BaseCurrency, counterCurrency:CounterCurrency, logic:Logic, triggerValue:Double, quoteTime:NSDate)
    {
        self.baseCurrency = baseCurrency
        self.counterCurrency = counterCurrency
        self.logic = logic
        self.triggerValue = triggerValue
        self.quoteTime = NSDate()
    }
}
