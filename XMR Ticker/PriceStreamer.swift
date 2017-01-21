//
//  PriceStreamer.swift
//  XMR Ticker
//
//  Created by John Woods on 14/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Foundation

//protocol for listeners
protocol PriceListener:class
{
    func didProcessPriceUpdate(_ updatedPriceStream:Quote)
}
extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


class PriceStreamer
{
    //quote model
    var quote:Quote?
    
    //delegate
    weak var delegate:PriceListener?
    
    //init
    init(delegate:PriceListener?)
    {
        self.delegate = delegate
        print("XMR Ticker \(NSDate()): price streamer init")
    }
    
    convenience init()
    {
        self.init(delegate:nil)
    }
    
    //update timer
    var updateTimer:Timer?
    var frequencyInSeconds:Double = 30 {
        willSet{
            print("XMR Ticker \(NSDate()): frequency changed to \(newValue)")
        }
        didSet {
            self.restartStream()
        }
    }
    
    //start streaming prices
    func startStream(){
        print("XMR Ticker \(NSDate()): stream starting")
        //immediately update price
        self.priceFetch()
        //set periodic future update
        self.updateTimer = Timer.scheduledTimer(timeInterval: self.frequencyInSeconds, target: self, selector: #selector(priceFetch), userInfo: nil, repeats: true)
    }
    
    //restart stream (for config changes)
    func restartStream(){
        print("XMR Ticker \(NSDate()): stream restarting")
        self.stopStream()
        self.startStream()
    }
    
    //stop streaming prices
    func stopStream(){
        print("XMR Ticker \(NSDate()): timer restarting")
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }
    
    
    @objc func priceFetch ()
    {
        //set up the URL request
        let poloAPI: String = "https://poloniex.com/public?command=returnTicker"
        guard let url = URL(string: poloAPI) else {
            print("XMR Ticker \(NSDate()): cannot create URL: \(poloAPI)")
            return
        }
        let urlRequest = URLRequest(url: url)
    
        //make the request
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler:
        {
            (data, response, error) in
            
            //make sure we got data
            guard let responseData = data else {
                print("XMR Ticker \(NSDate()): did not receive data")
                return
            }
            //parse the result as json, since that's what the API provides
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("XMR Ticker \(NSDate()): error trying to convert data to JSON")
                    return
                }
                
                var xmrParsedNotionalDictionary:[String:Double] = ["usd": 0.00, "btc": 0.00]
                
                //package up dictionary of associated notional values
                xmrParsedNotionalDictionary["usd"] = (Double)(jsonResponse["USDT_XMR"]!["last"]! as! String? ?? "0.00")?.roundTo(places: 2)
                xmrParsedNotionalDictionary["btc"] = (Double)(jsonResponse["BTC_XMR"]!["last"]! as! String? ?? "0.00")?.roundTo(places: 6)
                
                self.quote = Quote(baseCurrency: .xmr, notionalValues: xmrParsedNotionalDictionary, quoteTime: NSDate())
                self.delegate?.didProcessPriceUpdate(self.quote ?? Quote(baseCurrency: .err, notionalValues: xmrParsedNotionalDictionary, quoteTime: NSDate()))
            }
            catch  {
                print("XMR Ticker \(NSDate()): error trying to convert data to JSON")
                return
            }
        });
        task.resume()
    }
}
