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
| Custom floating action button | ❌ | ✅ |
| OAuth / SSO flows | ❌ | ✅ (via ASWebAuthenticationSession) |

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [SafariView](#safariview)
  - [Properties](#properties)
  - [Methods](#methods)
  - [Events](#events)
  - [Presentation Styles](#presentation-styles)
  - [Activity Button](#activity-button)
- [AuthSession](#authsession)
  - [Properties](#authsession-properties)
  - [Methods](#authsession-methods)
  - [Events](#authsession-events)
- [Constants](#constants)
- [API Reference](#api-reference)
- [Full Example](#full-example)
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
const SafariView = require('ti.safariview')

const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredControlTintColor: '#FF3B30',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
})

browser.addEventListener('load', e => {
    Ti.API.info('Loaded successfully: ' + e.success)
})

browser.addEventListener('close', e => {
    Ti.API.info('Closed by user: ' + e.userInitiated)
})

browser.open()
```

---

## SafariView

### Properties

#### `url` · String · **required**

The URL to load. Must be a valid `http://` or `https://` URL.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com'
})
```

---

#### `entersReaderIfAvailable` · Boolean · default: `false`

When `true`, Safari will automatically switch to Reader Mode if the page supports it. Ideal for article or blog content.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com/article',
    entersReaderIfAvailable: true,
})
```

---

#### `barCollapsingEnabled` · Boolean · default: `true`

When `true`, the address bar and toolbar collapse as the user scrolls down, giving more screen space to content.

> ⚠️ **Only works with `MODAL_PRESENTATION_FULL_SCREEN`** (the default) and `MODAL_PRESENTATION_CURRENT_CONTEXT`** . In Page Sheet and Form Sheet the content does not fill the entire screen, so iOS disables bar collapsing automatically.

> ⚠️ **Disable when using `activityButton`**. Since there is no event for when bars collapse, the floating button would remain visible while the bars are hidden. Set `barCollapsingEnabled: false` whenever an `activityButton` is present.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    barCollapsingEnabled: true, // only effective with MODAL_PRESENTATION_FULL_SCREEN
})
```

---

#### `preferredBarTintColor` · String (hex color)

The background color of Safari's navigation bar and toolbar. Accepts any hex color string.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredBarTintColor: '#1C1C1E',
})
```

Also supports Titanium's semantic colors for Dark Mode compatibility:

```javascript
preferredBarTintColor: Ti.UI.fetchSemanticColor('navigationBarColor'),
```

---

#### `preferredControlTintColor` · String (hex color)

The color of the controls and buttons (back, Done, share icon) inside Safari's navigation bar.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    preferredControlTintColor: '#FF3B30',
})
```

---

#### `dismissButtonStyle` · Int · default: `DISMISS_BUTTON_STYLE_DONE`

Controls the label of the dismiss button. Use the module constants.

| Constant | Button label | Best for |
|---|---|---|
| `DISMISS_BUTTON_STYLE_DONE` | **Done** | General browsing |
| `DISMISS_BUTTON_STYLE_CLOSE` | **Close** | Articles, content |
| `DISMISS_BUTTON_STYLE_CANCEL` | **Cancel** | Flows with clear intent (login, checkout) |

> ⚠️ Apple does not allow customizing the dismiss button icon or using SF Symbols. Only these three are available.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
})
```

---

#### `modalPresentationStyle` · Int · default: `MODAL_PRESENTATION_FULL_SCREEN`

Controls how the browser is presented on screen. Use the module constants. See [Presentation Styles](#presentation-styles) for a full comparison.

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    modalPresentationStyle: SafariView.MODAL_PRESENTATION_PAGE_SHEET,
})
```

---

#### `activityButton` · TiViewProxy

A native Titanium view (typically a `Ti.UI.Button`) that floats on top of the browser. Use the standard `left`, `right`, `top`, `bottom`, `width`, and `height` layout properties directly on the view proxy to control its position — they are read and translated to Auto Layout constraints automatically.

See [Activity Button](#activity-button) for full usage.

---

### Methods

#### `open()`

Opens the browser.

```javascript
browser.open()
```

---

#### `close()`

Closes the browser programmatically.

```javascript
browser.close()
```

---

### Events

#### `open`

Fired when the browser has finished opening.

```javascript
browser.addEventListener('open', () => {
    Ti.API.info('Browser is open')
})
```

---

#### `close`

Fired when the browser closes — either by the user tapping the dismiss button/swiping down, or programmatically via `browser.close()`.

| Property | Type | Description |
|---|---|---|
| `userInitiated` | Boolean | `true` if the user closed it manually |

```javascript
browser.addEventListener('close', e => {
    if (e.userInitiated) {
        Ti.API.info('User dismissed the browser')
    }
})
```

---

#### `load`

Fired when the initial page load completes.

| Property | Type | Description |
|---|---|---|
| `success` | Boolean | `true` if the page loaded successfully |

```javascript
browser.addEventListener('load', e => {
    if (!e.success) {
        Ti.API.error('Page failed to load')
    }
})
```

---

#### `redirect`

Fired when the initial URL redirects to another URL before the page loads.

| Property | Type | Description |
|---|---|---|
| `url` | String | The URL that was redirected to |

```javascript
browser.addEventListener('redirect', e => {
    Ti.API.info('Redirected to: ' + e.url)
})
```

---

### Presentation Styles

The `modalPresentationStyle` property controls how the browser appears on screen.

| Constant | Value | Swipe to close | barCollapsingEnabled |
|---|---|---|---|
| `MODAL_PRESENTATION_FULL_SCREEN` | `0` | ❌ | ✅ |
| `MODAL_PRESENTATION_PAGE_SHEET` | `1` | ✅ | ❌ |
| `MODAL_PRESENTATION_FORM_SHEET` | `2` | ✅ | ❌ |
| `MODAL_PRESENTATION_CURRENT_CONTEXT` | `3` | Depends on parent | ❌ |
| `MODAL_PRESENTATION_OVER_FULL_SCREEN` | `5` | ❌ | ✅ |
| `MODAL_PRESENTATION_OVER_CURRENT_CONTEXT` | `6` | Depends on parent | ❌ |

**`FULL_SCREEN` vs `OVER_FULL_SCREEN`:** Both cover the entire screen. The difference is that `OVER_FULL_SCREEN` keeps the parent view controller in memory and visible underneath (useful for transparent backgrounds), while `FULL_SCREEN` deallocates it.

**`CURRENT_CONTEXT` vs `OVER_CURRENT_CONTEXT`:** Same difference — `OVER_CURRENT_CONTEXT` keeps the parent VC in memory, `CURRENT_CONTEXT` does not.

#### Full Screen (default)

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    // MODAL_PRESENTATION_FULL_SCREEN is the default — no need to set
    barCollapsingEnabled: true,
    preferredBarTintColor: '#000000',
    preferredControlTintColor: '#FFFFFF',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_DONE,
})
browser.open()
```

#### Page Sheet (iOS card style)

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    modalPresentationStyle: SafariView.MODAL_PRESENTATION_PAGE_SHEET,
    preferredBarTintColor: '#1C1C1E',
    preferredControlTintColor: '#FF3B30',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
})
browser.open()
```

#### Dark Mode Aware

```javascript
const browser = SafariView.createSafariView({
    url: 'https://example.com',
    modalPresentationStyle: SafariView.MODAL_PRESENTATION_PAGE_SHEET,
    preferredBarTintColor: Ti.UI.fetchSemanticColor('navigationBarColor'),
    preferredControlTintColor: Ti.UI.fetchSemanticColor('accentColor'),
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
})
browser.open()
```

---

### Activity Button

You can place any Titanium view on top of the browser as a floating action button. This is useful for features like bookmarking, sharing, or any custom action.

The button **always bookmarks or acts on the initial URL** passed to `createSafariView` — not the URL the user may have navigated to internally. This is by design: `SFSafariViewController` does not expose the current URL to the host app to protect user privacy.

Use standard Titanium layout properties (`left`, `right`, `top`, `bottom`, `width`, `height`) on the button proxy to control its position. The button is anchored to the safe area, so `bottom: 20` correctly accounts for the home indicator on all iPhone models.

> ⚠️ Set `barCollapsingEnabled: false` when using `activityButton`. There is no event for when the bars collapse, so the button would remain visible while the bars are hidden.

```javascript
const bookmarkBtn = Ti.UI.createButton({
    image: '/images/bookmark.png',
    width: 52,
    height: 52,
    bottom: 20,
    right: 20,
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderRadius: 26,
})

bookmarkBtn.addEventListener('click', () => {
    saveBookmark(browser.url) // browser.url = the initial URL
    bookmarkBtn.image = '/images/bookmark_filled.png'
})

const browser = SafariView.createSafariView({
    url: 'https://example.com',
    barCollapsingEnabled: false, // ← required when activityButton is set
    preferredControlTintColor: '#FF3B30',
    activityButton: bookmarkBtn,
})

browser.open()
```

---

## AuthSession

`AuthSession` wraps `ASWebAuthenticationSession` — Apple's secure API for OAuth and SSO flows. It opens a one-time browser session that shares Safari's cookies (so users already logged into Google, Apple, or other providers won't need to log in again), without giving the host app access to the session data.

> ⚠️ **Keep a strong reference** to the `AuthSession` proxy. If it is garbage collected, the session is automatically cancelled.

### AuthSession Properties

#### `url` · String · **required**

The full OAuth/SSO authorization URL, including all query parameters.

```javascript
const authSession = SafariView.createAuthSession({
    url: 'https://accounts.google.com/o/oauth2/v2/auth?' + [
        'client_id=YOUR_CLIENT_ID',
        'redirect_uri=myapp://oauth/callback',
        'response_type=code',
        'scope=email profile',
        'state=RANDOM_STATE_TOKEN',
    ].join('&'),
})
```

---

#### `callbackURLScheme` · String · **required**

The custom URL scheme your app is registered to handle. Register it in `tiapp.xml`:

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
})
```

---

#### `prefersEphemeralWebBrowserSession` · Boolean · default: `false`

When `false` (default), the session shares cookies with Safari — users already logged in won't need to log in again.

When `true`, the session runs in a private context with no shared cookies, forcing a fresh login regardless of existing sessions.

```javascript
const authSession = SafariView.createAuthSession({
    url: 'https://...',
    callbackURLScheme: 'myapp',
    prefersEphemeralWebBrowserSession: true,
})
```

---

### AuthSession Methods

#### `start()`

Starts the authentication session.

```javascript
authSession.start()
```

#### `cancel()`

Cancels the session while in progress. Triggers the `complete` event with `cancelled: true`.

```javascript
authSession.cancel()
```

---

### AuthSession Events

#### `complete`

Fired when the session finishes — successfully, cancelled, or with an error.

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
        // Verify `state`, then exchange `code` for tokens in your backend
        exchangeCodeForToken(code)
    } else if (e.cancelled) {
        Ti.API.info('User cancelled login')
    } else {
        Ti.API.error('Auth error: ' + e.error)
    }
})
```

---

## Constants

### Dismiss Button Style

| Constant | Value | Button label |
|---|---|---|
| `DISMISS_BUTTON_STYLE_DONE` | `0` | Done |
| `DISMISS_BUTTON_STYLE_CLOSE` | `1` | Close |
| `DISMISS_BUTTON_STYLE_CANCEL` | `2` | Cancel |

### Modal Presentation Style

| Constant | Value |
|---|---|
| `MODAL_PRESENTATION_FULL_SCREEN` | `0` |
| `MODAL_PRESENTATION_PAGE_SHEET` | `1` |
| `MODAL_PRESENTATION_FORM_SHEET` | `2` |
| `MODAL_PRESENTATION_CURRENT_CONTEXT` | `3` |
| `MODAL_PRESENTATION_OVER_FULL_SCREEN` | `5` |
| `MODAL_PRESENTATION_OVER_CURRENT_CONTEXT` | `6` |

---

## API Reference

### `createSafariView(config)` → `TiSafariviewSafariViewProxy`

| Property | Type | Default | Required |
|---|---|---|---|
| `url` | String | — | ✅ |
| `entersReaderIfAvailable` | Boolean | `false` | |
| `barCollapsingEnabled` | Boolean | `true` | |
| `preferredBarTintColor` | String | system default | |
| `preferredControlTintColor` | String | system default | |
| `dismissButtonStyle` | Int (constant) | `DISMISS_BUTTON_STYLE_DONE` | |
| `modalPresentationStyle` | Int (constant) | `MODAL_PRESENTATION_FULL_SCREEN` | |
| `activityButton` | TiViewProxy | — | |

**Methods:** `open()`, `close()`

**Events:** `open`, `close { userInitiated }`, `load { success }`, `redirect { url }`

---

### `createAuthSession(config)` → `TiSafariviewAuthSessionProxy`

| Property | Type | Default | Required |
|---|---|---|---|
| `url` | String | — | ✅ |
| `callbackURLScheme` | String | — | ✅ |
| `prefersEphemeralWebBrowserSession` | Boolean | `false` | |

**Methods:** `start()`, `cancel()`

**Events:** `complete { success, cancelled, callbackURL, queryParams, error }`

---

## Full Example

```javascript
const SafariView = require('ti.safariview')

