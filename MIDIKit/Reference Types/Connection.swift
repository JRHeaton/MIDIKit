public final class Connection {
	public let client: Client
	public let inputPort: InputPort
	public let outputPort: OutputPort
	
	public var destinations: [Destination] = []
	
	public init(client: Client) throws {
		self.client = client
		inputPort = try client.createInputPort()
		outputPort = try client.createOutputPort()
	}
	
	public convenience init() throws {
		try self.init(client: Client())
	}
	
	public func send(message: ChannelMessageConvertible, onChannel channel: Int) throws {
		try destinations.forEach { try outputPort.send(message, onChannel: channel, toDestination: $0) }
	}
}
