//
//  LegacyBlock.swift
//  
//
//  Created by Chocoford on 2023/12/7.
//

import Foundation

struct Block_Old {
    public private(set) var id: UInt32
    public private(set) var mode: UInt32
    public private(set) var children: [Block_Old]  = []
    public private(set) var records: [Record_Old] = []
    
    public init(stream: BinaryStream, id: UInt32, allocator: Allocator_Old) throws
    {
        self.id = id
        
        if id >= allocator.blocks.count || id > Int.max
        {
            throw DSStoreError(message: "Invalid directory ID")
        }
        
        let (offset, _) = allocator.blocks[Int(id)]
        
        try stream.seek(offset: size_t(offset + 4), from: .begin)
        
        self.mode = try stream.readUInt32(endianness: .big)
        let count = try stream.readUInt32(endianness: .big)
        
        if self.mode == 0
        {
            for _ in 0 ..< count
            {
                self.records.append(try Record_Old(stream: stream))
            }
        }
        else
        {
            for _ in 0 ..< count
            {
                let blockID = try stream.readUInt32(endianness: .big)
                let pos     = stream.tell()
                
                self.children.append(try Block_Old(stream: stream, id: blockID, allocator: allocator))
                try stream.seek(offset: pos, from: .begin)
                self.records.append(try Record_Old(stream: stream))
            }
        }
    }
}
