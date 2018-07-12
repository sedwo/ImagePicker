import UIKit
import Photos

open class ImageStack {

  public struct Notifications {
    public static let imageDidPush = "imageDidPush"
    public static let imageDidDrop = "imageDidDrop"
    public static let stackDidReload = "stackDidReload"
  }

  open var assets = [PHAsset]()
  fileprivate let imageKey = "image"


  open func pushAsset(_ asset: PHAsset) {
    assets.append(asset)
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.imageDidPush), object: self, userInfo: [imageKey: asset])
  }


  open func dropAsset(_ asset: PHAsset) {
    for (index, item) in assets.enumerated() {
      if asset is ImageFileAsset && item is ImageFileAsset {
        let fileItem = item as! ImageFileAsset
        let fileAsset = asset as! ImageFileAsset
        if fileItem.fileURL == fileAsset.fileURL {
          assets.remove(at: index)
        }
      } else if asset is ImageFileAsset || item is ImageFileAsset {
        continue
      } else {
        if item == asset {
          assets.remove(at: index)
        }
      }
    }

    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.imageDidDrop), object: self, userInfo: [imageKey: asset])
  }


  open func resetAssets(_ assetsArray: [PHAsset]) {
    assets = assetsArray
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.stackDidReload), object: self, userInfo: nil)
  }


  open func containsAsset(_ asset: PHAsset) -> Bool {
    var contains: Bool = false

    for (index, item) in assets.enumerated() {
      if asset is ImageFileAsset && item is ImageFileAsset {
        if item == asset {
          contains = true
          break
        }
      } else if asset is ImageFileAsset || item is ImageFileAsset {
        continue
      } else {
        if item == asset {
          contains = true
          break
        }
      }
    }

    return contains
  }


  open func reload() {
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.stackDidReload), object: self, userInfo: nil)
  }


  func isEmpty() -> Bool {
    return assets.isEmpty
  }


  func count() -> Int {
    return assets.count
  }


}
