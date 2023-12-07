import Foundation


public enum Record: Hashable {
    case BKGD(BKGDRecord)
    case Iloc(IlocRecord)
    case bwsp(bwspRecord)
    case icvp(icvpRecord)
    case vSrn(vSrnRecord)
    case pBBk(pBBkRecord)

    public init(data: Data, baseOffset: Int) throws {
        var offset = baseOffset
        let nameLength = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
        offset += MemoryLayout<UInt32>.size
        
        guard let name = data.readString(at: offset, length: Int(nameLength * 2), encoding: .utf16) else {
            throw DSStoreError(message: "Invalid record name")
        }
        offset += Int(nameLength * 2)
        
        guard let rawType = data.readString(at: offset, length: 4, encoding: .utf8) else {
            throw DSStoreError(message: "Invalid structure type")
        }
        guard let type = RecordStructureType(rawValue: rawType) else {
            throw DSStoreError(message: "Invalid structure type(\(rawType))")
        }
        offset += MemoryLayout<UInt32>.size
        
        guard let rawDataType = data.readString(at: offset, length: 4, encoding: .utf8) else {
            throw DSStoreError(message: "Invalid record data-type")
        }
        guard let dataType = RecordDataType(rawValue: rawDataType) else {
            throw DSStoreError(message: "Invalid record data-type(\(rawDataType))")
        }
        offset += 4
        
        
        let value: RecordDataValue
        switch dataType {
            case .bool:
                value = .bool(data.readUInt8(at: offset) == 1)
                offset += MemoryLayout<UInt8>.size
                
            case .long:
                value = .long(data.readInteger(at: offset, as: UInt32.self, endianness: .big))
                offset += MemoryLayout<UInt32>.size
                
            case .shor:
                value = .shor(data.readInteger(at: offset, as: UInt32.self, endianness: .big))
                offset += MemoryLayout<UInt32>.size
                
            case .type:
                value = .type(data.readInteger(at: offset, as: UInt32.self, endianness: .big))
                offset += MemoryLayout<UInt32>.size
                
            case .comp:
                value = .comp(data.readInteger(at: offset, as: UInt64.self, endianness: .big))
                offset += MemoryLayout<UInt64>.size
                
            case .dutc:
                let ts = data.readInteger(at: offset, as: UInt64.self, endianness: .big)
                value = .dutc(Date(timeIntervalSinceReferenceDate: Double(ts)))
                offset += MemoryLayout<UInt64>.size
                
            case .blob:
                let length = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
                offset += MemoryLayout<UInt32>.size
                
                value = .blob(data[offset..<offset+Int(length)])
                offset += Int(length)
                
            case .ustr:
                let length = data.readInteger(at: offset, as: UInt32.self, endianness: .big)
                offset += MemoryLayout<UInt32>.size
                
                value = .ustr(data.readString(at: offset, length: size_t(length * 2), encoding: .utf16) ?? "")
                offset += size_t(length * 2)
        }
        
        
        
        switch type {
            case .BKGD:
                guard case .blob(let blobData) = value else {
                    throw DSStoreError(message: "data type(\(dataType)) mismatch with structure type(\(type)).")
                }
                self = try .BKGD(
                    BKGDRecord(
                        name: name,
                        type: type,
                        dataType: dataType,
                        data: blobData,
                        length: offset - baseOffset,
                        start: baseOffset
                    )
                )
            case .ICVO:
                fatalError("Not Implement")
            case .Iloc:
                guard case .blob(let blobData) = value else {
                    throw DSStoreError(message: "data type(\(dataType)) mismatch with structure type(\(type)).")
                }
                self = try .Iloc(
                    IlocRecord(
                        name: name,
                        type: type,
                        dataType: dataType,
                        data: blobData,
                        length: offset - baseOffset,
                        start: baseOffset
                    )
                )
            case .LSVO:
                fatalError("Not Implement")
            case .bwsp:
                guard case .blob(let blobData) = value else {
                    throw DSStoreError(message: "data type(\(dataType)) mismatch with structure type(\(type)).")
                }
                self = try .bwsp(
                    bwspRecord(
                        name: name,
                        type: type,
                        dataType: dataType,
                        data: blobData,
                        length: offset - baseOffset,
                        start: baseOffset
                    )
                )
            case .cmmt:
                fatalError("Not Implement")
            case .dilc:
                fatalError("Not Implement")
            case .dscl:
                fatalError("Not Implement")
            case .extn:
                fatalError("Not Implement")
            case .fwi0:
                fatalError("Not Implement")
            case .fwsw:
                fatalError("Not Implement")
            case .fwvh:
                fatalError("Not Implement")
            case .GRP0:
                fatalError("Not Implement")
            case .icgo:
                fatalError("Not Implement")
            case .icsp:
                fatalError("Not Implement")
            case .icvo:
                fatalError("Not Implement")
            case .icvp:
                guard case .blob(let blobData) = value else {
                    throw DSStoreError(message: "data type(\(dataType)) mismatch with structure type(\(type)).")
                }
                self = try .icvp(
                    icvpRecord(
                        name: name,
                        type: type,
                        dataType: dataType,
                        data: blobData,
                        length: offset - baseOffset,
                        start: baseOffset
                    )
                )
            case .icvt:
                fatalError("Not Implement")
            case .info:
                fatalError("Not Implement")
            case .logS:
                fatalError("Not Implement")
            case .lg1S:
                fatalError("Not Implement")
            case .lssp:
                fatalError("Not Implement")
            case .lsvo:
                fatalError("Not Implement")
            case .lsvt:
                fatalError("Not Implement")
            case .lsvp:
                fatalError("Not Implement")
            case .lsvP:
                fatalError("Not Implement")
            case .modD:
                fatalError("Not Implement")
            case .moDD:
                fatalError("Not Implement")
            case .phyS:
                fatalError("Not Implement")
            case .ph1S:
                fatalError("Not Implement")
            case .pict:
                fatalError("Not Implement")
            case .vSrn:
                guard case .long(let long) = value else {
                    throw DSStoreError(message: "data type(\(dataType)) mismatch with structure type(\(type)).")
                }
                self = try .vSrn(
                    vSrnRecord(
                        name: name,
                        type: type,
                        dataType: dataType,
                        value: long,
                        length: offset - baseOffset,
                        start: baseOffset
                    )
                )
            case .vstl:
                fatalError("Not Implement")
            case .pBB0:
                fatalError("Not Implement")
            case .pBBk:
                guard case .blob(let blobData) = value else {
                    throw DSStoreError(message: "data type(\(dataType)) mismatch with structure type(\(type)).")
                }
                self = try .pBBk(
                    pBBkRecord(
                        name: name,
                        type: type,
                        dataType: dataType,
                        data: blobData,
                        length: offset - baseOffset,
                        start: baseOffset
                    )
                )
        }
        
//        self.length = offset - baseOffset
    }
    
//    public mutating func transform(_ transform: (inout Self) -> Void) {
//        switch self {
//            case .BKGD(var bKGDRecord):
//                transform(&bKGDRecord)
//                self = .BKGD(bKGDRecord)
//            case .Iloc(let ilocRecord):
//                <#code#>
//            case .bwsp(let bwspRecord):
//                <#code#>
//            case .icvp(let icvpRecord):
//                <#code#>
//            case .vSrn(let vSrnRecord):
//                <#code#>
//        }
//    }
    
