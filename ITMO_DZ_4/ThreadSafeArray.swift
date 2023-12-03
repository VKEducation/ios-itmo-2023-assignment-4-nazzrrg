import Foundation

// RWLock is used because it is unlikely that there will be many more writes than reads.
// (Regular mutex would be more effective in that case because it is simpler => works faster even on system level)
final class ThreadSafeArray<T>: RangeReplaceableCollection {
    private var array: [T] = []
    private let rwMutex = RWLock()
    //todo: recursive lock
    typealias Index = Int
    typealias Element = T
    typealias Indices = Range<Index>
    typealias SubSequence = ThreadSafeArray<T>
    
    var endIndex: Index { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.endIndex }
    var indices: Range<Index> { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.indices }
    var startIndex: Index { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.startIndex }
    var last: Element? { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.last }
    var count: Int { get { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.count } }
    var first: Element? { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.first }
    var isEmpty: Bool { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.isEmpty }
    
    init() {
        array = Array<T>([])
    }
    
    init<S>(_ elements: S) where S : Sequence, ThreadSafeArray.Element == S.Element {
        array = Array<S.Element>(elements)
    }
    
    init(repeating element: Element, count: Int) {
        array = Array.init(repeating: element, count: count)
    }
    
    subscript(index: Index) -> Element {
        get { rwMutex.readLock(); defer { rwMutex.unlock() }; return array[index] }
        set { rwMutex.writeLock(); defer { rwMutex.unlock() }; array[index] = newValue }
    }
    
    subscript(index: Range<Index>) -> ThreadSafeArray<T> {
        get { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array[index]) }
    }
}

// RangeReplaceableCollection
extension ThreadSafeArray {
    func append(element: Element) { rwMutex.writeLock(); defer { rwMutex.unlock() }; array.append(element) }
    func append<S>(contentsOf sequence: S) where S: Sequence, T == S.Element {
        rwMutex.writeLock(); defer { rwMutex.unlock() }; array.append(contentsOf: sequence)
    }
    func applying(_ difference: CollectionDifference<Element>) -> Self? {
        rwMutex.writeLock()
        defer { rwMutex.unlock() }
        guard let newArray = array.applying(difference) else {
            return nil
        }
        array = newArray
        return self
    }
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> ThreadSafeArray<T> {
        rwMutex.readLock()
        defer { rwMutex.unlock() }
        return ThreadSafeArray<T>(try array.filter(isIncluded))
    }
    
    func insert(_ newElement: Element, at: Index) { rwMutex.writeLock(); defer { rwMutex.unlock() }; array.insert(newElement, at: at) }
    
    func remove(at index: Index) -> Element { rwMutex.writeLock(); defer { rwMutex.unlock() }; return array.remove(at: index) }
    
//    func remove(atOffsets: IndexSet) { rwMutex.writeLock(); defer { rwMutex.unlock() }; array.remove(remove(atOffsets: atOffsets)) }
//    Available when Self conforms to MutableCollection.
    
    func removeAll(keepingCapacity: Bool) { rwMutex.writeLock(); defer { rwMutex.unlock() }; array.removeAll(keepingCapacity: keepingCapacity) }
    
    func removeAll(where predicate: (Element) throws -> Bool) rethrows { rwMutex.writeLock(); defer { rwMutex.unlock() }; try array.removeAll(where: predicate) }
    
//    func removeLast(Int) { rwMutex.writeLock(); defer { rwMutex.unlock() }; return array.removeLast() }
//    Available when Self conforms to BidirectionalCollection and Self is Self.SubSequence.
//    Available when Self conforms to BidirectionalCollection.
    
    func removeSubrange(_ bounds: Range<Index>) { rwMutex.writeLock(); defer { rwMutex.unlock() }; array.removeSubrange(bounds) }
    
//    func replace<Output, Replacement>(some RegexComponent, maxReplacements: Int, with: (Regex<Output>.Match) throws -> Replacement) rethrows
//    Available when SubSequence is Substring.
    
//    func replace<Replacement>(some RegexComponent, with: Replacement, maxReplacements: Int)
//    Available when SubSequence is Substring.
    
//    func replace<C, Replacement>(C, with: Replacement, maxReplacements: Int)
//    Available when Element conforms to Equatable.
    
//    func replace<Output, Replacement>(maxReplacements: Int, content: () -> some RegexComponent, with: (Regex<Output>.Match) throws -> Replacement) rethrows
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
    
//    func replace<Replacement>(with: Replacement, maxReplacements: Int, content: () -> some RegexComponent)
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
    
