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

public struct Block {
    public var id: UInt32
    public var mode: UInt32
    public var children: [Block]  = []
    public var records: [Record] = []
    
//    public private(set) var start: Int
//    public private(set) var length: Int
    internal init(id: UInt32, mode: UInt32, children: [Block] = [], records: [Record] = []) {
        self.id = id
        self.mode = mode
        self.children = children
        self.records = records
    }
    
    
    public init(data: Data, id: UInt32, allocator: Allocator) throws {
        self.id = id
        
        guard id < allocator.blocks.count, id <= Int.max else {
            throw DSStoreError(message: "Invalid directory ID")
        }
        var offset = Int(allocator.blocks[Int(id)].offset)
        offset += 4
        self.mode = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
        offset += MemoryLayout<UInt32>.size
        let count = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
        offset += MemoryLayout<UInt32>.size

        // if mode == 0, continue read, else jump to specific position and read.
        if self.mode == 0 {
            for _ in 0..<count {
                let record = try Record(data: data, baseOffset: offset)
                self.records.append(record)
                offset += record.length
            }
        } else {
            for _ in 0..<count {
                let blockID = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
                offset += MemoryLayout<UInt32>.size
                self.children.append(try Block(data: data, id: blockID, allocator: allocator))
                self.records.append(try Record(data: data, baseOffset: offset))
            }
        }
//        self.length = offset - self.start
    }
    
    func constructBuffer(allocator: Allocator) throws -> [BufferConstruction] {
        var constructions: [BufferConstruction] = []
        var buffer: [UInt8] = []
        
        // mode
        buffer.append(
            contentsOf: self.mode.toBytes(endianness: .big)
        )
        
        // count
        if self.mode == 0 {
            buffer.append(
                contentsOf: UInt32(self.records.count).toBytes(endianness: .big)
            )
            for record in records {
                try buffer.append(
                    contentsOf: record.makeBuffer()
                )
            }
        } else {
            throw DSStoreError(message: "Not implemented")
//            guard self.children.count == self.records.count else {
//                throw DSStoreError(message: "Children count not equal to records count (mode: \(mode)")
//            }
//            for (child, record) in zip(self.children, self.records) {
//                buffer.append(contentsOf: child.id.toBytes(endianness: .big))
//                try constructions.append(contentsOf: child.constructBuffer(allocator: allocator))
//                try buffer.append(contentsOf: record.makeBuffer())
//            }
        }
        
        constructions.append(BufferConstruction(buffer: buffer, start: Int(allocator.blocks[Int(id)].offset+4)))
        
        return constructions
    }
    
    
    static func create() -> Block {
        Block(id: 2, mode: 0, children: [], records: [])
    }
}

extension Block: Hashable {}


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
