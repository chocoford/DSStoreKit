//
//  LegacyMasterBlock.swift
//  
//
//  Created by Chocoford on 2023/12/7.
//

import Foundation

struct MasterBlock_Old {
    public private(set) var id: UInt32
    public private(set) var rootNode: Block_Old
    
    public init(stream: BinaryStream, id: UInt32, allocator: Allocator_Old) throws {
        self.id = id
        
        if id >= allocator.blocks.count || id > Int.max {
            throw DSStoreError(message: "Invalid directory ID")
        }
        
        let (offset, _) = allocator.blocks[Int(id)]
        
        try stream.seek(offset: size_t(offset + 4), from: .begin)
        
        let rootNodeID = try stream.readUInt32(endianness: .big)
        let _ = try stream.readUInt32(endianness: .big)
        let _ = try stream.readUInt32(endianness: .big)
        let _ = try stream.readUInt32(endianness: .big)
        let _ = try stream.readUInt32(endianness: .big)
        
        self.rootNode = try Block_Old(stream: stream, id: rootNodeID, allocator: allocator)
    }
}
