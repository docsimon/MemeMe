//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by doc on 01/01/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var meme: Meme?
    let defaultTextTopButton = "TOP"
    let defaultTextBottonButton = "BOTTOM"
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // subscribe to notifications
        subscribeToKeyboardNotifications()
        // set the delegates
        imagePicker.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        // this button will be enabled after saving the meme
        shareButton.isEnabled = false
        setTextFieldAttributes(topTextField, defaultTextTopButton)
        setTextFieldAttributes(bottomTextField, defaultTextBottonButton)
    }
    
    func setTextFieldAttributes(_ textField: UITextField, _ defaultText: String){
        textField.text = defaultText
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue:UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -2.0]
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters;
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        // Move the view only if the bottom textfield is the one that
        // triggers the keyboard
        if bottomTextField.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar navbar and Buttons
        setButtons(hidden: true)
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // Show toolbar navbar and Buttons
        setButtons(hidden: false)
        return memedImage
    }
    
    func save() {
        // Create the meme
        let memedImage = generateMemedImage()
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        shareButton.isEnabled = true
        
    }
    
    func addMemeToSentMemes(meme: Meme){
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func setButtons(hidden: Bool){
        topToolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }
    
    func cancel(){
        topTextField.text = defaultTextTopButton
        bottomTextField.text = defaultTextBottonButton
        shareButton.isEnabled = false
        imageView.image = nil
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        save()
        guard let image = meme?.memedImage else {
            return
        }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
        activity.completionWithItemsHandler = {[weak self] (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                return
            }
            if let meme = self?.meme {
                self?.addMemeToSentMemes(meme: meme)
            }
            self?.showAlert(title: "Image saved!", msg: "The image has been saved in the photo Library 😎")
        }
    }
    
    @IBAction func pickImage(_ sender: Any) {
        cancel()
        if (sender as! UIBarButtonItem).tag == 0 {
            imagePicker.sourceType = .photoLibrary
        }else {
            imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: Any) {
        cancel()
        dismiss(animated: true, completion: nil)
    }
}

// Protocol implementation
extension MemeEditorViewController {
    
    // Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = chosenImage
        }
        else {
            showAlert(title: "Error", msg: "Problem using this picture")
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // TextFields
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // If the user leaves the textfield empty, it will be filled with the
    // default value
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)!{
            textField.text = (textField.tag == 0 ? defaultTextTopButton : defaultTextBottonButton)
        }
        if (bottomTextField.text != defaultTextBottonButton && topTextField.text != defaultTextTopButton && imageView.image != nil){
            shareButton.isEnabled = true
        }
    }
}

// Alert managing
extension MemeEditorViewController {
    func showAlert(title: String, msg: String){
        let alert = UIAlertController()
        alert.title = title
        alert.message = msg
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
