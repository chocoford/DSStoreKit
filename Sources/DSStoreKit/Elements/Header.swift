//
//  Header.swift
//  
//
//  Created by Chocoford on 2023/12/1.
//

import Foundation

public struct Header: Hashable {
      
    static var range: Range<Int> = 0..<36
    
    public var alignment: UInt32
    public var magic: UInt32
    public var offset1: UInt32
    public var size: UInt32
    public var offset2: UInt32
    
    var _unnamed4: [UInt32]
    
    internal init(
        alignment: UInt32, magic: UInt32, offset1: UInt32, size: UInt32, offset2: UInt32, _unnamed4: [UInt32]
    ) {
        self.alignment = alignment
        self.magic = magic
        self.offset1 = offset1
        self.size = size
        self.offset2 = offset2
        self._unnamed4 = _unnamed4
    }
    
    public init(data: Data) throws {
        let values: [UInt32] = data.readIntegers(at: 0, count: 9, as: UInt32.self, endianness: .big)
        
        guard values.count == 9 else {
            throw DSStoreError(message: "Read Header info failed")
        }
        
        self.alignment = values[0]
        self.magic = values[1]
        self.offset1 = values[2]
        self.size = values[3]
        self.offset2 = values[4]
        
        self._unnamed4 = Array(values[5..<9])
    }
    
    static func create() -> Header {
        Header(
            alignment: 1,
            magic: 1114989617,
            offset1: 8192,
            size: 2048,
            offset2: 8192,
            _unnamed4: [4108, 0, 0, 0]
        )
    }
    
    func constructBuffer() throws -> [BufferConstruction] {
        var constructions: [BufferConstruction] = []
        
        var buffer: [UInt8] = []
        
        buffer.append(contentsOf: self.alignment.toBytes(endianness: .big))
        buffer.append(contentsOf: self.magic.toBytes(endianness: .big))
        buffer.append(contentsOf: self.offset1.toBytes(endianness: .big))
        buffer.append(contentsOf: self.size.toBytes(endianness: .big))
        buffer.append(contentsOf: self.offset2.toBytes(endianness: .big))
        buffer.append(contentsOf: self._unnamed4.flatMap({$0.toBytes(endianness: .big)}))
        
        constructions.append(BufferConstruction(buffer: buffer, start: 0))
        
        return constructions
    }
}
