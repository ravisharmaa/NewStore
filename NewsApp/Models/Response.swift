//
//  Response.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import Foundation

struct Response: Codable, Hashable {
    let status: String?
    let sources: [Source]?
    
    let uuid = UUID()
    
    enum CodingKeys: String, CodingKey {
        case status
        case sources
        case uuid
    }
    
    
    struct Source: Codable, Hashable {
        let id: String?
        let name: String?
        let category: String?
        let uuid = UUID()
        
        enum CodingKeys: String, CodingKey {
            case id, name, category
            case uuid
        }
    }
    
    static var placeholder: Response {
        return Response(status: nil, sources: nil)
    }
}

typealias Sources = [Response.Source]
