//
//  Trigger.swift
//  XMR Ticker
//
//  Created by John Woods on 21/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Foundation
class Trigger:
{
    enum BaseCurrency{
        case xmr //monero
        case btc //bitcoin
        case usd //us dollar
        case err //error case
    }
    enum CounterCurrency{
        case xmr //monero
        case btc //bitcoin
        case usd //us dollar
        case err //error case
    }
    
    var baseCurrency:BaseCurrency
    var counterCurrency:CounterCurrency
    var triggerValue:Double
    var quoteTime:NSDate
    
    //init
    init(baseCurrency:BaseCurrency, counterCurrency:CounterCurrency, triggerValue:Double, quoteTime:NSDate)
    {
        self.baseCurrency = baseCurrency
        self.counterCurrency = counterCurrency
        self.triggerValue = triggerValue
        self.quoteTime = NSDate()
    }
}
