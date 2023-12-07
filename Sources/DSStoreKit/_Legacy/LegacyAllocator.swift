//
//  LegacyAllocator.swift
//  
//
//  Created by Chocoford on 2023/12/7.
//

import Foundation

struct Allocator_Old {
    public private(set) var blocks = [(offset: UInt32, size: UInt32)]()
    public private(set) var directories = [(name: String, id: UInt32)]()
    public private(set) var freeList = [[UInt32]]()
    
    public init(stream: BinaryStream, header: Header_Old) throws {
        try stream.seek(offset: size_t(header.offset1) + 4, from: .begin)
        
        let n = try stream.readUInt32(endianness: .big)
        
        try stream.seek(offset: 4, from: .current)
        
        for _ in 0 ..< n {
            self.blocks.append(Allocator.decodeOffsetAndSize(try stream.readUInt32(endianness: .big)))
        }
        
        let remaining = 256 - (n % 256)
        
        try stream.seek(offset: size_t(remaining * 4), from: .current)
        
        try self.readDirectories(stream: stream)
        try self.readFreeList(stream: stream)
    }
    
    private mutating func readDirectories(stream: BinaryStream) throws {
        let n = try stream.readUInt32(endianness: .big)
        
        for _ in 0 ..< n {
            let name = try stream.readString(length: size_t(try stream.readUInt8()), encoding: .utf8) ?? ""
            let id = try stream.readUInt32(endianness: .big)
            
            self.directories.append((name: name, id: id))
        }
    }
    
    private mutating func readFreeList(stream: BinaryStream) throws {
        for _ in 0 ..< 32 {
            let n      = try stream.readUInt32(endianness: .big)
            var values = [UInt32]()
            
            for _ in 0 ..< n {
                values.append(try stream.readUInt32(endianness: .big))
            }
            
            self.freeList.append(values)
        }
    }
    
    public static func decodeOffsetAndSize(_ value: UInt32) -> (offset: UInt32, size: UInt32) {
        let offset: UInt32 = value & ~0x1F
        let size: UInt32 = 1 << (value & 0x1F)
        
        return (offset: offset, size: size)
    }
}
