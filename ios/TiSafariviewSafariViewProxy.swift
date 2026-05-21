//
//  TiSafariviewSafariViewProxy.swift
//  Ti.SafariView
//
//  Created by Douglas Alves
//  Copyright (c) 2026 Your Company. All rights reserved.
//


import TitaniumKit
import SafariServices

@objc(TiSafariviewSafariViewProxy)
class TiSafariviewSafariViewProxy: TiWindowProxy {

    // MARK: - Private State

    private var safariVC: SFSafariViewController?

    // MARK: - JS-accessible Properties

    @objc var url: String?
    @objc var entersReaderIfAvailable: Bool = false
    @objc var barCollapsingEnabled: Bool = true
    @objc var preferredBarTintColor: Any?
    @objc var preferredControlTintColor: Any?
    @objc var dismissButtonStyle: Int = SFSafariViewController.DismissButtonStyle.done.rawValue

    // MARK: - TiWindowProxy Lifecycle

    override func windowWillOpen() {
        super.windowWillOpen()
        guard let urlString = url, URL(string: urlString) != nil else {
            throwException(
                "Ti.SafariView: URL inválida ou não definida.",
                subreason: "Defina a propriedade 'url' antes de abrir a window.",
                location: CODELOCATION
            )
            return
        }
    }

    override func windowDidOpen() {
        super.windowDidOpen()
        embedSafariVC()
        fireEvent("open", with: nil)
    }
    
    override func windowWillClose() {
        // Cleanup do child VC antes do Titanium fechar a window
        safariVC?.willMove(toParent: nil)
        safariVC?.view.removeFromSuperview()
        safariVC?.removeFromParent()
        safariVC = nil

        super.windowWillClose()
    }

    // MARK: - Private

    private func embedSafariVC() {
        guard let urlString = url,
              let url = URL(string: urlString),
              let hostVC = topMostViewController() else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = entersReaderIfAvailable
        config.barCollapsingEnabled = barCollapsingEnabled

        let vc = SFSafariViewController(url: url, configuration: config)
        vc.delegate = self

        if let color = resolveColor(from: preferredBarTintColor) {
            vc.preferredBarTintColor = color
        }
        if let color = resolveColor(from: preferredControlTintColor) {
            vc.preferredControlTintColor = color
        }
        if let style = SFSafariViewController.DismissButtonStyle(rawValue: dismissButtonStyle) {
            vc.dismissButtonStyle = style
        }

        hostVC.addChild(vc)
        vc.view.frame = hostVC.view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostVC.view.addSubview(vc.view)
        vc.didMove(toParent: hostVC)

        safariVC = vc
    }

    // MARK: - Helpers

    private func resolveColor(from value: Any?) -> UIColor? {
        if let tiColor = value as? TiColor {
            return tiColor.color
        }
        if let str = value as? String {
            return TiUtils.colorValue(str)?.color
        }
        return nil
    }

    private func topMostViewController() -> UIViewController? {
        guard let root = TiApp.controller() else { return nil }
        return findTopViewController(root)
    }

    private func findTopViewController(_ vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController {
            return findTopViewController(presented)
        }
        if let nav = vc as? UINavigationController {
            return findTopViewController(nav.visibleViewController ?? nav)
        }
        if let tab = vc as? UITabBarController {
            return findTopViewController(tab.selectedViewController ?? tab)
        }
        return vc
    }
}

// MARK: - SFSafariViewControllerDelegate

extension TiSafariviewSafariViewProxy: SFSafariViewControllerDelegate {

    /// Usuário fechou manualmente via botão Done/Close/Cancel ou swipe down
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        fireEvent("close", with: ["userInitiated": true])
        // Propaga o fechamento para o Titanium (tab/navGroup/modal)
        self.close(nil)
    }

    /// Carregamento inicial completou
    func safariViewController(
        _ controller: SFSafariViewController,
        didCompleteInitialLoad didLoadSuccessfully: Bool
    ) {
        fireEvent("load", with: ["success": didLoadSuccessfully])
    }

    /// URL inicial redirecionou
    func safariViewController(
        _ controller: SFSafariViewController,
        initialLoadDidRedirectTo URL: URL
    ) {
        fireEvent("redirect", with: ["url": URL.absoluteString])
    }
}
