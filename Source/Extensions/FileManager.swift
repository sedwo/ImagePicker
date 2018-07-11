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


  func fileCountIn(_ filePath: URL) -> Int {
    do {
      let fileURLs = try self.contentsOfDirectory(at: filePath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
      return fileURLs.count
    } catch {
      print("Error while enumerating files \(filePath.path): \(error.localizedDescription)")
      return -1
    }
  }


  func getAllFilesIn(_ filePath: URL) -> [URL]? {
    var fileURLs: [URL] = []
    var sortedFileURLs: [URL] = []

    do {
      let keys = [URLResourceKey.contentModificationDateKey,
                  URLResourceKey.creationDateKey]
      fileURLs = try self.contentsOfDirectory(at: filePath, includingPropertiesForKeys: keys, options: .skipsHiddenFiles)
    } catch {
      print("Error while enumerating files \(filePath.path): \(error.localizedDescription)")
      return nil
    }

    let orderedFullPaths = fileURLs.sorted(by: { (url1: URL, url2: URL) -> Bool in
      do {
        let values1 = try url1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
        let values2 = try url2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])

        if let date1 = values1.creationDate, let date2 = values2.creationDate {
          return date1.compare(date2) == ComparisonResult.orderedDescending
        }
      } catch {
        print("Error comparing : \(error.localizedDescription)")
        return false
      }
      return true
    })

    for fileName in orderedFullPaths {
      do {
        let values = try fileName.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
        if let date = values.creationDate{
          sortedFileURLs.append(fileName)
        }
      }
      catch {
        print("Error sorting file URL's. : \(error.localizedDescription)")
        return nil
      }
    }

    return sortedFileURLs
  }


  func getMostRecentFileIn(_ filePath: URL) -> URL? {
    return getAllFilesIn(filePath)?.first
  }


}
