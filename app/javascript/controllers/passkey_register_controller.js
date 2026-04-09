import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    optionsUrl: String
  }

  async connect() {
    this.element.addEventListener("click", this.register.bind(this))
  }

  async register(event) {
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
      options.user.id = this._base64urlToBuffer(options.user.id)
      if (options.excludeCredentials) {
        options.excludeCredentials = options.excludeCredentials.map(c => ({
          ...c,
          id: this._base64urlToBuffer(c.id)
        }))
      }

      const credential = await navigator.credentials.create({ publicKey: options })

      const credentialJson = {
        id: credential.id,
        rawId: this._bufferToBase64url(credential.rawId),
        type: credential.type,
        response: {
          attestationObject: this._bufferToBase64url(credential.response.attestationObject),
          clientDataJSON: this._bufferToBase64url(credential.response.clientDataJSON)
        },
        nickname: "Passkey"
      }

      const createResponse = await fetch("/webauthn_credentials", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Content-Type": "application/json"
        },
        body: JSON.stringify(credentialJson)
      })

      const result = await createResponse.json()
      if (result.status === "ok") {
        window.location.reload()
      } else {
        alert("Passkey registration failed: " + result.error)
      }
    } catch (err) {
      alert("Passkey registration failed: " + err.message)
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