    func replaceSubrange<C>(_ subrange: Range<Index>, with collection: C) where C: Collection, T == C.Element {
        rwMutex.writeLock(); defer { rwMutex.unlock() }; array.replaceSubrange(subrange, with: collection)
    }
    
//    func replacing<Output, Replacement>(some RegexComponent, maxReplacements: Int, with: (Regex<Output>.Match) throws -> Replacement) rethrows -> Self
//    Available when SubSequence is Substring.
    
//    func replacing<Output, Replacement>(some RegexComponent, subrange: Range<Self.Index>, maxReplacements: Int, with: (Regex<Output>.Match) throws -> Replacement) rethrows -> Self
//    Available when SubSequence is Substring.
    
//    func replacing<Replacement>(some RegexComponent, with: Replacement, maxReplacements: Int) -> Self
//    Available when SubSequence is Substring.
    
//    func replacing<C, Replacement>(C, with: Replacement, maxReplacements: Int) -> Self
//    Available when Element conforms to Equatable.
    
//    func replacing<C, Replacement>(C, with: Replacement, subrange: Range<Self.Index>, maxReplacements: Int) -> Self
//    Available when Element conforms to Equatable.
    
//    func replacing<Replacement>(some RegexComponent, with: Replacement, subrange: Range<Self.Index>, maxReplacements: Int) -> Self
//    Available when SubSequence is Substring.
    
//    func replacing<Output, Replacement>(maxReplacements: Int, content: () -> some RegexComponent, with: (Regex<Output>.Match) throws -> Replacement) rethrows -> Self
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
        
//    func replacing<Output, Replacement>(subrange: Range<Self.Index>, maxReplacements: Int, content: () -> some RegexComponent, with: (Regex<Output>.Match) throws -> Replacement) rethrows -> Self
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
        
//    func replacing<Replacement>(with: Replacement, maxReplacements: Int, content: () -> some RegexComponent) -> Self
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
        
//    func replacing<Replacement>(with: Replacement, subrange: Range<Self.Index>, maxReplacements: Int, content: () -> some RegexComponent) -> Self
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
        
    func reserveCapacity(_ minimumCapacity: Int) { rwMutex.writeLock(); defer { rwMutex.unlock() }; array.reserveCapacity(minimumCapacity) }
        
//    func trimPrefix(() -> some RegexComponent)
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
    
//    func trimPrefix(some RegexComponent)
//    Available when Self conforms to BidirectionalCollection and SubSequence is Substring.
    
//    func trimPrefix<Prefix>(Prefix)
//    Available when Element conforms to Equatable.
    
    func trimPrefix(while predicate: (Element) throws -> Bool) rethrows {
        rwMutex.writeLock(); defer { rwMutex.unlock() }; try array.trimPrefix(while: predicate)
    }
}

extension ThreadSafeArray: RandomAccessCollection {}

extension ThreadSafeArray: BidirectionalCollection {
//    func contains(some RegexComponent) -> Bool
//    Available when SubSequence is Substring.
    
//    func contains(() -> some RegexComponent) -> Bool
//    Available when SubSequence is Substring.
    
//    func difference<C>(from: C) -> CollectionDifference<Self.Element>
//    Available when Element conforms to Equatable.
    
    func difference<C>(from: C, by: (C.Element, Element) -> Bool) -> CollectionDifference<Element> where C: BidirectionalCollection, T == C.Element {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return array.difference(from: from, by: by)
    }
    
//    func firstMatch<Output>(of: () -> some RegexComponent) -> Regex<Output>.Match?
//    Available when SubSequence is Substring.
    
//    func firstMatch<Output>(of: some RegexComponent) -> Regex<Output>.Match?
//    Available when SubSequence is Substring.
    
//    func firstRange(of: some RegexComponent) -> Range<Self.Index>?
//    Available when SubSequence is Substring.

//    func firstRange(of: () -> some RegexComponent) -> Range<Self.Index>?
//    Available when SubSequence is Substring.
    
//    func firstRange<C>(of: C) -> Range<Index>?
//    Available when Element conforms to Comparable.
    
