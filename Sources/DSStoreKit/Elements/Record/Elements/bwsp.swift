//
//  bwsp.swift
//
//
//  Created by Chocoford on 2023/12/5.
//

import Foundation

extension CGRect: Hashable {
    public static func == (lhs: CGRect, rhs: CGRect) -> Bool {
        lhs.size.width == rhs.size.width &&
        lhs.size.height == rhs.size.height &&
        lhs.origin.x == rhs.origin.x &&
        lhs.origin.y == rhs.origin.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size.width)
        hasher.combine(size.height)
        hasher.combine(origin.x)
        hasher.combine(origin.y)
    }
    
}
extension Record {
    public struct bwspRecord: DSStoreRecord {
        public struct Value: Codable, Hashable {
            public var containerShowSidebar: Bool
            public var showPathbar: Bool?
            public var showSidebar, showStatusBar: Bool
            public var showTabView, showToolbar: Bool
            public var sidebarWidth: Int?
            public var windowBounds: CGRect
            
            enum CodingKeys: String, CodingKey {
                case containerShowSidebar = "ContainerShowSidebar"
                case showPathbar = "ShowPathbar"
                case showSidebar = "ShowSidebar"
                case showStatusBar = "ShowStatusBar"
                case showTabView = "ShowTabView"
                case showToolbar = "ShowToolbar"
                case sidebarWidth = "SidebarWidth"
                case windowBounds = "WindowBounds"
            }
            
            public init(
                containerShowSidebar: Bool,
                showPathbar: Bool,
                showSidebar: Bool,
                showStatusBar: Bool,
                showTabView: Bool,
                showToolbar: Bool,
                sidebarWidth: Int? = nil,
                windowBounds: CGRect
            ) {
                self.containerShowSidebar = containerShowSidebar
                self.showPathbar = showPathbar
                self.showSidebar = showSidebar
                self.showStatusBar = showStatusBar
                self.showTabView = showTabView
                self.showToolbar = showToolbar
                self.sidebarWidth = sidebarWidth
                self.windowBounds = windowBounds
            }
            
            public init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<Record.bwspRecord.Value.CodingKeys> = try decoder.container(keyedBy: Record.bwspRecord.Value.CodingKeys.self)
                self.containerShowSidebar = try container.decode(Bool.self, forKey: Record.bwspRecord.Value.CodingKeys.containerShowSidebar)
                self.showPathbar = try container.decodeIfPresent(Bool.self, forKey: Record.bwspRecord.Value.CodingKeys.showPathbar)
                self.showSidebar = try container.decode(Bool.self, forKey: Record.bwspRecord.Value.CodingKeys.showSidebar)
                self.showStatusBar = try container.decode(Bool.self, forKey: Record.bwspRecord.Value.CodingKeys.showStatusBar)
                self.showTabView = try container.decode(Bool.self, forKey: Record.bwspRecord.Value.CodingKeys.showTabView)
                self.showToolbar = try container.decode(Bool.self, forKey: Record.bwspRecord.Value.CodingKeys.showToolbar)
                self.sidebarWidth = try container.decodeIfPresent(Int.self, forKey: Record.bwspRecord.Value.CodingKeys.sidebarWidth)
                let boundsString = try container.decode(String.self, forKey: Record.bwspRecord.Value.CodingKeys.windowBounds)
                let values = boundsString
                    .replacingOccurrences(of: "{", with: "")
                    .replacingOccurrences(of: "}", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .components(separatedBy: ",")
                    .compactMap {Double($0)}
                guard values.count == 4 else {
                    throw DecodingError.typeMismatch(CGRect.self, DecodingError.Context(codingPath: [CodingKeys.windowBounds], debugDescription: "decode failed. expected 4 elements"))
                }
                self.windowBounds = CGRect(origin: .init(x: values[0], y: values[1]), size: CGSize(width: values[2], height: values[3]))
            }
        
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(containerShowSidebar, forKey: .containerShowSidebar)
                try container.encode(showPathbar, forKey: .showPathbar)
                try container.encode(showSidebar, forKey: .showSidebar)
                try container.encode(showStatusBar, forKey: .showStatusBar)
                try container.encode(showTabView, forKey: .showTabView)
                try container.encode(showToolbar, forKey: .showToolbar)
                if let sidebarWidth = sidebarWidth {
                    try container.encode(sidebarWidth, forKey: .sidebarWidth)
                }
                try container.encode("{{\(Int(windowBounds.origin.x)), \(Int(windowBounds.origin.y))}, {\(Int(windowBounds.size.width)), \(Int(windowBounds.size.height))}}", forKey: .windowBounds)
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
        
        public func encodeValue() throws -> [UInt8] {
            let data = try PropertyListEncoder().encode(self.value)
            return [
                UInt32(data.count).toBytes(endianness: .big),
                [UInt8](data)
            ].flatMap({$0})
        }
        
        public static func createNew(value: Value) throws -> bwspRecord {
            let data = try PropertyListEncoder().encode(value)
            return try bwspRecord(name: ".", type: .bwsp, dataType: .blob, data: data, length: 0, start: 0)
        }
    }
    
}
