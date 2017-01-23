//
//  Trigger.swift
//  XMR Ticker
//
//  Created by John Woods on 21/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Foundation

class Trigger
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
