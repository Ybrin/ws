import Foundation
import Sockets
import WebSockets
#if os(Linux)
    import Dispatch
#endif

let programName = CommandLine.arguments.first ?? "ws"
let help = """
Opens a WebSocket Connection and let you interact with it.

Usage:
  \(programName) <host> <port>
  \(programName) (-h | --help)

Examples:
  \(programName) apple.com 80

Options:
  -h, --help  Show this screen.
"""

var arguments = CommandLine.arguments
if arguments.count > 0 {
    arguments.remove(at: 0)
}

if arguments.contains("-h") || arguments.contains("--help") {
    print(help)
    exit(0)
}

guard arguments.count == 2 else {
    print(help)
    exit(1)
}

let hostAndAddress = arguments[0]
let portStr = arguments[1]
guard let port = UInt16(portStr) else {
    print("Port must be a UInt16 compatible type")
    print()
    print(help)
    exit(1)
}

var shouldPoll = true
var shouldRead = true

let cli = CLI(prefix: "WS Input")

let splitted = hostAndAddress.split(separator: "/").map({ String($0) })
let host = splitted.first ?? ""
let address = splitted.count > 1 ? "\(splitted[1])" : ""

let tcp = try TCPInternetSocket(scheme: "ws", hostname: host, port: port)
let to = "ws://\(host):\(String(port))/\(address)"
try WebSocket.connect(to: to, using: tcp) { ws in

    // Polling
    ws.onBinary = { s, bytes in
        cli.print(color: .blue, string: String(bytes: bytes))
    }
    ws.onText = { s, string in
        cli.print(color: .blue, string: string)
    }

    // keepalive
    let p = DispatchSource.makeTimerSource()
    p.schedule(deadline: .now(), repeating: .seconds(16))
    p.setEventHandler { try? ws.ping() }
    p.resume()

    DispatchQueue(label: "writing").async {
        // Writing
        while shouldRead {
            Thread.sleep(forTimeInterval: 0.1)
            let line = cli.getLine()

            do {
                let bytes = line.makeBytes()
                try ws.send(bytes)
                cli.print("Bytes written: \(bytes.count)")
            } catch {
                print("::: Write failed :::")
                print(error)
                exit(1)
            }
        }
    }
}

while shouldPoll || shouldRead {
    usleep(100000)
}
