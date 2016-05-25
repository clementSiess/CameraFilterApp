//
//  ViewController.swift
//  cameraTry
//
//  Created by Mac on 2/3/15.
//  Copyright (c) 2015 clement siess. All rights reserved.
//

import UIKit
//import MediaPlayer
import MobileCoreServices
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {

    @IBOutlet var photoView: UIImageView!
    @IBOutlet var btnPhoto: UIBarButtonItem!
    @IBOutlet var btnGallery: UIBarButtonItem!
    @IBOutlet var btnFilters: UIBarButtonItem!
    @IBOutlet var btnSave: UIBarButtonItem!
    
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection?
    var photosAsset: PHFetchResult!
    var returnImage: UIImage?
    
    
    @IBAction func btnTakePicture(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            // load the camera interface
            var picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            picker.allowsEditing = false
            presentViewController(picker, animated: true, completion: nil)
        } else {
            // No camera
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }

    @IBAction func pickImageFromLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker , animated: true, completion: nil)
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        photoView.image = returnImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  


//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        
          photoView.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
          dismissViewControllerAnimated(true , completion: nil)
        
    }

  
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
            picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSave(sender: AnyObject) {
        
        UIImageWriteToSavedPhotosAlbum(photoView.image!, self,
            #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError
        error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
            if error != nil {
            }
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "filters"{
            let imageEditController: PhotoEdit = segue.destinationViewController as! PhotoEdit
            
            imageEditController.receivedPic = photoView.image
        }
    }


}

