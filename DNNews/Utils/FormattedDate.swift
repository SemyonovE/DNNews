//
//  FormattedDate.swift
//  DNNews
//
//  Created by Evgenii Semenov on 24.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation

//MARK: Date formatter
class FormattedDate {
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    private var date: Date!
    
    public var string: String {
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
    
    init(date: Date? = nil) {
        self.date = date ?? Date()
    }
    
    init(dateString: String) {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        date = dateFormatter.date(from: dateString) ?? Date()
    }
}
