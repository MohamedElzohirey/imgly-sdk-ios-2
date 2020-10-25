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
        cameraViewController.maximumVideoLength = 15
        cameraViewController.isDark = true
        cameraViewController.showStickers = false
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
