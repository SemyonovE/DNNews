//
//  APIService.swift
//  DNNews
//
//  Created by Evgenii Semenov on 23.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation
import Moya

enum APIService: TargetType {
    
    case loadNews(String, Int)
    
    static var pageSize = 5 // Page size for requesting from api
    
    var headers: [String : String]? {
        return [
            "Content-Type"  : "application/json",
            "charset"       : "utf-8"
        ]
    }
    
    var baseURL: URL {
        return URL(string: "https://newsapi.org/")!
    }
    
    var path: String {
        return "v2/everything"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any] {
        var temporaryParameters = [String: Any]()
        
        switch self {
            case let .loadNews(query, page): // Creating url parameters for api
                temporaryParameters["q"] = query
                temporaryParameters["from"] = FormattedDate().string
                temporaryParameters["sortBy"] = "publishedAt"
                temporaryParameters["language"] = "ru"
                temporaryParameters["pageSize"] = APIService.pageSize
                temporaryParameters["apiKey"] = "4eb7d576aff8468798ef37153fd32c76"
                                                //"26eddb253e7840f988aec61f2ece2907"
                temporaryParameters["page"] = page
        }
        
        return temporaryParameters
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters,
                                  encoding: URLEncoding(destination: .queryString))
    }
    
    var sampleData: Data {
        var data: Data?
        
        switch self {
            case .loadNews:
                if let path = Bundle.main.path(forResource: "News", ofType: "json") {
                    data = try? Data(contentsOf: URL(fileURLWithPath: path))
                }
        }
        
        return data ?? Data()
    }
}
