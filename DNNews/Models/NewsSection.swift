//
//  NewsSection.swift
//  DNNews
//
//  Created by Evgenii Semenov on 24.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

//MARK: Setup model for news table's item
enum NewsSectionItem: IdentifiableType, Equatable {
    
    case item(ArticleTableViewCellViewModel)
    case errorConnection(TryAgainTableViewCellViewModel)
    
    typealias Identity = String
    
    var identity: String {
        switch self {
            case let .item(viewModel): return viewModel.article.title
        case let .errorConnection(viewModel): return viewModel.message ?? "error message"
        }
    }
    
    static func ==(lhs: NewsSectionItem, rhs: NewsSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

enum NewsSectionModel: IdentifiableType {
    
    case itemSection(content: [NewsSectionItem], header: String?, footer: String?)
    
    typealias Identity = String
    
    var identity: String {
        var value = ""
        switch self {
        case let .itemSection(_, header, footer):
            if let header = header { value += header }
            if let footer = footer { value += footer }
        }
        return value
    }
}

extension NewsSectionModel: AnimatableSectionModelType {
    typealias Item = NewsSectionItem
    
    var items: [Item] {
        switch self {
        case let .itemSection(content, _, _): return content
        }
    }
    
    init(original: NewsSectionModel, items: [Item]) {
        switch original {
        case let .itemSection(_, header, footer):
            self = .itemSection(content: items, header: header, footer: footer)
        }
    }
}

