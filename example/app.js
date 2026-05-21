const SafariView = require('ti.safariview')

// ─────────────────────────────────────────────
// Example 1: In-app browser (page sheet style)
// ─────────────────────────────────────────────

const browser = SafariView.createSafariView({
    url: 'https://example.com',
    entersReaderIfAvailable: false,
    barCollapsingEnabled: true,
    preferredBarTintColor: Ti.UI.fetchSemanticColor('navigationBarColor'),
    preferredControlTintColor: '#FF3B30',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
});

browser.addEventListener('open', ()  => Ti.API.info('Browser opened'));
browser.addEventListener('load', e  => Ti.API.info('Load success: ' + e.success));
browser.addEventListener('redirect', e  => Ti.API.info('Redirected to: ' + e.url));
browser.addEventListener('close', e  => Ti.API.info('Closed. User initiated: ' + e.userInitiated));

browser.open({
    modal: true,
    modalTransitionStyle: Ti.UI.iOS.MODAL_TRANSITION_STYLE_COVER_VERTICAL,
    modalStyle: Ti.UI.iOS.MODAL_PRESENTATION_FORMSHEET,
});


// ─────────────────────────────────────────────
// Example 2: Full screen browser
// ─────────────────────────────────────────────

const fullscreenBrowser = SafariView.createSafariView({
    url: 'https://example.com',
    navBarHidden: true,
    fullscreen: true,
    backgroundColor: '#000000',
    preferredBarTintColor: '#000000',
    preferredControlTintColor: '#FFFFFF',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_DONE,
});

fullscreenBrowser.open({ modal: true });


// ─────────────────────────────────────────────
// Example 3: Google OAuth flow
// ─────────────────────────────────────────────

const authSession = SafariView.createAuthSession({
    url: 'https://accounts.google.com/o/oauth2/v2/auth?' + [
        'client_id=YOUR_GOOGLE_CLIENT_ID',
        'redirect_uri=myapp://oauth/callback',
        'response_type=code',
        'scope=email profile',
        'state=RANDOM_STATE_TOKEN',
        'access_type=offline',
    ].join('&'),
    callbackURLScheme: 'myapp',
    prefersEphemeralWebBrowserSession: false,
});

authSession.addEventListener('complete', e => {
    if (e.success) {
        const { code, state } = e.queryParams
        // Verify `state`, then exchange `code` for tokens in your backend
        exchangeCodeForToken(code)
    } else if (e.cancelled) {
        Ti.API.info('User cancelled login')
    } else {
        Ti.API.error('Auth failed: ' + e.error)
    }
});

authSession.start()