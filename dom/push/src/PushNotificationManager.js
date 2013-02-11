/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

"use strict";

const DEBUG = true;
function debug(s) { dump("-*- PushNotificationManager: " + s + "\n"); }

const {classes: Cc, interfaces: Ci, utils: Cu, results: Cr} = Components;

Cu.import("resource://gre/modules/XPCOMUtils.jsm");
Cu.import("resource://gre/modules/Services.jsm");
Cu.import("resource://gre/modules/DOMRequestHelper.jsm");
Cu.import("resource://gre/modules/ObjectWrapper.jsm");

XPCOMUtils.defineLazyServiceGetter(this, "cpmm",
                                   "@mozilla.org/childprocessmessagemanager;1",
                                   "nsISyncMessageSender");


// PushNotificationManager
const nsIClassInfo                       = Ci.nsIClassInfo;
const PUSHNOTIFICATIONMANAGER_CONTRACTID = "@mozilla.org/pushnotificationmanager;1";
const PUSHNOTIFICATIONMANAGER_CID        = Components.ID("{af1ab247-9048-4794-8809-006230f7a354}");
const nsIDOMPushNotificationManager      = Components.interfaces.nsIDOMPushNotificationManager;

function PushNotificationManager() {
  if (DEBUG) {
    debug("Constructor");
  }
}

PushNotificationManager.prototype = {
  __proto__: DOMRequestIpcHelper.prototype,

  checkPrivileges: function checkPrivileges() {
    if (!this.hasPrivileges) {
      throw Cr.NS_ERROR_NOT_IMPLEMENTED;
   }

    if (!this.isApp) {
      throw Cr.NS_ERROR_FAILURE;
    }
  },

  setup: function setup(aOptions) {
    if (DEBUG) debug("Setup");

    this.checkPrivileges();

    return cpmm.sendSyncMessage("PushNotification:Setup", {options: aOptions})[0];
  },

  getSetup: function getSetup() {
    if (DEBUG) debug("getSetup");

    this.checkPrivileges();

    return ObjectWrapper.wrap(cpmm.sendSyncMessage("PushNotification:GetSetup")[0], this._window);
  }, 

  requestRemotePermission: function requestRemotePermission(token, pubkey) {
    if (DEBUG) debug("requestURL");

    this.checkPrivileges();

    let request = this.createRequest();
    cpmm.sendAsyncMessage("PushNotification:GetURL",
                          {id: this.getRequestId(request), manifestURL: this.manifestURL,
                           pageURL: this.pageURL, watoken: token, pubkey: pubkey});

    return request;
  },

  revokeRemotePermission: function revokeRemotePermission() {
    if (DEBUG) debug("revokeURL");

    this.checkPrivileges();

    let request = this.createRequest();
    cpmm.sendAsyncMessage("PushNotification:RevokeURL",
                          {id: this.getRequestId(request), manifestURL: this.manifestURL});
    return request;
  },

  unregisterUA: function unregisterUA() {
    if (DEBUG) debug("unregisterUA");

    this.checkPrivileges();

    let request = this.createRequest();
    cpmm.sendAsyncMessage("PushNotification:UnregisterUA",
                          {id: this.getRequestId(request)});
    return request;
  },

  unregisterApp: function unregisterApp(manifestURL) {
    if (DEBUG) debug("unregisterApp: " + manifestURL);

    this.checkPrivileges();

    let request = this.createRequest();
    cpmm.sendAsyncMessage("PushNotification:UnregisterApp",
                          {id: this.getRequestId(request), manifestURL: manifestURL});

    return request;
  },

  getRegisteredApps: function getRegisteredApps() {
    if (DEBUG) debug("rgetRegisteredApps");

    this.checkPrivileges();

    let request = this.createRequest();
    cpmm.sendAsyncMessage("PushNotification:GetApps",
                          {id: this.getRequestId(request)});

    return request;
  },

  receiveMessage: function(aMessage) {
    if (DEBUG) {
      debug("PushNotificationmanager::receiveMessage: " + aMessage.name);
    }
    let msg = aMessage.json;

    let req = this.takeRequest(msg.id);
    if (!req) {
      if (DEBUG) {
        debug("No request stored with id " + msg.id);
      }
      return;
    }

    switch (aMessage.name) {
      case "PushNotification:GetURL:Return":
      case "PushNotification:RevokeURL:Return":
      case "PushNotification:UnregisterApp:Return":
      case "PushNotification:UnregisterUA:Return":
        if (msg.error) {
          Services.DOMRequest.fireError(req, msg.error);
          return;
        }

        let result = msg.result;
        if (DEBUG) {
          debug("result: " + JSON.stringify(result));
        }
        Services.DOMRequest.fireSuccess(req, result);
        break;
      case "PushNotification:GetApps:Return":
        if (msg.error) {
          Services.DOMRequest.fireError(req, msg.error);
          return;
        }

        let res = msg.result;
        if (DEBUG) {
          debug("result: " + JSON.stringify(res));
        }
        Services.DOMRequest.fireSuccess(req, ObjectWrapper.wrap(res, this._window));
        break;
      default:
        if (DEBUG) {
          debug("Wrong message: " + aMessage.name);
        }
    }
  },


  init: function(aWindow) {
    // Set navigator.mozPush to null.
//    if (!Services.prefs.getBoolPref("dom.mozPush.enabled")) {
//      return null;
//    }
    this.initHelper(aWindow, ["PushNotification:GetURL:Return",
                              "PushNotification:RevokeURL:Return",
                              "PushNotification:GetApps:Return",
                              "PuahNotification:UnregisterApp:Return"]);

    let principal = aWindow.document.nodePrincipal;
    let secMan = Services.scriptSecurityManager;
    let perm = principal == secMan.getSystemPrincipal() ?
                 Ci.nsIPermissionManager.ALLOW_ACTION :
                 Services.perms.testExactPermissionFromPrincipal(principal,
                                                                 "request-push-notification");

    // hardcode perm
    perm = Ci.nsIPermissionManager.ALLOW_ACTION;

    // Only pages with perm set can use the netstats.
    this.hasPrivileges = perm == Ci.nsIPermissionManager.ALLOW_ACTION;
    if (DEBUG) {
      debug("has privileges: " + this.hasPrivileges);
    }

    // init app properties
    let appsService = Cc["@mozilla.org/AppsService;1"]
                        .getService(Ci.nsIAppsService);

    this.manifestURL = appsService.getManifestURLByLocalId(principal.appId);

    this.isApp = !(this.manifestURL.length == 0);
    if (this.isApp) {
      this.pageURL = principal.URI.spec;
    }
  },

  // Called from DOMRequestIpcHelper
  uninit: function uninit() {
    if (DEBUG) {
      debug("uninit call");
    }
  },

  classID : PUSHNOTIFICATIONMANAGER_CID,
  QueryInterface : XPCOMUtils.generateQI([nsIDOMPushNotificationManager,
                                         Ci.nsIDOMGlobalPropertyInitializer]),

  classInfo : XPCOMUtils.generateCI({classID: PUSHNOTIFICATIONMANAGER_CID,
                                     contractID: PUSHNOTIFICATIONMANAGER_CONTRACTID,
                                     classDescription: "PushNotificationManager",
                                     interfaces: [nsIDOMPushNotificationManager],
                                     flags: nsIClassInfo.DOM_OBJECT})
}

this.NSGetFactory = XPCOMUtils.generateNSGetFactory([PushNotificationManager])
