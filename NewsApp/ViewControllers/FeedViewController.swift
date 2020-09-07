//
//  FeedViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 9/4/20.
//

import UIKit
import Combine

class FeedViewController: UIViewController {
    
    
    var subscription: AnyCancellable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscription = FeedParserService.shared.parse().sink(receiveCompletion: { (_) in
            //
        }, receiveValue: { (parser) in
            parser.delegate = self
            parser.parse()
        })
        
    }
}


extension FeedViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "description":
            print(attributeDict["description"])
        default:
            print("hello")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(string)
    }
    
}
