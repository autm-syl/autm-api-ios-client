//
//  SearchProductViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD
import SideMenu

class SearchProductViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var mainCamView: UIView!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var lst_all_product:[Product] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lst_all_product = Globalvariables.shareInstance.listAllproduct;

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        mainCamView.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        
        //
        self.addBlur();
    }
    @IBAction func menuBtnClicked(_ sender: Any) {
        let menu = SideMenuManager.defaultManager.leftMenuNavigationController;
        present(menu!, animated: true, completion: nil)
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        self.searchWithText(text: code)
        print(code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func addBlur(){
        let w = self.view.bounds.width
        let h = self.view.bounds.height
        let overlayPath:UIBezierPath = UIBezierPath.init(rect: self.view.bounds);
        let transparentPath:UIBezierPath = UIBezierPath.init(rect: CGRect.init(x: (w - 280)/2, y: (h - 280)/2, width: 280, height: 280));
        overlayPath.append(transparentPath);
        overlayPath.usesEvenOddFillRule = true;
        
        let fillLayer:CAShapeLayer = CAShapeLayer.init();
        fillLayer.path = overlayPath.cgPath;
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd;
        fillLayer.fillColor = UIColor(red: 4/255.0, green: 97/255.0, blue: 78/255.0, alpha: 0.3).cgColor;

        self.mainCamView.layer.addSublayer(fillLayer)
    }

    
    // function mine
    func searchWithText(text: String) {
        if (self.lst_all_product.count == 0){
            // show error
            SVProgressHUD.showError(withStatus: "Không có sản phẩm nào");
            SVProgressHUD.dismiss(withDelay: 3.0);
            return;
        }
        var isfound = false
       self.lst_all_product.forEach { (item) in
           //
           let code = item.barcode;
           
           if (text == code) {
               // ok
               //self.lst_show_product.append(item); go go
            
            self.showDetailProduct(product: item);
            isfound = true;
           }
       }
        if (!isfound) {
            SVProgressHUD.showError(withStatus: "Không tìm thấy sản phẩm nào");
            SVProgressHUD.dismiss(withDelay: 3.0);
            
            self.perform(#selector(rerunCamera), with: nil, afterDelay: 2.0);
        }
    }
    
    private func showDetailProduct(product:Product){
        performSegue(withIdentifier: "showDetailProduct", sender: product);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        let product = sender as? Product
        if segue.identifier == "showDetailProduct" {
            if let destinationVC = segue.destination as? DetailsViewController {
                destinationVC.product = product;
            }
        }
    }
    
    @objc func rerunCamera(){
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
}
