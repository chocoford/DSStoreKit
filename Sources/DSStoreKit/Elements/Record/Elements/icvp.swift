//
//  File.swift
//  
//
//  Created by Chocoford on 2023/12/5.
//

import Foundation
extension Record {
    public struct icvpRecord: DSStoreRecord {
        public struct Value: Codable, Hashable {
            public var arrangeBy: String
            public var backgroundColorBlue, backgroundColorGreen, backgroundColorRed: Double
            public var backgroundImageAlias: Data?
            public var backgroundType: Int
            public var gridOffsetX, gridOffsetY, gridSpacing: CGFloat
            public var iconSize: CGFloat
            public var labelOnBottom: Bool
            public var showIconPreview, showItemInfo: Bool
            public var textSize, viewOptionsVersion: Int
            
            public init(
                arrangeBy: String = "none",
                backgroundColorBlue: Double = 1,
                backgroundColorGreen: Double = 1,
                backgroundColorRed: Double = 1,
                backgroundImageAlias: Data? = nil,
                backgroundType: Int = 1,
                gridOffsetX: CGFloat = 0.0,
                gridOffsetY: CGFloat = 0.0,
                gridSpacing: CGFloat = 100,
                iconSize: CGFloat = 112,
                labelOnBottom: Bool = true,
                showIconPreview: Bool = true,
                showItemInfo: Bool = false,
                textSize: Int = 12,
                viewOptionsVersion: Int = 1
            ) {
                self.arrangeBy = arrangeBy
                self.backgroundColorBlue = backgroundColorBlue
                self.backgroundColorGreen = backgroundColorGreen
                self.backgroundColorRed = backgroundColorRed
                self.backgroundImageAlias = backgroundImageAlias
                self.backgroundType = backgroundType
                self.gridOffsetX = gridOffsetX
                self.gridOffsetY = gridOffsetY
                self.gridSpacing = gridSpacing
                self.iconSize = iconSize
                self.labelOnBottom = labelOnBottom
                self.showIconPreview = showIconPreview
                self.showItemInfo = showItemInfo
                self.textSize = textSize
                self.viewOptionsVersion = viewOptionsVersion
            }
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
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(self.value)
            return [
                UInt32(data.count).toBytes(endianness: .big),
                [UInt8](data)
            ].flatMap({$0})
        }
        
        public static func createNew(value: Value) throws -> icvpRecord {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(value)
            return try icvpRecord(name: ".", type: .icvp, dataType: .blob, data: data, length: 0, start: 0)
        }
        
