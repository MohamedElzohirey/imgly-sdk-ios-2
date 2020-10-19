//
//  MultiImagesEditorVC.swift
//  imglyKit iOS
//
//  Created by Mohamed Elzohirey on 10/18/20.
//  Copyright © 2020 9elements GmbH. All rights reserved.
//

import UIKit

class MultiImagesEditorVC: UIViewController {
    var editContainerView: UIView = UIView()
    var allImagesContainerView: UIView = UIView()
    var completionBlock: IMGLYEditorCompletionBlock?
    var completionAllImagesBlock: IMGLYEditorAllImagesCompletionBlock?
    var highResolutionImage: UIImage?
    let editorViewController = IMGLYMainEditorViewController()
    var images:[UIImage] = []
    var editedImages:[UIImage] = []
    var filters:[IMGLYFixedFilterStack] = []
    var initialFilterType = IMGLYFilterType.none
    var initialFilterIntensity = NSNumber(value: 0.75 as Double)
    var selectedRow = 0
    fileprivate func completionImageHandler(_ image: UIImage?,_ fixedFilter: IMGLYFixedFilterStack) {
        if images.count == 1 {return}
        if let image = image{
            editedImages[selectedRow] = image
            filters[selectedRow] = fixedFilter
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [IndexPath(row: self.selectedRow, section: 0)])
            }
        }
    }
    @objc fileprivate func cancelTapped(_ sender: UIBarButtonItem?) {
        if let completionBlock = completionBlock {
            completionBlock(.cancel, nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    @objc func tappedDone(_ sender: UIBarButtonItem?) {
        if images.count == 1 {
            editorViewController.tappedDone(nil)
        }else{
            completionAllImagesBlock?(.done, editedImages)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        images.forEach { (img) in
            filters.append(IMGLYFixedFilterStack())
            editedImages.append(img)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MultiImagesEditorVC.cancelTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MultiImagesEditorVC.tappedDone(_:)))

        editorViewController.completionImageHandler =  completionImageHandler
        view.addSubview(editContainerView)
        view.addSubview(allImagesContainerView)
        allImagesContainerView.backgroundColor = .blue
        editContainerView.translatesAutoresizingMaskIntoConstraints = false
        allImagesContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = editContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let horizontalAllImagesConstraint = allImagesContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)

        //let verticalConstraint = editContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        //let widthConstraint = editContainerView.widthAnchor.constraint(equalToConstant: 300)
        
        let verticalConstraint = editContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        let verticalAllImagesConstraint = allImagesContainerView.topAnchor.constraint(equalTo: editContainerView.bottomAnchor)

        let widthConstraint = editContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0)
        
        let widthAllImagesConstraint = allImagesContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0)
        var height:CGFloat = 100.0
        if images.count == 1{
            height = 0
        }
        let heightConstraint = editContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0, constant: -height)

        let heightAllImagesConstraint = allImagesContainerView.heightAnchor.constraint(equalToConstant: height)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        view.addConstraints([horizontalAllImagesConstraint, verticalAllImagesConstraint, widthAllImagesConstraint, heightAllImagesConstraint])
        
        editorViewController.highResolutionImage = highResolutionImage
        editorViewController.initialFilterType = initialFilterType
        editorViewController.initialFilterIntensity = initialFilterIntensity
        editorViewController.completionBlock = completionBlock
        addChild(editorViewController)
        editorViewController.view.frame = editContainerView.bounds
        editorViewController.didMove(toParent: self)
        editContainerView.addSubview(editorViewController.view)
        if images.count>1{
            configureMenuCollectionView()
        }
    }

    private let ButtonCollectionViewCellSize = CGSize(width: 100, height: 100)
    private let ButtonCollectionViewCellReuseIdentifier = "IMGLYImageItemCollectionViewCell"
    var collectionView:UICollectionView!
    fileprivate func configureMenuCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = ButtonCollectionViewCellSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(IMGLYImageItemCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCellReuseIdentifier)
        
        let views = [ "collectionView" : collectionView ]
        allImagesContainerView.addSubview(collectionView)
        allImagesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: views))
        allImagesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       

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
extension MultiImagesEditorVC: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editedImages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCellReuseIdentifier, for: indexPath)
        
        if let buttonCell = cell as? IMGLYImageItemCollectionViewCell {
            buttonCell.imageView.image = editedImages[indexPath.row]
        }
        
        return cell
    }
}

extension MultiImagesEditorVC: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        editorViewController.highResolutionImage = images[indexPath.row]
        editorViewController.fixedFilterStack = filters[indexPath.row]
        editorViewController.viewDidLoad()
    }
}
