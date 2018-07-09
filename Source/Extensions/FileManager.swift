import Foundation


extension FileManager {

  // https://gist.github.com/brennanMKE/a0a2ee6aa5a2e2e66297c580c4df0d66
  func directoryExistsAtPath(_ path: URL) -> Bool {
    var isDirectory = ObjCBool(true)
    let exists = self.fileExists(atPath: path.absoluteString, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
  }


  func createDirectory(_ filePath: URL) -> URL? {
    if !directoryExistsAtPath(filePath) {
      do {
        try self.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print(error.localizedDescription)
        return nil
      }
    }

    return filePath
  }


  func removeDirectory(_ filePath: URL) {
    do {
      try self.removeItem(atPath: filePath.path)
    } catch {
      print(error.localizedDescription)
    }
  }

}
