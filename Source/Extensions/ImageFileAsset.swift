import UIKit
import Photos


class ImageFileAsset: PHAsset {
  
  var fileURL: URL!
  
  convenience init(with fileURL: URL) {
    self.init()
    self.fileURL = fileURL
  }
  
  override init() {
    super.init()
  }
  
}
