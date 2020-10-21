//
//  MultiImagesEditorVC.swift
//  imglyKit iOS
//
//  Created by Mohamed Elzohirey on 10/18/20.
//  Copyright © 2020 9elements GmbH. All rights reserved.
//

import UIKit

open class MultiImagesEditorVC: UIViewController {
    var originalY:CGFloat = 0
    open var placeholder = ""
    open var text = ""
    open var hasTextComment = false
    var editContainerView: UIView = UIView()
    var allImagesContainerView: UIView = UIView()
    var growingTextViewContainer: UIView = UIView()
    var growingTextView: SimpleGrowingTextView = SimpleGrowingTextView()
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
        /*if let completionBlock = completionBlock {
            completionBlock(.cancel, nil, false, nil)
        } else {
            dismiss(animated: true, completion: nil)
        }*/
        dismiss(animated: true, completion: nil)
    }
    @objc func tappedDone(_ sender: UIBarButtonItem?) {
        editorViewController.postText = growingTextView.text
        if images.count == 1 {
            editorViewController.tappedDone(nil)
        }else{
            completionAllImagesBlock?(.done, editedImages, editorViewController.postDirect, editorViewController.postText)
        }
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MultiImagesEditorVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MultiImagesEditorVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        images.forEach { (img) in
            filters.append(IMGLYFixedFilterStack())
            editedImages.append(img)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MultiImagesEditorVC.cancelTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MultiImagesEditorVC.tappedDone(_:)))

        editorViewController.completionImageHandler =  completionImageHandler
        view.addSubview(editContainerView)
        view.addSubview(allImagesContainerView)
        growingTextViewContainer.backgroundColor = .clear
        if hasTextComment{
            growingTextViewContainer.addSubview(growingTextView)
            growingTextViewContainer.addSubview (postButton)
            growingTextViewContainer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            growingTextView.placeholder = placeholder
            growingTextView.text = text
        }
        view.addSubview(growingTextViewContainer)
        allImagesContainerView.backgroundColor = .blue
        editContainerView.translatesAutoresizingMaskIntoConstraints = false
        allImagesContainerView.translatesAutoresizingMaskIntoConstraints = false
        growingTextViewContainer.translatesAutoresizingMaskIntoConstraints = false
        growingTextView.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = editContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let horizontalAllImagesConstraint = allImagesContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let horizontalGrowingConstraint = growingTextViewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)

        let verticalConstraint = editContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        let verticalGrowingConstraint = growingTextViewContainer.bottomAnchor.constraint(equalTo: editContainerView.bottomAnchor, constant: -100)
        let verticalAllImagesConstraint = allImagesContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        let widthConstraint = editContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0)
        let widthGrowingConstraint = growingTextViewContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: 0)
        growingTextView.numberOfLines = 5
        growingTextView.backgroundColor = .clear
        growingTextView.returnKeyType = .done
        growingTextView.delegate = self
        growingTextView.minHeight = 40.0
        growingTextView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 55)
        growingTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let widthAllImagesConstraint = allImagesContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0)
        var height:CGFloat = 100.0
        if images.count == 1{
            height = 0
        }
        let heightConstraint = editContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0, constant: -height)
        if hasTextComment{
            let heightGrowingConstraint = growingTextViewContainer.heightAnchor.constraint(equalTo: growingTextView.heightAnchor, multiplier: 1.0, constant: 0)
            view.addConstraints([horizontalGrowingConstraint,widthGrowingConstraint,verticalGrowingConstraint,heightGrowingConstraint])
        }
        let heightAllImagesConstraint = allImagesContainerView.heightAnchor.constraint(equalToConstant: height)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint,heightConstraint])

        view.addConstraints([horizontalAllImagesConstraint, verticalAllImagesConstraint, widthAllImagesConstraint, heightAllImagesConstraint])
        

        if hasTextComment{
            growingTextViewContainer.addConstraints([
                growingTextView.topAnchor.constraint(equalTo: growingTextViewContainer.topAnchor),
                growingTextView.bottomAnchor.constraint(equalTo: growingTextViewContainer.bottomAnchor),
                growingTextView.widthAnchor.constraint(equalTo: growingTextViewContainer.widthAnchor, multiplier: 1.0)
            ])
        }


   
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
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //postButton.addConstraint(NSLayoutConstraint(item: postButton, attribute: .trailing, relatedBy: .equal, toItem: growingTextView, attribute: .trailing, multiplier: 1, constant: 0))
        postButton.frame = CGRect(x: 200, y: 10, width: 100, height: 100)
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        originalY = self.view.frame.origin.y
            //+ (self.navigationController?.navigationBar.frame.size.height ?? 0)
    }
    private let ButtonCollectionViewCellSize = CGSize(width: 100, height: 100)
    private let ButtonCollectionViewCellReuseIdentifier = "IMGLYImageItemCollectionViewCell"
    var collectionView:UICollectionView!
    var postButton:UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: view.frame.size.width - 50, y: 0, width: 40, height: 40)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        button.setTitle("Post", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(addPost), for: .touchUpInside)
        return button
    }
    @objc func addPost() {
        editorViewController.postDirect = true
        editorViewController.postText = growingTextView.text
        tappedDone(nil)
    }
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
        
        let views:[String:Any] = ["collectionView":collectionView!]
        allImagesContainerView.addSubview(collectionView)
        allImagesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: views))
        allImagesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views))
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
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

extension MultiImagesEditorVC: UITextViewDelegate{
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    open func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        var shouldMoveViewUp = false
        
        // if active text field is not nil
        
        
        let bottomOfTextField = growingTextView.convert(growingTextView.bounds, to: self.view).maxY;
        
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        
        // if the bottom of Textfield is below the top of keyboard, move up
        if bottomOfTextField > topOfKeyboard {
            shouldMoveViewUp = true
        }
        
        
        if(shouldMoveViewUp) {
            self.view.frame.origin.y = originalY -  (bottomOfTextField-topOfKeyboard)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = originalY
    }
}
