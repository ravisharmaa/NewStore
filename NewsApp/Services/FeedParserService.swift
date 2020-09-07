//
//  FeedParserService.swift
//  NewsApp
//
//  Created by Ravi Bastola on 9/3/20.
//

import Foundation
import Combine


struct FeedParserService {
    
    
    static let shared = FeedParserService()
    
    private init() {}
    
    func parse() -> AnyPublisher<XMLParser, Error>  {
        
        let request = URLRequest(url: URL(string: "https://www.onlinekhabar.com/content/entertainment/feed")!)
            
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { (element) -> Data in
            
            guard let response = element.response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkError.InvalidURL
            }
        
            return element.data
            
        }.map { (data) -> XMLParser in
           
            return XMLParser(data: data)
            
        }.eraseToAnyPublisher()
    }
}
