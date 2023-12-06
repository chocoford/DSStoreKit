//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/5.
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
                backgroundType: Int = 2,
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
            encoder.outputFormat = .binary
            let data = try encoder.encode(self.value)
            return [
                UInt32(data.count).toBytes(endianness: .big),
                [UInt8](data)
            ].flatMap({$0})
        }
        
        public static func createNew(value: Value) throws -> icvpRecord {
            let data = try PropertyListEncoder().encode(value)
            return try icvpRecord(name: ".", type: .icvp, dataType: .blob, data: data, length: 0, start: 0)
        }
    }
    
}
