//
//  HomeVC.swift
//  ControllerEV3
//
//  Created by Jordy Kingama on 23/05/2016.
//  Copyright © 2016 La Mixite. All rights reserved.
//

import UIKit
import AVKit
import SwiftyJSON
import AVFoundation
//import Alamofire
import CDJoystick
import SocketIO

class HomeVC: UIViewController
{
    // MARK: IBOutlets
    @IBOutlet weak var displayTf: UITextField!
    @IBOutlet weak var switchA: UISwitch!
    @IBOutlet weak var switchB: UISwitch!
    @IBOutlet weak var buzzerBtn: UIButton!
    @IBOutlet weak var clawsBtn: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var jailLabel: UILabel!
    @IBOutlet weak var checkpointLabel: UILabel!
    @IBOutlet weak var clickClaws: UIButton!
    @IBOutlet weak var modeToggle: UISegmentedControl!
    @IBOutlet weak var webView2: UIWebView!
    @IBOutlet weak var alertSignal: UIView!
    
    // MARK: Variables
    let videoURL01      = "http://192.168.0.151:8082"
    let videoURL02      = "http://192.168.0.151:8083"
    let socket          = SocketIOClient(socketURL: URL(string: "http://192.168.0.150:3000")!, config: [.log(true), .forcePolling(true)])
    var modeManuel      = false
    var alertIsOn       = false
    let myColor         = UIColor(red: 229/255, green: 115/255, blue: 115/255, alpha: 1)
    
    let tapGestureWebView01    = UITapGestureRecognizer()
    let tapGestureWebView02    = UITapGestureRecognizer()
    var fullscreenVC           = FullscreenVC()
    
    
    // MARK: Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initButtons()
        initJoystick()
        initGestures()
        
        fullscreenVC          = self.storyboard?.instantiateViewController(withIdentifier: "FULLSCREEN") as! FullscreenVC
        
        let request01         = URLRequest(url: URL(string: videoURL01)!)
        let request02         = URLRequest(url: URL(string: videoURL02)!)
        webView.loadRequest(request01)
        webView2.loadRequest(request02)
        
        socket.on("/connect") { data, ack in
            print("Socket connected")
            self.socket.emit("/newClient", "SWIFT")
        }
        
        socket.on("env/onSetMessage") { data, ack in
            self.displayTf.text  = (data[0] as AnyObject).description

        }
        
        socket.on("env/onSetDoor") { data, ack in
            let json    = JSON(data[0])
            
            if(json["n"] == 0)
            {
                if(json["state"] == 0)
                {
                    self.switchA.setOn(false, animated: true)
                }
                else if(json["state"] == 1)
                {
                    self.switchA.setOn(true, animated: true)
                }
            }
            else if(json["n"] == 1)
            {
                if(json["state"] == 0)
                {
                    self.switchB.setOn(false, animated: true)
                }
                else if(json["state"] == 1)
                {
                    self.switchB.setOn(true, animated: true)
                }
            }
        }
        
        socket.on("env/onBuzzer") { data, ack in
            
        }
        
        socket.on("env/onSetBalls") { data, ack in
            let dictionary              = JSON(data[0])
            var i   = 0

            for j in 0...dictionary.count
            {
                if(dictionary[j]["prison"] == true)
                {
                    i+=1
                }
            }
            
            self.jailLabel.text         = "Prison " + i.description
            self.checkpointLabel.text   = "Checkpoint " + dictionary.count.description
        }
        
        socket.on("env/onSetMode") { data, ack in
            let response    = JSON(data[0])
            
            if(response == 0)
            {
                self.modeManuel                         = false
                self.clawsBtn.isEnabled                   = false
                self.clawsBtn.backgroundColor           = UIColor.lightGray
                self.modeToggle.selectedSegmentIndex    = 0
            }
            else if(response == 1)
            {
                self.modeManuel                         = true
                self.clawsBtn.isEnabled                   = true
                self.modeToggle.selectedSegmentIndex    = 1
                self.clawsBtn.backgroundColor           = self.myColor
            }
        }
        
        socket.on("env/onSetAllCams") { data, ack in
            
        }
        
        socket.on("env/onSetCam") { data, ack in
            
        }
        
        socket.on("env/setAllRobots") { data, ack in
            
        }
        
        socket.on("env/getRobot") { data, ack in
            
        }
        
        socket.on("env/onAlerte") { data, ack in
            print("ALERTE")
            
            self.alertIsOn   = true
            self.alertSignal.backgroundColor =   UIColor.red
        }
        
        socket.on("env/onAlerteEnd") { data, ack in
            print("ALERTE END")
            
            self.alertIsOn   = false
            self.alertSignal.backgroundColor =   UIColor.green
        }
        
        socket.connect()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        webView.reload()
        webView2.reload()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    @IBAction func switchA(_ sender: AnyObject)
    {
        if switchA.isOn
        {
            let data    = "{\"n\": 0, \"state\": 1}"
            socket.emit("env/setDoor", data)
        }
        else if (!switchA.isOn)
        {
            let data    = "{\"n\": 0, \"state\": 0}"
            socket.emit("env/setDoor", data)
        }
    }
    
    @IBAction func switchB(_ sender: AnyObject)
    {
        var data    = "{\"n\": 1, \"state\": 1}"
        if (!switchB.isOn)
        {
            data    = "{\"n\": 1, \"state\": 0}"
        }
        socket.emit("env/setDoor", data)
    }
    
    @IBAction func clickBuzzer(_ sender: AnyObject)
    {
        socket.emit("env/buzzer")
    }
    
