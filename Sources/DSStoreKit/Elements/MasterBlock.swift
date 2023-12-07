//
//  Header.swift
//
//
//  Created by Chocoford on 2023/12/1.
//

import Foundation

public struct MasterBlock: Hashable {
    public var id: UInt32

    public var rootNode: Block
    
    internal init(id: UInt32, rootNode: Block) {
        self.id = id
        self.rootNode = rootNode
    }
    
    public init(data: Data, id: UInt32, allocator: Allocator) throws {
        self.id = id
        
        guard id < allocator.blocks.count, id <= Int.max else {
            throw DSStoreError(message: "Invalid directory ID")
        }
        
        let (offset, _) = allocator.blocks[Int(id)]
        
        let rootNodeID = data.readInteger(at: Int(offset + 4), as: UInt32.self, endianness: .big)
        
        self.rootNode = try Block(data: data, id: rootNodeID, allocator: allocator)
    }
    
    func constructBuffer(allocator: Allocator) throws -> [BufferConstruction] {
        var constructions: [BufferConstruction] = []

        var buffer: [UInt8] = []

        // rootNodeID
        buffer.append(
            contentsOf: self.rootNode.id.toBytes(endianness: .big)
        )
        
        constructions.append(BufferConstruction(buffer: buffer, start: Int(allocator.blocks[Int(id)].offset)+4))
        
        try constructions.append(contentsOf: self.rootNode.constructBuffer(allocator: allocator))
        
        return constructions
    }
    
    static func create() -> MasterBlock {
        MasterBlock(id: 1, rootNode: Block.create())
    }
}

