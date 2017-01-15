//
//  PriceStreamer.swift
//  XMR Ticker
//
//  Created by John Woods on 14/01/2017.
//  Copyright © 2017 John Woods. All rights reserved.
//

import Foundation

//protocol
protocol PriceListener:class {
    func didProcessPriceUpdate(_ updatedPrice:Quote)
}

class PriceStreamer
{
    //terms declaration
    enum Terms {
        case usd
        case btc
    }
    
    //terms default to USD
    var terms:Terms = .usd {
        didSet {
            self.restartStream()
        }
    }
    
    //update timer
    var updateTimer:Timer?
    var frequencyInSeconds:Double = 30 {
        didSet {
            self.restartStream()
        }
    }
    
    //quote model
    let quote:Quote = Quote()
    
    //delegate
    weak var delegate:PriceListener?
    
    //init
    init(delegate:PriceListener?)
    {
        self.delegate = delegate
    }
    convenience init()
    {
        self.init(delegate:nil)
    }
    
    //start streaming prices
    func startStream(){
        //immediately update price
        self.priceFetch()
        //set periodic update
        self.updateTimer = Timer.scheduledTimer(timeInterval: self.frequencyInSeconds, target: self, selector: #selector(priceFetch), userInfo: nil, repeats: true)
    }
    
    //restart stream (for config changes)
    func restartStream(){
        print("stream restarting")
        self.stopStream()
        self.startStream()
    }
    
    //stop streaming prices
    func stopStream(){
        print("timer reinit")
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }
    
    
    @objc func priceFetch ()
    {
        // Set up the URL request
        let poloAPI: String = "https://poloniex.com/public?command=returnTicker"
        guard let url = URL(string: poloAPI) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
    
        // make the request
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler:
        {
            (data, response, error) in
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                
                if(self.terms == .usd)
                {                    
                    self.quote.terms = .usd
                    self.quote.notional = (Double)(jsonResponse["USDT_XMR"]!["last"]! as! String? ?? "0.00")!

                }
                else if(self.terms == .btc)
                {
                    self.quote.terms = .btc
                    self.quote.notional = (Double)(jsonResponse["BTC_XMR"]!["last"]! as! String? ?? "0.00")!
                }
                self.delegate?.didProcessPriceUpdate(self.quote)
            }
            catch  {
                print("error trying to convert data to JSON")
                return
            }
            
        });
        task.resume()
    }
    
}
