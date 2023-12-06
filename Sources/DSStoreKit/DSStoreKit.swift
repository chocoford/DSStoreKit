import Foundation

public struct DSStore: Hashable {
    var data: Data
    
    var header: Header
    var allocator: Allocator
    var directories: [String : MasterBlock] = [:]
    
    internal init(header: Header, allocator: Allocator, directories: [String : MasterBlock] = [:]) {
        self.data = Data(capacity: 3840)
        self.header = header
        self.allocator = allocator
        self.directories = directories
    }
    
    internal init(data: Data) throws {
        self.data = data
        self.header = try Header(data: data)
        self.allocator = try Allocator(data: data, header: self.header)
        
        for directory in self.allocator.directories {
            self.directories[directory.name] = try MasterBlock(data: data, id: directory.id, allocator: self.allocator)
        }
    }
    
    public init(url: URL) throws {
        var url = url
        var isDirectory = ObjCBool(false)
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if isDirectory.boolValue,
           let fileURL = URL(string: url.absoluteString.appending("/.DS_Store")) {
            url = fileURL
        }
        
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }

    func constructBuffer() throws -> Data {

        var constructions: [BufferConstruction] = []
        
        try constructions.append(contentsOf: self.header.constructBuffer())
        try constructions.append(contentsOf: self.allocator.constructBuffer(header: self.header))
        
        
        for directory in self.allocator.directories {
            guard let directory = self.directories[directory.name] else {
                throw DSStoreError(message: "Invalid direcotry(\(directory.name)")
            }
            try constructions.append(contentsOf: directory.constructBuffer(allocator: self.allocator))
        }
        
        print(constructions.sorted(by: {
            $0.start < $1.start
        }).map {
            [
                "start": $0.start,
                "end": $0.end
            ]
        })
        
        let data = constructions.combine()
                
        return data
    }
    
}

extension DSStore {
    public mutating func save(to url: URL? = nil) throws {
        var data = self.data
        
        // save header
        let headerBuffer = try self.header.constructBuffer()
        headerBuffer.applyToData(data: &data)
        
        let allocatorBuffer = try self.allocator.constructBuffer(header: self.header)
        allocatorBuffer.applyToData(data: &data)
        
        for directory in self.directories.values {
            let directoryBuffer = try directory.constructBuffer(allocator: self.allocator)
            directoryBuffer.applyToData(data: &data)
        }
        
        self.data = data
        
        if var url = url {
            if !url.absoluteString.hasSuffix(".DS_Store") {
                var appendString = url.absoluteString.hasSuffix("/") ? "" : "/"
                if let fileURL = URL(string: url.absoluteString.appending("\(appendString).DS_Store")) {
                    url = fileURL
                }
            }
            try self.data.write(to: url)
        }
    }
    
    public static func create() -> DSStore {
//        DSStore(header: Header.create(), allocator: Allocator.create(), directories: ["DSDB" : MasterBlock.create()])
        var dsStore = try! DSStore(url: Bundle.module.url(forResource: "DS_Store-clean", withExtension: nil)!)
        
        dsStore.directories["DSDB"]?.rootNode.records = []
        
        return dsStore
    }
    
    /// **Important!** The order matter!
    public mutating func appendRecord(_ record: Record) {
        self.directories["DSDB"]?.rootNode.records.append(record)
//        self.allocator.directories.first(where: {$0.name == "DSDB"})?.id
    }
}


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
