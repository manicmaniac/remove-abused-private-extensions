# remove-abused-private-extensions

A makeshift tool to modify Swift source files to prohibit using private extensions to declare group of private method.


Before:

```swift
class Foo {
    func internalMethod() {
    }
}

private extension Foo {
    func privateMethod() {
    }
}
```

After:

```swift
class Foo {
    func internalMethod() {
    }

    private func privateMethod() {
    }
}
```


## Usage

    ./remove-abused-private-extensions <FILE> [FILE...]

Given `FILE`s will be rewritten in-place.
