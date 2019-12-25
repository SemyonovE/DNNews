//
//  ResponseModels.swift
//  DNNews
//
//  Created by Evgenii Semenov on 24.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation

//MARK: Response models from api
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int?
    let articles: [Article]
}

struct Article: Codable {
    let source: ArticleSource?
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

struct ArticleSource: Codable {
    let id: String?
    let name: String
}

struct ApiError: Decodable, LocalizedError {
    let status: String
    let code: String?
    let message: String?
}