    @IBAction func sendButton(_ sender: AnyObject)
    {
        if (!displayTf.text!.isEmpty)
        {
            let  data   = "{\"msg\": \"\(displayTf.text as NSString!)\", \"color\": [255, 0, 0]}"
            socket.emit("env/setMessage", data)
            
            let alert   = UIAlertController(title: "Message Posted", message: displayTf.text, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func clickModeToggle(_ sender: AnyObject)
    {
        if (modeToggle.selectedSegmentIndex == 0)
        {
            socket.emit("env/setMode", 0)
            self.modeManuel                         = false
            self.clawsBtn.isEnabled                   = false
            self.clawsBtn.backgroundColor           = UIColor.lightGray
        }
        else if (modeToggle.selectedSegmentIndex == 1)
        {
            socket.emit("env/setMode", 1)
            self.modeManuel                         = true
            self.clawsBtn.isEnabled                   = true
            self.clawsBtn.backgroundColor           = self.myColor
        }
    }
    
    @IBAction func clickClaws(_ sender: AnyObject)
    {
        print("CLAWS")
    }
    
    // MARK: Functions
    fileprivate func initJoystick()
    {
        // 1. Initialize an instance of `CDJoystick` using the constructor:
        let joystick                    = CDJoystick()
        joystick.frame                  = CGRect(x: controlView.frame.midX + 50,
                                                 y: clawsBtn.frame.maxY + 70, width: 45, height: 45)
        
        joystick.backgroundColor        = .clear
        
        // 2. Customize the joystick.
        joystick.substrateColor         = .lightGray
        joystick.substrateBorderColor   = .gray
        joystick.substrateBorderWidth   = 1.0
        joystick.stickSize              = CGSize(width: 35, height: 35)
        joystick.stickColor             = .darkGray
        joystick.stickBorderColor       = .black
        joystick.stickBorderWidth       = 2.0
        joystick.fade                   = 0.5
        
        // 3. Setup the tracking handler to get velocity and angle data:
        joystick.trackingHandler        = { (joystickData) -> () in
            self.socket.emit("robots/setRobot/move", self.setOrientation(Float(joystickData.velocity.x), y: Float(joystickData.velocity.y)))
            
            Thread.sleep(forTimeInterval: 0.2)
        }
        
        // 4. Add the joystick to your view:
        view.addSubview(joystick)
    }
    
    fileprivate func initButtons()
    {
        alertSignal.layer.cornerRadius  = 30
        alertSignal.clipsToBounds       = true
        alertSignal.backgroundColor     = UIColor.green
        
        buzzerBtn.layer.cornerRadius    = 15
        clawsBtn.layer.cornerRadius     = 15
        
        sendButton.layer.cornerRadius   = 0.5 * 15
        sendButton.clipsToBounds        = true
    }
    
    fileprivate func initGestures()
    {
        tapGestureWebView01.addTarget(self, action: #selector(HomeVC.tapFirstWebView))
        tapGestureWebView02.addTarget(self, action: #selector(HomeVC.tapSecondWebView))
        
        webView.addGestureRecognizer(tapGestureWebView01)
        webView2.addGestureRecognizer(tapGestureWebView02)
        
        webView.scrollView.isUserInteractionEnabled   = false
        webView2.scrollView.isUserInteractionEnabled  = false
    }
    
    fileprivate func setOrientation(_ x: Float, y: Float) -> NSDictionary
    {
        var direct  = ["up": 0, "down": 0, "left": 0, "right": 0]
        
        if(x > -0.35 && x < 0.35 && y < 0)
        {
            direct["up"] = 1
            direct["down"] = 0
            direct["left"] = 0
            direct["right"] = 0
            
            print("UP")
        }
        else if(x > 0.35 && y < 0)
        {
            direct["up"] = 1
            direct["down"] = 0
            direct["left"] = 0
            direct["right"] = 1
            
            print("UP RIGHT")
        }
        else if(x > 0.35 && y > 0)
        {
            direct["up"] = 0
            direct["down"] = 1
            direct["left"] = 0
            direct["right"] = 1
            
            print("DOWN RIGHT")
        }
        else if(x < 0.35 && x > -0.35 && y > 0)
        {
            direct["up"] = 0
            direct["down"] = 1
            direct["left"] = 0
            direct["right"] = 0
            
            print("DOWN")
        }
        else if(x < -0.35 && y > 0)
        {
            direct["up"] = 0
            direct["down"] = 1
            direct["left"] = 1
            direct["right"] = 0
            
            print("DOWN LEFT")
        }
        else if(x < -0.35 && y < 0)
        {
            direct["up"] = 1
            direct["down"] = 0
            direct["left"] = 1
            direct["right"] = 0
            
            print("UP LEFT")
        }

        print("Orientation: ", direct)
        return direct as NSDictionary
    }
    
    func tapFirstWebView()
    {
        print("TAP FIRST WEB VIEW")
        
        fullscreenVC.videoURL               = videoURL01
        fullscreenVC.modalPresentationStyle = UIModalPresentationStyle.popover
        
        self.present(fullscreenVC, animated: true, completion: nil)
    }
    
    func tapSecondWebView()
    {
        print("TAP SECOND WEB VIEW")
        
        fullscreenVC.videoURL               = videoURL02
        fullscreenVC.modalPresentationStyle = UIModalPresentationStyle.popover
        
        self.present(fullscreenVC, animated: true, completion: nil)
    }
    
    
    
    
}
