//
//  NewsViewModel.swift
//  DNNews
//
//  Created by Evgenii Semenov on 23.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class NewsViewModel {
    
//MARK: Sections of news for table
    public let sections = BehaviorRelay<[NewsSectionModel]>(value: [])
    
//MARK: Rx variables
    private let apiService = MoyaProvider<APIService>(plugins: [])//NetworkLogPlugin()])
    private let disposeBag = DisposeBag()
    private let error = PublishSubject<ApiError?>()
    
//MARK: Model's events
    private let searchEvent = PublishSubject<()>()
    private let addNewsEvent = PublishSubject<()>()

//MARK: Model's variables
    private var isLastLoadingSuccess = false
    public var query = "apple"
    public var currentPage = 1
    private var errorMessage: String? = nil
    
    init() {
        searchEvent // When user search some news or reload its
            .flatMapLatest{ [unowned self] _ in
                return self.prepareArticles()
            }.map { items in
                self.saveUserData(data: items)
                return [NewsSectionModel.itemSection(content: items, header: nil, footer: nil)]
            }.bind(to: sections)
            .disposed(by: disposeBag)
        
        addNewsEvent // When user requests more news
            .flatMapLatest{ [unowned self] _ in
                return self.prepareArticles()
            }.filter { $0.count > 0 }
            .map { [unowned self] newItems in
                switch self.sections.value[0] {
                    case var .itemSection(content: currentItems, header: _, footer: _):
                        currentItems = currentItems.filter { self.filterErrorItems(item: $0) }
                        let initialSize = currentItems.count
                        
                        for item in newItems { // Append new unique articles
                            if !currentItems.contains(item) {
                                currentItems.append(item)
                            }
                        }
                        
//MARK: Return latest news when last page was requested
                        if self.currentPage > 4 * APIService.pageSize {
                            return self.sections.value
                        }
                        
//MARK: Request new articles when its already exist
                        if initialSize == currentItems.count && self.currentPage < 4 * APIService.pageSize {
                            self.currentPage += 1
                            self.addNews()
                            return []
                        }
                        
                        self.saveUserData(data: currentItems) // Save news to UserDefaults
                        return [NewsSectionModel.itemSection(content: currentItems, header: nil, footer: nil)]
                }
            }
            .filter { $0.count > 0 }
            .bind(to: sections)
            .disposed(by: disposeBag)
        
//MARK: Printing error message when error
        error.subscribe(onNext: { error in
            if let message = error?.message {
                print(message)
            } else {
                print("Unnowned error")
            }
        }).disposed(by: disposeBag)
    }
    
//MARK: Creating table sections items from models
    func prepareArticles() -> Observable<[NewsSectionItem]> {
        return self.load()
            .map { response in
                guard let response = response else {
                    let model = TryAgainTableViewCellViewModel(message: self.errorMessage)
                    return [NewsSectionItem.errorConnection(model)]
                }
                
                return response.articles.map { article -> NewsSectionItem in
                    let model = ArticleTableViewCellViewModel(article: ArticleModel(article: article))
                    return NewsSectionItem.item(model)
                }
            }
    }
    
    func searchNews() { // When search or refresh
        searchEvent.onNext(())
    }
    
    func addNews() { // When request morw news
        if !isLastLoadingSuccess { // Request last page again when it hasn't been loaded
            currentPage -= 1
        }
        addNewsEvent.onNext(())
    }

//MARK: News loading
    func load() -> Observable<NewsResponse?> {
        if self.currentPage < 1 {
            isLastLoadingSuccess = false
            return Observable<NewsResponse?>.just(nil) // Return nil when number of page is incorrect for api
        }
        
        return apiService.rx.request(.loadNews(self.query, self.currentPage))
            .timeout(3, scheduler: MainScheduler.instance)
            .do(onSuccess: { response in
                if response.statusCode != 200 { // When successful API response with error code
                    self.isLastLoadingSuccess = false

                    if let json = try JSONSerialization.jsonObject(with: response.data) as? [String: String],
                        let message = json["message"] {
                        
                        self.errorMessage = message
                    }
                } else {
                    self.isLastLoadingSuccess = true
                }
            }, onError: { _ in
                self.isLastLoadingSuccess = false
            })
            .asObservable()
//            .filterSuccessfulStatusCodes()
            .map(NewsResponse?.self)
            .catchError { [weak self] error in
                self?.catchError(error)
                return Observable<NewsResponse?>.just(nil)
            }
    }
    
    private func catchError(_ error: Error) {
        if let apiError = error as? ApiError {
            self.errorMessage = apiError.message
            self.error.onNext(apiError)
        } else {
            self.errorMessage = "No connection"
        }
    }
    
//MARK: Setup articles instead of loading them
    public func setAtricles(articles: [ArticleModel]) {
        sections.accept([NewsSectionModel.itemSection(content: articles
            .map { article -> NewsSectionItem in
                let model = ArticleTableViewCellViewModel(article: article)
                return NewsSectionItem.item(model)
            }, header: nil, footer: nil)])
    }
    
//MARK: Changing items of articles to
    private func saveUserData(data: [NewsSectionItem]) {
        guard data.count > 1 else { return }
        
        UserData.shared.saveData(newData: data
            .filter { self.filterErrorItems(item: $0) }
            .map { item -> ArticleModel in
            switch item {
                case let .item(model):
                    return model.article
                default: return ArticleModel()
            }
        })
    }
    
    private func filterErrorItems(item :NewsSectionItem) -> Bool {
        switch item {
            case .item: return true
            case .errorConnection: return false
        }
    }
}
