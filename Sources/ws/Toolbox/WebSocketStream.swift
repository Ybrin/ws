//
//  WebSocketStream.swift
//  ws
//
//  Created by Koray Koska on 28.11.17.
//

import Foundation
import WebSockets
import Sockets

final class WebSocketStream: DuplexStream {

    func read(max: Int, into buffer: inout Bytes) throws -> Int {
    }

    func write(max: Int, from buffer: Bytes) throws -> Int {
    }

    var isClosed: Bool

    func close() throws {
    }

    func setTimeout(_ timeout: Double) throws {
    }
}
