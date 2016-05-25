//
//  PhotoEditViewController.swift
//  cameraTry
//
//  Created by Mac on 2/12/15.
//  Copyright (c) 2015 clement siess. All rights reserved.
//


import UIKit
import Photos
import PhotosUI
import AssetsLibrary

class PhotoEdit: UIViewController, PHContentEditingController {
    
    var input: PHContentEditingInput?
    var displayedImage: UIImage?
    var imageOrientation: Int32?
    var currentFilter = "CIColorInvert"
    var receivedPic: UIImage?

    @IBOutlet var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = receivedPic
        displayedImage = imageView.image
        
    }
    
    
    @IBAction func sepiaSelected(sender: AnyObject){
        currentFilter = "CISepiaTone"
        
        if displayedImage != nil {
            imageView.image = performFilter(displayedImage!, orientation: nil)
        }
    }
    
    @IBAction func monoSelected(sender: AnyObject){
        currentFilter = "CIPhotoEffectMono"
        
        if displayedImage != nil {
            imageView.image = performFilter(displayedImage!, orientation: nil)
        }
    }
    
    @IBAction func invertSelected(sender: AnyObject){
        currentFilter = "CIColorInvert"
        
        if displayedImage != nil {
            imageView.image = performFilter(displayedImage!, orientation: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performFilter(inputImage: UIImage, orientation: Int32?)->UIImage {
          var cimage: CIImage
          cimage = CIImage(image: inputImage)!
          if orientation != nil {
            cimage = cimage.imageByApplyingOrientation(imageOrientation!)
        }
        
        let filter = CIFilter(name: currentFilter)
        filter!.setDefaults()
        filter!.setValue(cimage, forKey: "inputImage")
        
        switch currentFilter{
          case "CISepiaTone", "CIEdges": filter!.setValue(0.8, forKey: "inputIntensity")
          case "CIMotionBlur": filter!.setValue(0.00, forKey: "inputAngle")
          default: break
        }
        let ciFilteredImage = filter!.outputImage
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciFilteredImage!, fromRect: ciFilteredImage!.extent)
        let resultImage = UIImage(CGImage: cgImage, scale: 1.0, orientation: inputImage.imageOrientation)
        return resultImage
    }
    
    func canHandleAdjustmentData(adjustmentData: PHAdjustmentData?) -> Bool {
        
        return false
    }
    
    func startContentEditingWithInput(contentEditingInput: PHContentEditingInput?, placeholderImage: UIImage) {
        
        input = contentEditingInput
        
        if input != nil {
            displayedImage = input!.displaySizeImage
            imageOrientation = input!.fullSizeImageOrientation
            imageView.image = displayedImage
            
        }
    }
    
    
    func finishContentEditingWithCompletionHandler(completionHandler: ((PHContentEditingOutput!) -> Void)!) {

        dispatch_async(dispatch_get_global_queue(CLong(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {

            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            let url = self.input?.fullSizeImageURL
            
            if let imageUrl = url {
                let fullImage = UIImage(contentsOfFile: imageUrl.path!)
                
                let resultImage = self.performFilter(fullImage!, orientation: self.imageOrientation)
                
                let renderedJPEGData = UIImageJPEGRepresentation(resultImage, 0.9)
                
                renderedJPEGData!.writeToURL(output.renderedContentURL, atomically: true)
                
                let archivedData = NSKeyedArchiver.archivedDataWithRootObject(self.currentFilter)
                let adjustmentData = PHAdjustmentData(formatIdentifier: "edu.cvtc.cameraTry", formatVersion: "1.0", data: archivedData)
                
                output.adjustmentData = adjustmentData
            }
            
            
            completionHandler?(output)
            
        }
    }
    
    
    
    var shouldShowCancelConfirmation: Bool {

        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "return"{
            let imageEditController: ViewController = segue.destinationViewController as! ViewController
            
            imageEditController.returnImage = imageView.image
        }
    }
    
    
    
    @IBAction func save(sender: AnyObject) {
        
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self,
            #selector(PhotoEdit.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    func image(image: UIImage, didFinishSavingWithError
        error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Photo was not saved", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
            }
    }
    
}
