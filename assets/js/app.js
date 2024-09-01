// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import { Elm } from "../src/Main.elm";
/*      window.addEventListener("scroll", function() {
          let menuArea = document.getElementById("menu-area");
          if(window.pageYOffset > 0) {
              menuArea.classList.add("navbar_sticky");
          } else {
              menuArea.classList.remove("navbar_sticky");
          }
      });
      */


customElements.define('intl-date',
    class extends HTMLElement {
        // things required by Custom Elements
        constructor() { 
            super(); 

        }
        connectedCallback() {
            (function(d, src, c) { var t=d.scripts[d.scripts.length - 1],s=d.createElement('script');s.id='la_x2s6df8d';s.async=true;s.src=src;s.onload=s.onreadystatechange=function(){var rs=this.readyState;if(rs&&(rs!='complete')&&(rs!='loaded')){return;}c(this);};t.parentElement.insertBefore(s,t.nextSibling);})(document,
'https://greekcoin.ladesk.com/scripts/track.js',
function(e){ LiveAgent.createButton('ngkt511x', document.getElementById("chatButton")); });
        }
        attributeChangedCallback() { }
    }
);

      window.onloadCallback = () => {       

      var storageKey = "store";
      var flags = localStorage.getItem(storageKey);
 
          var app = Elm.Main.init({
            //node: document.getElementById('elm'),
            flags: flags
           });


      app.ports.renderCaptcha.subscribe(function(val){
          window.requestAnimationFrame(() => {
              recaptcha = grecaptcha.render(val, {
                sitekey: '6LcFecIUAAAAANK6DvbwjV6YlhnE5dpYyRzebX5P',
                callback: app.ports.setRecaptchaToken.send
              });
            });

      });

      app.ports.resetCaptcha.subscribe(function(val){
          window.requestAnimationFrame(() => {
              recaptcha = grecaptcha.reset();
            });

      });

       app.ports.renderCaptchaProfile.subscribe(function(val){
          window.requestAnimationFrame(() => {
              recaptcha = grecaptcha.render(val, {
                sitekey: '6LcFecIUAAAAANK6DvbwjV6YlhnE5dpYyRzebX5P',
                callback: app.ports.setRecaptchaTokenProfile.send
              });
            });

      });

      app.ports.storeCache.subscribe(function(val) {

        if (val === null) {
          localStorage.removeItem(storageKey);
        } else {
          localStorage.setItem(storageKey, JSON.stringify(val));
        }
        
        // Report that the new session was stored succesfully.
        setTimeout(function() { app.ports.onStoreChange.send(val); }, 0);
      });


      app.ports.scrolUp.subscribe(function(data){
            window.scrollTo(0, 0);
        });

      app.ports.send.subscribe(function(data) {
        let socket = new WebSocket("wss://ws.kraken.com");
        
        socket.onopen = function(e) {
          var myJSON = JSON.stringify(data);
          socket.send(myJSON)
        }
        
        socket.onmessage = function(event) {
            app.ports.receive.send(JSON.parse(event.data));
        };
      });
      var x = 0;

      app.ports.sendReq2.subscribe(function(data) {
        let socket = new WebSocket("wss://ws.kraken.com");
        if(x==0){ 
          socket.onopen = function(e) {
            var myJSON = JSON.stringify(data);
            socket.send(myJSON)
          }
        
          socket.onmessage = function(event) {
            app.ports.receiveVal.send(JSON.parse(event.data));
            app.ports.receiveValHome.send(JSON.parse(event.data));
          };
            x++;
        }else { console.log("Denied") }
        });

      app.ports.sendReq.subscribe(function(data) {
        let socket = new WebSocket("wss://ws.kraken.com");
        if(x==0) { 
          socket.onopen = function(e) {
            var myJSON = JSON.stringify(data);
            socket.send(myJSON)
          }
        
          socket.onmessage = function(event) {
              app.ports.receiveVal.send(JSON.parse(event.data));
              app.ports.receiveValHome.send(JSON.parse(event.data));
          };
            x++;
        } else {console.log("Denied")}
      });

      // Whenever localStorage changes in another tab, report it if necessary.
      window.addEventListener("storage", function(event) {
        if (event.storageArea === localStorage && event.key === storageKey) {
          app.ports.onStoreChange.send(event.newValue);
        }
      }, false);

     customElements.define('captch-node', class extends HTMLElement {
       connectedCallback(){

            window.requestAnimationFrame(() => {
              recaptcha = grecaptcha.render("recaptcha", {
                sitekey: '6LcFecIUAAAAANK6DvbwjV6YlhnE5dpYyRzebX5P',
                callback: app.ports.setRecaptchaToken.send
              });
            });
       }
     })     
 }

