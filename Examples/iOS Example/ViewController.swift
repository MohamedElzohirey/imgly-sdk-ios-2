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
        cameraViewController.squareMode = true
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
    func editorAllImagesCompletionBlock(result: IMGLYEditorResult, image: [UIImage]) {
        cameraViewController.dismiss(animated: true) {}
    }
    func editorCompletionBlock(result: IMGLYEditorResult, image: UIImage?) {
        cameraViewController.dismiss(animated: true, completion: nil)
        guard let image = image else{return}
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}