// ─────────────────────────────────────────────
// Example 1: Full screen browser with bookmark button
// ─────────────────────────────────────────────

const bookmarkBtn = Ti.UI.createButton({
    image: '/images/bookmark.png',
    width: 52,
    height: 52,
    bottom: 20,
    right: 20,
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderRadius: 26,
})

bookmarkBtn.addEventListener('click', () => {
    saveBookmark(browser.url)
    bookmarkBtn.image = '/images/bookmark_filled.png'
})

const browser = SafariView.createSafariView({
    url: 'https://example.com',
    entersReaderIfAvailable: false,
    barCollapsingEnabled: false,      // ← required when activityButton is set
    preferredBarTintColor: Ti.UI.fetchSemanticColor('navigationBarColor'),
    preferredControlTintColor: '#FF3B30',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
    activityButton: bookmarkBtn,
})

browser.addEventListener('open', ()  => Ti.API.info('Browser opened'))
browser.addEventListener('load', e  => Ti.API.info('Load success: ' + e.success))
browser.addEventListener('redirect', e  => Ti.API.info('Redirected to: ' + e.url))
browser.addEventListener('close', e  => Ti.API.info('Closed. User initiated: ' + e.userInitiated))

browser.open()


// ─────────────────────────────────────────────
// Example 2: Page Sheet (swipe to dismiss)
// ─────────────────────────────────────────────

