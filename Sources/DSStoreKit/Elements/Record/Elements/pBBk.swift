//
//  File.swift
//  
//
//  Created by Chocoford on 2023/12/6.
//

import Foundation

extension Record {
    public struct pBBkRecord: DSStoreRecord {

        public var name: String
        public var type: RecordStructureType
        public var dataType: RecordDataType
        public var value: Data

        public var length: Int
        public var start: Int
        
        init(name: String, type: RecordStructureType, dataType: RecordDataType, data: Data, length: Int, start: Int) throws {
            self.name = name
            self.type = type
            self.dataType = dataType
            self.value = data
            self.length = length
            self.start = start
        }
        
        
        func encodeValue() throws -> [UInt8] {
            [UInt8](value)
        }
    }
    
}
