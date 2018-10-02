//
//  AppDelegate.swift
//  MarketingCloudDemo
//
//  Created by apple on 03/10/18.
//  Copyright © 2018 Gautham. All rights reserved.
//

import UIKit
import MarketingCloudSDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate{
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        var error: NSError?
        let success: Bool = MarketingCloudSDK.sharedInstance().sfmc_configure(&error)
        if success == true {
            // The SDK has been fully configured and is ready for use!
            
            // turn on logging for debugging.  Not recommended for production apps.
            MarketingCloudSDK.sharedInstance().sfmc_setDebugLoggingEnabled(true)
            
            // Great place for setting the contact key, tags and attributes since you know the SDK is setup and ready.
            MarketingCloudSDK.sharedInstance().sfmc_setContactKey("user@mycompany.com")
            MarketingCloudSDK.sharedInstance().sfmc_addTag("Hiking Supplies")
            MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("FavoriteTeamName", value: "favoriteTeamName")
            
            DispatchQueue.main.async {
                if #available(iOS 10.0, *) {
                    // set the delegate if needed then ask if we are authorized - the delegate must be set here if used
                    UNUserNotificationCenter.current().delegate = self
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
                        if error == nil {
                            if granted == true {
                                // we are authorized to use notifications, request a device token for remote notifications
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                        }
                    })
                }
                else {
                    let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
                    let setting = UIUserNotificationSettings(types: type, categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(setting)
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            //  MarketingCloudSDK sfmc_configure failed
            if #available(iOS 10.0, *) {
                os_log("MarketingCloudSDK sfmc_configure failed with error = %@", error!)
            } else {
                // Fallback on earlier versions
                NSLog("MarketingCloudSDK sfmc_configure failed with error = %@", error!)
            }
        }
        
        return success
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MarketingCloudSDK.sharedInstance().sfmc_setDeviceToken(deviceToken)
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // tell the MarketingCloudSDK about the notification
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationRequest(response.notification.request)
        completionHandler()
    }
    
    
    // This method is REQUIRED for correct functionality of the SDK.
    // This method will be called on the delegate when the application receives a silent push
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let theSilentPushContent = UNMutableNotificationContent()
        theSilentPushContent.userInfo = userInfo
        let theSilentPushRequest = UNNotificationRequest(identifier:UUID().uuidString, content: theSilentPushContent, trigger: nil)
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationRequest(theSilentPushRequest)
        
        completionHandler(.newData)
    }
    
    
}