    public func makeBuffer() throws -> [UInt8] {
        switch self {
            case .BKGD(let bKGDRecord):
                try bKGDRecord.makeBuffer()
            case .Iloc(let record):
                try record.makeBuffer()
            case .bwsp(let bwspRecord):
                try bwspRecord.makeBuffer()
            case .icvp(let icvpRecord):
                try icvpRecord.makeBuffer()
            case .vSrn(let record):
                try record.makeBuffer()
            case .pBBk(let record):
                try record.makeBuffer()
        }
    }
    
    var start: Int {
        switch self {
            case .BKGD(let bKGDRecord):
                bKGDRecord.start
            case .Iloc(let record):
                record.start
            case .bwsp(let bwspRecord):
                bwspRecord.start
            case .icvp(let icvpRecord):
                icvpRecord.start
            case .vSrn(let record):
                record.start
            case .pBBk(let record):
                record.start
        }
    }
    
    var length: Int {
        switch self {
            case .BKGD(let bKGDRecord):
                bKGDRecord.length
            case .Iloc(let record):
                record.length
            case .bwsp(let bwspRecord):
                bwspRecord.length
            case .icvp(let icvpRecord):
                icvpRecord.length
            case .vSrn(let record):
                record.length
            case .pBBk(let record):
                record.length
        }
    }
    
    var name: String {
        switch self {
            case .BKGD(let record):
                record.name
            case .Iloc(let record):
                record.name
            case .bwsp(let record):
                record.name
            case .icvp(let record):
                record.name
            case .vSrn(let record):
                record.name
            case .pBBk(let record):
                record.name
        }
    }
    
    var structureType: RecordStructureType {
        switch self {
            case .BKGD(let record):
                record.type
            case .Iloc(let record):
                record.type
            case .bwsp(let record):
                record.type
            case .icvp(let record):
                record.type
            case .vSrn(let record):
                record.type
            case .pBBk(let record):
                record.type
        }
    }
    
    public typealias Key = String
    var key: Key {
        switch self {
            case .BKGD(let record):
                record.key
            case .Iloc(let record):
                record.key
            case .bwsp(let record):
                record.key
            case .icvp(let record):
                record.key
            case .vSrn(let record):
                record.key
            case .pBBk(let record):
                record.key
        }
    }
}
