import { Controller } from "@hotwired/stimulus"
import * as Credential from "credential";

export default class extends Controller {
  
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
        if (data.create_options.user) {
          Credential.create(data);
        }
      });
    }
    
    function err(response) {
      console.log("Create Credential Failed.");
    }
  }
}
