//
//  Model.swift
//  News-To-Watch
//
//  Created by Roman Tverdokhleb on 10.09.2023.
//

import Foundation

struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
    let author: String?
    var clickCounter: Int?
}

struct Source: Codable {
    let name: String
}
