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
import CDJoystick
import SocketIO

class HomeVC: UIViewController {
    
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
    let firstCameraUrl = "URL"
    let secondCameraUrl = "URL"
    let manager = SocketManager(socketURL: URL(string: "http://URL")!, config: [.log(true), .forcePolling(true)])
    var socket: SocketIOClient!
    var modeManuel = false
    var alertIsOn = false
    let myColor = UIColor(red: 229/255, green: 115/255, blue: 115/255, alpha: 1)
    var fullscreenVC = FullscreenVC()
    
    lazy var firstCameraTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapFirstWebView))
        
        return tapGesture
    }()
    
    lazy var secondCameraTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapSecondWebView))
        
        return tapGesture
    }()
    
    lazy var joystick: CDJoystick = {
        let joystick = CDJoystick()
        joystick.substrateColor = .lightGray
        joystick.substrateBorderColor = .gray
        joystick.substrateBorderWidth = 1.0
        joystick.stickSize = CGSize(width: 35, height: 35)
        joystick.stickColor = .darkGray
        joystick.stickBorderColor = .black
        joystick.stickBorderWidth = 2.0
        joystick.fade = 0.5
        joystick.backgroundColor = .clear
        joystick.trackingHandler = { (joystickData) -> () in
            self.socket.emit("robots/setRobot/move", self.setOrientation(Float(joystickData.velocity.x), y: Float(joystickData.velocity.y)))
            
            Thread.sleep(forTimeInterval: 0.2)
        }
        
        return joystick
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        socket = manager.defaultSocket
        setupUI()
        
        fullscreenVC = self.storyboard?.instantiateViewController(withIdentifier: "FULLSCREEN") as! FullscreenVC
        
        webView.loadRequest(URLRequest(url: URL(string: firstCameraUrl)!))
        webView2.loadRequest(URLRequest(url: URL(string: secondCameraUrl)!))
        
        socket.on("/connect") { data, ack in
            print("Socket connected")
            self.socket.emit("/newClient", "SWIFT")
        }
        
        socket.on("env/onSetMessage") { data, ack in
            self.displayTf.text  = (data[0] as AnyObject).description
        }
        
        socket.on("env/onSetDoor") { data, ack in
            let json = JSON(data[0])
            
            if(json["n"] == 0) {
                if(json["state"] == 0) {
                    self.switchA.setOn(false, animated: true)
                } else if(json["state"] == 1) {
                    self.switchA.setOn(true, animated: true)
                }
            }
            else if(json["n"] == 1) {
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
            let dictionary = JSON(data[0])
            var i = 0

            for j in 0...dictionary.count {
                if(dictionary[j]["prison"] == true) {
                    i+=1
                }
            }
            
            self.jailLabel.text = "Prison \(i.description)"
            self.checkpointLabel.text = "Checkpoint \(dictionary.count.description)"
        }
        
        socket.on("env/onSetMode") { data, ack in
            let response = JSON(data[0])
            
            if(response == 0) {
                self.modeManuel = false
                self.clawsBtn.isEnabled = false
                self.clawsBtn.backgroundColor = UIColor.lightGray
                self.modeToggle.selectedSegmentIndex = 0
            } else if(response == 1) {
                self.modeManuel = true
                self.clawsBtn.isEnabled = true
                self.modeToggle.selectedSegmentIndex = 1
                self.clawsBtn.backgroundColor = self.myColor
            }
        }
        
        socket.on("env/onAlerte") { data, ack in
            self.alertIsOn = true
            self.alertSignal.backgroundColor = UIColor.red
        }
        
        socket.on("env/onAlerteEnd") { data, ack in
            self.alertIsOn = false
            self.alertSignal.backgroundColor = UIColor.green
        }
        
        socket.connect()
    }
    
    override func viewDidLayoutSubviews() {
        joystick.frame = CGRect(x: controlView.frame.midX - 22, y: clawsBtn.frame.maxY + 70, width: 45, height: 45)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        webView.reload()
        webView2.reload()
    }
    
    // MARK: IBActions
    @IBAction func switchA(_ sender: AnyObject)
    {
        var data = "{\"n\": 0, \"state\": 1}"

        if (!switchA.isOn) {
            data = "{\"n\": 0, \"state\": 0}"
        }
        
        socket.emit("env/setDoor", data)
    }
    
    @IBAction func switchB(_ sender: AnyObject)
    {
        var data = "{\"n\": 1, \"state\": 1}"
        
        if (!switchB.isOn) {
            data = "{\"n\": 1, \"state\": 0}"
        }
        
        socket.emit("env/setDoor", data)
    }
    
    @IBAction func clickBuzzer(_ sender: AnyObject)
    {
        socket.emit("env/buzzer")
    }
    
    @IBAction func sendButton(_ sender: AnyObject)
    {
        if (!displayTf.text!.isEmpty) {
            let data = "{\"msg\": \"\(displayTf.text!)\", \"color\": [255, 0, 0]}"
            socket.emit("env/setMessage", data)
            
            let alert = UIAlertController(title: "Message Posted", message: displayTf.text, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func clickModeToggle(_ sender: AnyObject)
    {
        if (modeToggle.selectedSegmentIndex == 0) {
            socket.emit("env/setMode", 0)
            self.modeManuel = false
            self.clawsBtn.isEnabled = false
            self.clawsBtn.backgroundColor = UIColor.lightGray
        } else if (modeToggle.selectedSegmentIndex == 1) {
            socket.emit("env/setMode", 1)
            self.modeManuel = true
            self.clawsBtn.isEnabled = true
            self.clawsBtn.backgroundColor = self.myColor
        }
    }
    
    @IBAction func clickClaws(_ sender: AnyObject)
    {
        print("CLAWS")
    }
    
    // MARK: Functions
    private func setupUI()
    {
        alertSignal.layer.cornerRadius = alertSignal.frame.size.width/2
        alertSignal.clipsToBounds = true
        alertSignal.backgroundColor = UIColor.green
        
        buzzerBtn.layer.cornerRadius = 15
        clawsBtn.layer.cornerRadius = 15
        
        sendButton.layer.cornerRadius = 0.5 * 15
        sendButton.clipsToBounds = true
        
        
        secondCameraTapGesture.addTarget(self, action: #selector(tapSecondWebView))
        
        webView.addGestureRecognizer(firstCameraTapGesture)
        webView2.addGestureRecognizer(secondCameraTapGesture)
        
        webView.scrollView.isUserInteractionEnabled = false
        webView2.scrollView.isUserInteractionEnabled = false
        
        view.addSubview(joystick)
    }
    
    private func setOrientation(_ x: Float, y: Float) -> NSDictionary
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
    
    @objc func tapFirstWebView()
    {
        fullscreenVC.videoURL = firstCameraUrl
        fullscreenVC.modalPresentationStyle = .popover
        
        self.present(fullscreenVC, animated: true, completion: nil)
    }
    
    @objc func tapSecondWebView()
    {
        fullscreenVC.videoURL = secondCameraUrl
        fullscreenVC.modalPresentationStyle = .popover
        
        self.present(fullscreenVC, animated: true, completion: nil)
    }
}
