/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

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
