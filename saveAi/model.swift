//
//  model.swift
//  saveAi
//
//  Created by Mohamet amine Ndiaye on 24/06/2024.
//

import Foundation
struct Product: Codable {
    let photoId: String
    let item: String
    let price: Double
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case photoId
        case item
        case price
        case category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        photoId = try container.decode(String.self, forKey: .photoId)
        item = try container.decode(String.self, forKey: .item)
        category = try container.decode(String.self, forKey: .category)
        
        // Handle price as a string and convert to Double
        let priceString = try container.decode(String.self, forKey: .price)
        if let priceValue = Double(priceString.replacingOccurrences(of: "$", with: "")) {
            price = priceValue
        } else {
            price = 0.0
        }
    }
}
