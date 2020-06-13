//
//  Model.swift
//  NewsApi
//
//  Created by Faizyy on 13/06/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import Foundation

struct Model: Decodable {
    var status: String
    var totalResults: Int
    var articles: Array<Article>
}

struct Article: Decodable {
    var title: String
    var desc: String
    var urlToImage: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case desc = "description"
        case title
        case url
        case urlToImage
    }
}
