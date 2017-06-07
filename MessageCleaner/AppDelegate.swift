//
//  AppDelegate.swift
//  MessageCleaner
//
//  Created by Cemil Browne on 24/5/17.
//  Copyright © 2017 Cemil Browne. All rights reserved.
//

import Cocoa
import SQLite

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var timer: Timer? = nil
    var statusBar : NSStatusBar = NSStatusBar.system()
    var statusItem : NSStatusItem = NSStatusItem()
    let popover : NSPopover = NSPopover()
    let defaults = UserDefaults.standard
    var windowController: NSWindowController? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        initializeStatusItem()
        let newUser = checkAndRegisterUserDefaults()
        windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AboutWindow") as? NSWindowController
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(AppDelegate.WakeNotification), name: NSNotification.Name.NSWorkspaceDidWake, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(AppDelegate.SleepNotification), name: NSNotification.Name.NSWorkspaceWillSleep, object: nil)
        if newUser == true {
            showPopover(sender: nil)
        }
    }
    func WakeNotification(_ aNotification: Notification) {
        checkAndStartTimer()
    }
    func SleepNotification(_ aNotification: Notification) {
        
    }
    func showAboutWindow () {
        if(windowController != nil) {
            windowController!.showWindow(nil)

        }
    }
    
    func closeAboutWindow() {
        if(windowController != nil) {
            windowController!.close()
            
        }
    }
    
