//
//  UserData.swift
//  DNNews
//
//  Created by Evgenii Semenov on 25.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation

class UserData {
    
    private let dataKey = "DNNewsApp"
    
    public var data: [ArticleModel] = []
    static let shared = UserData()
    
// MARK: Loading saved articles if it exists
    init() {
        if let data = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: dataKey) as? Data ?? Data()) as? [ArticleModel] {
            self.data = data
        }
    }
    
// MARK: Saving articles to UserDefaults
    func saveData(newData: [ArticleModel]) {
        data = newData
        
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: data), forKey: dataKey)
    }
}
