//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/5.
//

import Foundation

extension Record {
    public struct BKGDRecord: DSStoreRecord {
        public struct Value: Codable, Hashable {
            
        }
        
        public var name: String
        public var type: RecordStructureType
        public var dataType: RecordDataType
        public var value: Value

        public var length: Int
        public var start: Int
        
        init(name: String, type: RecordStructureType, dataType: RecordDataType, data: Data, length: Int, start: Int) throws {
            self.name = name
            self.type = type
            self.dataType = dataType
            self.value = try PropertyListDecoder().decode(Value.self, from: data)
            self.length = length
            self.start = start
        }
        
        func encodeValue() throws -> [UInt8] {
            let data = try PropertyListEncoder().encode(self.value)
            return [
                UInt32(data.count).toBytes(endianness: .big),
                [UInt8](data)
            ].flatMap({$0})
        }
    }
    
}
