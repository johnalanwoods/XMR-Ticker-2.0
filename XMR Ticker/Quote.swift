//
//  Quote.swift
//  XMR Ticker
//
//  Created by John Woods on 14/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Foundation

class Quote
{   //terms declaration
    enum Terms {
        case usd
        case btc
    }
    
    var terms:Terms = .usd
    var notional:Double = 0.00
}
