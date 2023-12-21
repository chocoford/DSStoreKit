# DSStoreKit

This package is a backup for the [`AppDMG`](https://github.com/chocoford/AppDMG) package, whose main function is to parse and modify the undocumented `.DS_Store` files in the Mac operating system.

## Installation

#### Package.swift

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/chocoford/DSStoreKit.git", branch: "main")
    ],
    targets: [
        .target(
						...
            dependencies: [
								...
                "DSStoreKit"
            ],
            ...
        )
    ]
)
```

#### Xcode project

`Menubar` - `File` - `Add Package Dependencies...` - type and search `https://github.com/chocoford/DSStoreKit.git`

## How to use

### import `DSStoreKit`
```swift
import DSStoreKit
```

### Create a DS\_Store

```swift
var dsStore = DSStore.create()

// make changes
// ...

try dsStore.save(to: ...)
```

### Read a .DS\_Store file

```swift 
let dsStore = try DSStore(url: ...)
// or
// let dsStore = try DSStore(path: ...)

print(dsStore)

```

## Roadmap



## See also
- [AppDMG](https://github.com/chocoford/AppDMG) - A swift package that enables creating DMG files programmatically.


## Acknowledgment

* https://metacpan.org/dist/Mac-Finder-DSStore/view/DSStoreFormat.pod
* https://formats.kaitai.io/ds_store/index.html
* [sindresorhus/*create-dmg*](https://github.com/sindresorhus/create-dmg)
* [create-dmg/*create-dmg*](https://github.com/create-dmg/create-dmg)

