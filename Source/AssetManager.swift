import Foundation
import UIKit
import Photos

open class AssetManager {

  open static func getImage(_ name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = Bundle(for: AssetManager.self)

    if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/ImagePicker.bundle") {
      bundle = resourceBundle
    }

    return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
  }

  open static func fetch(withConfiguration configuration: Configuration, _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
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

  open static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
    requestOptions.isNetworkAccessAllowed = true

    imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
      if let info = info, info["PHImageFileUTIKey"] == nil {
        DispatchQueue.main.async(execute: {
          completion(image)
        })
      }
    }
  }

  open static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true

    var images = [UIImage]()
    for asset in assets {
      imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
        if let image = image {
          images.append(image)
        }
      }
    }
    return images
  }

  open static func resolveAssets(_ assets: [PHAsset],imagesClosers: @escaping ([(imageData: Data, location: CLLocation?)])->()) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true

    var imagesData = [(imageData: Data,location: CLLocation?)]()

    if !assets.isEmpty {
      for asset in assets {

        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        asset.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) -> Void in

          let optionsRequest = PHImageRequestOptions()
          optionsRequest.version = .original
          optionsRequest.isSynchronous = true

          if asset.location == nil {
            //Image without location and exif data (like screenshots)
            let targetSize = ImagePickerController.photoQuality == AVCaptureSession.Preset.photo ? PHImageManagerMaximumSize : CGSize(width: 720, height: 1280)
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: optionsRequest) { image, _ in
              if let image = image, let data = UIImageJPEGRepresentation(image, 1.0) {
                imagesData.append((data, asset.location))
                if (imagesData.count == assets.count) {
                  imagesClosers(imagesData)
                }
              }
            }
          } else {
            ////Image with location and exif data
            imageManager.requestImageData(for: asset, options: optionsRequest, resultHandler: { (data, string, orientation, info) in
              if let data = data {
                imagesData.append((data, contentEditingInput!.location))
                if (imagesData.count == assets.count) {
                  imagesClosers(imagesData)
                }
              }
            })
          }
        }
      }
    } else {
      imagesClosers(imagesData)
    }
  }

}
