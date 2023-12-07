//
//  LegacyRecord.swift
//  
//
//  Created by Chocoford on 2023/12/7.
//

import Foundation

public struct Record_Old {
    public enum DataType: Int {
        case bool
        case long
        case shor
        case type
        case comp
        case dutc
        case blob
        case ustr
    }
    
    public var name: String
    public var type: UInt32
    public var dataType: DataType
    public var value: Any?
    
    public init(stream: BinaryStream) throws {
        let nameLength = try stream.readUInt32(endianness: .big)
        
        guard let name = try stream.readString(length: size_t(nameLength * 2), encoding: .utf16) else {
            throw DSStoreError(message: "Invalid record name")
        }
        
        self.name = name
        self.type = try stream.readUInt32(endianness: .big)
        
        guard let dataType = try stream.readString(length: 4, encoding: .utf8) else {
            throw DSStoreError(message: "Invalid record data-type")
        }
        
        if dataType == "bool" {
            self.dataType = .bool
            self.value = try stream.readUInt8() == 1
        } else if dataType == "long" {
            self.dataType = .long
            self.value = try stream.readInt32(endianness: .big)
        } else if dataType == "shor" {
            self.dataType = .shor
            self.value = try stream.readInt32(endianness: .big)
        } else if dataType == "type" {
            self.dataType = .type
            self.value = try stream.readUInt32(endianness: .big)
        } else if dataType == "comp" {
            self.dataType = .comp
            self.value = try stream.readInt64(endianness: .big)
        } else if dataType == "dutc" {
            self.dataType = .dutc
            let ts = try stream.readInt64(endianness: .big)
            self.value = Date(timeIntervalSinceReferenceDate: Double(ts))
        } else if dataType == "blob" {
            self.dataType = .blob
            let length = try stream.readUInt32(endianness: .big)
            self.value = Data(try stream.read(size: size_t(length)))
        } else if dataType == "ustr" {
            self.dataType = .ustr
            let length = try stream.readUInt32(endianness: .big)
            self.value = try stream.readString(length: size_t(length * 2), encoding: .utf16)
        } else {
            throw DSStoreError(message: "Unknown record data-type")
        }
    }
}
