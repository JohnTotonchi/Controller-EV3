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
    
    let tapGesture  = UITapGestureRecognizer()
    var videoURL    = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tapGesture.addTarget(self, action: #selector(FullscreenVC.leavePopView))
        self.view.addGestureRecognizer(tapGesture)
        videoView.scrollView.isUserInteractionEnabled   = false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let request = URLRequest(url: URL(string: videoURL)!)
        videoView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leavePopView()
    {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
