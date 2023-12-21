//
//  Data+Extension.swift
//
//
//  Created by Chocoford on 2023/12/2.
//

import Foundation

extension Data {
    func readInteger<T: FixedWidthInteger>(
        at offset: Int,
        as type: T.Type,
        endianness: Endianness
    ) -> T {
        self.readIntegers(at: offset, count: 1, as: type, endianness: endianness)[0]
    }
    
    func readUInt8(
        at offset: Int
    ) -> UInt8 {
        self.readIntegers(at: offset, count: 1, as: UInt8.self, endianness: .big)[0]
    }
    
    func readIntegers<T: FixedWidthInteger>(
        at offset: Int,
        count: Int,
        as type: T.Type,
        endianness: Endianness
    ) -> [T] {
        let sizeOfOneValue = MemoryLayout<T>.size
        let totalSize = sizeOfOneValue * count
        precondition(offset + totalSize <= self.count, "index(\(offset + totalSize)) out of bounds(\(self.count))")

        var values: [T] = []
        values.reserveCapacity(count)

        for i in 0..<count {
            let range = (offset + i * sizeOfOneValue)..<(offset + (i + 1) * sizeOfOneValue)
            let value = self.subdata(in: range).withUnsafeBytes { rawBufferPointer -> T in
                let bufferPointer = rawBufferPointer.bindMemory(to: type)
                var value = bufferPointer.baseAddress!.pointee
                switch endianness {
                case .big:
                    value = value.bigEndian
                case .little:
                    value = value.littleEndian
                }
                return value
            }
            values.append(value)
        }

        return values
    }
    
    func readString(at offset: Int, length: Int, encoding: String.Encoding) -> String? {
        let bytes = self.readIntegers(at: offset, count: length, as: UInt8.self, endianness: .big)
        return String(bytes: bytes, encoding: encoding)
    }
}
