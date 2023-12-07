//
//  File.swift
//  
//
//  Created by Chocoford on 2023/12/3.
//

import Foundation

extension FixedWidthInteger {
    func toBytes(endianness: Endianness) -> [UInt8] {
        var mutableValue = (endianness == .big) ? self.bigEndian : self.littleEndian
        return withUnsafeBytes(of: &mutableValue) { Array($0) }
    }
}
