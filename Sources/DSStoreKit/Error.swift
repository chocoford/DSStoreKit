//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/1.
//

import Foundation

struct DSStoreError: LocalizedError {
    var errorDescription: String?
    
    init(message: String) {
        self.errorDescription = message
    }
}
