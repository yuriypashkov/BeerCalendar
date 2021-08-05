//
//  NetworkConfiguration.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/26/21.
//

import Foundation

class NetworkConfiguration {
    
    static let shared = NetworkConfiguration()
    
    var token = ""
    //var apiUrl = "https://api.untappd.com/v4/beer/info/BID"
    var apiUrl = "http://12d2db6f3f41.ngrok.io/beer"
}
