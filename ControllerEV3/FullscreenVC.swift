//
//  FullscreenVC.swift
//  ControllerEV3
//
//  Created by Jordy Kingama on 02/06/2016.
//  Copyright © 2016 La Mixite. All rights reserved.
//

import UIKit

class FullscreenVC: UIViewController {

    @IBOutlet weak var videoView: UIWebView!
    
    let tapGesture = UITapGestureRecognizer()
    var videoURL = "URL"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tapGesture.addTarget(self, action: #selector(leavePopView))
        self.view.addGestureRecognizer(tapGesture)
        videoView.scrollView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let request = URLRequest(url: URL(string: videoURL)!)
        videoView.loadRequest(request)
    }
    
    @objc func leavePopView()
    {
        self.dismiss(animated: true, completion: nil)
    }
}
