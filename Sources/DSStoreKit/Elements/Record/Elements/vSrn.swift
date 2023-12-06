//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/5.
//

import Foundation

extension Record {
    public struct vSrnRecord: DSStoreRecord {
        public var name: String
        public var type: RecordStructureType
        public var dataType: RecordDataType
        public var value: UInt32

        public var length: Int
        public var start: Int
        
        init(
            name: String, type: RecordStructureType, dataType: RecordDataType, value: UInt32, length: Int, start: Int
        ) throws {
            self.name = name
            self.type = type
            self.dataType = dataType
            self.value = value
            self.length = length
            self.start = start
        }
        
        func encodeValue() throws -> [UInt8] {
            value.toBytes(endianness: .big)
        }
        
        static public func general() -> vSrnRecord {
            try! vSrnRecord(name: ".", type: .vSrn, dataType: .long, value: 1, length: 0, start: 0)
        }
    }
    
}