        /// Copied from `create-dmg`
        public static func createBackgroundAlias(backgroundURL url: URL?) throws -> Data? {
            guard let url = url else { return nil }
            struct CreateBackgroundAliasError: LocalizedError {
                var errorDescription: String?
                init(message errorDescription: String? = nil) {
                    self.errorDescription = errorDescription
                }
            }
            struct Info {
                struct InfoError: LocalizedError {
                    var errorDescription: String?
                    init(message errorDescription: String? = nil) {
                        self.errorDescription = errorDescription
                    }
                }
                
                var version: UInt16 = 2
                var extra: [Extra]
                
                var target: Target
                var parent: Parent
                var volume: Volume
                
                struct Extra {
                    var type: Int16
                    var length: UInt16
                    var data: [UInt8]
                }
                
                struct Target {
                    var id: UInt32
                    var type: UInt16
                    var filename: String
                    var createdAt: Date
                    
                    init(filename: String, fileAttrs: [FileAttributeKey : Any]) throws {
                        guard let id = fileAttrs[.systemFileNumber] as? UInt32 else {
                            throw InfoError(message: "[Target] Invalid system file number")
                        }
                        self.id = id
                        guard let type = fileAttrs[.type] as? FileAttributeType,
                              type == .typeRegular || type == .typeDirectory else {
                            throw InfoError(message: "[Target] Invalid file type")
                        }
                        self.type = type == .typeRegular ? 0 : 1
                        self.filename = filename
                        guard let createdAt = fileAttrs[.creationDate] as? Date else {
                            throw InfoError(message: "[Target] Invalid creation date")
                        }
                        self.createdAt = createdAt
                    }
                }
                
                struct Parent {
                    var id: UInt32
                    var name: String
                    
                    init(filename: String, fileAttrs: [FileAttributeKey : Any]) throws {
                        guard let id = fileAttrs[.systemFileNumber] as? UInt32 else {
                            throw InfoError(message: "[Parent] Invalid system file number")
                        }
                        self.id = id
                        self.name = filename
                    }
                }
                
                struct Volume {
                    var name: String
                    var createdAt: Date
                    var signature: String
                    var type: UInt16
                    
                    init(url: URL, fileAttrs: [FileAttributeKey : Any]) throws {
                        guard let volname = try url.resourceValues(forKeys: [.volumeNameKey]).volumeName else {
                            throw InfoError(message: "[Volume] Get volname failed")
                        }
//                        print("volname: \(volname)")
                        self.name = volname
                        guard let createdAt = fileAttrs[.creationDate] as? Date else {
                            throw InfoError(message: "[Target] Invalid creation date")
                        }
                        self.createdAt = createdAt
                        self.signature = "H+"
                        self.type = url.filePath == "/" ? 0 : 5
                    }
                }
            }
            
            func findVolURL(startURL: URL, startAtts: [FileAttributeKey : Any]) -> URL? {
                var lastURL = startURL
                var lastDev = startAtts[.deviceIdentifier] as? Int
                var lastIno = startAtts[.systemFileNumber] as? Int
                
                while true {
//                    do {
                        let parentURL = lastURL.deletingLastPathComponent()
                    if parentURL.lastPathComponent.contains("dmg.") {
                        return parentURL
                    }
//                        let parentAttrs = try FileManager.default.attributesOfItem(atPath: parentURL.filePath)
//                        let dev = parentAttrs[.deviceIdentifier] as? Int
//                        if dev != lastDev {
//                            return lastURL
//                        }
//                        let ino = parentAttrs[.systemFileNumber] as? Int
//                        if ino == lastIno {
//                            return lastURL
//                        }
//                        
//                        lastDev = dev
//                        lastIno = ino
                        lastURL = parentURL
//                    } catch {
//                        print(error)
//                        return nil
//                    }
                }
            }
            
            let parentURL = url.deletingLastPathComponent()
            let targetAttributes = try FileManager.default.attributesOfItem(atPath: url.filePath)
            let parentAttributes = try FileManager.default.attributesOfItem(atPath: parentURL.filePath)
            guard let volumeURL = findVolURL(startURL: url, startAtts: targetAttributes) else {
                throw CreateBackgroundAliasError(message: "Find no Volume")
            }
//            print("volume url: \(volumeURL.filePath)")
            let volumeAttributes = try FileManager.default.attributesOfItem(atPath: volumeURL.filePath)
            
            let infoTarget = try Info.Target(filename: url.lastPathComponent, fileAttrs: targetAttributes)
            let infoParent = try Info.Parent(filename: parentURL.lastPathComponent, fileAttrs: parentAttributes)
            let infoVolume = try Info.Volume(url: volumeURL, fileAttrs: volumeAttributes)
            
            var info = Info(extra: [], target: infoTarget, parent: infoParent, volume: infoVolume)
            
            // type 0 - parent name
            do {
                guard let parentNameBytes = info.parent.name.data(using: .utf8) else {
                    throw CreateBackgroundAliasError(message: "Add extra failed: parent name")
                }
                info.extra.append(
                    Info.Extra(type: Int16(0), length: UInt16(parentNameBytes.count), data: [UInt8](parentNameBytes))
                )
            }
            
            // type 1 - parent id
            do {
                info.extra.append(
                    Info.Extra(type: Int16(1), length: UInt16(4), data: info.parent.id.toBytes(endianness: .big))
                )
            }
            
            // type 14 - target filename
            do {
                let targetFilename = info.target.filename
                let targetFilenameLength = UInt16(targetFilename.count)
                var targetFilenameBytes = [UInt8]()
                targetFilenameBytes.append(contentsOf: targetFilenameLength.toBytes(endianness: .big))
                guard let targetFilenameBytesData = targetFilename.data(using: .utf16BigEndian) else {
                    throw CreateBackgroundAliasError(message: "Invalid targe filename")
                }
                targetFilenameBytes.append(contentsOf: [UInt8](targetFilenameBytesData))
                guard 2 + targetFilenameLength * 2 == targetFilenameBytes.count else {
                    throw CreateBackgroundAliasError(message: "Target filename bytes count validation failed: \(targetFilenameLength) != \(targetFilenameBytes.count)")
                }
                info.extra.append(Info.Extra(type: Int16(14), length: UInt16(targetFilenameBytes.count), data: targetFilenameBytes))
            }
            
            // type 15 - volume name
            do {
                let volname = info.volume.name
                let volnameLength = UInt16(volname.count)
                var volnameBytes = [UInt8]()
                volnameBytes.append(contentsOf: volnameLength.toBytes(endianness: .big))
                guard let volnameBytesData = volname.data(using: .utf16BigEndian) else {
                    throw CreateBackgroundAliasError(message: "Invalid volume name")
                }
                volnameBytes.append(contentsOf: [UInt8](volnameBytesData))
                info.extra.append(
                    Info.Extra(type: Int16(15), length: UInt16(volnameBytes.count), data: [UInt8](volnameBytes))
                )
            }
            
            // type 18 - lp
            do {
//                let volPath = volumeURL.filePath
//                let volPathLength = volPath.count
//                guard volPath == url.filePath.prefix(volPathLength) else { throw CreateBackgroundAliasError(message: "volPath check failed") }
//                let lp = url.filePath.suffix(url.filePath.count - volPathLength)
//                print("lp: ", lp)
                let bgImagePath = "/.bcakground/dmg-background.tiff"
                guard let lpBytes = bgImagePath.data(using: .utf8) else { throw CreateBackgroundAliasError(message: "Get lp utf8 data failed") }
                info.extra.append(
                    Info.Extra(type: Int16(18), length: UInt16(lpBytes.count), data: [UInt8](lpBytes))
                )
            }
            
            // type 19 - volume path
            do {
                let volPath = volumeURL.filePath
                guard let volPathBytes = volPath.data(using: .utf8) else {
                    throw CreateBackgroundAliasError(message: "Get Volume path utf8 data failed.")
                }
                info.extra.append(
                    Info.Extra(type: Int16(19), length: UInt16(volPathBytes.count), data: [UInt8](volPathBytes))
                )
            }
            
            // MARK: write bytes
            let bufferCount: UInt16 = {
                let baseLength: UInt16 = 150
                let extraLength: UInt16 = info.extra.reduce(0) { p, extra in
                    let padding = extra.length % 2
                    return p + 4 + extra.length + padding
                }
                let trailerLength: UInt16 = 4
                return baseLength + extraLength + trailerLength
            }()
            var buffer = [UInt8]()
            buffer.append(contentsOf: UInt32(0).toBytes(endianness: .big))

            buffer.append(contentsOf: UInt16(bufferCount).toBytes(endianness: .big))
            buffer.append(contentsOf: UInt16(info.version).toBytes(endianness: .big))
            buffer.append(contentsOf: UInt16(info.target.type).toBytes(endianness: .big))
            
            buffer.append(contentsOf: UInt8(info.volume.name.count).toBytes(endianness: .big))
            
            guard let volNameData = info.volume.name.data(using: .utf8) else { throw CreateBackgroundAliasError(message: "Invalid volname data") }
            let volnameBytes = [UInt8](volNameData)
            guard volnameBytes.count < 28 else { throw CreateBackgroundAliasError(message: "Volume name too long: <--\(info.volume.name)-->(\(volnameBytes.count))") }
            buffer.append(contentsOf: volnameBytes + [UInt8](repeating: 0, count: 27 - volnameBytes.count))
            
            // Volume Creation Date
            buffer.append(contentsOf: UInt32(info.volume.createdAt.timeIntervalSince1970).toBytes(endianness: .big))
            
            // Volume Signature
            let sig = info.volume.signature
            guard sig == "BD" || sig == "H+" || sig == "HX" else { throw CreateBackgroundAliasError(message: "Invalid volume signature, should be one of 'BD', 'H+' or 'HX'") }
            guard let sigData = sig.data(using: .ascii) else { throw CreateBackgroundAliasError(message: "Invalid volume signature") }
            buffer.append(contentsOf: [UInt8](sigData))
            
            // Volume type
            buffer.append(contentsOf: info.volume.type.toBytes(endianness: .big))
            
            // Parent id
            buffer.append(contentsOf: info.parent.id.toBytes(endianness: .big))
            
            let targetFilename = info.target.filename
            guard targetFilename.count < 64 else { throw CreateBackgroundAliasError(message: "File name is not longer than 63 chars") }
            buffer.append(UInt8(targetFilename.count))
            guard let targetFilenameData = targetFilename.data(using: .utf8) else { throw CreateBackgroundAliasError(message: "Invalid target filename") }
            let targetFilenameBytes = [UInt8](targetFilenameData)
            buffer.append(contentsOf: targetFilenameBytes + [UInt8](repeating: 0, count: 63 - targetFilenameBytes.count))
            
            // Target id
            buffer.append(contentsOf: info.target.id.toBytes(endianness: .big))
            
            // Target Creation Date
            buffer.append(contentsOf: UInt32(info.target.createdAt.timeIntervalSince1970).toBytes(endianness: .big))
            
            // fileTypeName
            buffer.append(contentsOf: "\0\0\0\0".data(using: .utf8)!)
            // fileCreatorName
            buffer.append(contentsOf: "\0\0\0\0".data(using: .utf8)!)
            // nlvlFrom
            buffer.append(contentsOf: Int16(-1).toBytes(endianness: .big))
            // nlvlTo
            buffer.append(contentsOf: Int16(-1).toBytes(endianness: .big))
            // volAttrs
            buffer.append(contentsOf: UInt32(0x00000D02).toBytes(endianness: .big))
            // volFSID
            buffer.append(contentsOf: UInt16(0x0000).toBytes(endianness: .big))
            
            buffer.append(contentsOf: [UInt8](repeating: 0, count: 10))
            
            guard buffer.count == 150 else { throw CreateBackgroundAliasError(message: "Buffer length check failed: not equal to 150") }
            
            for extra in info.extra {
                buffer.append(contentsOf: Int16(extra.type).toBytes(endianness: .big))
                buffer.append(contentsOf: UInt16(extra.length).toBytes(endianness: .big))
                buffer.append(contentsOf: extra.data)
                if extra.length % 2 == 1 {
                    buffer.append(UInt8(0))
                }
            }
            
            buffer.append(contentsOf: Int16(-1).toBytes(endianness: .big))
            buffer.append(contentsOf: UInt16(0).toBytes(endianness: .big))
            
            guard buffer.count == bufferCount else {
                throw CreateBackgroundAliasError(message: "Buffer finale length check failed: buffer length\(buffer.count) != \(bufferCount)")
            }
            
            return Data(buffer)
        }
    }
    
}
