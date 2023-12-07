# DSStoreKit

This package is a backup for the `AppDMG` package, whose main function is to parse and modify the undocumented `.DS_Store` files in the Mac operating system.

## Installation

```

```

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
- AppDMG


## Acknowledgment

* https://metacpan.org/dist/Mac-Finder-DSStore/view/DSStoreFormat.pod
* https://formats.kaitai.io/ds_store/index.html
* [sindresorhus/*create-dmg*](https://github.com/sindresorhus/create-dmg)
* [create-dmg/*create-dmg*](https://github.com/create-dmg/create-dmg)

