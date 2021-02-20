import "../css/app.scss"
import "../node_modules/signature_pad/dist/signature_pad.min.js";

import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

var canvas = document.querySelector("#drawing_pad");
var signaturePad = new SignaturePad(canvas, {minWidth: 3, backgroundColor: "rgb(0, 0, 0)", penColor: "white"});

// Returns signature image as data URL (see https://mdn.io/todataurl for the list of possible parameters)
signaturePad.toDataURL(); // save image as PNG
signaturePad.toDataURL("image/png"); // save image as JPEG

// Clears the canvas
signaturePad.clear();

let Hooks = {}
Hooks.OnCanvasClear = {
  mounted(){
    this.handleEvent("clear_canvas", () => signaturePad.clear());
    this.handleEvent("save_canvas", () => {
      const data = signaturePad.toDataURL('image/png');
      this.pushEvent("send_image", { image_data: data });
      signaturePad.clear();
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// connect if there are any LiveViews on the page
liveSocket.connect()