    func formIndex(before: inout Index) { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.formIndex(before: &before) }
    
    func index(before: Index) -> Index { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.index(before: before) }
    
//    func joined(separator: String) -> String
//    Available when Element is String.
    
    func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.last(where: predicate)
    }
    
//    func lastIndex(of: Element) -> Index?
//    Available when Element conforms to Equatable.
    
    func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.lastIndex(where: predicate)
    }
    
//    func matches<Output>(of: () -> some RegexComponent) -> [Regex<Output>.Match]
//    Available when SubSequence is Substring.
    
//    func matches<Output>(of: some RegexComponent) -> [Regex<Output>.Match]
//    Available when SubSequence is Substring.
    
    func popLast() -> Element? { rwMutex.writeLock(); defer { rwMutex.unlock() }; return array.popLast() }
    
//    Available when Self is Self.SubSequence.
    
//    func prefixMatch<Output>(of: () -> some RegexComponent) -> Regex<Output>.Match?
//    Available when SubSequence is Substring.
    
//    func prefixMatch<R>(of: R) -> Regex<R.RegexOutput>.Match?
//    Available when SubSequence is Substring.
    
//    func ranges(of: some RegexComponent) -> [Range<Self.Index>]
//    Available when SubSequence is Substring.
    
//    func ranges(of: () -> some RegexComponent) -> [Range<Self.Index>]
//    Available when SubSequence is Substring.
    
    func removeLast() -> Element { rwMutex.writeLock(); defer { rwMutex.unlock() }; return array.removeLast() }
//    Available when Self is Self.SubSequence.

    
//    func removeLast(Int)
//    Available when Self is Self.SubSequence.
    
    //todo
//    func reversed() -> ReversedCollection<Self>
//    Returns a view presenting the elements of the collection in reverse order.
    
//    func split(maxSplits: Int, omittingEmptySubsequences: Bool, separator: () -> some RegexComponent) -> [Self.SubSequence]
//    Available when SubSequence is Substring.
    
//    func split(separator: some RegexComponent, maxSplits: Int, omittingEmptySubsequences: Bool) -> [Self.SubSequence]
//    Available when SubSequence is Substring.
    
//    func starts(with: some RegexComponent) -> Bool
//    Available when SubSequence is Substring.
    
//    func starts(with: () -> some RegexComponent) -> Bool
//    Available when SubSequence is Substring.
        
//    func trimmingPrefix(some RegexComponent) -> Self.SubSequence
//    Available when SubSequence is Substring.
        
//    func trimmingPrefix(() -> some RegexComponent) -> Self.SubSequence
//    Available when SubSequence is Substring.
        
//    func wholeMatch<Output>(of: () -> some RegexComponent) -> Regex<Output>.Match?
//    Available when SubSequence is Substring.
        
//    func wholeMatch<R>(of: R) -> Regex<R.RegexOutput>.Match?
//    Available when SubSequence is Substring.
}

extension ThreadSafeArray: Collection {
//    func index(after i: Int) -> Int { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.index(after: i) }
//    func index(before i: Int) -> Int { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.index(before: i) }
    func insert<C>(contentsOf sequence: C, at index: Index) where C: Collection, T == C.Element {
        rwMutex.writeLock(); defer { rwMutex.unlock() }; return array.insert(contentsOf: sequence, at: index)
    }
    
//    func popFirst() -> Element?
//    Available when Self is Self.SubSequence.
    
    func removeFirst() -> Element { rwMutex.writeLock(); defer { rwMutex.unlock() }; return array.removeFirst() }

    func removeFirst(_ k: Int) { rwMutex.writeLock(); defer { rwMutex.unlock() }; array.removeFirst(k) }
    
    func index(after: Index) -> Index { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.index(after: after) }
    
//    func formIndex(_ index: inout Index, offsetBy: Int)
//    Offsets the given index by the specified distance.
    
//    func formIndex(inout Self.Index, offsetBy: Int, limitedBy: Self.Index) -> Bool
//    Offsets the given index by the specified distance, or so that it equals the given limiting index.
    
//    func contains<C>(c: C) -> Bool where C: BidirectionalCollection, T == C.Element
//    Available when Element conforms to Equatable.
    
