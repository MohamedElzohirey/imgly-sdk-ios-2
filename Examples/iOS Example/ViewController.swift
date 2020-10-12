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
        present(cameraViewController, animated: true, completion: nil)
    }
    func editorCompletionBlock(result: IMGLYEditorResult, image: UIImage?) {
        guard let image = image else{return}
        cameraViewController.dismiss(animated: true, completion: nil)
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
