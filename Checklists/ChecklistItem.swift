

import Foundation
import UIKit

class ChecklistItem: NSObject, NSCoding {
  var text: String
  var checked: Bool
  var itemID: Int
  var dueDate = NSDate()
  var shouldRemind = false
  
  required init?(coder aDecoder: NSCoder) {
    text = aDecoder.decodeObjectForKey("Text") as! String
    checked = aDecoder.decodeBoolForKey("Checked")
    itemID = aDecoder.decodeIntegerForKey("ItemID")
    dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
    shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
    super.init()
  }
  
  init(text: String, checked: Bool) {
    self.text = text
    self.checked = checked
    itemID = DataModel.nextChecklistItemID()
  }
  
  func toggleChecked() {
    checked = !checked
  }

  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(text, forKey: "Text")
    aCoder.encodeBool(checked, forKey: "Checked")
    aCoder.encodeInteger(itemID, forKey: "ItemID")
    aCoder.encodeObject(dueDate, forKey: "DueDate")
    aCoder.encodeBool(shouldRemind, forKey: "ShouldRemind")
  }
  
  func scheduleNotification() {
    let existingNotification = notificationForThisItem()
    if let notification = existingNotification {
      UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
    if shouldRemind && dueDate.compare(NSDate()) != .OrderedAscending {
      let localNotification = UILocalNotification()
      localNotification.fireDate = dueDate
      localNotification.timeZone = NSTimeZone.defaultTimeZone()
      localNotification.alertBody = "I am a local notification!"
      localNotification.soundName = UILocalNotificationDefaultSoundName
      UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
  }
  
  func notificationForThisItem() -> UILocalNotification? {
    let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
    
    for notification in allNotifications {
      if let number = notification.userInfo?["ItemID"] as? Int where number == itemID {
        return notification
      }
    }
    return nil
  }
  
  deinit {
    if let notification = notificationForThisItem() {
      print("Remove existing notification \(notification)")
      UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
  }
}
