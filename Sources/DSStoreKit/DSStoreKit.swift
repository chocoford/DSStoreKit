import Foundation

public struct DSStore: Hashable {
    var data: Data
    
    var header: Header
    var allocator: Allocator
    var directories: [DirectoryName : MasterBlock] = [:]
    
    internal init(header: Header, allocator: Allocator, directories: [DirectoryName : MasterBlock] = [:]) {
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
}

//MARK: - API
public extension DSStore {
    /// Save changes. If url is not specified, it will not write anything to disk.
    /// - Parameter url: The url you want to write to disk.
    mutating func save(to url: URL? = nil) throws {
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
                let appendString = url.absoluteString.hasSuffix("/") ? "" : "/"
                if let fileURL = URL(string: url.absoluteString.appending("\(appendString).DS_Store")) {
                    url = fileURL
                }
            }
            try self.data.write(to: url)
        }
    }
    
    
    /// Create a clean DSStore.
    static func create() -> DSStore {
        var dsStore = try! DSStore(url: Bundle.module.url(forResource: "DS_Store-clean", withExtension: nil)!)
        dsStore.directories[.DSDB]?.rootNode.records = [:]
        return dsStore
    }
    
    mutating func insertRecord(_ record: Record, directoryName: DirectoryName = .DSDB) {
        self.directories[directoryName]?.rootNode.records[record.key] = record
    }
}