const sheet = SafariView.createSafariView({
    url: 'https://example.com',
    modalPresentationStyle: SafariView.MODAL_PRESENTATION_PAGE_SHEET,
    preferredBarTintColor: '#1C1C1E',
    preferredControlTintColor: '#007AFF',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_CLOSE,
})

sheet.open()


// ─────────────────────────────────────────────
// Example 3: Full screen with bar collapsing
// ─────────────────────────────────────────────

const fullscreen = SafariView.createSafariView({
    url: 'https://example.com/article',
    entersReaderIfAvailable: true,
    barCollapsingEnabled: true,       // works because default is FULL_SCREEN
    preferredBarTintColor: '#000000',
    preferredControlTintColor: '#FFFFFF',
    dismissButtonStyle: SafariView.DISMISS_BUTTON_STYLE_DONE,
})

fullscreen.open()


// ─────────────────────────────────────────────
// Example 4: Google OAuth flow
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

## Known Limitations

- **Bar collapsing event**: There is no delegate callback for when bars collapse/expand. This is intentional — iOS manages it internally.
- **Current URL**: The host app cannot read the URL the user is currently viewing. `SFSafariViewController` only exposes the initial URL and redirect events, by design.
- **Dismiss button**: Only three text labels are available (`Done`, `Close`, `Cancel`). SF Symbols or custom icons are not supported by Apple.
- **Bar collapsing + activityButton**: Use `barCollapsingEnabled: false` whenever an `activityButton` is present, since the button cannot respond to bar collapse events.
- **Android**: This module is iOS only. For Android, consider using Chrome Custom Tabs.

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
