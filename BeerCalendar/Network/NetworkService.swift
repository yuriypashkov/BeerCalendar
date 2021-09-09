//
//  NetworkService.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/26/21.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    private lazy var urlSession: URLSession = {
        return URLSession.init(configuration: .default)
    }()
    
    func requestBeerData(onResult: @escaping (Result<[BeerData], Error>) -> Void) {
        
        let url = URL(string: NetworkConfiguration.shared.apiUrl + NetworkAdresses.beer.rawValue)!
        let urlRequest = URLRequest(url: url)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                onResult(.failure(NetworkError.noData))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 400 else {
                onResult(.failure(NetworkError.failedResponse))
                return
            }
            
            do {
                let beerInfoResponse = try JSONDecoder().decode([BeerData].self, from: data)
                onResult(.success(beerInfoResponse))
            }
            catch {
                onResult(.failure(NetworkError.decodingError))
            }
        }
        
        dataTask.resume()
        
    }
    
    func requestBreweryData(onResult: @escaping (Result<[BreweryData], Error>) -> Void) {
        let url = URL(string: NetworkConfiguration.shared.apiUrl + NetworkAdresses.brewery.rawValue)!
        let urlRequest = URLRequest(url: url)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                onResult(.failure(NetworkError.noData))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 400 else {
                onResult(.failure(NetworkError.failedResponse))
                return
            }
            
            do {
                let beerInfoResponse = try JSONDecoder().decode([BreweryData].self, from: data)
                onResult(.success(beerInfoResponse))
            }
            catch {
                onResult(.failure(NetworkError.decodingError))
                //onResult(.failure(error))
            }
        }
        
        dataTask.resume()
    }
    
    func requestCrowdFindingData(onResult: @escaping (Result<CrowdFindingADData, Error>) -> Void) {
        let url = URL(string: NetworkConfiguration.shared.apiUrl + NetworkAdresses.crowdFinding.rawValue)!
        let urlRequest = URLRequest(url: url)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                onResult(.failure(NetworkError.noData))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 400 else {
                onResult(.failure(NetworkError.failedResponse))
                return
            }

            do {
                let beerInfoResponse = try JSONDecoder().decode(CrowdFindingADData.self, from: data)
                onResult(.success(beerInfoResponse))
            }
            catch (let error) {
                onResult(.failure(error))
            }
            
        }
        
        dataTask.resume()
    }
    
    
}

enum NetworkError: Error {
    case noData
    case failedResponse
    case decodingError
}

enum NetworkAdresses: String{
    case beer = "/beers"
    case brewery = "/breweries"
    case crowdFinding = "/crowdfinding"
}
