//
//  Everything.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import Foundation

struct Everything: Codable, Hashable {
    let status: String?
    let totalResults: Int?
    let articles: [Articles]?

    let uuid = UUID()
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case articles
        case uuid
    }
    

    struct Articles: Codable, Hashable {
        
        let source: Response.Source?
        let author: String?
        let title: String?
        let url: String?
        let urlToImage: String?
        let content: String?
        let description: String?
        
        let uuid = UUID()
        
        enum CodingKeys: String, CodingKey {
            case author, title, url, urlToImage, content, description, uuid, source
        }
    }
    
    static var placeholder: Everything {
        return Everything(status: nil, totalResults: nil, articles: nil)
    }
    
}
