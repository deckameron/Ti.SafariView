//
//  TiSafariviewModule.swift
//  Ti.SafariView
//
//  Created by Douglas Alves
//  Copyright (c) 2026 Your Company. All rights reserved.
//

import UIKit
import TitaniumKit
import SafariServices

/**
 
 Titanium Swift Module Requirements
 ---
 
 1. Use the @objc annotation to expose your class to Objective-C (used by the Titanium core)
 2. Use the @objc annotation to expose your method to Objective-C as well.
 3. Method arguments always have the "[Any]" type, specifying a various number of arguments.
 Unwrap them like you would do in Swift, e.g. "guard let arguments = arguments, let message = arguments.first"
 4. You can use any public Titanium API like before, e.g. TiUtils. Remember the type safety of Swift, like Int vs Int32
 and NSString vs. String.
 
 */

@objc(TiSafariviewModule)
class TiSafariviewModule: TiModule {
    
    public let testProperty: String = "Ti.SafariView"
    
    func moduleGUID() -> String {
        return "c4b0685c-e63b-46b2-ab77-0c0f160e21f4"
    }
    
    override func moduleId() -> String! {
        return "ti.safariview"
    }
    
    override func startup() {
        super.startup()
        debugPrint("[DEBUG] \(self) loaded")
    }
    
    // MARK: - Factory Methods
    
    @objc(createSafariView:)
    func createSafariView(_ args: [Any]?) -> TiSafariviewSafariViewProxy {
        let proxy = TiSafariviewSafariViewProxy()
        proxy._init(withPageContext: pageContext, args: args)
        return proxy
    }
    
    @objc(createAuthSession:)
    func createAuthSession(_ args: [Any]?) -> TiSafariviewAuthSessionProxy {
        let proxy = TiSafariviewAuthSessionProxy()
        proxy._init(withPageContext: pageContext, args: args)
        return proxy
    }
    
    // MARK: - DismissButtonStyle Constants
    
    @objc var DISMISS_BUTTON_STYLE_DONE: Int {
        return SFSafariViewController.DismissButtonStyle.done.rawValue       // 0
    }
    @objc var DISMISS_BUTTON_STYLE_CLOSE: Int {
        return SFSafariViewController.DismissButtonStyle.close.rawValue      // 1
    }
    @objc var DISMISS_BUTTON_STYLE_CANCEL: Int {
        return SFSafariViewController.DismissButtonStyle.cancel.rawValue     // 2
    }
    
    // MARK: - Modal Styles
    @objc var MODAL_PRESENTATION_FULL_SCREEN: Int { return 0 }
    @objc var MODAL_PRESENTATION_PAGE_SHEET: Int { return 1 }
    @objc var MODAL_PRESENTATION_FORM_SHEET: Int { return 2 }
    @objc var MODAL_PRESENTATION_CURRENT_CONTEXT: Int { return 3 }
    @objc var MODAL_PRESENTATION_OVER_FULL_SCREEN: Int { return 5 }
    @objc var MODAL_PRESENTATION_OVER_CURRENT_CONTEXT: Int { return 6 }
}
