//
//  ViewController.swift
//  iOS Example
//
//  Created by Mohamed Elzohirey on 10/12/20.
//  Copyright © 2020 9elements GmbH. All rights reserved.
//

import UIKit
import imglyKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //navigationController?.pushViewController(cameraViewController, animated: true)
    }
    let cameraViewController = IMGLYCameraViewController(recordingModes: [.photo, .video])
    
    @IBAction func  open(){
        var images:[IMGLYSticker] = []
        images.append(IMGLYSticker(image: UIImage(named: "1")!, thumbnail: UIImage(named: "1")))
        images.append(IMGLYSticker(image: UIImage(named: "2")!, thumbnail: UIImage(named: "2")))
        images.append(IMGLYSticker(image: UIImage(named: "3")!, thumbnail: UIImage(named: "3")))
        images.append(IMGLYSticker(image: UIImage(named: "4")!, thumbnail: UIImage(named: "4")))
        images.append(IMGLYSticker(image: UIImage(named: "5")!, thumbnail: UIImage(named: "5")))
        images.append(IMGLYSticker(image: UIImage(named: "6")!, thumbnail: UIImage(named: "6")))
        images.append(IMGLYSticker(image: UIImage(named: "7")!, thumbnail: UIImage(named: "7")))
        images.append(IMGLYSticker(image: UIImage(named: "8")!, thumbnail: UIImage(named: "8")))
        images.append(IMGLYSticker(image: UIImage(named: "9")!, thumbnail: UIImage(named: "9")))
        images.append(IMGLYSticker(image: UIImage(named: "10")!, thumbnail: UIImage(named: "10")))
        images = addStickers()
        IMGStickersList.stickers = images
        cameraViewController.maximumVideoLength = 15
        cameraViewController.isDark = true
        cameraViewController.showStickers = true
        cameraViewController.hasTextComment = true
        cameraViewController.placeholder = "Tesss"
        cameraViewController.text = "Here we go"
        cameraViewController.squareMode = false
        cameraViewController.modalPresentationStyle = .fullScreen
        cameraViewController.editorCompletionBlockDone = editorCompletionBlock
        cameraViewController.editorCompletionAllImagesBlockDone = editorAllImagesCompletionBlock
        cameraViewController.videoCompletionBlock = videoCompletionBlock
        present(cameraViewController, animated: true, completion: nil)
    }
    func addStickers()->[IMGLYSticker]{
        let stickerFiles = [
            "glasses_nerd",
            "glasses_normal",
            "glasses_shutter_green",
            "glasses_shutter_yellow",
            "glasses_sun",
            "hat_cap",
            "hat_party",
            "hat_sherrif",
            "hat_zylinder",
            "heart",
            "mustache_long",
            "mustache1",
            "mustache2",
            "mustache3",
            "pipe",
            "snowflake",
            "star"
        ]
        
        return stickerFiles.map { (file: String) -> IMGLYSticker? in
            if let image = UIImage(named: file) {
                let thumbnail = UIImage(named: file + "_thumbnail")
                return IMGLYSticker(image: image, thumbnail: thumbnail)
            }
            
            return nil
            }.filter { $0 != nil }.map { $0! }
        
    }
    func videoCompletionBlock(result: Bool, url:URL?){
        print(url?.absoluteString)
        DispatchQueue.main.async {
            self.cameraViewController.dismiss(animated: true) {}
        }
    }
    func editorAllImagesCompletionBlock(result: IMGLYEditorResult, image: [UIImage], postDirect: Bool, postText: String?) {
        cameraViewController.dismiss(animated: true) {}
    }
    func editorCompletionBlock(result: IMGLYEditorResult, image: UIImage?, postDirect: Bool, postText: String?) {
        cameraViewController.dismiss(animated: true, completion: nil)
        guard let image = image else{return}
    }
}
