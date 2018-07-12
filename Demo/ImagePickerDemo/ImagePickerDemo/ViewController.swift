import UIKit
import ImagePicker
import Lightbox
import CocoaLumberjack
import CoreLocation
import AVFoundation



class ViewController: UIViewController, ImagePickerDelegate, LightboxControllerDeleteDelegate {

  lazy var imagePicker: ImagePickerController = {
    let config = Configuration()
    config.savePhotosToCameraRoll = false
    return ImagePickerController(configuration: config)
  }()

  lazy var button: UIButton = self.makeButton()


  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false

    view.addConstraint(
      NSLayoutConstraint(item: button, attribute: .centerX,
                         relatedBy: .equal, toItem: view,
                         attribute: .centerX, multiplier: 1,
                         constant: 0))

    view.addConstraint(
      NSLayoutConstraint(item: button, attribute: .centerY,
                         relatedBy: .equal, toItem: view,
                         attribute: .centerY, multiplier: 1,
                         constant: 0))
  }

  func makeButton() -> UIButton {
    let button = UIButton()
    button.setTitle("Show ImagePicker", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    button.addTarget(self, action: #selector(showImagePickerButton(button:)), for: .touchUpInside)

    return button
  }

  @objc func showImagePickerButton(button: UIButton) {
    imagePicker.delegate = self
    ImagePickerController.photoQuality = AVCaptureSession.Preset.photo  // full resolution photo quality output

    present(imagePicker, animated: true, completion: nil)
  }



  // MARK: - ImagePickerDelegate(s)

  func imageStackDidPress(_ imagePicker: ImagePickerController, images: [(imageData: Data?, imageFileURL: URL?)]) {
    DDLogVerbose("")

    guard images.count > 0 else { return }
    DDLogInfo("images.count = \(images.count)")

    let lightboxImages = images.map {
      return LightboxImage(image: UIImage(data: $0.imageData!)!)
    }

    LightboxConfig.DeleteButton.enabled = true
    LightboxConfig.InfoLabel.ellipsisText = "Show more"

    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    lightbox.imageDeleteDelegate = self

    imagePicker.present(lightbox, animated: true, completion: nil)



  }


  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [(imageData: Data?, imageFileURL: URL?)]) {
    DDLogVerbose("")

    guard images.count > 0 else { return }
    DDLogInfo("images.count = \(images.count)")

    for (index, image) in images.enumerated() {
      DDLogInfo("image[\(index)] path = \(String(describing: image.imageFileURL?.path))")

      // Move images into our own app.
      let destFileName = "\(UUID().uuidString).jpg"
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let destPath = documentsDirectory.appendingPathComponent(destFileName, isDirectory: false)

      do {
        if image.imageFileURL == nil {  // PHAsset data
          if let data = image.imageData {
            try data.write(to: destPath)
            DDLogVerbose("PHAsset data written")
          }
        } else {  // file asset (local .jpg)
          if let imageFilePath = image.imageFileURL?.path {
            if FileManager.default.fileExists(atPath: imageFilePath) {
              try FileManager.default.moveItem(atPath: imageFilePath, toPath: destPath.path)
              DDLogVerbose("local .jpg written")
            } else {
              DDLogError("file doesn't exist  :(")
            }
          }
        }
      }
      catch let error as NSError {
        DDLogError("Ooops! Something went wrong: \(error)")
      }
    }

    imagePicker.dismiss(animated: true, completion: nil)
  }


  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    DDLogVerbose("")
    imagePicker.dismiss(animated: true, completion: nil)
  }


  // MARK: - LightboxControllereDelegate(s)

  func lightboxController(_ controller: LightboxController, didDeleteImageAt index: Int) {
    print("remove image at index: \(index)")

    let selectedAsset = imagePicker.galleryView.selectedStack.assets[index]
    imagePicker.galleryView.selectedStack.dropAsset(selectedAsset)

    DDLogWarn("dropped asset")
  }


}
