//
//  NewsViewController.swift
//  DNNews
//
//  Created by Evgenii Semenov on 23.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import UIKit
import SnapKit
import RxDataSources
import RxSwift
import RxCocoa

//MARK: State of loading articles
fileprivate enum Refreshing {
    case ready
    case swiped
    case loading
    case initial
    case addition
}

class NewsViewController: UIViewController, UITableViewDelegate {

//MARK: Rx variables
    private var refreshing = BehaviorSubject<Refreshing>(value: .initial)
    private let disposeBag = DisposeBag()
    
//MARK: UI
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let activityIndicator = UIActivityIndicatorView()
    
//MARK: Controller variables
    private var numberOfArticles = 0
    public var viewModel = NewsViewModel()
    private var visibleCellIndexPath: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        
//MARK: If saved data exists, loading it, else request it
        let userData = UserData.shared
        if userData.data.count < APIService.pageSize {
            viewModel.searchNews()
        } else {
            viewModel.setAtricles(articles: userData.data)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
//MAKER: When user rotate device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            self.tableView.snp.updateConstraints { make in
                self.setTableViewWidthForIPad(maker: make, size: size)
            }
            return
        }
        self.visibleCellIndexPath = self.tableView.indexPathsForVisibleRows?.first
        
        coordinator.animate(alongsideTransition: nil, completion: { [unowned self] _ in
            self.tableView.scrollToRow(at: self.visibleCellIndexPath ?? IndexPath(row: 0, section: 0),
                                       at: .top,
                                       animated: false)
        })
        
        
        
    }

    private func setupRx() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.register(UINib(nibName: "ArticleTableViewCell",
                                 bundle: Bundle(for: type(of: self))),
                           forCellReuseIdentifier: "articleCell")
        tableView.register(UINib(nibName: "TryAgainTableViewCell",
                                 bundle: Bundle(for: type(of: self))),
                           forCellReuseIdentifier: "errorCell")
        
        let dataSource = RxTableViewSectionedReloadDataSource<NewsSectionModel>(configureCell: {
            dataSource, tableView, indexPath, model in
            switch model {
                case let .item(viewModel):
                    let itemCell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleTableViewCell
                    itemCell.viewModel = viewModel

                    return itemCell
                
                case let .errorConnection(viewModel):
                    let itemCell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath) as! TryAgainTableViewCell
                    itemCell.viewModel = viewModel
                    
//MARK: Try to load news again at the click of a button
                    itemCell.buttonTapped.subscribe(onNext : { [unowned self] _ in
                        self.requestMore()
                    }).disposed(by: itemCell.disposeBag)
                    
                    return itemCell
            }
        })
        
        viewModel.sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
//MARK: Updating state and number of articles when news reloaded
        viewModel.sections.subscribe(onNext: { [unowned self] articles in
            guard articles.count > 0 else { return }
            
            self.numberOfArticles = articles[0].items.count
            self.refreshing.onNext(.ready)
        }).disposed(by: disposeBag)
        
//MARK: Showing detail of news on a webView
        tableView.rx.modelSelected(NewsSectionItem.self)
            .bind { [unowned self] model in
                let viewController = DetailViewController()
                
                switch model {
                    case let .item(viewModel):
                        viewController.viewModel = DetailViewModel(url: viewModel.article.url)
                        self.navigationController?.pushViewController(viewController, animated: true)
                    
                default: break
                }
            }.disposed(by: disposeBag)

//MARK: Refresh or request more articles when it needed
        tableView.rx.contentOffset.bind { [unowned self] offset in
            guard let refreshing = try? self.refreshing.value() else { return }
            
            if refreshing == .ready && offset.y < -100 { // When user swiped down
                self.viewModel.currentPage = 1
                self.refreshing.onNext(.swiped)
                
            } else if refreshing == .swiped && offset.y == 0 { // When tableView returned after user's swipe
                self.viewModel.searchNews()
                self.refreshing.onNext(.loading)
                
            } else if refreshing == .ready // Request more articles when scrolled to bottom
                && offset.y > 0
                && offset.y > (self.tableView.contentSize.height - self.tableView.frame.height) {
                
                self.requestMore()
            }
            
        }.disposed(by: disposeBag)

//MARK: Changing state of loading indicator
        refreshing.subscribe(onNext: { state in
            switch state {
                case .ready:
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()

                case .swiped, .initial, .addition:
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()

                default: break
            }
        }).disposed(by: disposeBag)
    }
    
//MARK: Addition needed screen elements and making its' constraints
    private func setupUI() {
        
        if #available(iOS 13, *) {
            view.backgroundColor = UIColor.init { trait -> UIColor in
                return trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
            }
        } else {
            view.backgroundColor = .white
        }
        
        view.addSubview(searchBar) // Search bar
        searchBar.snp.makeConstraints { make in
            make.trailing.leading.top.equalTo(view.safeAreaLayoutGuide)
        }
        searchBar.text = viewModel.query
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        
        view.addSubview(tableView) // Table view
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            if UIDevice.current.userInterfaceIdiom == .pad {
                make.centerX.equalTo(view.safeAreaLayoutGuide)
                self.setTableViewWidthForIPad(maker: make, size: view.frame.size)
            } else {
                make.leading.trailing.equalTo(view)
            }
        }
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = .clear
        
        view.addSubview(activityIndicator) // Activity Indicator
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func requestMore() {
        guard viewModel.currentPage < 4 * APIService.pageSize else { return }
        
        viewModel.currentPage += 1
        refreshing.onNext(.addition)
        viewModel.addNews()
    }
    
    private func setTableViewWidthForIPad(maker: ConstraintMaker, size: CGSize) {
        if size.width > size.height {
            maker.width.equalTo(size.width - 256)
        } else {
            maker.width.equalTo(size.width - 128)
        }
    }
}

extension NewsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, text.count >= 3 else { return }
        
        self.viewModel.query = text
        self.viewModel.searchNews()
        view.endEditing(true)
    }
}
