//
//  ArticleTableViewCell.swift
//  DNNews
//
//  Created by Evgenii Semenov on 23.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

fileprivate let noImage = UIImage(named: "noimage")!

class ArticleTableViewCell: WithDisposeBagTableViewCell {

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
//MARK: View model for setup fields of the cell
    public var viewModel: ArticleTableViewCellViewModel! {
        didSet {
            
            if let url = self.viewModel.article.imageUrl {
                self.imageCover.kf.setImage(with: URL(string: url), placeholder: noImage)
            } else {
                self.imageCover.image = noImage
            }
                
            self.titleLabel.text = self.viewModel.article.title
            self.contentLabel.text = self.viewModel.article.content
            if let dateString = self.viewModel.article.date {
                self.dateLabel.text = FormattedDate(dateString: dateString).string
            }
        }
    }
}
