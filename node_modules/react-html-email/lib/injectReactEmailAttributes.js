'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.emailAttributes = undefined;
exports.default = injectReactEmailAttributes;

var _ReactInjection = require('react/lib/ReactInjection');

var emailAttributes = exports.emailAttributes = {
  Properties: {
    'xmlns': _ReactInjection.DOMProperty.MUST_USE_ATTRIBUTE,
    'align': _ReactInjection.DOMProperty.MUST_USE_ATTRIBUTE,
    'valign': _ReactInjection.DOMProperty.MUST_USE_ATTRIBUTE,
    'bgcolor': _ReactInjection.DOMProperty.MUST_USE_ATTRIBUTE
  }
};

var injected = false;

function injectReactEmailAttributes() {
  if (injected) {
    return;
  }

  // make React accept some HTML attributes useful to emails
  _ReactInjection.DOMProperty.injectDOMPropertyConfig(emailAttributes);

  injected = true;
}