//
//  Item.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/27/20.
//

import Foundation

struct Item: Hashable, Codable {
    let id: String
    let name: String
    let category: String
    var identifier = UUID()
}
