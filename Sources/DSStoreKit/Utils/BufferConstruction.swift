//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/4.
//

import Foundation

struct BufferConstruction {
    var buffer: [UInt8]
    var start: Int
    
    var end: Int {
        start + buffer.count * MemoryLayout<UInt8>.size
    }
}

extension [BufferConstruction] {
    func combine() -> Data {
        let end = self.reduce(0) { Swift.max($0, $1.end) }
        let start = self.reduce(end) { Swift.min($0, $1.start) }
//        let totalSize = end - start
        var combinedData = Data(count: end)

        for construction in self {
            combinedData.replaceSubrange(construction.start..<construction.end, with: construction.buffer)
        }

        return combinedData[start..<end]
    }
    
    func getCombineRange() -> Range<Int> {
        let end = self.reduce(0) { Swift.max($0, $1.end) }
        let start = self.reduce(end) { Swift.min($0, $1.start) }
        return start..<end
    }
    
    func getDiscreteRanges() -> [Range<Int>] {
        map {
            $0.start..<$0.end
        }
    }
    
    func applyToData(data: inout Data) {
        for construction in self {
            if construction.end > data.count {
                data.append(contentsOf: [UInt8].init(repeating: 0, count: construction.end - data.count))
            }
            print("apply buffer to data, range: ", construction.start..<construction.end)
            print("from")
            print([UInt8](data[construction.start..<construction.end]))
            print("to")
            print(construction.buffer)
            data[construction.start..<construction.end] = Data(construction.buffer)
        }
    }
}

