import Foundation

private protocol AnyOptional {
    var isNil: Bool { get }
    var isNotNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
    var isNotNil: Bool { self != nil }
}
