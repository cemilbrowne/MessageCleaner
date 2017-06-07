//
//  PopUpController.swift
//  MessageCleaner
//
//  Created by Cemil Browne on 24/5/17.
//  Copyright © 2017 Cemil Browne. All rights reserved.
//

import Cocoa

class PopUpController: NSViewController {

    @IBOutlet weak var UnitPopUp: NSPopUpButton!
    @IBOutlet weak var MinutesText: NSTextField!
    @IBOutlet weak var MinuteField: NSTextField!
    @IBOutlet weak var EveryText: NSTextField!
    @IBOutlet weak var DeleteOlderThan: NSTextField!
    @IBOutlet weak var RunManuallyCheckBox: NSButton!
    @IBOutlet weak var DeleteAttachments: NSButton!
    @IBOutlet weak var DeleteEmptyChats: NSButton!
    @IBOutlet weak var RunOnStartup: NSButton!
    @IBOutlet weak var NextRunLabel: NSTextField!
    let delegate : AppDelegate = NSApplication.shared().delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var viewUpdateTimer: Timer? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        RunManuallyCheckBox.state = defaults.integer(forKey: "RunManually")
        EnableManualFields()
        MinuteField.stringValue = String(defaults.integer(forKey: "MinuteField"))
        DeleteOlderThan.stringValue = String(defaults.integer(forKey: "DeleteOlderThan"))
        DeleteAttachments.state = defaults.integer(forKey: "DeleteAttachments")
        DeleteEmptyChats.state = defaults.integer(forKey: "DeleteEmpty")
        RunOnStartup.state = defaults.integer(forKey: "RunOnStartup")
        UnitPopUp.selectItem(at: defaults.integer(forKey: "UnitValue"))
        setNextRunTime()
        viewUpdateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setNextRunTime), userInfo: nil, repeats: true)
    }
    
    
    func setDefaults() {
        let RunManuallyState = RunManuallyCheckBox.state
        let MinuteFieldState = MinuteField.integerValue
        let DeleteOlderThanState = DeleteOlderThan.integerValue
        let DeleteAttachmentsState = DeleteAttachments.state
        let DeleteEmptyState = DeleteEmptyChats.state
        let RunOnStartupState = RunOnStartup.state
        let UnitValueState = UnitPopUp.indexOfSelectedItem
        delegate.setDefaults(RunManually: RunManuallyState, MinuteField: MinuteFieldState, DeleteOlderThan: DeleteOlderThanState, DeleteAttachments: DeleteAttachmentsState, DeleteEmpty: DeleteEmptyState, RunOnStartup: RunOnStartupState, UnitValue: UnitValueState)
    }
    func setNextRunTime() {
        NextRunLabel.stringValue = "Next Run: " + delegate.getFriendlyTimerDate()
    }
    
    func startTimer() {
        delegate.startTimer(duration: MinuteField.integerValue)
        setNextRunTime()
    }
    func stopTimer() {
        delegate.stopTimer()
    }
    func EnableManualFields() {
        if RunManuallyCheckBox.state == NSOnState {
            MinutesText.isHidden = true
            MinuteField.isHidden = true
            EveryText.isHidden = true
        } else {
            MinutesText.isHidden = false
            MinuteField.isHidden = false
            EveryText.isHidden = false
        }
    }
    @IBAction func AboutClicked(_ sender: Any) {
        delegate.showAboutWindow()
    }
    @IBAction func UnitsChanged(_ sender: Any) {
        setDefaults()
    }
    @IBAction func ExitClicked(_ sender: Any) {
        setDefaults()
        NSApplication.shared().terminate(nil)
    }
    @IBAction func TimerValueChanged(_ sender: Any) {
        if let _ = Int(MinuteField.stringValue) {
            setDefaults()
            startTimer()
        } else {
            MinuteField.stringValue = String(defaults.integer(forKey: "MinuteField"))
        }
    }
    @IBAction func checkboxClicked(_ sender: Any) {
        setDefaults()
    }
    @IBAction func OlderThanValueChanged(_ sender: Any) {
        if let _ = Int(DeleteOlderThan.stringValue) {
            setDefaults()
        } else {
            DeleteOlderThan.stringValue = String(defaults.integer(forKey: "DeleteOlderThan"))
        }
    }
    @IBAction func RunManuallyClicked(_ sender: Any) {
        setDefaults()
        EnableManualFields()
        if RunManuallyCheckBox.state == NSOnState {
            stopTimer()
        } else {
            startTimer()
        }
    }
    @IBAction func RunRightNowClicked(_ sender: Any) {
        setDefaults()
        delegate.timerFired()
        RunManuallyClicked(sender)
    }
    
}
