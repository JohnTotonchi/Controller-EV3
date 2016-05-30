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
import Alamofire
import CDJoystick
import SocketIOClientSwift

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
    
    let videoURL    = "http://192.168.0.101:8081"
    let socket      = SocketIOClient(socketURL: NSURL(string: "http://192.168.0.150:3000")!, options: [.Log(true), .ForcePolling(true)])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initButtons()
        initJoystick()
        
        let request         = NSURLRequest(URL: NSURL(string: videoURL)!)
        webView.loadRequest(request)
        
        socket.on("/connect") { data, ack in
            print("Socket connected")
            self.socket.emit("/newClient")
        }
        
        socket.on("env/onSetMessage") { data, ack in
            self.displayTf.text  = data[0].description
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
            
        }
        
        socket.on("env/onSetAllCams") { data, ack in
            
        }
        
        socket.on("env/onSetCam") { data, ack in
            
        }
        
        socket.on("env/setAllRobots") { data, ack in
            
        }
        
        socket.on("env/getRobot") { data, ack in
            
        }
        
        socket.connect()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    @IBAction func switchA(sender: AnyObject)
    {
        if switchA.on
        {
            let data    = "{\"n\": 0, \"state\": 1}"
            socket.emit("env/setDoor", data)
        }
        else if (!switchA.on)
        {
            let data    = "{\"n\": 0, \"state\": 0}"
            socket.emit("env/setDoor", data)
        }
    }
    
    @IBAction func switchB(sender: AnyObject)
    {
        var data    = "{\"n\": 1, \"state\": 1}"
        if (!switchB.on)
        {
            data    = "{\"n\": 1, \"state\": 0}"
        }
        socket.emit("env/setDoor", data)
    }
    
    @IBAction func clickBuzzer(sender: AnyObject)
    {
        socket.emit("env/buzzer")
    }
    
    @IBAction func sendButton(sender: AnyObject)
    {
        if (!displayTf.text!.isEmpty)
        {
            let  data   = "{\"msg\": \"\(displayTf.text as NSString!)\", \"color\": [255, 0, 0]}"
            socket.emit("env/setMessage", data)
        }
    }
    
    private func initJoystick() {
        // 1. Initialize an instance of `CDJoystick` using the constructor:
        let joystick                    = CDJoystick()
        joystick.frame                  = CGRect(x: controlView.frame.midX + 45,
                                                 y: clawsBtn.frame.maxY + 65, width: 40, height: 40)
        
        joystick.backgroundColor        = .clearColor()
        
        // 2. Customize the joystick.
        joystick.substrateColor         = .lightGrayColor()
        joystick.substrateBorderColor   = .grayColor()
        joystick.substrateBorderWidth   = 1.0
        joystick.stickSize              = CGSize(width: 30, height: 30)
        joystick.stickColor             = .darkGrayColor()
        joystick.stickBorderColor       = .blackColor()
        joystick.stickBorderWidth       = 2.0
        joystick.fade                   = 0.5
        
        // 3. Setup the tracking handler to get velocity and angle data:
        joystick.trackingHandler        = { (joystickData) -> () in
            print("X velocity: ", joystickData.velocity.x)
            print("Y velocity: ", joystickData.velocity.y)
//            self.objectView.center.x += joystickData.velocity.x
//            self.objectView.center.y += joystickData.velocity.y
        }
        
        // 4. Add the joystick to your view:
        view.addSubview(joystick)
    }
    
    private func initButtons()
    {
        let myColor                     = UIColor( red: 229, green: 115, blue:0, alpha: 115)
        displayTf.layer.borderColor     = myColor.CGColor
        buzzerBtn.layer.cornerRadius    = 15;
        clawsBtn.layer.cornerRadius     = 15;
        
        sendButton.layer.cornerRadius   = 0.5 * 15
        sendButton.clipsToBounds        = true
    }

}
