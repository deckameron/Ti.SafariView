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
class TiSafariviewSafariViewProxy: TiProxy {

    private var safariVC: SFSafariViewController?
    private var containerVC: UIViewController?

    @objc var url: String?
    @objc var entersReaderIfAvailable: Bool = false
    @objc var barCollapsingEnabled: Bool = true
    @objc var preferredBarTintColor: Any?
    @objc var preferredControlTintColor: Any?
    @objc var dismissButtonStyle: Int = SFSafariViewController.DismissButtonStyle.done.rawValue
    @objc var activityButton: TiViewProxy?
    
    // default: 0 = UIModalPresentationStyle.fullScreen
    @objc var modalPresentationStyle: Int = 0

    // MARK: - Public Methods

    @objc(open:)
    func open(_ args: [Any]?) {
        guard let urlString = url, let url = URL(string: urlString) else {
            throwException(
                "Ti.SafariView: URL inválida ou não definida.",
                subreason: "Defina a propriedade 'url' antes de chamar open().",
                location: CODELOCATION
            )
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = self.entersReaderIfAvailable
            config.barCollapsingEnabled = self.barCollapsingEnabled

            let vc = SFSafariViewController(url: url, configuration: config)
            vc.delegate = self

            if let color = self.resolveColor(from: self.preferredBarTintColor) {
                vc.preferredBarTintColor = color
            }
            if let color = self.resolveColor(from: self.preferredControlTintColor) {
                vc.preferredControlTintColor = color
            }
            if let style = SFSafariViewController.DismissButtonStyle(rawValue: self.dismissButtonStyle) {
                vc.dismissButtonStyle = style
            }

            self.safariVC = vc
            
            if let style = UIModalPresentationStyle(rawValue: modalPresentationStyle) {
                vc.modalPresentationStyle = style
            }

            guard let presenter = topMostViewController() else { return }
            
            presenter.present(vc, animated: true) { [weak self, weak vc] in
                guard let self = self, let vc = vc else { return }

                if let buttonProxy = self.activityButton {
                    self.addCustomButton(buttonProxy, over: vc.view)
                }

                self.fireEvent("open", with: nil)
            }
        }
    }

    @objc(close:)
    func close(_ args: [Any]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let vc = self.safariVC else { return }
            self.activityButton?.view?.removeFromSuperview()
            vc.dismiss(animated: true)
            self.safariVC = nil
        }
    }

    // MARK: - Floating Button

    private func addCustomButton(_ proxy: TiViewProxy, over parentView: UIView) {
        guard let buttonView = proxy.view else { return }

        buttonView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(buttonView)

        let guide = parentView.safeAreaLayoutGuide
        var constraints: [NSLayoutConstraint] = []

        if let v = tiFloat(proxy, key: "left") {
            constraints.append(buttonView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: v))
        }
        if let v = tiFloat(proxy, key: "right") {
            constraints.append(buttonView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -v))
        }
        if let v = tiFloat(proxy, key: "top") {
            constraints.append(buttonView.topAnchor.constraint(equalTo: guide.topAnchor, constant: v))
        }
        if let v = tiFloat(proxy, key: "bottom") {
            constraints.append(buttonView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -v))
        }
        if let v = tiFloat(proxy, key: "width") {
            constraints.append(buttonView.widthAnchor.constraint(equalToConstant: v))
        }
        if let v = tiFloat(proxy, key: "height") {
            constraints.append(buttonView.heightAnchor.constraint(equalToConstant: v))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func tiFloat(_ proxy: TiViewProxy, key: String) -> CGFloat? {
        guard let value = proxy.value(forKey: key) as? NSNumber else { return nil }
        return CGFloat(value.floatValue)
    }

    // MARK: - Helpers

    private func topMostViewController() -> UIViewController? {
        guard let root = TiApp.controller() else { return nil }
        return findTopViewController(root)
    }

    private func findTopViewController(_ vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController { return findTopViewController(presented) }
        if let nav = vc as? UINavigationController { return findTopViewController(nav.visibleViewController ?? nav) }
        if let tab = vc as? UITabBarController { return findTopViewController(tab.selectedViewController ?? tab) }
        return vc
    }

    private func resolveColor(from value: Any?) -> UIColor? {
        if let tiColor = value as? TiColor { return tiColor.color }
        if let str = value as? String { return TiUtils.colorValue(str)?.color }
        return nil
    }
    
    private class SafariBrowserContainer: UIViewController {

        var onDidAppear: (() -> Void)?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            onDidAppear?()
        }

        // Repassa preferências de apresentação para o filho
        override var childForStatusBarStyle: UIViewController? {
            return children.first
        }

        override var childForStatusBarHidden: UIViewController? {
            return children.first
        }
    }
}

// MARK: - SFSafariViewControllerDelegate

extension TiSafariviewSafariViewProxy: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        activityButton?.view?.removeFromSuperview()
        safariVC = nil
        fireEvent("close", with: ["userInitiated": true])
    }

    func safariViewController(
        _ controller: SFSafariViewController,
        didCompleteInitialLoad didLoadSuccessfully: Bool
    ) {
        if let buttonView = activityButton?.view {
            buttonView.superview?.bringSubviewToFront(buttonView)
        }

        fireEvent("load", with: ["success": didLoadSuccessfully])
    }

    func safariViewController(
        _ controller: SFSafariViewController,
        initialLoadDidRedirectTo URL: URL
    ) {
        fireEvent("redirect", with: ["url": URL.absoluteString])
    }
}
