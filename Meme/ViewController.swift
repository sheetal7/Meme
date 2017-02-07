//
//  ViewController.swift
//  Meme
//
//  Created by Sheetal Sahasrabudhe on 1/17/17.
//  Copyright © 2017 Sheetal.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    
    var imageSet: Bool = false
    @IBOutlet weak var MemeImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        MemeImage.image = nil
        topTextField.text = "Top"
        bottomTextField.text = "Bottom"
        imageSet = false
        shareButton.isEnabled = false
    }
    

    func bringupPicker(_ sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated: true, completion: nil)

    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        bringupPicker(.camera)
    }
    
    @IBAction func albumButtonPressed(_ sender: UIBarButtonItem) {
        bringupPicker(.photoLibrary)
    }
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    
    var finalMemeImage: Meme!
    
    func generateMemedImage() -> UIImage {
        bottomToolbar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        bottomToolbar.isHidden = false
        return memedImage
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func activityViewControllerClosed() {
        //Your UIActivityViewController has been closed, you can do something here
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        save()
    
        if let image = finalMemeImage.memedImage {
            if let data = UIImagePNGRepresentation(image) {
                let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
                print("filename:" , filename)
            try? data.write(to: filename)
            }
        }
    }
    
    func save() {
        
        print ("saving Meme")
        //Create the meme
        finalMemeImage = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: MemeImage.image!, memedImage: generateMemedImage())
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(finalMemeImage)
    }
    
    @IBAction func shareButtonClicked(_ sender: UIBarButtonItem) {
        save()
        let activityViewController = UIActivityViewController(
            activityItems: [finalMemeImage.memedImage! as UIImage],
            applicationActivities: nil)
        // access the completion handler
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%activity: \(activity), success: \(success), items: \(items), error: \(error)")
            let sentMemesController = self.storyboard!.instantiateViewController(withIdentifier: "SentMemesController") as! UITabBarController
             self.present(sentMemesController, animated: true, completion: nil)
            
        }
        present(activityViewController, animated: true, completion: nil)
        
    }

    func bringupSentMemesView() {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        topTextField.clearsOnBeginEditing = true
        bottomTextField.clearsOnBeginEditing = true
        topTextField.delegate = self
        bottomTextField.delegate = self
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.white,
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0]
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [String : Any]){
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            MemeImage.contentMode = UIViewContentMode.scaleAspectFit
            
            MemeImage.image = image
            print ("setting image")
            imageSet = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = imageSet
        //saveButton.isEnabled = imageSet
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }

    func keyboardWillShow(_ notification:Notification) {
        
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
