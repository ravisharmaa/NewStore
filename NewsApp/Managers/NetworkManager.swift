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
    case InvalidURL = "The url is invalid."
    case InvalidResponse = "The response is invalid."
    case InvalidData = "The data is invalid."
    case JSONError = "The json is invalid."
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



enum RequestMethod: CustomStringConvertible {
    case get
    case post
    case put
    case patch
    case delete
    
    var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}

extension NetworkManager: ApiConfiguration {
    
    internal var apiKey: String {
        return ApiConstants.ApiKey.description
    }
    
    internal var path: String {
        return ApiConstants.NetworkPath.description
    }
    
    func sendRequest<T: Codable>(to endpoint: String, method: RequestMethod = .get, model: T.Type, queryItems: [String: Any]?, postData: [String: Any]? = nil)  -> AnyPublisher<T, NetworkError> {
        
        var innerUrl = urlComponents
        
        innerUrl.path = path + endpoint
        
        var urlQueryItem: [URLQueryItem] = []
        
        if let queryItems = queryItems {
            for (key, data) in queryItems where queryItems.count > 0 {
                urlQueryItem.append(.init(name:key, value: data as? String))
            }
        }
        
        urlQueryItem.append(URLQueryItem(name: ApiConstants.ApiKeyPrefix.description, value: apiKey))
        
        innerUrl.queryItems = urlQueryItem
        
        
        guard let url = innerUrl.url else {
            return Empty<T, NetworkError>().eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.description
        
        
        let urlPublisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
        
        return urlPublisher.tryMap({ (element) -> Data in
            
            guard let response = element.response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkError.InvalidResponse
            }
            return element.data
        })
        .decode(type: T.self, decoder: JSONDecoder())
        
        .catch({ (_) -> AnyPublisher<T, NetworkError> in
            return Empty<T, NetworkError>().eraseToAnyPublisher()
        }).eraseToAnyPublisher()
    }
}
