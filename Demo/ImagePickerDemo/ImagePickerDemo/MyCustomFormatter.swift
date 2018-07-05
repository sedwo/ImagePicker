import CocoaLumberjack


// MARK: - DDLogFormatter
public class MyCustomFormatter: NSObject, DDLogFormatter {
    let dateFormmater = DateFormatter()

    public override init() {
        super.init()
        dateFormmater.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    }


    public func format(message logMessage: DDLogMessage) -> String? {

        let dt = dateFormmater.string(from: logMessage.timestamp)
        let file = logMessage.fileName

        // let functionName = (logMessage.function ?? "").isEmpty ? "<empty function>" : logMessage.function!
        let functionName = logMessage.function!
        let lineNumber = logMessage.line
        let logMsg = logMessage.message

        return "\(dt) [\(file):@\(lineNumber):\(functionName)] - \(logMsg)"
    }
}
