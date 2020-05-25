//
//  TabBarViewController.swift
//  in-sight
//
//  Created by Josh Leikam on 7/4/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var insightTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.layer.borderWidth = 0
        self.tabBar.clipsToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 0){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                if Reachability.isConnectedToNetwork() == true
                {
                    print("Connected")
                }
                else
                {
                    let controller = UIAlertController(title: "No Connection Detected", message: "This app requires an Internet/Mobile Data connection", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    controller.addAction(ok)
                    
                    present(controller, animated: true, completion: nil)
                }
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            if Reachability.isConnectedToNetwork() == true
            {
                print("Connected")
            }
            else
            {
                let controller = UIAlertController(title: "No Connection Detected", message: "This app requires an Internet/Mobile Data connection", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                controller.addAction(ok)
                
                present(controller, animated: true, completion: nil)
            }
        }

    }
    
    
}
