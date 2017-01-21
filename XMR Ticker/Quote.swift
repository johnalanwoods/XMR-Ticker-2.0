//
//  Quote.swift
//  XMR Ticker
//
//  Created by John Woods on 14/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Foundation

class Quote
{
    enum BaseCurrency{
        case xmr //monero
        case btc //bitcoin
        case usd //us dollar
        case err //error case
    }
    var baseCurrency:BaseCurrency?
    var notionalValues:[String:Double]?
    var quoteTime:NSDate
    
    //init
    init(baseCurrency:BaseCurrency?, notionalValues:[String:Double]?, quoteTime:NSDate)
    {
        self.baseCurrency = baseCurrency
        self.notionalValues = notionalValues
        self.quoteTime = NSDate()
    }
}
