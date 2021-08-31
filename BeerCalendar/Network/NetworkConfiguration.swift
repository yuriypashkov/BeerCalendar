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
    //var apiUrl = "http://localhost:3000"
    var apiUrl = "https://adb3-78-107-92-206.ngrok.io"
    //var apiUrl = "http://188.119.67.67:3000"
}
