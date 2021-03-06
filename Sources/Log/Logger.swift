/// Copyright 2017 Sergei Egorov
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import Foundation
import Filesystem

public class Logger {
    
    // MARK: Error enum
    
    public enum Error: Swift.Error {
        case couldNotOpenFile
    }

    // MARK: Properties, initialization, deinitialization

    /// FileOutputStreamer instance of a class for recording in a log file.
    fileprivate let outputStreamer: FileOutputStreamer

    /// Encoding of the text of log.
    fileprivate let encoding: String.Encoding

    /// The date format of timestamp (default: ISO 8601 date format).
    fileprivate var dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    /// The timestamp for log entry.
    fileprivate var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let currentDate = Date()
        return formatter.string(from: currentDate)
    }

    /// Initialization.
    ///
    /// - Parameters:
    ///   - logPath:    Path to the log file in which it is necessary to make record.
    ///   - encoding:   Encoding of the text of log. Default value is utf8.
    ///   - dateFormat: The date format of timestamp for log entry.
    ///                 Default value is ISO 8601 date format `yyyy-MM-dd'T'HH:mm:ss.SSSZ`.
    ///
    /// - Throws: `Logger.Error.couldNotOpenFile`
    ///
    public convenience init(_ logPath: String, encoding: String.Encoding = .utf8, dateFormat: String) throws {
        do {
            try self.init(logPath, encoding: encoding)
            self.dateFormat = dateFormat
        } catch {
            throw Error.couldNotOpenFile
        }
    }

    /// Initialization.
    ///
    /// - Parameters:
    ///   - logPath:    Path to the log file in which it is necessary to make record.
    ///   - encoding:   Encoding of the text of log. Default value is utf8.
    ///
    /// - Throws: `Logger.Error.couldNotOpenFile`
    ///
    public init(_ logPath: String, encoding: String.Encoding = .utf8) throws {
        do {
            self.outputStreamer = try FileOutputStreamer(file: logPath)
            self.encoding = encoding
        } catch {
            throw Error.couldNotOpenFile
        }
    }

}

extension Logger: LogProtocol {

    // MARK: LogProtocol

    /// Creates log entry and writes it in the log file.
    ///
    /// - Parameters:
    ///   - entryMsg:  Text message for log entry.
    ///   - file:      The file from which write process is initiated.
    ///   - line:      The line of the file from which write process is initiated.
    ///   - function:  Function from which write process is initiated.
    ///   - entryType: Type of the log entry. Accepts values - verbose, debug, info,
    ///                warning, error.
    ///
    public func record(entryMsg: String, file: String, line: Int, function: String, entryType: EntryType) {
        let pipe = Delimiter.spacedPipe.rawValue
        var entry = date
        entry.append(pipe)
        entry.append(entryType.description)
        entry.append(pipe)
        entry.append("\(file.lastPathComponent):\(String(line))")
        entry.append(pipe)
        entry.append(function)
        entry.append(Delimiter.spacedHyphen.rawValue)
        entry.append(entryMsg)
        entry.append(Delimiter.newLine.rawValue)
        let entryData = entry.data(using: encoding)!
        outputStreamer.write(content: entryData)
        outputStreamer.synchronize()
    }

}
