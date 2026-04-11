import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    optionsUrl: String,
    authenticateUrl: String
  }

  async connect() {
    this.element.addEventListener("click", this.authenticate.bind(this))
  }

  async authenticate(event) {
    event.preventDefault()
    try {
      const optionsResponse = await fetch(this.optionsUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Content-Type": "application/json"
        }
      })
      const options = await optionsResponse.json()

      options.challenge = this._base64urlToBuffer(options.challenge)
      if (options.allowCredentials) {
        options.allowCredentials = options.allowCredentials.map(c => ({
          ...c,
          id: this._base64urlToBuffer(c.id)
        }))
      }

      const assertion = await navigator.credentials.get({ publicKey: options })

      const assertionJson = {
        id: assertion.id,
        rawId: this._bufferToBase64url(assertion.rawId),
        type: assertion.type,
        response: {
          authenticatorData: this._bufferToBase64url(assertion.response.authenticatorData),
          clientDataJSON: this._bufferToBase64url(assertion.response.clientDataJSON),
          signature: this._bufferToBase64url(assertion.response.signature),
          userHandle: assertion.response.userHandle ? this._bufferToBase64url(assertion.response.userHandle) : null
        }
      }

      const authResponse = await fetch(this.authenticateUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Content-Type": "application/json"
        },
        body: JSON.stringify(assertionJson)
      })

      const result = await authResponse.json()
      if (result.status === "ok") {
        const redirectUrl = new URL(result.redirect_url, window.location.href)
        if (redirectUrl.origin === window.location.origin) {
          window.location.href = redirectUrl.href
        } else {
          window.location.href = "/"
        }
      } else {
        alert("Passkey sign-in failed: " + result.error)
      }
    } catch (err) {
      alert("Passkey sign-in failed: " + err.message)
    }
  }

  _base64urlToBuffer(base64url) {
    const padding = "=".repeat((4 - base64url.length % 4) % 4)
    const base64 = (base64url + padding).replace(/-/g, "+").replace(/_/g, "/")
    const binary = window.atob(base64)
    const buffer = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) {
      buffer[i] = binary.charCodeAt(i)
    }
    return buffer.buffer
  }

  _bufferToBase64url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ""
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    return window.btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "")
  }
}