    func distance(from: Index, to: Index) -> Int { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.distance(from: from, to: to) }
    
    func drop(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        rwMutex.writeLock(); defer { rwMutex.unlock() }; return try ThreadSafeArray(array.drop(while: predicate))
    }
    
    func dropFirst(_ k: Int) -> SubSequence { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array.dropFirst(k)) }
    
    func dropLast(_ k: Int) -> SubSequence { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array.dropLast(k)) }
    
//    func firstIndex(of: Element) -> Index?
//    Available when Element conforms to Equatable.
    
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.firstIndex(where: predicate)
    }
    
//    func firstRange<C>(of: C) -> Range<Self.Index>?
//    Available when Element conforms to Equatable.
    
    func flatMap(_ transform: (Element) throws -> String?) rethrows -> [String] {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.flatMap(transform)
    }
    
    func formIndex(after: inout Index) { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.formIndex(after: &after) }
    
    func index(_ i: Index, offsetBy: Int) -> Index { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.index(i, offsetBy: offsetBy) }
    
    func index(_ i: Index, offsetBy: Int, limitedBy: Index) -> Index? {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return array.index(i, offsetBy: offsetBy, limitedBy: limitedBy)
    }
    
//    func index(of: Self.Element) -> Self.Index?
//    Available when Element conforms to Equatable.
    
    func map<V>(_ transform: (Element) throws -> V) rethrows -> [V] where V == Element {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.map(transform)
    }

    func prefix(_ maxLength: Int) -> SubSequence { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array.prefix(maxLength)) }
    
    func prefix(through: Index) -> SubSequence { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array.prefix(through: through)) }
    
    func prefix(upTo: Index) -> SubSequence { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array.prefix(upTo: upTo)) }
    
    func prefix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence  {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try ThreadSafeArray(array.prefix(while: predicate))
    }
    
    func randomElement() -> Element? { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.randomElement() }
    
    func randomElement<V>(using generator: inout V) -> Element? where V: RandomNumberGenerator {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return array.randomElement(using: &generator)
    }
    
//    func ranges<C>(of: C) -> [Range<Index>]
//    Available when Element conforms to Equatable.
        
    func split(maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [SubSequence] {
        rwMutex.readLock()
        defer { rwMutex.unlock() }
        let splits = try array.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
        var result: [ThreadSafeArray<Element>] = Array()
        for split in splits {
            result.append(ThreadSafeArray(split))
        }
        return result
    }
    
//    func split(separator: Element, maxSplits: Int, omittingEmptySubsequences: Bool) -> [SubSequence]
//    Available when Element conforms to Equatable.
    
//    func split<C>(separator: C, maxSplits: Int, omittingEmptySubsequences: Bool) -> [SubSequence]
//    Available when Element conforms to Equatable.
    func suffix(_ maxLength: Int) -> SubSequence { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array.suffix(maxLength)) }
    
    func suffix(from: Int) -> SubSequence { rwMutex.readLock(); defer { rwMutex.unlock() }; return ThreadSafeArray(array.suffix(from: from)) }
    
//    func trimPrefix<Prefix>(Prefix)
//    Available when Self is SubSequence and Element conforms to Equatable.
    
//    func trimPrefix(while: (Element) throws -> Bool) throws {
//    }
//    Available when Self is SubSequence.
    
//    func trimmingPrefix<Prefix>(Prefix) -> SubSequence
//    Available when Element conforms to Equatable.
    
    func trimmingPrefix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try ThreadSafeArray(array.trimmingPrefix(while: predicate))
    }
}

