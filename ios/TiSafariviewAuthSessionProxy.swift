//
//  TiSafariviewAuthSessionProxy.swift
//  Ti.SafariView
//
//  Created by Douglas Alves
//  Copyright (c) 2026 Your Company. All rights reserved.
//


import TitaniumKit
import AuthenticationServices

@objc(TiSafariviewAuthSessionProxy)
class TiSafariviewAuthSessionProxy: TiProxy {

    // MARK: - Private State

    // CRÍTICO: manter referência forte — sessão é cancelada se desalocada
    private var authSession: ASWebAuthenticationSession?

    // MARK: - JS-accessible Properties

    /// URL de autenticação completa (incluindo redirect_uri, client_id, etc.)
    @objc var url: String?

    /// Scheme do callback (ex: "myapp" para "myapp://oauth/callback")
    @objc var callbackURLScheme: String?

    /// true = sessão privada sem cookies do Safari (default: false)
    @objc var prefersEphemeralWebBrowserSession: Bool = false

    // MARK: - Public Methods

    /// Inicia a sessão de autenticação. Retorna true se iniciou com sucesso.
    @objc(start:)
    func start(_ args: [Any]?) {
        guard let urlString = url, let authURL = URL(string: urlString) else {
            throwException(
                "Ti.SafariView AuthSession: URL is invalid.",
                subreason: "Define the 'url' property before calling 'start()'.",
                location: CODELOCATION
            )
            return
        }

        guard let scheme = callbackURLScheme, !scheme.isEmpty else {
            throwException(
                "Ti.SafariView AuthSession: callbackURLScheme is not defined.",
                subreason: "Define the 'callbackURLScheme' with the URL scheme of your app.",
                location: CODELOCATION
            )
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: scheme
            ) { [weak self] callbackURL, error in
                guard let self = self else { return }
                self.handleAuthCompletion(callbackURL: callbackURL, error: error)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = self.prefersEphemeralWebBrowserSession

            self.authSession = session
            let started = session.start()

            if !started {
                self.fireEvent("complete", with: [
                    "success": false,
                    "cancelled": false,
                    "error": "Authentication session could not be started."
                ])
                self.authSession = nil
            }
        }
    }

    /// Cancela a sessão em andamento.
    @objc(cancel:)
    func cancel(_ args: [Any]?) {
        DispatchQueue.main.async { [weak self] in
            self?.authSession?.cancel()
            self?.authSession = nil
        }
    }

    // MARK: - Completion Handler

    private func handleAuthCompletion(callbackURL: URL?, error: Error?) {
        authSession = nil

        if let error = error as? ASWebAuthenticationSessionError {
            let cancelled = error.code == .canceledLogin
            fireEvent("complete", with: [
                "success": false,
                "cancelled": cancelled,
                "error": cancelled ? "Login was cancelled by the user." : error.localizedDescription,
                "callbackURL": NSNull()
            ])
            return
        }

        if let error = error {
            fireEvent("complete", with: [
                "success": false,
                "cancelled": false,
                "error": error.localizedDescription,
                "callbackURL": NSNull()
            ])
            return
        }

        guard let callbackURL = callbackURL else {
            fireEvent("complete", with: [
                "success": false,
                "cancelled": false,
                "error": "Callback URL not received.",
                "callbackURL": NSNull()
            ])
            return
        }

        // Parsear query params do callback para conveniência do dev
        let queryParams = parseQueryParams(from: callbackURL)

        fireEvent("complete", with: [
            "success": true,
            "cancelled": false,
            "error": NSNull(),
            "callbackURL": callbackURL.absoluteString,
            "queryParams": queryParams  // { code: '...', state: '...' }
        ])
    }

    private func parseQueryParams(from url: URL) -> [String: String] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems
        else { return [:] }

        return items.reduce(into: [:]) { result, item in
            result[item.name] = item.value ?? ""
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension TiSafariviewAuthSessionProxy: ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}
