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
    //var apiUrl = "http://localhost:3000/beer"
    var apiUrl = "http://c44d78eb5a82.ngrok.io/beer"
}