extension ThreadSafeArray: Sequence {
    //    func contains(Self.Element) -> Bool
    //    Available when Element conforms to Equatable.
    
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.contains(where: predicate)
    }
    
    func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.allSatisfy(predicate)
    }
    
    func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.first(where: predicate)
    }
    
    //    func min() -> Element?
    //    Available when Element conforms to Comparable.
    
    func min(by predicate: (Element, Element) throws -> Bool) rethrows -> Element? {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.min(by: predicate)
    }
    
    //    func max() -> Element?
    //    Available when Element conforms to Comparable.
    
    func max(by predicate: (Element, Element) throws -> Bool) rethrows -> Element? {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.max(by: predicate)
    }
    
    func compactMap<ElementOfResult>(_ predicate: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.compactMap(predicate)
    }
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.reduce(initialResult, nextPartialResult)
    }
    
    func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.reduce(into: initialResult, updateAccumulatingResult)
    }
    
    func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.flatMap(transform)
    }
    
    func forEach(_ body: (Element) throws -> Void) rethrows {
        rwMutex.writeLock(); defer { rwMutex.unlock() }; try array.forEach(body)
    }
        
//    func enumerated() -> EnumeratedSequence<Self>
//    Returns a sequence of pairs (n, x), where n represents a consecutive integer starting at zero and x represents an element of the sequence.
    var underestimatedCount: Int {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return array.underestimatedCount
    }
    
//    func sorted() -> [Element]
//    Available when Element conforms to Comparable.
    
    func sorted(by predicate: (Element, Element) throws -> Bool) rethrows -> [Element] {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return try array.sorted(by: predicate)
    }
    
    func reversed() -> [Element] { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.reversed() }
    
    
    func shuffled() -> [Element] { rwMutex.readLock(); defer { rwMutex.unlock() }; return array.shuffled() }
    
    func shuffled<V>(using generator: inout V) -> [Element] where V: RandomNumberGenerator {
        rwMutex.readLock(); defer { rwMutex.unlock() }; return array.shuffled(using: &generator)
    }
        
//    func joined(separator: String) -> String
//    Available when Element conforms to StringProtocol.
    
//    func joined<Separator>(separator: Separator) -> JoinedSequence<Self>
//    Returns the concatenated elements of this sequence of sequences, inserting the given separator between each element.
    
//    func elementsEqual<OtherSequence>(OtherSequence) -> Bool
//    Available when Element conforms to Equatable.
    
    func elementsEqual<OtherSequence>(_ other: OtherSequence, by predicate: (Element, OtherSequence.Element) throws -> Bool) rethrows -> Bool where OtherSequence: ThreadSafeArray, OtherSequence.Element == Element
    {
        rwMutex.readLock();
        other.rwMutex.readLock();
        defer { rwMutex.unlock() };
        defer { other.rwMutex.unlock() };
        return try array.elementsEqual(other.array, by: predicate)
    }
    
//    func starts<PossiblePrefix>(with: PossiblePrefix) -> Bool
//    Available when Element conforms to Equatable.
    
//    func lexicographicallyPrecedes<OtherSequence>(OtherSequence) -> Bool
//    Available when Element conforms to Comparable.
    
    func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence, by predicate: (Element, Element) throws -> Bool) rethrows -> Bool where OtherSequence: ThreadSafeArray, OtherSequence.Element == Element
    {
        rwMutex.readLock();
        other.rwMutex.readLock();
        defer { rwMutex.unlock() };
        defer { other.rwMutex.unlock() };
        return try array.lexicographicallyPrecedes(other.array, by: predicate)
    }
}

// Specific multithread functions
extension ThreadSafeArray {
    func findAndInsert<C> (
        contentsOf collection: C,
        atLastWhere predicate: (Element) throws -> Bool,
        or backupIndex: Index
    ) rethrows where C : Collection, T == C.Element {
        rwMutex.writeLock()
        defer { rwMutex.unlock() }
        array.insert(contentsOf: collection, at: try array.lastIndex(where: predicate) ?? backupIndex)
    }
    
    func findAndInsert<C> (
        contentsOf collection: C,
        atFirstWhere predicate: (Element) throws -> Bool,
        or backupIndex: Index
    ) rethrows where C : Collection, T == C.Element {
        rwMutex.writeLock()
        defer { rwMutex.unlock() }
        array.insert(contentsOf: collection, at: try array.firstIndex(where: predicate) ?? backupIndex)
    }
}

extension ThreadSafeArray: CustomStringConvertible {
    public var description: String {
        rwMutex.readLock()
        defer { rwMutex.unlock() }
        return "\(array)"
    }
}

