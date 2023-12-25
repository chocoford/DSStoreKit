//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/25.
//

import Foundation

extension URL {
    var filePath: String {
        if #available(macOS 13.0, *) {
            self.path(percentEncoded: false)
        } else {
            self.path
        }
    }
}
