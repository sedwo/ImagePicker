import UIKit
import ImagePicker
import Lightbox
import CocoaLumberjack
import CoreLocation
import AVFoundation
import Photos



class ViewController: UIViewController, ImagePickerDelegate, LightboxControllerDeleteDelegate {

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


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    showImagePickerButton()
  }


  func makeButton() -> UIButton {
    let button = UIButton()
    button.setTitle("Show ImagePicker", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    button.addTarget(self, action: #selector(showImagePickerButton), for: .touchUpInside)

    return button
  }

  
  @objc func showImagePickerButton() {
    let config = Configuration()
    config.savePhotosToCameraRoll = false

    let imagePicker = ImagePickerController(configuration: config)
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

    if let imagePicker = UIViewController.findVC(vcKind: ImagePickerController.self) {
      let selectedAsset = imagePicker.galleryView.selectedStack.assets[index]
      imagePicker.galleryView.selectedStack.dropAsset(selectedAsset)
      DDLogWarn("dropped asset at index: \(index)")
    }

  }


}



extension UIViewController {

  // Returns a ViewController of a class Kind
  // EXAMPLE: .findVC(vcKind: CustomViewController.self)//ref to an instance of CustomViewController
  // https://stackoverflow.com/a/50144326/7599
  public static func findVC<T: UIViewController>(vcKind: T.Type? = nil) -> T? {
    guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
    if let vc = appDelegate.window?.rootViewController as? T {
      return vc
    } else if let vc = appDelegate.window?.rootViewController?.presentedViewController as? T {
      return vc
    } else if let vc = appDelegate.window?.rootViewController?.childViewControllers {
      return vc.lazy.flatMap { $0 as? T }.first
    }
    return nil
  }

}
