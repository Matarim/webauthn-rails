credentials_controller.js

function getCSRFToken() {
  var CSRFSelector = document.querySelector('meta[name="csrf-token"]')
  if (CSRFSelector) {
    return CSRFSelector.getAttribute("content")
  } else {
    return null
  }
}

function displayError(message) {
  const ele = document.querySelector('#message-box');
  const event = new CustomEvent('msg', { detail: { message: message}});
  ele.dispatchEvent(event);
}

function callback(original_url, callback_url, body) {
  fetch(encodeURI(callback_url), {
    method: "POST",
    body: JSON.stringify(body),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": getCSRFToken()
    },
    credentials: 'same-origin'
  }).then(function(response) {
    if (response.ok) {
      window.location.replace(encodeURI(original_url))
    } else if (response.status < 500) {
      response.text().then((text) => { displayError(text) });
    } else {
      console.log('Fail Callback.');
    }
  });
}

function create(data) {
  const { original_url, callback_url, create_options } = data
  const options = WebAuthnJSON.parseCreationOptionsFromJSON({ "publicKey": create_options })
  WebAuthnJSON.create(options).then((credentials) => {
    callback(original_url, callback_url, credentials);
  }).catch(function(error) {
    console.log("credential: Creation Error.");
  });
}

function get(data) {
  const { original_url, callback_url, get_options } = data
  const options = WebAuthnJSON.parseRequestOptionsFromJSON({ "publicKey": get_options })
  WebAuthnJSON.get(options).then((credentials) => {
    callback(original_url, callback_url, credentials);
  }).catch(function(error) {
    console.log("credential: Get Credential Error.");
  });
}

export { create, get, displayError }
