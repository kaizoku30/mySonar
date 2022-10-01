import Foundation
import CoreGraphics

extension Array {
    func iteratorFunction(_ blockForEachIndex: (Int) -> Void) {
        for i in 0..<self.count {
            blockForEachIndex(i)
        }
    }
}

extension Array where Element: Equatable {

    ///Removes a given object from array if present. otherwise does nothing
    mutating func removeObject(_ object: Iterator.Element) {
        if let index = self.firstIndex(of: object) {
            self.remove(at: index)
        }
    }

    ///Removes an array of objects
    mutating func removeObjects(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }

    ///Removes all null values present in an Array
    mutating func removeNullValues() {
        self = self.compactMap { $0 }
    }

    ///Returns a sub array within the range
    subscript(range: Range<Int>) -> Array {

        var array = [Element]()

        let min = range.lowerBound
        let max = range.upperBound

        for i in min..<max {
            array += [self[i]]
        }
        return array
    }
}

extension Array where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { return reduce(0, +) }
}

extension Array where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0: Double(Int(total)) / Double(count)
    }
}

extension Array where Element: FloatingPoint {
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0: total / Element(count)
    }
}

extension Array where Element: Hashable {
    /// Method to remove duplicates
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    /// mutating Method to remove duplicates
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
    // Remove all collection element that is equal to the given `object`:
    mutating func removeAll(object: Element) {
        for (index, item) in self.enumerated() where item == object {
                remove(at: index)
        }
    }

}

extension RangeReplaceableCollection {
    /// Returns a collection containing, in order, the first instances of
    /// elements of the sequence that compare equally for the keyPath.
    func unique<T: Hashable>(for keyPath: KeyPath<Element, T>) -> Self {
        var unique = Set<T>()
        return filter { unique.insert($0[keyPath: keyPath]).inserted }
    }
}

extension Sequence {
    /// Returns an array containing, in order, the first instances of
    /// elements of the sequence that compare equally for the keyPath.
    func unique<T: Hashable>(for keyPath: KeyPath<Element, T>) -> [Element] {
        var unique = Set<T>()
        return filter { unique.insert($0[keyPath: keyPath]).inserted }
    }
}

extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        NSOrderedSet(array: self as! [Any]).array as! [Element]
    }
}

extension Array {
    
    func filterDuplicates(includeElement: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {
        
        var results = [Element]()
        
        forEach { (element) in
            
            let existingElements = results.filter {
                
                return includeElement(element, $0)
            }
            
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    func eachSlice(_ clump: Int) -> [[Self.Element]] {
        return self.reduce(into: []) { memo, cur in
            if memo.count == 0 {
                return memo.append([cur])
            }
            if memo.last!.count < clump {
                memo.append(memo.removeLast() + [cur])
            } else {
                memo.append([cur])
            }
        }
    }
    
}

extension Array where Element: Equatable {

    mutating func updateObject(_ object: Iterator.Element) {
        if let index = self.firstIndex(of: object) {
            self[index] = object
        }
    }
}

extension Array where Element: Equatable {
    func indexOfElement(element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

// MARK: - Array Extenstion
extension Array where Element: Equatable {
    @discardableResult
    func removeDuplicates() -> [Element] {
        var uniqueValues = [Element]()
        forEach {
            if !uniqueValues.contains($0) {
                uniqueValues.append($0)
            }
        }
        return uniqueValues
    }
    
    mutating
    func removeDuplicate() {
        var uniqueValues = [Element]()
        forEach {
            if !uniqueValues.contains($0) {
                uniqueValues.append($0)
            }
        }
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
