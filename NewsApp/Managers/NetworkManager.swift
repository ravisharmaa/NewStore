//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import UIKit
import Combine

protocol ApiConfiguration {
    
    var apiKey: String { get }
    
    var path: String { get }
}


enum NetworkError: String, Error {
    case InvalidURL = "The url is invalid"
    case InvalidResponse = "The response is invalid"
    case InvalidData = "The data is invalid"
    case JSONError = "The json is invalid"
}


struct NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    private var urlComponents: URLComponents =  {
        var component = URLComponents()
        component.scheme = ApiConstants.URLScheme.description
        component.host = ApiConstants.Host.description
        return component
        
    }()
    
}

extension NetworkManager: ApiConfiguration {
     
    internal var apiKey: String {
        return ApiConstants.ApiKey.description
    }
    
    internal var path: String {
        return ApiConstants.NetworkPath.description
    }
    
     func sendRequest<T: Codable>(to endpoint: String, model: T.Type, queryItems: [String: Any]?) -> AnyPublisher<T, NetworkError> {
        
        var innerUrl = urlComponents
        
        innerUrl.path = path + endpoint
        
        var urlQueryItem = [URLQueryItem]()
        
        if let queryItems = queryItems {
            for (key, data) in queryItems where queryItems.count > 0 {
                urlQueryItem.append(URLQueryItem(name:key, value: data as? String))
            }
        }
        
        urlQueryItem.append(URLQueryItem(name: ApiConstants.ApiKeyPrefix.description, value: apiKey))
       
        innerUrl.queryItems = urlQueryItem
        
        
        guard let url = innerUrl.url else {
           fatalError()
        }
        
        
        let urlPublisher = URLSession.shared.dataTaskPublisher(for: url)
        
        return urlPublisher.map({$0.data})
            
            .decode(type: T.self, decoder: JSONDecoder())
            
            .catch({ (_) -> AnyPublisher<T, NetworkError> in
                return Empty<T, NetworkError>().eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
