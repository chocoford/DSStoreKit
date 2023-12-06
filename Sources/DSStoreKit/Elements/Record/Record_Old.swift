//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/5.
//

import Foundation


//public struct Record {
//    public var name: String
//
//    /// structure type: A Four Char Code
//    public var type: RecordStructureType
//    public var dataType: RecordDataType
//    public var _value: Any?
//
//    /// The length of `Record` in data.
//    public private(set) var length: Int
//    public private(set) var start: Int
//
//    public init(data: Data, baseOffset: Int) throws {
//        self.start = baseOffset
//        var offset = baseOffset
//        let nameLength = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
//        offset += MemoryLayout<UInt32>.size
//
//        guard let name = data.readString(at: offset, length: Int(nameLength * 2), encoding: .utf16) else {
//            throw DSStoreError(message: "Invalid record name")
//        }
//        offset += Int(nameLength * 2)
//
//        self.name = name
//
//
//        guard let rawType = data.readString(at: offset, length: 4, encoding: .utf8) else {
//            throw DSStoreError(message: "Invalid structure type")
//        }
//        guard  let type = RecordStructureType(rawValue: rawType) else {
//            throw DSStoreError(message: "Invalid structure type(\(rawType))")
//        }
//        self.type = type
//        offset += MemoryLayout<UInt32>.size
//
//        guard let dataType = data.readString(at: offset, length: 4, encoding: .utf8) else {
//            throw DSStoreError(message: "Invalid record data-type")
//        }
//        offset += 4
//
//        switch dataType {
//            case "bool":
//                self.dataType = .bool
//                self._value = data.readUInt8(at: offset) == 1
//                offset += MemoryLayout<UInt8>.size
//
//            case "long":
//                self.dataType = .long
//                self._value = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
//                offset += MemoryLayout<UInt32>.size
//
//            case "shor":
//                self.dataType = .shor
//                self._value = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
//                offset += MemoryLayout<UInt32>.size
//
//            case "type":
//                self.dataType = .type
//                self._value = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
//                offset += MemoryLayout<UInt32>.size
//
//            case "comp":
//                self.dataType = .comp
//                self._value = data.readInteger(at: offset, as: UInt64.self, endianness: .big)
//                offset += MemoryLayout<UInt64>.size
//
//            case "dutc":
//                self.dataType = .dutc
//                let ts = data.readInteger(at: offset, as: UInt64.self, endianness: .big)
//                self._value = Date(timeIntervalSinceReferenceDate: Double(ts))
//                offset += MemoryLayout<UInt64>.size
//
//            case "blob":
//                self.dataType = .blob
//                let length = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
//                offset += MemoryLayout<UInt32>.size
//
//                self._value = data[offset..<offset+Int(length)]
//                offset += Int(length)
//
//            case "ustr":
//                self.dataType = .ustr
//                let length = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
//                offset += MemoryLayout<UInt32>.size
//
//                self._value = data.readString(at: offset, length: size_t(length * 2), encoding: .utf16)
//                offset += size_t(length * 2)
//
//            default:
//                throw DSStoreError(message: "Unknown record data-type")
//        }
//
//        self.length = offset - baseOffset
//    }
//
//    func makeBuffer() throws -> [UInt8] {
//        var buffer: [UInt8] = []
//
//        // name length
//        let nameLength = self.name.utf16.count
//        buffer.append(contentsOf: UInt32(nameLength).toBytes(endianness: .big))
//
//        // name
//        guard let nameBuffer = self.name.data(using: .utf16BigEndian) else {
//            return []
//        }
//        buffer.append(contentsOf: [UInt8](nameBuffer))
//
//        // type
//        guard let data = self.type.rawValue.data(using: .utf8) else {
//            throw DSStoreError(message: "Invalid structure type")
//        }
//        buffer.append(contentsOf: [UInt8](data))
//
//        // dataType
//        buffer.append(contentsOf: self.dataType.buffer)
//
//        // value
//        switch self.dataType {
//            case .bool:
//                guard let value = self._value as? UInt8 else { throw DSStoreError(message: "Invalid value, expected UInt8.") }
//                buffer.append(contentsOf: value.toBytes(endianness: .big))
//            case .long:
//                guard let value = self._value as? UInt32 else { throw DSStoreError(message: "Invalid value, expected UInt32.") }
//                buffer.append(contentsOf: value.toBytes(endianness: .big))
//            case .shor:
//                guard let value = self._value as? UInt32 else { throw DSStoreError(message: "Invalid value, expected UInt32.") }
//                buffer.append(contentsOf: value.toBytes(endianness: .big))
//            case .type:
//                guard let value = self._value as? UInt32 else { throw DSStoreError(message: "Invalid value, expected UInt32.") }
//                buffer.append(contentsOf: value.toBytes(endianness: .big))
//            case .comp:
//                guard let value = self._value as? UInt64 else { throw DSStoreError(message: "Invalid value, expected UInt64.") }
//                buffer.append(contentsOf: value.toBytes(endianness: .big))
//            case .dutc:
//                guard let value = self._value as? UInt64 else { throw DSStoreError(message: "Invalid value, expected UInt64.") }
//                buffer.append(contentsOf: value.toBytes(endianness: .big))
//            case .blob:
//                guard let value = self._value as? Data else { throw DSStoreError(message: "Invalid value, expected Data.") }
//                buffer.append(contentsOf: UInt32(value.count).toBytes(endianness: .big))
//                buffer.append(contentsOf: [UInt8](value))
//
//            case .ustr:
//                guard let value = self._value as? String else { throw DSStoreError(message: "Invalid value, expected String.") }
//                buffer.append(contentsOf: UInt32(value.count).toBytes(endianness: .big))
//                guard let data = value.data(using: .utf16BigEndian) else {
//                    throw DSStoreError(message: "Invalid ustr value.")
//                }
//                buffer.append(contentsOf: [UInt8](data))
//
//        }
//
//        guard buffer.count == self.length else {
//            throw DSStoreError(message: "[Record] makeBuffer failed: length check failed. (\(buffer.count) != \(self.length)")
//        }
//
//        return buffer
//    }
//}
//
//
//extension Record: Hashable {
//    public static func == (lhs: Record, rhs: Record) -> Bool {
//        var valueEqual: Bool{
//            switch lhs._value {
//                case let value as UInt8:
//                    if let rhsValue = rhs._value as? UInt8 {
//                        return value == rhsValue
//                    }
//                case let value as UInt32:
//                    if let rhsValue = rhs._value as? UInt32 {
//                        return value == rhsValue
//                    }
//                case let value as UInt64:
//                    if let rhsValue = rhs._value as? UInt64 {
//                        return value == rhsValue
//                    }
//                case let value as String:
//                    if let rhsValue = rhs._value as? String {
//                        return value == rhsValue
//                    }
//                case let value as Data:
//                    if let rhsValue = rhs._value as? Data {
//                        return value == rhsValue
//                    }
//                default:
//                    break
//            }
//            return false
//        }
//
//
//        return lhs.name == rhs.name &&
//        lhs.type == rhs.type &&
//        lhs.dataType == rhs.dataType &&
//        lhs.length == rhs.length &&
//        valueEqual
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(self.name)
//        hasher.combine(self.type)
//        hasher.combine(self.dataType)
//        switch self._value {
//            case let value as UInt8:
//                hasher.combine(value)
//            case let value as UInt32:
//                hasher.combine(value)
//            case let value as UInt64:
//                hasher.combine(value)
//            case let value as String:
//                hasher.combine(value)
//            case let value as Data:
//                hasher.combine(value)
//            default:
//                fatalError("Unexpected value: \(self._value ?? "nil")")
//        }
//    }
//
//}
