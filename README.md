# Ti.SafariView

> Native `SFSafariViewController` and `ASWebAuthenticationSession` module for Titanium SDK — iOS only.

Ti.SafariView brings the full power of Safari into your Titanium app. Unlike Titanium's built-in `WebView`, `SFSafariViewController` shares cookies, saved passwords, and AutoFill with the system Safari, supports Reader Mode, Content Blockers, and Safe Browsing — all while keeping user data private from the host app by design.

![Titanium](https://img.shields.io/badge/Titanium-12.0+-red.svg) ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg) ![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg) ![License](https://img.shields.io/badge/license-MIT-green.svg) ![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)

---

## Why SFSafariViewController over WebView?

| Feature | Ti.WebView | Ti.SafariView |
|---|---|---|
| Shared Safari cookies & sessions | ❌ | ✅ |
| AutoFill (passwords, credit cards) | ❌ | ✅ |
| Safari Content Blockers | ❌ | ✅ |
| Reader Mode | ❌ | ✅ |
| Safe Browsing protection | ❌ | ✅ |
| Host app cannot read browsing data | ❌ | ✅ (by design) |
| Native progress bar & controls | ❌ | ✅ |
| OAuth / SSO flows | ❌ | ✅ (via ASWebAuthenticationSession) |
| Opens as a Titanium Window | N/A | ✅ |

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [SafariView](#safariview)
  - [Properties](#properties)
  - [Inherited Window Properties](#inherited-window-properties)
  - [Events](#events)
  - [Presentation Styles](#presentation-styles)
- [AuthSession](#authsession)
  - [Properties](#authsession-properties)
  - [Methods](#authsession-methods)
  - [Events](#authsession-events)
- [Constants](#constants)
- [API Reference](#api-reference)
- [License](#license)

---

## Installation

### 1. Download the Module

Download the latest `.zip` from the [Releases page](https://github.com/deckameron/Ti.SafariView/releases).

### 2. Install in your Titanium project

```bash
# Copy the compiled module to your project:
{YOUR_PROJECT}/modules/iphone/
```

### 3. Configure tiapp.xml

```xml
<modules>
    <module platform="iphone">ti.safariview</module>
</modules>
```

---

## Quick Start

```javascript
const SafariView = require('ti.safariview');

const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredControlTintColor: '#FF3B30',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
});

browser.addEventListener('load', e => {
    Ti.API.info('Loaded successfully: ' + e.success)
});

browser.addEventListener('close', e => {
    Ti.API.info('Closed by user: ' + e.userInitiated)
});

browser.open({ modal: true });
```

---

## SafariView

`SafariView` extends `TiWindowProxy`, which means it behaves like a native Titanium Window. You can open it modally, push it into a navigation stack, or open it inside a tab — using the exact same patterns you already know.

### Properties

#### `url` · String · **required**

The URL to load. Must be a valid `http://` or `https://` URL.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com'
});
```

---

#### `entersReaderIfAvailable` · Boolean · default: `false`

When `true`, Safari will automatically switch to Reader Mode if the page supports it. Ideal for article or blog content.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com/article',
    entersReaderIfAvailable: true,
});
```

---

#### `barCollapsingEnabled` · Boolean · default: `true`

When `true`, the address bar collapses as the user scrolls down, giving more screen space to content.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    barCollapsingEnabled: false, // always visible bar
});
```

---

#### `preferredBarTintColor` · String (hex color)

The background color of Safari's navigation bar. Accepts any hex color string.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredBarTintColor: '#1C1C1E',
});
```

Also supports Titanium's semantic colors for Dark Mode compatibility:

```javascript
preferredBarTintColor: Ti.UI.fetchSemanticColor('backgroundColor'),
```

---

#### `preferredControlTintColor` · String (hex color)

The color of the controls and buttons (back button, Done, share icon) inside Safari's navigation bar.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredControlTintColor: '#FF3B30',
});
```

---

#### `dismissButtonStyle` · Int · default: `DISMISS_BUTTON_STYLE_DONE`

Controls the label of the dismiss button shown in the navigation bar. Use the module constants:

| Constant | Button label |
|---|---|
| `SafariView.DISMISS_BUTTON_STYLE_DONE` | **Done** |
| `SafariView.DISMISS_BUTTON_STYLE_CLOSE` | **Close** |
| `SafariView.DISMISS_BUTTON_STYLE_CANCEL` | **Cancel** |

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
});
```

---

### Inherited Window Properties

Because `SafariView` extends `TiWindowProxy`, all standard Titanium Window properties work natively — no extra configuration needed.

#### `modal` · Boolean

Presents the browser as a modal sheet from the bottom.

```javascript
browser.open({
  modal:  true,
  modalTransitionStyle:  Titanium.UI.iOS.MODAL_TRANSITION_STYLE_COVER_VERTICAL,
  modalStyle:  Ti.UI.iOS.MODAL_PRESENTATION_FORMSHEET
});
```

#### `fullscreen` · Boolean

When `true`, the browser covers the entire screen including the status bar area.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    fullscreen: true,
});
browser.open({ modal: true });
```

#### `navBarHidden` · Boolean

Hides the Titanium navigation bar. Recommended when using `fullscreen: true` to avoid a double navigation bar.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    navBarHidden: true,
    fullscreen: true,
});
```

#### `backgroundColor` · String

The background color visible behind the browser while it loads. Setting this to the same color as `preferredBarTintColor` prevents a flash of white during initialization.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    backgroundColor: '#1C1C1E',
    preferredBarTintColor: '#1C1C1E',
});
```

---

### Events

#### `open`

Fired when the browser window has finished opening.

```javascript
browser.addEventListener('open', () => {
    Ti.API.info('Browser is open');
});
```

---

#### `close`

Fired when the browser window closes — either by the user tapping the dismiss button/swiping down, or programmatically via `browser.close()`.

| Property | Type | Description |
|---|---|---|
| `userInitiated` | Boolean | `true` if the user closed it manually |

```javascript
browser.addEventListener('close', e => {
    if (e.userInitiated) {
        Ti.API.info('User dismissed the browser');
    }
});
```

---

#### `load`

Fired when the initial page load completes (success or failure).

| Property | Type | Description |
|---|---|---|
| `success` | Boolean | `true` if the page loaded successfully |

```javascript
browser.addEventListener('load', e => {
    if (!e.success) {
        Ti.API.error('Page failed to load');
    }
});
```

---

#### `redirect`

Fired when the initial URL redirects to another URL before the page loads.

| Property | Type | Description |
|---|---|---|
| `url` | String | The URL that was redirected to |

```javascript
browser.addEventListener('redirect', e => {
    Ti.API.info('Redirected to: ' + e.url);
});
```

---

### Presentation Styles

Because `SafariView` is a `TiWindowProxy`, you control presentation entirely through standard Titanium APIs — not through module-specific properties.

#### Full Screen (recommended for immersive content)

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    navBarHidden: true,
    backgroundColor: '#000000',
    preferredBarTintColor: '#000000',
    preferredControlTintColor: '#FFFFFF',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_DONE,
});

browser.open({ modal: true });
```

#### Page Sheet (default iOS card style)

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredBarTintColor: '#1C1C1E',
    preferredControlTintColor: '#007AFF',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
});

browser.open({
    modal: true,
    modalTransitionStyle: Ti.UI.iOS.MODAL_TRANSITION_STYLE_COVER_VERTICAL,
    modalStyle: Ti.UI.iOS.MODAL_PRESENTATION_FORMSHEET,
});
```

#### Dark Mode Aware

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredBarTintColor: Ti.UI.fetchSemanticColor('navigationBarColor'),
    preferredControlTintColor: Ti.UI.fetchSemanticColor('accentColor'),
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
});

browser.open({ modal: true });
```

---

## AuthSession

`AuthSession` wraps `ASWebAuthenticationSession` — Apple's secure API for OAuth and SSO flows. It opens a one-time browser session that shares Safari's cookies (so users already logged into Google, Apple, or other providers won't need to log in again), without giving the host app access to the session data.

> ⚠️ **Important:** Keep a strong reference to the `AuthSession` proxy. If it is garbage collected, the session is automatically cancelled.

### AuthSession Properties

#### `url` · String · **required**

The full OAuth/SSO authorization URL, including all query parameters (`client_id`, `redirect_uri`, `scope`, `state`, etc.).

```javascript
const authSession = SafariView.createAuthSession({
    url: 'https://accounts.google.com/o/oauth2/v2/auth?' + [
        'client_id=YOUR_CLIENT_ID',
        'redirect_uri=myapp://oauth/callback',
        'response_type=code',
        'scope=email profile',
        'state=RANDOM_STATE_TOKEN',
    ].join('&'),
});
```

---

#### `callbackURLScheme` · String · **required**

The custom URL scheme your app is registered to handle. This is the scheme part of your `redirect_uri` (e.g. if your redirect URI is `myapp://oauth/callback`, the scheme is `myapp`).

Register the scheme in your `tiapp.xml`:

```xml
<ios>
    <plist>
        <dict>
            <key>CFBundleURLTypes</key>
            <array>
                <dict>
                    <key>CFBundleURLSchemes</key>
                    <array>
                        <string>myapp</string>
                    </array>
                </dict>
            </array>
        </dict>
    </plist>
</ios>
```

```javascript
const authSession = SafariView.createAuthSession({
    url: 'https://...',
    callbackURLScheme: 'myapp',
});
```

---

#### `prefersEphemeralWebBrowserSession` · Boolean · default: `false`

When `false` (default), the session shares cookies with Safari — users already logged in elsewhere won't need to log in again.

When `true`, the session runs in a private/incognito context with no shared cookies. Useful when you want to force a fresh login regardless of existing sessions.

```javascript
const authSession = SafariView.createAuthSession({
    url: 'https://...',
    callbackURLScheme: 'myapp',
    prefersEphemeralWebBrowserSession: true, // force fresh login
});
```

---

### AuthSession Methods

#### `start()`

Starts the authentication session. Displays the browser and begins the flow.

```javascript
authSession.start();
```

---

#### `cancel()`

Cancels the session while it is in progress. Triggers the `complete` event with `cancelled: true`.

```javascript
authSession.cancel();
```

---

### AuthSession Events

#### `complete`

Fired when the session finishes — whether successfully, cancelled by the user, or with an error.

| Property | Type | Description |
|---|---|---|
| `success` | Boolean | `true` if authentication completed successfully |
| `cancelled` | Boolean | `true` if the user dismissed the login screen |
| `callbackURL` | String \| null | The full callback URL returned by the provider |
| `queryParams` | Object | Parsed query parameters from the callback URL (e.g. `{ code, state }`) |
| `error` | String \| null | Error message if the session failed |

```javascript
authSession.addEventListener('complete', e => {
    if (e.success) {
        const { code, state } = e.queryParams
        Ti.API.info('Authorization code: ' + code);
        // Exchange `code` for an access token in your backend
    } else if (e.cancelled) {
        Ti.API.info('User cancelled login');
    } else {
        Ti.API.error('Auth error: ' + e.error);
    }
});
```

---

## Constants

### Dismiss Button Style

Used with the `dismissButtonStyle` property on `SafariView`.

| Constant | Value | Button Label |
|---|---|---|
| `DISMISS_BUTTON_STYLE_DONE` | `0` | Done |
| `DISMISS_BUTTON_STYLE_CLOSE` | `1` | Close |
| `DISMISS_BUTTON_STYLE_CANCEL` | `2` | Cancel |

---

## API Reference

### Module Methods

#### `createSafariView(config)` → `TiSafariviewSafariViewProxy`

Creates a new browser window backed by `SFSafariViewController`. Extends `TiWindowProxy` — open it like any Titanium Window.

**Config options:**

| Property | Type | Default | Required |
|---|---|---|---|
| `url` | String | — | ✅ |
| `entersReaderIfAvailable` | Boolean | `false` | |
| `barCollapsingEnabled` | Boolean | `true` | |
| `preferredBarTintColor` | String | system default | |
| `preferredControlTintColor` | String | system default | |
| `dismissButtonStyle` | Int (constant) | `DISMISS_BUTTON_STYLE_DONE` | |
| + all `Ti.UI.Window` properties | | | |

**Events:** `open`, `close`, `load`, `redirect`

---

#### `createAuthSession(config)` → `TiSafariviewAuthSessionProxy`

Creates a new `ASWebAuthenticationSession` for OAuth and SSO flows.

**Config options:**

| Property | Type | Default | Required |
|---|---|---|---|
| `url` | String | — | ✅ |
| `callbackURLScheme` | String | — | ✅ |
| `prefersEphemeralWebBrowserSession` | Boolean | `false` | |

**Methods:** `start()`, `cancel()`

**Events:** `complete`

---

## Full Example

```javascript
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
})

browser.addEventListener('open',     ()  => Ti.API.info('Browser opened'))
browser.addEventListener('load',      e  => Ti.API.info('Load success: ' + e.success))
browser.addEventListener('redirect',  e  => Ti.API.info('Redirected to: ' + e.url))
browser.addEventListener('close',     e  => Ti.API.info('Closed. User initiated: ' + e.userInitiated))

browser.open({
    modal: true,
    modalTransitionStyle: Ti.UI.iOS.MODAL_TRANSITION_STYLE_COVER_VERTICAL,
    modalStyle: Ti.UI.iOS.MODAL_PRESENTATION_FORMSHEET,
})


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
})

fullscreenBrowser.open({ modal: true })


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
})

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
})

authSession.start()
```

---

## Requirements

- Titanium SDK 12.0+
- iOS 15.0+
- Xcode 14+

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
