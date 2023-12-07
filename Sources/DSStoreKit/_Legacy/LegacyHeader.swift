//
//  LegacyHeader.swift
//  
//
//  Created by Chocoford on 2023/12/7.
//

import Foundation

struct Header_Old {
    public var alignment: UInt32
    public var magic: UInt32
    public var offset1: UInt32
    public var size: UInt32
    public var offset2: UInt32
    
    public init(stream: BinaryStream) throws {
        try stream.seek(offset: 0, from: .begin)
        
        self.alignment = try stream.readUInt32(endianness: .big)
        self.magic = try stream.readUInt32(endianness: .big)
        self.offset1 = try stream.readUInt32(endianness: .big)
        self.size = try stream.readUInt32(endianness: .big)
        self.offset2 = try stream.readUInt32(endianness: .big)
        
        guard self.alignment == 0x01, self.magic == 0x42756431 else {
            throw DSStoreError(message: "Invalid header magic bytes")
        }
        
        guard self.offset1 == self.offset2, self.offset1 > 0 else {
            throw DSStoreError(message: "Invalid allocator offset")
        }
        
        guard self.size > 0 else {
            throw DSStoreError(message: "Invalid allocator size")
        }
    }
}
