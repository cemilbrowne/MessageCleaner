//
//  AboutWindowController.swift
//  MessageCleaner
//
//  Created by Cemil Browne on 26/5/17.
//  Copyright © 2017 Cemil Browne. All rights reserved.
//

import Foundation

import Cocoa

class AboutViewController: NSViewController {
    let delegate : AppDelegate = NSApplication.shared().delegate as! AppDelegate
    @IBAction func OKClicked(_ sender: Any) {
        delegate.closeAboutWindow()
    }
}
