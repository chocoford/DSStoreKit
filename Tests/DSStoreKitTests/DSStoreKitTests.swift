import XCTest
@testable import DSStoreKit

final class DSStoreKitTests: XCTestCase {
    func testDSStoreOld() throws {
        let dsStoreOld = try DSStore_Old(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        dump(dsStoreOld)
    }   
    
    func testDSStore() throws {
//        let dsStoreOld = try DSStore_Old(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        let dsStore = try DSStore(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
//        let dsStore = try DSStore(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DSStore-clean")!)
//        let dsStore = try DSStore(url: URL(string: "file:///Volumes/Trickle Capture Test 0.1.19 RC 2(18)/.DS_Store")!)
        dump(dsStore)
        XCTAssertEqual(dsStore, DSStore.create())
    }
    
    func testRecordBuffer() throws {
        let dsStore = try DSStore(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        let originData = try Data(contentsOf: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        dump(dsStore)
        for (name, directory) in dsStore.directories {
            for (i, record) in directory.rootNode.records.enumerated() {
                var newData = originData
                let newBuffer = try record.makeBuffer()
                newData.replaceSubrange(record.start..<record.start+record.length, with: Data(newBuffer))
                let newDSStore = try DSStore(data: newData)
                
                XCTAssertEqual(
                    record,
                    newDSStore.directories[name]?.rootNode.records[i]
                )
            }
        }
    }
    
    func testBlockBuffer() throws {
        let dsStore = try DSStore(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        let originData = try Data(contentsOf: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)

        for (name, directory) in dsStore.directories {
            var newData = originData
            let constructions = try directory.rootNode.constructBuffer(allocator: dsStore.allocator)
            constructions.applyToData(data: &newData)
            let newDSStore = try DSStore(data: newData)
            
            print(directory == newDSStore.directories[name])
            XCTAssertEqual(directory, newDSStore.directories[name])
            
            
            if !directory.rootNode.children.isEmpty {
                for (i, block) in directory.rootNode.children.enumerated() {
                    var newData = originData
                    let constructions = try directory.rootNode.constructBuffer(allocator: dsStore.allocator)
                    constructions.applyToData(data: &newData)
                    let newDSStore = try DSStore(data: newData)
                    
                    XCTAssertEqual(
                        block,
                        newDSStore.directories[name]?.rootNode.children[i]
                    )
                }
            }
        }
        
    }
    
    
    func testConstructBuffer() throws {
        var dsStore = try DSStore(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        let originData = try Data(contentsOf: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        
        try dsStore.save()

        XCTAssertEqual(
            originData,
            dsStore.data
        )
    }
    
    func testModifyRecord() throws {
        let url = URL(string: "file:///private/tmp/dmg.aISah7/.DS_Store")!
        let oldDsStore = try DSStore(url: url)
        dump(oldDsStore, name: "Before modified")
        var dsStore = oldDsStore
        let key = dsStore.directories.keys.first!
        
        for (i, record) in (dsStore.directories[key]?.rootNode.records ?? []).enumerated() {
            switch record {
                case .bwsp(var record):
//                    record.value.windowBounds = .init(origin: .zero, size: .init(width: 400, height: 400))
//                    dsStore.directories[key]?.rootNode.records[i] = .bwsp(record)
                    break
                case .icvp(var record):
                    record.value.iconSize = 16
                    dsStore.directories[key]?.rootNode.records[i] = .icvp(record)
                default:
                    break
            }
        }
//        try FileManager.default.removeItem(at: url)
        try dsStore.save(to: url)
        
        
        let finalDSStore = try DSStore(url: url)
        dump(finalDSStore)
    }
    
    func testCreate() throws {
        var dsStore = DSStore.create()
        dump(dsStore)
        print(dsStore.data.count)
//        try dsStore.save()
//        var newDSStore = try DSStore(data: dsStore.data)
//        dump(newDSStore)
//        newDSStore.appendRecord(.vSrn(.general()))
//        try newDSStore.appendRecord(.icvp(.createNew(value: .init())))
//        try newDSStore.appendRecord(.bwsp(.createNew(value: .init(
//            containerShowSidebar: false, showPathbar: false, showSidebar: false,
//            showStatusBar: false, showTabView: false, showToolbar: false, windowBounds: CGRect(origin: .zero, size: .init(width: 400, height: 400))
//        ))))
//        try newDSStore.save(to: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/TestFolder/TestCreate/.DS_Store")!)
    }
    
    func testData() throws {
        let data = try Data(contentsOf: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        let buffer = Array(data)
        print(buffer)
        let bufferFromFRead = readAllBytesFromFile(path: "/Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")
        XCTAssertEqual(buffer, bufferFromFRead)
    }
    
    
}


extension DSStoreKitTests {
    func readAllBytesFromFile(path: String) -> [UInt8]? {
        // 打开文件
        guard let file = fopen(path, "rb") else {
            print("无法打开文件")
            return nil
        }

        // 移动到文件末尾以确定文件大小
        fseek(file, 0, SEEK_END)
        let fileSize = ftell(file)
        rewind(file)  // 回到文件开头

        // 分配足够大小的缓冲区
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: fileSize)
        defer {
            buffer.deallocate()  // 确保最后释放内存
        }

        // 使用 fread 读取数据
        let readItems = fread(buffer, 1, fileSize, file)
        if readItems != fileSize {
            print("读取文件时发生错误")
            fclose(file)
            return nil
        }

        // 关闭文件
        fclose(file)

        // 将读取的数据转换为 UInt8 数组
        let data = Array(UnsafeBufferPointer(start: buffer, count: fileSize))
        return data
    }
}
