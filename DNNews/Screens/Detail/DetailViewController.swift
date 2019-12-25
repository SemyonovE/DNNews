//
//  DetailViewController.swift
//  DNNews
//
//  Created by Evgenii Semenov on 23.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {
    
//MARK: UI
    private let webView = UIWebView()
    private let activityIndicator = UIActivityIndicatorView()
    
//MARK: Rx
    private let disposeBag = DisposeBag()
    
//MARK: View model
    public var viewModel: DetailViewModel! {
        didSet {
            guard let url = viewModel.url else {
                self.showAlertWhenError(message: "URL is not correct")
                return
            }
            
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        if #available(iOS 13, *) { // Initial color themes of the main view and the navigation bar
            let commonColor = UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
            }
            view.backgroundColor = commonColor
            navigationController?.navigationBar.barTintColor = commonColor
        } else {
            view.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = .white
        }
        
        view.addSubview(webView) // Web view
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(activityIndicator) // Activity indicator
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.startAnimating()
        
//MARK: Web view events
        webView.rx.didFinishLoad.bind { [weak self] _ in
            self?.stopActivityIndicator()
        }.disposed(by: disposeBag)
        
        webView.rx.didFailLoad.bind { [weak self] error in
            self?.stopActivityIndicator()
            self?.showAlertWhenError(message: error.localizedDescription)
        }.disposed(by: disposeBag)
    }
    
//MARK: When the web page is loaded
    private func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
//MARK: Alert message for user when error of loading web page
    private func showAlertWhenError(message: String? = nil) {
        let alert = UIAlertController(title: "Error was happened",
                                      message: message ?? "Web page not fully loaded",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
