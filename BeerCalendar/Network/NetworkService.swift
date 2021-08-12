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
        
        let url = URL(string: NetworkConfiguration.shared.apiUrl + "/beers")!
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
            catch (let error) {
                onResult(.failure(error))
            }
        }
        
        dataTask.resume()
        
    }
    
    func requestBreweryData(onResult: @escaping (Result<[BreweryData], Error>) -> Void) {
        let url = URL(string: NetworkConfiguration.shared.apiUrl + "/breweries")!
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
            catch (let error) {
                onResult(.failure(error))
            }
        }
        
        dataTask.resume()
    }
    
//    func requestAllData(onResult: @escaping (Result<([BeerData],[BreweryData]), Error>) -> Void) {
//        let urls = [URL(string: NetworkConfiguration.shared.apiUrl + "/beers")!, URL(string: NetworkConfiguration.shared.apiUrl + "/breweries")!]
//        var result = ([BeerData](), [BreweryData]())
//        var subjectCollection = [BeerData]()
//        let urlDownloadQueue = DispatchQueue(label: "com.urlDownloader.urlqueue")
//        let urlDownloadGroup = DispatchGroup()
//        
//        urls.forEach { url in
//            urlDownloadGroup.enter()
//            let urlRequest = URLRequest(url: url)
//            
//            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//                guard let data = data, let subject = try? JSONDecoder().decode(BeerData.self, from: data) else {
//                    urlDownloadQueue.async {
//                        urlDownloadGroup.leave()
//                    }
//                    return
//                }
//                urlDownloadQueue.async {
//                        subjectCollection.append(subject)
//                        urlDownloadGroup.leave()
//                }
//            }
//            
//        }
//        
//        urlDownloadGroup.notify(queue: DispatchQueue.global()) {
//                completion(subjectCollection)
//            }
//        
//    }
    
}

enum NetworkError: Error {
    case noData
    case failedResponse
}
