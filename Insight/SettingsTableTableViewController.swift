//
//  SettingsTableTableViewController.swift
//  Insight
//
//  Created by Josh Leikam on 7/18/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import UserNotifications
import MessageUI

class SettingsTableTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBAction func reportButton(_ sender: Any) {
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["insightofthedayapp@gmail.com"])
            self.present(composeVC, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Cannot Send Mail", message: "Please Configure Your IOS Mail App", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: { action in
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { action in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }

        
    }
    
    @IBAction func rateButton(_ sender: Any) {
        print("rate presd")
        let appID = "1257457178"
        let reviewString = "https://itunes.apple.com/us/app/id\(appID)?ls=1&mt=8&action=write-review"
        let revURL = URL(string: reviewString)

        UIApplication.shared.open(revURL!, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func contactButton(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["insightofthedayapp@gmail.com"])
            self.present(composeVC, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Cannot Send Mail", message: "Please Configure Your IOS Mail App", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: { action in
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { action in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var settingsTableView: UITableView!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var enableNotificationLabel: UILabel!
    @IBOutlet weak var notificationTextField: UITextField!
    
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createDatePicker()
        self.checkNotificationStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        
        self.settingsTableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkNotificationStatus()
        self.initDatePicker()
        self.initNotificationTextField()
    }
    
    func willEnterForeground(){
        self.checkNotificationStatus()
        self.initDatePicker()
        self.initNotificationTextField()
    }
    
    
    
    func refresh(notification: NSNotification){
        self.checkNotificationStatus()
        self.initDatePicker()
        self.initNotificationTextField()
    }
    
    func scheduleDefaultLocalNotification(){
        
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { (notifications) in
            if(notifications.count == 0){
                let content = UNMutableNotificationContent()
                content.title = "Insight of the Day"
                content.body = "Your insight of the day is ready!"
                content.sound = UNNotificationSound.default()
                var dateComponents = DateComponents()
                dateComponents.hour = 12
                dateComponents.minute = 00
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
    
    func createDatePicker(){
        datePicker.datePickerMode = .time
        datePicker.backgroundColor = UIColor.white
        toolBar.sizeToFit()
        toolBar.clipsToBounds = true
        toolBar.barTintColor = UIColor.white
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
        doneButton.tintColor = UIColor.black
        
        toolBar.setItems([doneButton], animated: true)
        
        self.notificationTextField.tintColor = .clear
        self.notificationTextField.inputAccessoryView = toolBar
        self.notificationTextField.inputView = datePicker
        
    }
    
    func doneButtonPressed(){
        self.clearLocalNotifications()
        
        let date = datePicker.date
        
        self.scheduleLocalNotification(date: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        
        let dateStr = formatter.string(from: date)
        
        notificationTextField.text = dateStr
        
        let defaults = UserDefaults.standard
        defaults.set(dateStr, forKey: "notificationTime")
        defaults.set(datePicker.date, forKey: "notificationDate")
        
        
        self.view.endEditing(true)
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                    if granted{
                        self.clearLocalNotifications()
                        self.scheduleLocalNotification(date: date)
                    }
                    else if !granted{
                        center.removeAllPendingNotificationRequests()
                        
                    }
                }
            }
            
            if settings.authorizationStatus == .denied {
                let alert = UIAlertController(title: "Notifications Disabled", message: "To enable notifications go to IOS Settings -> Notifications -> Insight of the Day -> Allow.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: { action in
                    
                    self.notificationSwitch.setOn(false, animated: true)
                }))
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { action in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }))
                
                
                self.present(alert, animated: true, completion: nil)
            }
            
        })
     
        
    }
    
    func scheduleLocalNotification(date: Date){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Insight of the Day"
        content.body = "Your insight of the day is ready!"
        content.sound = UNNotificationSound.default()
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        self.notificationSwitch.setOn(true, animated: true)
    }
    
    func clearLocalNotifications(){
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func checkNotificationStatus(){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                self.notificationSwitch.setOn(false, animated: false)
            }
            
            if settings.authorizationStatus == .denied {
                self.notificationSwitch.setOn(false, animated: false)
            }
            
            if settings.authorizationStatus == .authorized{
                let didCancelNotifications = UserDefaults.standard.value(forKey: "didCancelNotifications") as! Bool
                center.getPendingNotificationRequests(completionHandler: { (notifications) in
                    if(notifications.count == 0 && didCancelNotifications == false){
                        self.notificationSwitch.setOn(true, animated: false)
                        self.scheduleLocalNotification(date: self.datePicker.date)
                    }
                    else if(didCancelNotifications){
                        self.notificationSwitch.setOn(false, animated: false)
                    }

                })
            }
            
        })
//        center.getPendingNotificationRequests { (notifications) in
//            if(notifications.count>0){
//                self.notificationSwitch.setOn(true, animated: false)
//            }
//           else{
//                self.notificationSwitch.setOn(false, animated: false)
////                self.clearLocalNotifications()
////                self.scheduleLocalNotification(date: self.datePicker.date)
////            }
//        }
    }
    
    func initNotificationTextField(){
        let notificationTime = UserDefaults.standard.value(forKey: "notificationTime")
        self.notificationTextField.text! = notificationTime as! String
        
    }
    
    func initDatePicker(){
        let notificationDate = UserDefaults.standard.value(forKey: "notificationDate")
        self.datePicker.date = notificationDate as! Date
    }

    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        let current = UNUserNotificationCenter.current()
        
        if(sender.isOn){
            
            UserDefaults.standard.set(false, forKey: "didCancelNotifications")
            
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    // Means you can request
                    current.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                        if granted{
                            self.scheduleDefaultLocalNotification()
                        }
                        else if !granted{
                            current.removeAllPendingNotificationRequests()
                            self.notificationSwitch.setOn(false, animated: true)

                        }
                    }
                }
                if settings.authorizationStatus == .denied {
                    // User should enable notifications from settings & privacy
                    
                    let alert = UIAlertController(title: "Notifications Disabled", message: "To enable notifications go to IOS Settings -> Notifications -> Allow.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: { action in
                        
                        self.notificationSwitch.setOn(false, animated: false)
                    }))
                    alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { action in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
                
                if settings.authorizationStatus == .authorized {
                    
                    let alert = UIAlertController(title: "Notifications Enabled", message: "A notification has been scheduled for: " + self.notificationTextField.text! , preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    self.scheduleLocalNotification(date: self.datePicker.date)
                }
            })
        }
        else{
            
            self.clearLocalNotifications()
            
            let alert = UIAlertController(title: "Notifications Cancelled", message: "Any pending notifications have been cancelled", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: "didCancelNotifications")
        }

    }

}

