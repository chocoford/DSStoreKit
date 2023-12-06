//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/12/5.
//

import Foundation

protocol DSStoreRecord: Hashable {
    associatedtype T: Codable & Hashable
    var name: String { get }
    var type: RecordStructureType { get }
    var dataType: RecordDataType { get }
    var value: T { get }
    
    var length: Int { get }
    var start: Int { get }
    
    func makeBuffer() throws -> [UInt8]
    func encodeValue() throws -> [UInt8]
    
}

extension DSStoreRecord {
    func makeBuffer() throws -> [UInt8] {
        var buffer: [UInt8] = []

        // name length
        let nameLength = self.name.utf16.count
        buffer.append(contentsOf: UInt32(nameLength).toBytes(endianness: .big))
        
        // name
        guard let nameBuffer = self.name.data(using: .utf16BigEndian) else {
            return []
        }
        buffer.append(contentsOf: [UInt8](nameBuffer))
        
        // type
        guard let data = self.type.rawValue.data(using: .utf8) else {
            throw DSStoreError(message: "Invalid structure type")
        }
        buffer.append(contentsOf: [UInt8](data))
        
        // dataType
        buffer.append(contentsOf: self.dataType.buffer)
        
        // value
        try buffer.append(contentsOf: self.encodeValue())
        
//        guard buffer.count == self.length else {
//            throw DSStoreError(message: "[Record] \(self.type.rawValue) makeBuffer failed: length check failed. (\(buffer.count) != \(self.length)")
//        }
        
        return buffer
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.dataType == rhs.dataType &&
        lhs.value.hashValue == rhs.value.hashValue
    }
}


public enum RecordStructureType: String, Hashable {
    /// 12-byte blob, directories only. 
    /// Indicates the background of the Finder window viewing this directory (in icon mode). The format depends on the kind of background:
    ///
    /// **Default background**  \
    /// FourCharCode DefB, followed by eight unknown bytes, probably garbage.
    ///
    /// **Solid color**  \
    /// FourCharCode ClrB, followed by an RGB value in six bytes, followed by two unknown bytes.
    ///
    /// **Picture**  \
    /// FourCharCode PctB, followed by the the length of the blob stored in the 'pict' record, followed by four unknown bytes. The 'pict' record points to the actual background image.
    case BKGD
    case ICVO
    case Iloc
    case LSVO
    
    /// A blob containing a binary plist.
    /// This contains the size and layout of the window (including whether optional parts like the sidebar or path bar are visible).
    /// This appeared in Snow Leopard (10.6).
    ///
    /// The plist contains the keys WindowBounds (a string in the same format in which AppKit saves window frames); SidebarWidth (a float), and booleans ShowSidebar, ShowToolbar, ShowStatusBar, and ShowPathbar. 
    /// Sometimes contains ViewStyle (a string), TargetURL (a string), and TargetPath (an array of strings).
    case bwsp
    case cmmt
    case dilc
    case dscl
    case extn
    case fwi0
    case fwsw
    case fwvh
    case GRP0
    case icgo
    case icsp
    case icvo
    
    /// A blob containing a plist, giving settings for the icon view. Appeared in Snow Leopard (10.6), probably supplanting 'icvo'.
    ///
    /// The plist holds a dictionary with several key-value pairs: booleans showIconPreview, showItemInfo, and labelOnBottom; numbers scrollPositionX, scrollPositionY, gridOffsetX, gridOffsetY, textSize, iconSize, gridSpacing, and viewOptionsVersion; string arrangeBy.
    ///
    /// The value of the backgroundType key (an integer) presumably controls the presence of further optional keys such as backgroundColorRed/backgroundColorGreen/backgroundColorBlue.
    case icvp
    case icvt
    case info
    case logS, lg1S
    case lssp
    case lsvo
    case lsvt
    case lsvp
    case lsvP
    case modD, moDD
    case phyS, ph1S
    case pict
    case vSrn
    case vstl
    
    /// Finder Folder Background Image Bookmark
    case pBB0, pBBk
}

public enum RecordDataType: String, Hashable {
    case bool
    case long
    case shor
    case type
    case comp
    case dutc
    case blob
    case ustr
    
    var buffer: [UInt8] {
        guard let data = self.rawValue.data(using: .utf8) else {
            return []
        }
        return [UInt8](data)
    }
}

public enum RecordDataValue {
    case bool(Bool)
    case long(UInt32)
    case shor(UInt32)
    case type(UInt32)
    case comp(UInt64)
    case dutc(Date)
    case blob(Data)
    case ustr(String)
}
