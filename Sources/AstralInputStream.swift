//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.InputStream
import class Foundation.Stream
import protocol Foundation.StreamDelegate
import struct Foundation.Data
import class Foundation.RunLoop

public class AstralInputStream: InputStream {

    // MARK: Initializer
    public init(inputStreams: [InputStream]) {
        self.inputStreams = inputStreams
        self.currentIndex = 0
        self._streamStatus = Stream.Status.notOpen
        super.init(data: Data())
    }

    // MARK: Stored Properties
    public let inputStreams: [InputStream]
    public private(set) var currentIndex: Int
    private var _streamStatus: Stream.Status
    private var _streamError: Error?
    private weak var _delegate: StreamDelegate?

    // MARK: Computed Properties
    override public var hasBytesAvailable: Bool {
        return true
    }

    override public var streamStatus: Stream.Status {
        return self._streamStatus
    }

    override public var streamError: Error? {
        return _streamError
    }

    override public var delegate: StreamDelegate? {
        set { self._delegate = newValue }
        get { return self._delegate }
    }

    // MARK: Instance Methods
    override public func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
         if self.streamStatus == Stream.Status.closed { return 0 }

        var totalNumberOfBytesRead: Int = 0

        while totalNumberOfBytesRead < len {
            print("Total number of bytes read: \(totalNumberOfBytesRead)")

            if self.currentIndex == self.inputStreams.count {
                self.close()
                break
            }
            let currentInputStream: InputStream = self.inputStreams[self.currentIndex]

            if currentInputStream.streamStatus != Stream.Status.open {
                currentInputStream.open()
            }

            guard currentInputStream.hasBytesAvailable else {
                self.currentIndex += 1
                continue
            }

            let remainingLength: Int = Int(len) - totalNumberOfBytesRead
            let numberOfBytesRead = currentInputStream.read(&buffer[totalNumberOfBytesRead], maxLength: remainingLength)

            if numberOfBytesRead == 0 {
                self.currentIndex += 1
                continue
            }

            if numberOfBytesRead == -1 {
                self._streamError = currentInputStream.streamError
                return -1
            }

            totalNumberOfBytesRead += numberOfBytesRead

        }

        return totalNumberOfBytesRead
    }

    override public func getBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, length: UnsafeMutablePointer<Int>) -> Bool {
        guard self.currentIndex < self.inputStreams.count else { return false }

        return self.inputStreams[self.currentIndex].getBuffer(buffer, length: length)
    }

    override public func open() {
        guard self.streamStatus != Stream.Status.open else { return }
        self._streamStatus = Stream.Status.open
    }

    override public func close() {
        self._streamStatus = Stream.Status.closed
    }

    override public func property(forKey: Stream.PropertyKey) -> Any? {
        return nil
    }

    override public func setProperty(_ property: Any?, forKey: Stream.PropertyKey) -> Bool {
        return false
    }

    override public func schedule(in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {}

    override public func remove(from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {}

}
