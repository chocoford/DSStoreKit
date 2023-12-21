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
        
        
//        XCTAssertEqual(dsStore, DSStore.create())
    }
    
    func testRecordBuffer() throws {
        let dsStore = try DSStore(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        let originData = try Data(contentsOf: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        dump(dsStore)
        for (name, directory) in dsStore.directories {
            for (recordName, record) in directory.rootNode.records {
                var newData = originData
                let newBuffer = try record.makeBuffer()
                newData.replaceSubrange(record.start..<record.start+record.length, with: Data(newBuffer))
                let newDSStore = try DSStore(data: newData)
                
                XCTAssertEqual(
                    record,
                    newDSStore.directories[name]?.rootNode.records[recordName]
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
    
    func testReocrdsOrder() throws {
        var dsStore = try DSStore(url: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/DS_Store")!)
        let oldDSStore = dsStore
        try dsStore.save()
        dump(try DSStore(data: dsStore.data))
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
        
        for record in dsStore.directories[key]!.rootNode.records.values {
            switch record {
                case .bwsp(var record):
//                    record.value.windowBounds = .init(origin: .zero, size: .init(width: 400, height: 400))
//                    dsStore.directories[key]?.rootNode.records[i] = .bwsp(record)
                    break
                case .icvp(var record):
                    record.value.iconSize = 16
                    dsStore.directories[key]?.rootNode.records[record.key] = .icvp(record)
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
//        dump(dsStore)
//        print(dsStore.data.count)
//        try dsStore.save()
//        var newDSStore = try DSStore(data: dsStore.data)
//        dump(newDSStore)
        dsStore.insertRecord(.vSrn(.general()))
        try dsStore.insertRecord(.icvp(.createNew(value: .init())))
        try dsStore.insertRecord(.bwsp(.createNew(value: .init(
            containerShowSidebar: false, showPathbar: false, showSidebar: false,
            showStatusBar: false, showTabView: false, showToolbar: false, windowBounds: CGRect(origin: .zero, size: .init(width: 400, height: 400))
        ))))
        try dsStore.save()
        
        dump(try DSStore(data: dsStore.data))
//        try newDSStore.save(to: URL(string: "file:///Users/chocoford/Developer/DSStoreKit/Tests/TestFolder/TestCreate/.DS_Store")!)
    }
    
    func testRecordOrder() throws {
        var dsStore = DSStore.create()
        dsStore.insertRecord(.vSrn(.general()))
        try dsStore.insertRecord(.icvp(.createNew(value: .init())))
        try dsStore.insertRecord(.bwsp(.createNew(value: .init(
            containerShowSidebar: false, showPathbar: false, showSidebar: false,
            showStatusBar: false, showTabView: false, showToolbar: false, windowBounds: CGRect(origin: .zero, size: .init(width: 400, height: 400))
        ))))
        try dsStore.insertRecord(.Iloc(.createNew(name: "Applications", iconPos: .zero)))
        try dsStore.insertRecord(.Iloc(.createNew(name: "asd", iconPos: .zero)))
        dump(dsStore.directories.first?.value.rootNode.sortedRecords)
    }
}
