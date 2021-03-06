
import UIKit
//import AVFoundation
import MobileCoreServices

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectVideoButton: DefaultButton!
    
    
    private var videoPicker: UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        FileManager.forbidBackupToiCloud()
        self.initButton()
        self.initVideoPicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initButton() {
        selectVideoButton.touchDown = {
//            Device.sharedInstance.request(usage: .audio) { (isAuthorized: Bool) in
//                Device.sharedInstance.request(usage: .camera) { (isAuthorized: Bool) in
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                        self.present(self.videoPicker, animated: true, completion: nil)
                    }
//                }
//            }
        }
    }
    
    
    private func initVideoPicker() {
        self.videoPicker = UIImagePickerController()
//        self.videoPicker.modalPresentationStyle = .popover
        self.videoPicker.modalPresentationStyle = .overCurrentContext
        self.videoPicker.allowsEditing = true
        self.videoPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.videoPicker.mediaTypes = [kUTTypeMovie as String]
        self.videoPicker.delegate = self
        
        /*if let popover = self.videoPicker.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = self.view.frame
            popover.permittedArrowDirections = UIPopoverArrowDirection.any
        }*/
    }
    
    
    private func gotoPreview(videoUrl: URL) {
        let storyboard: UIStoryboard = UIStoryboard(name: "VideoExporter", bundle: nil)
        let vc: VideoExporterViewController = storyboard.instantiateViewController(withIdentifier: "VideoExporter") as! VideoExporterViewController
        vc.videoUrl = videoUrl
        self.present(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoURL: URL = info[UIImagePickerControllerMediaURL] as? URL {
            
            FileManager().remove(atPath: FileManager.videoUploadPath)
            FileManager().remove(atPath: FileManager.tempVideoUploadPath)
            
            VideoConvertor.mp4(url: videoURL, to: FileManager.videoUploadURL, callback: { (error: Bool, message: String) in
                var err: Bool = error
                var mes: String = message
                if !err {
                    let res = FileManager().fileSize(atPath: FileManager.videoUploadPath)
                    print(res.size.mb)
                    if res.error {
                        err = true
                        mes = "ファイルの読み込みに失敗しました"
                    } else {
                        if res.size > (1024 * 1024 * 5) {
                            err = true
                            mes = "ファイルサイズが大きすぎます \(res.size.mb)"
                        }
                    }
                }
                picker.dismiss(animated: true, completion: {
                    if err {
                        let alert: UIAlertController = UIAlertController.simple(title: "読込みエラー", message: mes)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.gotoPreview(videoUrl: FileManager.videoUploadURL)
                })
            })
            
            /*VideoConvertor.mp4(url: videoURL, to: FileManager.tempVideoUploadURL, callback: { (error: Bool, message: String) in
                var err: Bool = error
                var mes: String = message
                if !err {
                    let res = FileManager().fileSize(atPath: FileManager.tempVideoUploadPath)
                    print(res.size.mb)
                    if res.error {
                        err = true
                        mes = "ファイルの読み込みに失敗しました"
                    } else {
                        if res.size > (1024 * 1024 * 5) {
                            err = true
                            mes = "ファイルサイズが大きすぎます \(res.size.mb)"
                        }
                    }
                }
                let exporter: VideoExporter = VideoExporter(to: FileManager.videoUploadURL)
                exporter.export(url: FileManager.tempVideoUploadURL) { (error: Bool, message: String) in
                    if error {
                        let alert: UIAlertController = UIAlertController.simple(title: "読込みエラー", message: message)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    let res = FileManager().fileSize(atPath: FileManager.videoUploadPath)
                    print("size \(res.size / 1024)KB")
                    picker.dismiss(animated: true, completion: {
                        if err {
                            let alert: UIAlertController = UIAlertController.simple(title: "読込みエラー", message: mes)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        self.gotoPreview(videoUrl: FileManager.videoUploadURL)
                    })
                }
            })*/
            
            return
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}