//    func applicationIsInStartUpItems() -> Bool {
//        return (itemReferencesInLoginItems().existingReference != nil)
//    }
//    
//    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
//        if let appURL : NSURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as NSURL {
//            if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
//                
//                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
//                let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
//                
//                for (index, loginItem) in loginItems.enumerated() {
//                    let currentItemRef: LSSharedFileListItem = loginItems.object(at: index) as! LSSharedFileListItem
//                    if let itemURL = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
//                        if (itemURL.takeRetainedValue() as NSURL).isEqual(appURL) {
//                            return (currentItemRef, lastItemRef)
//                        }
//                    }
//                }
//                
//                return (nil, lastItemRef)
//            }
//        }
//        
//        return (nil, nil)
//    }
//    
//    func toggleLaunchAtStartup() {
//        let itemReferences = itemReferencesInLoginItems()
//        let shouldBeToggled = (itemReferences.existingReference == nil)
//        if let loginItemsRef = LSSharedFileListCreate( nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
//            if shouldBeToggled {
//                if let appUrl : CFURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as CFURL {
//                    print("Add login item")
//                    LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
//                }
//            } else {
//                if let itemRef = itemReferences.existingReference {
//                    print("Remove login item")
//                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
//                }
//            }
//        }
//    }
    func checkAndRegisterUserDefaults() -> Bool {
        var newUser : Bool = false
        let RunManually = defaults.object(forKey: "MinuteField")
        if  RunManually == nil {
            newUser = true
            setDefaults(RunManually: 1, MinuteField: 60, DeleteOlderThan: 20, DeleteAttachments: 0, DeleteEmpty: 0, RunOnStartup: 0, UnitValue: 0)
        }
        checkAndStartTimer()
        return newUser
    }
    
    func checkAndStartTimer() {

        let RunManually = defaults.integer(forKey: "RunManually")
        let interval = defaults.integer(forKey: "MinuteField")
        if RunManually == 1 {
            
        } else {
            startTimer(duration: interval)
        }
    }
    func setDefaults(RunManually: Int, MinuteField: Int, DeleteOlderThan: Int, DeleteAttachments: Int, DeleteEmpty: Int, RunOnStartup: Int, UnitValue: Int) {

        defaults.set(UnitValue, forKey: "UnitValue")
        defaults.set(RunManually, forKey: "RunManually")
        defaults.set(MinuteField, forKey: "MinuteField")
        defaults.set(DeleteOlderThan, forKey: "DeleteOlderThan")
        defaults.set(DeleteAttachments, forKey: "DeleteAttachments")
        defaults.set(DeleteEmpty, forKey: "DeleteEmpty")
        defaults.set(RunOnStartup, forKey: "RunOnStartup")
        defaults.synchronize()
    }
    func initializeStatusItem() {
        statusItem = statusBar.statusItem(withLength: NSVariableStatusItemLength)
        let StatusImage = NSImage(named: "Status Icon")!
        StatusImage.isTemplate = true
        statusItem.button!.image = StatusImage
        statusItem.button!.target = self
        statusItem.button!.action = #selector(AppDelegate.togglePopover)
        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        popover.behavior = NSPopoverBehavior.transient
        popover.contentViewController = PopUpController(nibName: "PopUpController", bundle: nil)
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("Terminating")
    }
    
    func closePopover(sender: AnyObject?) {
        popover.close()
    }
    func startTimer(duration: Int) {
        NSLog("Starting timer with duration: \(duration)")
        if timer != nil {
            timer!.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: Double(duration)*60.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
    }

    func getFriendlyTimerDate() -> String {
        if timer != nil {
            if(timer!.isValid) {
                let timerDate = timer?.fireDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss"
                return dateFormatter.string(from: timerDate!)
            } else {
                return "N/A"
            }
        }
        return "N/A"
    }
    func stopTimer() {
        NSLog("Stopping timer (if required)")
        if timer != nil {
            timer!.invalidate()
        }
        
    }
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    func timerFired() {
        dealWithMessages()
        checkAndStartTimer()
    }
    
    func dealWithMessages() {
        NSLog("Dealing with Messages")
        let ChatDBPath = getChatDBPath()
        if checkMessagesInForeground() {
            NSLog("Messages in foreground; not doing anything")
            return
        }
        killMessages()
        let DBSuccess = manipulateChatDb(path: ChatDBPath!, age: calculateOlderThanSeconds())
        if DBSuccess && (defaults.integer(forKey: "DeleteAttachments") == 1) {
            dealWithAttachments(olderThanMinutes: calculateOlderThanMinutes())
        }
        bounceIMAgent()
        restartMessages()
    }
    func restartMessages() {
        NSLog("Restarting Messages")
        let myAppleScript = "tell application \"/Applications/Messages.app\" to run"
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            _ = scriptObject.executeAndReturnError(&error)
        }
    }
    func bounceIMAgent() {
        NSLog("Bouncing IM Agent")
        let command = "killall imagent > /dev/null 2>&1"
        _ = runShellCommand(command: command)

    }
    func dealWithAttachments(olderThanMinutes: Int) {
        let attachmentsDir = getMessagesDir() + "Attachments/"
        
        if FileManager.default.fileExists(atPath: attachmentsDir) {
            let command = "find \""+attachmentsDir+"\" -mmin +"+String(olderThanMinutes)+" -type f -delete"
            _ = runShellCommand(command: command)
        }
    }
    func calculateOlderThanMinutes() -> Int {
        let raw_age = defaults.integer(forKey: "DeleteOlderThan")
        let UnitValue = defaults.integer(forKey: "UnitValue")
        
        switch UnitValue {
        case 0:
            return raw_age
        case 1:
            return raw_age * 60
        case 2:
            return raw_age * 60 * 24
        default:
            return 60*24*365*15
        }

    }
    func calculateOlderThanSeconds() -> Int {
        return (calculateOlderThanMinutes() * 60)
    }
    func manipulateChatDb(path: String, age: Int) -> Bool {
        do {
            let db = try Connection(path)
            let query = "delete from message where date < (strftime('%s','now')-strftime('%s','2001-01-01')-\(age));"
            try db.execute(query)
            try db.execute("delete from chat_message_join where message_id not in (select ROWID from message)")
            if(defaults.integer(forKey: "DeleteEmpty") == 1) {
                try db.execute("delete from chat where ROWID not in (select chat_id from chat_message_join)")
                NSLog("Deleted Chats too")
            }
            try db.execute("delete from deleted_messages")
        } catch {
            NSLog("DB Error")
            return false
        }
        return true
    }
    func killMessages() {
        _ = runShellCommand(command: "killall Messages > /dev/null 2>&1")
    }
    func runShellCommand(command: String) -> NSString? {
        // Create a Task instance (was NSTask on swift pre 3.0)
        let task = Process()
        
        // Set the task parameters
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", command]
        
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Launch the task
        task.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return output
    }
    func checkMessagesInForeground() -> Bool {
        let output = runShellCommand(command: "/usr/bin/lsappinfo info `lsappinfo front` |grep bundleID |cut -d \"=\" -f 2")
        
        if output != nil {
            let trimmedOutput = output!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmedOutput == "\"com.apple.iChat\"" {
                return true
            } else {
                return false
            }
        }
        return true
    }
    func getMessagesDir() -> String {
        let libraryDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let messagesDir = libraryDir + "/Messages/"
        
        return messagesDir
    }
    func getChatDBPath() -> String? {
        let messagesDir = getMessagesDir()
        let chatDB = messagesDir + "chat.db"
        if FileManager.default.fileExists(atPath: chatDB) {
            return chatDB
        }
        return nil
     
    }
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    

}

