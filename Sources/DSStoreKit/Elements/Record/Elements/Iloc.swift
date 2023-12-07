//
//  File.swift
//  
//
//  Created by Chocoford on 2023/12/5.
//

import Foundation
import CoreGraphics

extension CGPoint: Hashable {
    enum CodingKeys: CodingKey {
        case x
        case y
    }

    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.x == rhs.x &&
        lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension Record {
    public struct IlocRecord: DSStoreRecord {
        public var name: String
        public var type: RecordStructureType
        public var dataType: RecordDataType
        public var value: CGPoint

        var paddings: [UInt8] = []
        public var length: Int
        public var start: Int
        
        init(
            name: String, 
            type: RecordStructureType,
            dataType: RecordDataType, 
            data: Data,
            length: Int,
            start: Int
        ) throws {
            let data = Data(data)
            guard data.count == 16 else {
                throw DSStoreError(message: "Invalid Iloc value")
            }
            
            var offset = 0
            let horizontalPos = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
            offset += 4
            let verticalPos = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
            offset += 4
            self.paddings = data.readIntegers(at: offset, count: 8, as: UInt8.self, endianness: .big) // 6bytes 0xff and 2bytes 0
            
            self.name = name
            self.type = type
            self.dataType = dataType
            self.value = CGPoint(x: Double(horizontalPos), y: Double(verticalPos))
            self.length = length
            self.start = start
        }
        
        func encodeValue() throws -> [UInt8] {
            [
                UInt32(16).toBytes(endianness: .big),
                UInt32(value.x).toBytes(endianness: .big),
                UInt32(value.y).toBytes(endianness: .big),
                self.paddings
            ].flatMap({$0})
        }
        
        public static func createNew(name: String, iconPos: CGPoint) throws -> IlocRecord {
            let data = Data([
                UInt32(iconPos.x).toBytes(endianness: .big),
                UInt32(iconPos.y).toBytes(endianness: .big),
                [255, 255, 255, 0,0,0,0,0].map{UInt8($0)}
            ].flatMap({$0}))
            print(data.count)
            return try IlocRecord(name: name, type: .Iloc, dataType: .blob, data: data, length: 0, start: 0)
        }
        
    }
}
