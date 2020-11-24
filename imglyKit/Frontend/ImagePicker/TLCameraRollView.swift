//
//  TLCameraRollView.swift
//  imglyKit iOS
//
//  Created by Mohamed Elzohirey on 11/8/20.
//  Copyright © 2020 9elements GmbH. All rights reserved.
//

import UIKit
import  Photos
import PhotosUI
 public protocol TLCameraRollViewDelegate: class {
    func selectImage(image: UIImage?, isRealImage:Bool, asset: PHAsset?)
}
open class TLCameraRollView: UIView {
    open var cameraImage:UIImage? = TLBundle.podBundleImage(named: "camera")
    open var delegate:TLCameraRollViewDelegate?
    open var isDark:Bool = false{
        didSet{
            if isDark{
                backgroundColor = .black
                collectionView.backgroundColor = .black
            }else{
                backgroundColor = .white
                collectionView.backgroundColor = .white
            }
        }
    }
    private var queue = DispatchQueue(label: "tilltue.photos.pikcker.queue")
    private var photoLibrary = TLPhotoLibrary()
    private var focusedCollection: TLAssetsCollection? = nil
    public var configure = TLPhotosPickerConfigure()
    public var customDataSouces: TLPhotopickerDataSourcesProtocol? = nil
    private var thumbnailSize = CGSize.zero
    @IBOutlet open var collectionView: UICollectionView!
    open override func awakeFromNib() {
        super.awakeFromNib()
        //loadPhotos(limitMode: false)
        registerNib(nibName: "TLPhotoCollectionViewCRollCell", bundle: TLBundle.bundle())
        self.customDataSouces?.registerSupplementView(collectionView: self.collectionView)
        initItemSize()
    }
    open func refresh(){
        loadPhotos(limitMode: false)
    }
    private func loadPhotos(limitMode: Bool) {
        self.photoLibrary.limitMode = limitMode
        self.photoLibrary.delegate = self
        self.photoLibrary.fetchCollection(configure: self.configure)
    }
    @objc public func registerNib(nibName: String, bundle: Bundle) {
        self.collectionView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: nibName)
    }
    private func initItemSize() {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let width:CGFloat = 90.0
        self.thumbnailSize = CGSize(width: width, height: width)
        layout.itemSize = self.thumbnailSize
        layout.minimumLineSpacing = 2
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 2
        self.collectionView.collectionViewLayout = layout
    }
    
}
extension TLCameraRollView: TLPhotoLibraryDelegate {
    func loadCameraRollCollection(collection: TLAssetsCollection) {
        self.focusedCollection = collection
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func loadCompleteAllCollection(collections: [TLAssetsCollection]) {
    }
}
extension TLCameraRollView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching {
    
    //Delegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as?
            TLPhotoCollectionViewCRollCell{
            let real:Bool = !(indexPath.section == 0 && indexPath.row == 0)
            if !real{
                self.delegate?.selectImage(image: cell.imageView?.image, isRealImage: real, asset: cell.asset)
                return
            }
            guard let collection = self.focusedCollection else {
                self.delegate?.selectImage(image: cell.imageView?.image, isRealImage: real, asset: cell.asset)
                return
            }
            guard let asset = collection.getTLAsset(at: indexPath) else {                 self.delegate?.selectImage(image: cell.imageView?.image, isRealImage: real, asset: cell.asset)
                return
            }
            self.delegate?.selectImage(image: asset.fullResolutionImage, isRealImage: real, asset: cell.asset)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    //Datasource
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        func makeCell(nibName: String) -> TLPhotoCollectionViewCRollCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! TLPhotoCollectionViewCRollCell
            cell.configure = self.configure
            //cell.imageView?.image = self.placeholderThumbnail
            cell.liveBadgeImageView?.image = nil
            cell.imageView?.layer.cornerRadius = 18.0
            cell.imageView?.layer.masksToBounds = true
            if isDark{
                cell.backgroundColor = .black
                cell.contentView.backgroundColor = .black
            }else{
                cell.backgroundColor = .white
                cell.contentView.backgroundColor = .white
            }
            if  indexPath.section == 0 && indexPath.row == 0{}else{
                cell.indicator?.startAnimating()
            }
            return cell
        }
        let nibName = self.configure.nibSet?.nibName ?? "TLPhotoCollectionViewCRollCell"
        var cell = makeCell(nibName: nibName)
        
        guard let collection = self.focusedCollection else {return cell}
        cell.isCameraCell = collection.useCameraButton && indexPath.section == 0 && indexPath.row == 0
        if cell.isCameraCell {
            if let nibName = self.configure.cameraCellNibSet?.nibName {
                cell = makeCell(nibName: nibName)
            }else{
                cell.imageView?.image = self.cameraImage
            }
            return cell
        }
        guard let asset = collection.getTLAsset(at: indexPath) else {
            cell.indicator?.stopAnimating()
            cell.imageView?.image = self.cameraImage
            return cell
        }
        
        cell.asset = asset.phAsset
        if asset.state == .progress {
            //cell.indicator?.startAnimating()
        }else {
            cell.indicator?.stopAnimating()
        }
        if let phAsset = asset.phAsset {
            if false {
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true
                let requestID = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, options: options) { [weak self, weak cell] (image,complete) in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                            cell?.imageView?.image = image
                            cell?.update(with: phAsset)
                            cell?.indicator?.stopAnimating()
                        cell?.durationView?.isHidden = asset.type != .video
                        cell?.duration = asset.type == .video ? phAsset.duration : nil
                    }
                }
            }else {
                queue.async { [weak self, weak cell] in
                    guard let `self` = self else { return }
                    let requestID = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, completionBlock: { (image,complete) in
                        DispatchQueue.main.async {
                            cell?.imageView?.image = image
                            cell?.update(with: phAsset)
                            cell?.indicator?.stopAnimating()
                            cell?.durationView?.isHidden = asset.type != .video
                            cell?.duration = asset.type == .video ? phAsset.duration : nil
                        }
                    })
                }
            }
        }
        cell.alpha = 0
        UIView.transition(with: cell, duration: 0.1, options: .curveEaseIn, animations: {
            cell.alpha = 1
        }, completion: nil)
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collection = self.focusedCollection else {
            return 0
        }
        return self.focusedCollection?.sections?[safe: section]?.assets.count ?? collection.count
    }
    
    //Prefetch
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    }
    
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TLPhotoCollectionViewCRollCell else {
            return
        }
        cell.willDisplayCell()
    }
}

// MARK: - CustomDataSources for supplementary view
extension TLCameraRollView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let identifier = self.customDataSouces?.supplementIdentifier(kind: kind) else {
            return UICollectionReusableView()
        }
        let reuseView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: identifier,
                                                                        for: indexPath)
       /* if let section = self.focusedCollection?.sections?[safe: indexPath.section] {
            self.customDataSouces?.configure(supplement: reuseView, section: section)
        }*/
        return reuseView
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        /*if let sections = self.focusedCollection?.sections?[safe: section], sections.title != "camera" {
            return self.customDataSouces?.headerReferenceSize() ?? CGSize.zero
        }*/
        return CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        /*if let sections = self.focusedCollection?.sections?[safe: section], sections.title != "camera" {
            return self.customDataSouces?.footerReferenceSize() ?? CGSize.zero
        }*/
        return CGSize.zero
    }
}
