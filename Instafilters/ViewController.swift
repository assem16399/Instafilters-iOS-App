//
//  ViewController.swift
//  Instafilters
//
//  Created by Aasem Hany on 25/01/2023.
//

import CoreImage
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var filterSlider: UISlider!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var currentSelectedImage:UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        configureNavBar()
    }
    
    @IBAction func onChangeFilterPressed(_ sender: UIButton) {
        let ac = UIAlertController(title: "Filters", message: "Select a filter to apply", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.popoverPresentationController?.sourceView = sender
        ac.popoverPresentationController?.sourceRect = sender.bounds
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    func setFilter(action:UIAlertAction) {
        guard let filterName = action.title else{
            dismiss(animated: true)
            return
        }
        currentFilter = CIFilter(name:filterName)
        title = currentFilter.name
        guard let currentSelectedImage else {return}
        currentFilter.setValue(CIImage(image: currentSelectedImage), forKey: kCIInputImageKey)
        applyProcessing()
        dismiss(animated: true)
    }
    
    @IBAction func onSavePressed(_ sender: UIButton) {
        guard let img = imageView.image else {
            
            let ac = UIAlertController(title: "No Photo", message: "Please select a photo to save", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
            return
        }
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_: didFinishSavingWithError: contextInfo:)), nil)
    }
    
    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    
    func configureNavBar() {
        title = currentFilter.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddImagePressed))
    }
    
    @objc func onAddImagePressed(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterSlider.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterSlider.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterSlider.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentSelectedImage.size.width / 2, y: currentSelectedImage.size.height / 2), forKey: kCIInputCenterKey) }
        guard let outputImg = currentFilter.outputImage else {return}
        
        if let cgImg = context.createCGImage(outputImg, from: outputImg.extent) {
            let image = UIImage(cgImage: cgImg)
            self.imageView.image = image
        }
    }
    
    @objc func image(_ image:UIImage,didFinishSavingWithError error:Error?,contextInfo:UnsafeRawPointer) {
        if let error {
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else{
            let ac = UIAlertController(title: "Saved", message: "Picture saved successfully", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentSelectedImage = image
        
        let beginImage = CIImage(image: currentSelectedImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func getDocDirPath() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
}
