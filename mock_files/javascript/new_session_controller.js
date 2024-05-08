import { Controller } from "@hotwired/stimulus"
import * as Credential from "credential";

export default class extends Controller {
  static targets = [ "password", "webauthn", "default" ]
  static values = {
    callback: String,
    webauthn: String
  }

  connect() {
    this.webauthn = true

    let banner = document.querySelector(".browser-supported")
    if (window.PublicKeyCredential) {
      PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()
          .then((available) => {
            if (!available) {
              banner.classList.remove("d-none")
            }
          })
          .catch((err) => console.log("Something went wrong."));
    }
  }

  submit(event) {
    event.preventDefault();
    
    const headers = new Headers();
    const action = event.target.action;
    const options = {
      method: event.target.method,
      headers: headers,
      body: new FormData(event.target)
    };
    
    fetch(action, options).then((response) => {
      if (response.ok) {
        ok(response);
      } else {
        err(response);
      }
    });
    
    function ok(response) {
      response.json().then((data) => {
        Credential.get(data);
      }).catch(function(error) {
        location.reload();
      });
    }
    
    function err(response) {
      response.json().then((json) => {
        const message = response.statusText + " - " + json.errors.join(" ");
        console.log("Use Auth For Login Failed.")
        Credential.displayError(message);
      }).catch(function(error) {
        location.reload();
      });
    }
  }

  toggle(event) {
    event.preventDefault()
    this.passwordTarget.classList.toggle("hidden")
    this.defaultTarget.classList.toggle("hidden")
    this.webauthnTarget.classList.toggle("hidden")

    if(this.webauthn) {
      this.element.setAttribute("data-remote", true)
      this.element.setAttribute("data-turbo", false)
      this.element.setAttribute("action", this.callbackValue)
    } else {
      this.element.setAttribute("data-remote", false)
      this.element.setAttribute("data-turbo", true)
      this.element.setAttribute("action", this.callbackValue)
    }

    this.webauthn = !this.webauthn
  }
}
