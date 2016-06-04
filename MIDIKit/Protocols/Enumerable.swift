public protocol Enumerable {
	static var count: Int { get }
	init(index: Int)
}

extension Enumerable {
	public static var all: [Self] {
		return (0..<Self.count).map(Self.init)
	}
	
	public static var allLazy: AnyRandomAccessCollection<Self> {
		return .init((0..<Self.count).lazy.map(Self.init))
	}
}
