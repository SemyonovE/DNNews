//
//  TryAgainTableViewCell.swift
//  DNNews
//
//  Created by Evgenii Semenov on 25.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TryAgainTableViewCell: WithDisposeBagTableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
//MARK: Rx variables
    public let buttonTapped = PublishSubject<()>()
    
    public var viewModel: TryAgainTableViewCellViewModel! {
        didSet {
            messageLabel.text = viewModel.message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bindButtonTap()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bindButtonTap()
    }
    
    private func bindButtonTap() {
//MARK: Button tap binding
        tryAgainButton.rx.tap.bind { _ in
            self.buttonTapped.onNext(())
        }.disposed(by: disposeBag)
    }
    
}
