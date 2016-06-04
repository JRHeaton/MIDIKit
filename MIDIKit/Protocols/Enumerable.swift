/// A type that can be counted and addressed via an integer index
public protocol Enumerable {
	static var count: Int { get }
	init(index: Int)
}

extension Enumerable {
	
	/// An instant mapping from indices to values
	public static var all: [Self] {
		return (0..<Self.count).map(Self.init)
	}
	
	/// A lazy mapping from indices to values
	public static var allLazy: AnyRandomAccessCollection<Self> {
		return .init((0..<Self.count).lazy.map(Self.init))
	}
}
