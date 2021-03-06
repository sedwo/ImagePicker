import Foundation
import UIKit
import Photos


open class AssetManager {

  public static func resolveAsset(_ asset: PHAsset, size: CGSize = UIScreen.main.bounds.size, shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {

    if asset is ImageFileAsset {
      // Include internal cached /tmp files.
      let fileAsset = asset as! ImageFileAsset
      if let image = UIImage(contentsOfFile: fileAsset.fileURL.path) {
        let scaledImage = image.scaled(to: size)
        completion(image)
      }
    } else {  // pure PHAsset
      let imageManager = PHImageManager.default()
      let requestOptions = PHImageRequestOptions()
      requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
      requestOptions.isNetworkAccessAllowed = true
      requestOptions.isSynchronous = true

      imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
        if let info = info, info["PHImageFileUTIKey"] == nil {
          DispatchQueue.main.async(execute: {
            completion(image)
          })
        }
      }
    }
  }


  open static func resolveAssets(_ assets: [PHAsset], size: CGSize = UIScreen.main.bounds.size, completion: @escaping ([(imageData: Data?, imageFileURL: URL?)])->()) {

    var images = [(imageData: Data?, imageFileURL: URL?)]()

    if !assets.isEmpty {
      for asset in assets {

        if asset is ImageFileAsset {
          // Include internal cached /tmp files.
          let fileAsset = asset as! ImageFileAsset
          if let image = UIImage(contentsOfFile: fileAsset.fileURL.path) {
            let scaledImage = image.scaled(to: size)

            if let scaledImageData = scaledImage.jpegData(compressionQuality: 1.0) {
              images.append((scaledImageData, fileAsset.fileURL))
            }
            if (images.count == assets.count) {
              completion(images)
            }
          }

        } else {  // camera roll asset

          let imageManager = PHImageManager.default()
          let requestOptions = PHImageRequestOptions()
          requestOptions.deliveryMode = .highQualityFormat
          requestOptions.isNetworkAccessAllowed = true
          requestOptions.isSynchronous = true
          requestOptions.version = .original
          imageManager.requestImageData(for: asset, options: requestOptions, resultHandler: { (data, string, orientation, info) in
            if let data = data {
              images.append((imageData: data, nil))
            }
            if (images.count == assets.count) {
              completion(images)
            }
          })
        }
      }
    }
  }


  public static func fetch(withConfiguration configuration: Configuration, _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
    guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }

    DispatchQueue.global(qos: .background).async {
      let fetchResult = configuration.allowVideoSelection
        ? PHAsset.fetchAssets(with: PHFetchOptions())
        : PHAsset.fetchAssets(with: .image, options: PHFetchOptions())

      if fetchResult.count > 0 {
        var assets = [PHAsset]()
        fetchResult.enumerateObjects({ object, _, _ in
          assets.insert(object, at: 0)
        })

        DispatchQueue.main.async {
          completion(assets)
        }
      }
    }
  }


  public static func getResourceImage(_ name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = Bundle(for: AssetManager.self)

    if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/ImagePicker.bundle") {
      bundle = resourceBundle
    }

    return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
  }


}
