//
//  LegacyDSStore.swift
//
//
//  Created by Chocoford on 2023/12/7.
//

import Foundation

struct DSStore_Old {
    var header: Header_Old
    var allocator: Allocator_Old
    var directories: [ String : MasterBlock_Old ] = [:]
    
    public init(url: URL) throws {
        guard let stream = BinaryFileStream(url: url) else {
            throw DSStoreError(message: "Cannot read file: \( url.path )")
        }
        
        self.header = try Header_Old(stream: stream)
        self.allocator = try Allocator_Old(stream: stream, header: self.header)
        
        for directory in self.allocator.directories {
            self.directories[directory.name] = try MasterBlock_Old(stream: stream, id: directory.id, allocator: self.allocator)
        }
    }
}
