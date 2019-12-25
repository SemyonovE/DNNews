//
//  WithDisposeBagTableViewCell.swift
//  DNNews
//
//  Created by Evgenii Semenov on 25.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WithDisposeBagTableViewCell: UITableViewCell {

    public var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
