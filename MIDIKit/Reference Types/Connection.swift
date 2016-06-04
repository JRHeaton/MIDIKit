//
//  Connection.swift
//  
//
//  Created by John Heaton on 6/4/16.
//
//

public final class Connection {
	public let client: Client
	public let inputPort: InputPort
	public let outputPort: OutputPort
	
	public var destinations: [Destination] = []
	
	public init() throws {
		client = try Client()
		inputPort = try client.createInputPort()
		outputPort = try client.createOutputPort()
	}
	
	public func send(message: ChannelMessageConvertible, onChannel channel: Int) throws {
		try destinations.forEach { try outputPort.send(message, onChannel: channel, toDestination: $0) }
	}
}
