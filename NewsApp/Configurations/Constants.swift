//
//  Constants.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import Foundation


enum ApiConstants: CustomStringConvertible {
    
    case ApiKeyPrefix
    case ApiKey
    case NetworkPath
    case URLScheme
    case Host
    case QueryStringForKeyword
    case EndPointForEverything
    case CountryKeyword
    case TopHeadlines
    case General
    case Technology
    case Business
    case US
    
    var description: String {
        
        switch self {
        
        case .ApiKeyPrefix:
            return "apiKey"
        case .ApiKey:
            return "e0191b8e5d20470a9170f76115257c8e"
        case .NetworkPath:
            return "/v2/"
        case .URLScheme:
            return "https"
        case .Host:
            return "newsapi.org"
        case .QueryStringForKeyword:
            return "q"
        case .EndPointForEverything:
            return "everything"
        case .TopHeadlines:
            return "top-headlines"
        case .Business:
            return "business"
        case .Technology:
            return "technology"
        case .General:
            return "general"
        case .US:
            return "us"
        case .CountryKeyword:
            return "country"
        
        }
    }
}

enum CellReuseIdentifiers: CustomStringConvertible {
    
    case NewsCell
    
    var description: String {
        switch self {
       
        case .NewsCell:
            return "NewsCell"
        }
    }
}
