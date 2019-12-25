//
//  Article.swift
//  DNNews
//
//  Created by Evgenii Semenov on 24.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation
import UIKit

// MARK: Keys of each field of the article for saving
fileprivate enum PropertyKey {
    case title
    case imageUrl
    case content
    case date
    case url
    
    var value: String {
        switch self {
            case .title: return "title"
            case .imageUrl: return "imageUrl"
            case .content: return "content"
            case .date: return "date"
            case .url: return "url"
        }
    }
}

// MARK: Article model for saving to UserDefaults
class ArticleModel: NSObject, NSCoding {
    
    var title: String
    var imageUrl: String?
    var content: String?
    var date: String?
    var url: String
    
    init(article: Article) {
        self.title = article.title
        self.imageUrl = article.urlToImage
        self.content = article.description
        self.date = article.publishedAt
        self.url = article.url
    }
    
    override init() {
        self.title = ""
        self.imageUrl = nil
        self.content = nil
        self.date = nil
        self.url = ""
    }
    
    init(title: String, imageUrl: String?, content: String?, date: String?, url: String) {
        self.title = title
        self.imageUrl = imageUrl
        self.content = content
        self.date = date
        self.url = url
    }
    
    required convenience init(coder aCoder: NSCoder) {
        let title = aCoder.decodeObject(forKey: PropertyKey.title.value) as! String
        let imageUrl = aCoder.decodeObject(forKey: PropertyKey.imageUrl.value) as! String?
        let content = aCoder.decodeObject(forKey: PropertyKey.content.value) as! String?
        let date = aCoder.decodeObject(forKey: PropertyKey.date.value) as! String?
        let url = aCoder.decodeObject(forKey: PropertyKey.url.value) as! String
        self.init(title: title, imageUrl: imageUrl, content: content, date: date, url: url)
    }
    
    func encode(with acoder: NSCoder) {
        acoder.encode(title, forKey: PropertyKey.title.value)
        acoder.encode(imageUrl, forKey: PropertyKey.imageUrl.value)
        acoder.encode(content, forKey: PropertyKey.content.value)
        acoder.encode(date, forKey: PropertyKey.date.value)
        acoder.encode(url, forKey: PropertyKey.url.value)
    }
}
