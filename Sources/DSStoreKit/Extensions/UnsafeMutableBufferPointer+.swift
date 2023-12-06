//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/1.
//

import Foundation
public extension UnsafeMutableBufferPointer{
    func toArray() -> [Element] {
        Array(unsafeUninitializedCapacity: self.count) {
            for i in 0 ..< self.count {
                $0[i] = self[i]
            }
            
            $1 = self.count
        }
    }
}
