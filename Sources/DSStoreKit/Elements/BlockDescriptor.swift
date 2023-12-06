//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/4.
//

import Foundation

public struct BlockDescriptor: Hashable {
    public private(set) var address: UInt32
    public private(set) var offset: UInt32
    public private(set) var size: UInt32
    
    init(address: UInt32) {
        self.address = address
        let (offset, size) = BlockDescriptor.decodeOffsetAndSize(address)
        self.offset = offset
        self.size = size
    }
    
    static func encodeOffsetAndSize(offset: UInt32, size: UInt32) -> UInt32 {
        let offsetPart: UInt32 = offset & ~0x1F
        let sizePart: UInt32 = UInt32(log2(Double(size))) & 0x1F
        
        return offsetPart | sizePart
    }

    
    public static func decodeOffsetAndSize(_ value: UInt32) -> (offset: UInt32, size: UInt32) {
        let offset: UInt32 = value & ~0x1F
        let size: UInt32 = 1 << (value & 0x1F)
        
        return (offset: offset, size: size)
    }
}
