var vs = { exports: {} }, wl = {}, ys = { exports: {} }, ye = {};
/**
 * @license React
 * react.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
var Ja;
function vd() {
  if (Ja) return ye;
  Ja = 1;
  var u = Symbol.for("react.element"), y = Symbol.for("react.portal"), f = Symbol.for("react.fragment"), x = Symbol.for("react.strict_mode"), _ = Symbol.for("react.profiler"), S = Symbol.for("react.provider"), F = Symbol.for("react.context"), V = Symbol.for("react.forward_ref"), P = Symbol.for("react.suspense"), ee = Symbol.for("react.memo"), T = Symbol.for("react.lazy"), Y = Symbol.iterator;
  function X(a) {
    return a === null || typeof a != "object" ? null : (a = Y && a[Y] || a["@@iterator"], typeof a == "function" ? a : null);
  }
  var J = { isMounted: function() {
    return !1;
  }, enqueueForceUpdate: function() {
  }, enqueueReplaceState: function() {
  }, enqueueSetState: function() {
  } }, A = Object.assign, Z = {};
  function U(a, p, v) {
    this.props = a, this.context = p, this.refs = Z, this.updater = v || J;
  }
  U.prototype.isReactComponent = {}, U.prototype.setState = function(a, p) {
    if (typeof a != "object" && typeof a != "function" && a != null) throw Error("setState(...): takes an object of state variables to update or a function which returns an object of state variables.");
    this.updater.enqueueSetState(this, a, p, "setState");
  }, U.prototype.forceUpdate = function(a) {
    this.updater.enqueueForceUpdate(this, a, "forceUpdate");
  };
  function ve() {
  }
  ve.prototype = U.prototype;
  function ae(a, p, v) {
    this.props = a, this.context = p, this.refs = Z, this.updater = v || J;
  }
  var ke = ae.prototype = new ve();
  ke.constructor = ae, A(ke, U.prototype), ke.isPureReactComponent = !0;
  var xe = Array.isArray, te = Object.prototype.hasOwnProperty, Ne = { current: null }, B = { key: !0, ref: !0, __self: !0, __source: !0 };
  function C(a, p, v) {
    var k, E = {}, D = null, q = null;
    if (p != null) for (k in p.ref !== void 0 && (q = p.ref), p.key !== void 0 && (D = "" + p.key), p) te.call(p, k) && !B.hasOwnProperty(k) && (E[k] = p[k]);
    var le = arguments.length - 2;
    if (le === 1) E.children = v;
    else if (1 < le) {
      for (var b = Array(le), ne = 0; ne < le; ne++) b[ne] = arguments[ne + 2];
      E.children = b;
    }
    if (a && a.defaultProps) for (k in le = a.defaultProps, le) E[k] === void 0 && (E[k] = le[k]);
    return { $$typeof: u, type: a, key: D, ref: q, props: E, _owner: Ne.current };
  }
  function de(a, p) {
    return { $$typeof: u, type: a.type, key: p, ref: a.ref, props: a.props, _owner: a._owner };
  }
  function re(a) {
    return typeof a == "object" && a !== null && a.$$typeof === u;
  }
  function he(a) {
    var p = { "=": "=0", ":": "=2" };
    return "$" + a.replace(/[=:]/g, function(v) {
      return p[v];
    });
  }
  var Pe = /\/+/g;
  function we(a, p) {
    return typeof a == "object" && a !== null && a.key != null ? he("" + a.key) : p.toString(36);
  }
  function ce(a, p, v, k, E) {
    var D = typeof a;
    (D === "undefined" || D === "boolean") && (a = null);
    var q = !1;
    if (a === null) q = !0;
    else switch (D) {
      case "string":
      case "number":
        q = !0;
        break;
      case "object":
        switch (a.$$typeof) {
          case u:
          case y:
            q = !0;
        }
    }
    if (q) return q = a, E = E(q), a = k === "" ? "." + we(q, 0) : k, xe(E) ? (v = "", a != null && (v = a.replace(Pe, "$&/") + "/"), ce(E, p, v, "", function(ne) {
      return ne;
    })) : E != null && (re(E) && (E = de(E, v + (!E.key || q && q.key === E.key ? "" : ("" + E.key).replace(Pe, "$&/") + "/") + a)), p.push(E)), 1;
    if (q = 0, k = k === "" ? "." : k + ":", xe(a)) for (var le = 0; le < a.length; le++) {
      D = a[le];
      var b = k + we(D, le);
      q += ce(D, p, v, b, E);
    }
    else if (b = X(a), typeof b == "function") for (a = b.call(a), le = 0; !(D = a.next()).done; ) D = D.value, b = k + we(D, le++), q += ce(D, p, v, b, E);
    else if (D === "object") throw p = String(a), Error("Objects are not valid as a React child (found: " + (p === "[object Object]" ? "object with keys {" + Object.keys(a).join(", ") + "}" : p) + "). If you meant to render a collection of children, use an array instead.");
    return q;
  }
  function Re(a, p, v) {
    if (a == null) return a;
    var k = [], E = 0;
    return ce(a, k, "", "", function(D) {
      return p.call(v, D, E++);
    }), k;
  }
  function Ce(a) {
    if (a._status === -1) {
      var p = a._result;
      p = p(), p.then(function(v) {
        (a._status === 0 || a._status === -1) && (a._status = 1, a._result = v);
      }, function(v) {
        (a._status === 0 || a._status === -1) && (a._status = 2, a._result = v);
      }), a._status === -1 && (a._status = 0, a._result = p);
    }
    if (a._status === 1) return a._result.default;
    throw a._result;
  }
  var se = { current: null }, z = { transition: null }, K = { ReactCurrentDispatcher: se, ReactCurrentBatchConfig: z, ReactCurrentOwner: Ne };
  function O() {
    throw Error("act(...) is not supported in production builds of React.");
  }
  return ye.Children = { map: Re, forEach: function(a, p, v) {
    Re(a, function() {
      p.apply(this, arguments);
    }, v);
  }, count: function(a) {
    var p = 0;
    return Re(a, function() {
      p++;
    }), p;
  }, toArray: function(a) {
    return Re(a, function(p) {
      return p;
    }) || [];
  }, only: function(a) {
    if (!re(a)) throw Error("React.Children.only expected to receive a single React element child.");
    return a;
  } }, ye.Component = U, ye.Fragment = f, ye.Profiler = _, ye.PureComponent = ae, ye.StrictMode = x, ye.Suspense = P, ye.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED = K, ye.act = O, ye.cloneElement = function(a, p, v) {
    if (a == null) throw Error("React.cloneElement(...): The argument must be a React element, but you passed " + a + ".");
    var k = A({}, a.props), E = a.key, D = a.ref, q = a._owner;
    if (p != null) {
      if (p.ref !== void 0 && (D = p.ref, q = Ne.current), p.key !== void 0 && (E = "" + p.key), a.type && a.type.defaultProps) var le = a.type.defaultProps;
      for (b in p) te.call(p, b) && !B.hasOwnProperty(b) && (k[b] = p[b] === void 0 && le !== void 0 ? le[b] : p[b]);
    }
    var b = arguments.length - 2;
    if (b === 1) k.children = v;
    else if (1 < b) {
      le = Array(b);
      for (var ne = 0; ne < b; ne++) le[ne] = arguments[ne + 2];
      k.children = le;
    }
    return { $$typeof: u, type: a.type, key: E, ref: D, props: k, _owner: q };
  }, ye.createContext = function(a) {
    return a = { $$typeof: F, _currentValue: a, _currentValue2: a, _threadCount: 0, Provider: null, Consumer: null, _defaultValue: null, _globalName: null }, a.Provider = { $$typeof: S, _context: a }, a.Consumer = a;
  }, ye.createElement = C, ye.createFactory = function(a) {
    var p = C.bind(null, a);
    return p.type = a, p;
  }, ye.createRef = function() {
    return { current: null };
  }, ye.forwardRef = function(a) {
    return { $$typeof: V, render: a };
  }, ye.isValidElement = re, ye.lazy = function(a) {
    return { $$typeof: T, _payload: { _status: -1, _result: a }, _init: Ce };
  }, ye.memo = function(a, p) {
    return { $$typeof: ee, type: a, compare: p === void 0 ? null : p };
  }, ye.startTransition = function(a) {
    var p = z.transition;
    z.transition = {};
    try {
      a();
    } finally {
      z.transition = p;
    }
  }, ye.unstable_act = O, ye.useCallback = function(a, p) {
    return se.current.useCallback(a, p);
  }, ye.useContext = function(a) {
    return se.current.useContext(a);
  }, ye.useDebugValue = function() {
  }, ye.useDeferredValue = function(a) {
    return se.current.useDeferredValue(a);
  }, ye.useEffect = function(a, p) {
    return se.current.useEffect(a, p);
  }, ye.useId = function() {
    return se.current.useId();
  }, ye.useImperativeHandle = function(a, p, v) {
    return se.current.useImperativeHandle(a, p, v);
  }, ye.useInsertionEffect = function(a, p) {
    return se.current.useInsertionEffect(a, p);
  }, ye.useLayoutEffect = function(a, p) {
    return se.current.useLayoutEffect(a, p);
  }, ye.useMemo = function(a, p) {
    return se.current.useMemo(a, p);
  }, ye.useReducer = function(a, p, v) {
    return se.current.useReducer(a, p, v);
  }, ye.useRef = function(a) {
    return se.current.useRef(a);
  }, ye.useState = function(a) {
    return se.current.useState(a);
  }, ye.useSyncExternalStore = function(a, p, v) {
    return se.current.useSyncExternalStore(a, p, v);
  }, ye.useTransition = function() {
    return se.current.useTransition();
  }, ye.version = "18.3.1", ye;
}
var ba;
function Es() {
  return ba || (ba = 1, ys.exports = vd()), ys.exports;
}
/**
 * @license React
 * react-jsx-runtime.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
var ec;
function yd() {
  if (ec) return wl;
  ec = 1;
  var u = Es(), y = Symbol.for("react.element"), f = Symbol.for("react.fragment"), x = Object.prototype.hasOwnProperty, _ = u.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentOwner, S = { key: !0, ref: !0, __self: !0, __source: !0 };
  function F(V, P, ee) {
    var T, Y = {}, X = null, J = null;
    ee !== void 0 && (X = "" + ee), P.key !== void 0 && (X = "" + P.key), P.ref !== void 0 && (J = P.ref);
    for (T in P) x.call(P, T) && !S.hasOwnProperty(T) && (Y[T] = P[T]);
    if (V && V.defaultProps) for (T in P = V.defaultProps, P) Y[T] === void 0 && (Y[T] = P[T]);
    return { $$typeof: y, type: V, key: X, ref: J, props: Y, _owner: _.current };
  }
  return wl.Fragment = f, wl.jsx = F, wl.jsxs = F, wl;
}
var tc;
function gd() {
  return tc || (tc = 1, vs.exports = yd()), vs.exports;
}
var s = gd(), Mi = {}, gs = { exports: {} }, _t = {}, ws = { exports: {} }, xs = {};
/**
 * @license React
 * scheduler.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
var nc;
function wd() {
  return nc || (nc = 1, (function(u) {
    function y(z, K) {
      var O = z.length;
      z.push(K);
      e: for (; 0 < O; ) {
        var a = O - 1 >>> 1, p = z[a];
        if (0 < _(p, K)) z[a] = K, z[O] = p, O = a;
        else break e;
      }
    }
    function f(z) {
      return z.length === 0 ? null : z[0];
    }
    function x(z) {
      if (z.length === 0) return null;
      var K = z[0], O = z.pop();
      if (O !== K) {
        z[0] = O;
        e: for (var a = 0, p = z.length, v = p >>> 1; a < v; ) {
          var k = 2 * (a + 1) - 1, E = z[k], D = k + 1, q = z[D];
          if (0 > _(E, O)) D < p && 0 > _(q, E) ? (z[a] = q, z[D] = O, a = D) : (z[a] = E, z[k] = O, a = k);
          else if (D < p && 0 > _(q, O)) z[a] = q, z[D] = O, a = D;
          else break e;
        }
      }
      return K;
    }
    function _(z, K) {
      var O = z.sortIndex - K.sortIndex;
      return O !== 0 ? O : z.id - K.id;
    }
    if (typeof performance == "object" && typeof performance.now == "function") {
      var S = performance;
      u.unstable_now = function() {
        return S.now();
      };
    } else {
      var F = Date, V = F.now();
      u.unstable_now = function() {
        return F.now() - V;
      };
    }
    var P = [], ee = [], T = 1, Y = null, X = 3, J = !1, A = !1, Z = !1, U = typeof setTimeout == "function" ? setTimeout : null, ve = typeof clearTimeout == "function" ? clearTimeout : null, ae = typeof setImmediate < "u" ? setImmediate : null;
    typeof navigator < "u" && navigator.scheduling !== void 0 && navigator.scheduling.isInputPending !== void 0 && navigator.scheduling.isInputPending.bind(navigator.scheduling);
    function ke(z) {
      for (var K = f(ee); K !== null; ) {
        if (K.callback === null) x(ee);
        else if (K.startTime <= z) x(ee), K.sortIndex = K.expirationTime, y(P, K);
        else break;
        K = f(ee);
      }
    }
    function xe(z) {
      if (Z = !1, ke(z), !A) if (f(P) !== null) A = !0, Ce(te);
      else {
        var K = f(ee);
        K !== null && se(xe, K.startTime - z);
      }
    }
    function te(z, K) {
      A = !1, Z && (Z = !1, ve(C), C = -1), J = !0;
      var O = X;
      try {
        for (ke(K), Y = f(P); Y !== null && (!(Y.expirationTime > K) || z && !he()); ) {
          var a = Y.callback;
          if (typeof a == "function") {
            Y.callback = null, X = Y.priorityLevel;
            var p = a(Y.expirationTime <= K);
            K = u.unstable_now(), typeof p == "function" ? Y.callback = p : Y === f(P) && x(P), ke(K);
          } else x(P);
          Y = f(P);
        }
        if (Y !== null) var v = !0;
        else {
          var k = f(ee);
          k !== null && se(xe, k.startTime - K), v = !1;
        }
        return v;
      } finally {
        Y = null, X = O, J = !1;
      }
    }
    var Ne = !1, B = null, C = -1, de = 5, re = -1;
    function he() {
      return !(u.unstable_now() - re < de);
    }
    function Pe() {
      if (B !== null) {
        var z = u.unstable_now();
        re = z;
        var K = !0;
        try {
          K = B(!0, z);
        } finally {
          K ? we() : (Ne = !1, B = null);
        }
      } else Ne = !1;
    }
    var we;
    if (typeof ae == "function") we = function() {
      ae(Pe);
    };
    else if (typeof MessageChannel < "u") {
      var ce = new MessageChannel(), Re = ce.port2;
      ce.port1.onmessage = Pe, we = function() {
        Re.postMessage(null);
      };
    } else we = function() {
      U(Pe, 0);
    };
    function Ce(z) {
      B = z, Ne || (Ne = !0, we());
    }
    function se(z, K) {
      C = U(function() {
        z(u.unstable_now());
      }, K);
    }
    u.unstable_IdlePriority = 5, u.unstable_ImmediatePriority = 1, u.unstable_LowPriority = 4, u.unstable_NormalPriority = 3, u.unstable_Profiling = null, u.unstable_UserBlockingPriority = 2, u.unstable_cancelCallback = function(z) {
      z.callback = null;
    }, u.unstable_continueExecution = function() {
      A || J || (A = !0, Ce(te));
    }, u.unstable_forceFrameRate = function(z) {
      0 > z || 125 < z ? console.error("forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported") : de = 0 < z ? Math.floor(1e3 / z) : 5;
    }, u.unstable_getCurrentPriorityLevel = function() {
      return X;
    }, u.unstable_getFirstCallbackNode = function() {
      return f(P);
    }, u.unstable_next = function(z) {
      switch (X) {
        case 1:
        case 2:
        case 3:
          var K = 3;
          break;
        default:
          K = X;
      }
      var O = X;
      X = K;
      try {
        return z();
      } finally {
        X = O;
      }
    }, u.unstable_pauseExecution = function() {
    }, u.unstable_requestPaint = function() {
    }, u.unstable_runWithPriority = function(z, K) {
      switch (z) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
          break;
        default:
          z = 3;
      }
      var O = X;
      X = z;
      try {
        return K();
      } finally {
        X = O;
      }
    }, u.unstable_scheduleCallback = function(z, K, O) {
      var a = u.unstable_now();
      switch (typeof O == "object" && O !== null ? (O = O.delay, O = typeof O == "number" && 0 < O ? a + O : a) : O = a, z) {
        case 1:
          var p = -1;
          break;
        case 2:
          p = 250;
          break;
        case 5:
          p = 1073741823;
          break;
        case 4:
          p = 1e4;
          break;
        default:
          p = 5e3;
      }
      return p = O + p, z = { id: T++, callback: K, priorityLevel: z, startTime: O, expirationTime: p, sortIndex: -1 }, O > a ? (z.sortIndex = O, y(ee, z), f(P) === null && z === f(ee) && (Z ? (ve(C), C = -1) : Z = !0, se(xe, O - a))) : (z.sortIndex = p, y(P, z), A || J || (A = !0, Ce(te))), z;
    }, u.unstable_shouldYield = he, u.unstable_wrapCallback = function(z) {
      var K = X;
      return function() {
        var O = X;
        X = K;
        try {
          return z.apply(this, arguments);
        } finally {
          X = O;
        }
      };
    };
  })(xs)), xs;
}
var rc;
function xd() {
  return rc || (rc = 1, ws.exports = wd()), ws.exports;
}
/**
 * @license React
 * react-dom.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
var lc;
function kd() {
  if (lc) return _t;
  lc = 1;
  var u = Es(), y = xd();
  function f(e) {
    for (var t = "https://reactjs.org/docs/error-decoder.html?invariant=" + e, n = 1; n < arguments.length; n++) t += "&args[]=" + encodeURIComponent(arguments[n]);
    return "Minified React error #" + e + "; visit " + t + " for the full message or use the non-minified dev environment for full errors and additional helpful warnings.";
  }
  var x = /* @__PURE__ */ new Set(), _ = {};
  function S(e, t) {
    F(e, t), F(e + "Capture", t);
  }
  function F(e, t) {
    for (_[e] = t, e = 0; e < t.length; e++) x.add(t[e]);
  }
  var V = !(typeof window > "u" || typeof window.document > "u" || typeof window.document.createElement > "u"), P = Object.prototype.hasOwnProperty, ee = /^[:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD][:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\-.0-9\u00B7\u0300-\u036F\u203F-\u2040]*$/, T = {}, Y = {};
  function X(e) {
    return P.call(Y, e) ? !0 : P.call(T, e) ? !1 : ee.test(e) ? Y[e] = !0 : (T[e] = !0, !1);
  }
  function J(e, t, n, r) {
    if (n !== null && n.type === 0) return !1;
    switch (typeof t) {
      case "function":
      case "symbol":
        return !0;
      case "boolean":
        return r ? !1 : n !== null ? !n.acceptsBooleans : (e = e.toLowerCase().slice(0, 5), e !== "data-" && e !== "aria-");
      default:
        return !1;
    }
  }
  function A(e, t, n, r) {
    if (t === null || typeof t > "u" || J(e, t, n, r)) return !0;
    if (r) return !1;
    if (n !== null) switch (n.type) {
      case 3:
        return !t;
      case 4:
        return t === !1;
      case 5:
        return isNaN(t);
      case 6:
        return isNaN(t) || 1 > t;
    }
    return !1;
  }
  function Z(e, t, n, r, l, i, o) {
    this.acceptsBooleans = t === 2 || t === 3 || t === 4, this.attributeName = r, this.attributeNamespace = l, this.mustUseProperty = n, this.propertyName = e, this.type = t, this.sanitizeURL = i, this.removeEmptyString = o;
  }
  var U = {};
  "children dangerouslySetInnerHTML defaultValue defaultChecked innerHTML suppressContentEditableWarning suppressHydrationWarning style".split(" ").forEach(function(e) {
    U[e] = new Z(e, 0, !1, e, null, !1, !1);
  }), [["acceptCharset", "accept-charset"], ["className", "class"], ["htmlFor", "for"], ["httpEquiv", "http-equiv"]].forEach(function(e) {
    var t = e[0];
    U[t] = new Z(t, 1, !1, e[1], null, !1, !1);
  }), ["contentEditable", "draggable", "spellCheck", "value"].forEach(function(e) {
    U[e] = new Z(e, 2, !1, e.toLowerCase(), null, !1, !1);
  }), ["autoReverse", "externalResourcesRequired", "focusable", "preserveAlpha"].forEach(function(e) {
    U[e] = new Z(e, 2, !1, e, null, !1, !1);
  }), "allowFullScreen async autoFocus autoPlay controls default defer disabled disablePictureInPicture disableRemotePlayback formNoValidate hidden loop noModule noValidate open playsInline readOnly required reversed scoped seamless itemScope".split(" ").forEach(function(e) {
    U[e] = new Z(e, 3, !1, e.toLowerCase(), null, !1, !1);
  }), ["checked", "multiple", "muted", "selected"].forEach(function(e) {
    U[e] = new Z(e, 3, !0, e, null, !1, !1);
  }), ["capture", "download"].forEach(function(e) {
    U[e] = new Z(e, 4, !1, e, null, !1, !1);
  }), ["cols", "rows", "size", "span"].forEach(function(e) {
    U[e] = new Z(e, 6, !1, e, null, !1, !1);
  }), ["rowSpan", "start"].forEach(function(e) {
    U[e] = new Z(e, 5, !1, e.toLowerCase(), null, !1, !1);
  });
  var ve = /[\-:]([a-z])/g;
  function ae(e) {
    return e[1].toUpperCase();
  }
  "accent-height alignment-baseline arabic-form baseline-shift cap-height clip-path clip-rule color-interpolation color-interpolation-filters color-profile color-rendering dominant-baseline enable-background fill-opacity fill-rule flood-color flood-opacity font-family font-size font-size-adjust font-stretch font-style font-variant font-weight glyph-name glyph-orientation-horizontal glyph-orientation-vertical horiz-adv-x horiz-origin-x image-rendering letter-spacing lighting-color marker-end marker-mid marker-start overline-position overline-thickness paint-order panose-1 pointer-events rendering-intent shape-rendering stop-color stop-opacity strikethrough-position strikethrough-thickness stroke-dasharray stroke-dashoffset stroke-linecap stroke-linejoin stroke-miterlimit stroke-opacity stroke-width text-anchor text-decoration text-rendering underline-position underline-thickness unicode-bidi unicode-range units-per-em v-alphabetic v-hanging v-ideographic v-mathematical vector-effect vert-adv-y vert-origin-x vert-origin-y word-spacing writing-mode xmlns:xlink x-height".split(" ").forEach(function(e) {
    var t = e.replace(
      ve,
      ae
    );
    U[t] = new Z(t, 1, !1, e, null, !1, !1);
  }), "xlink:actuate xlink:arcrole xlink:role xlink:show xlink:title xlink:type".split(" ").forEach(function(e) {
    var t = e.replace(ve, ae);
    U[t] = new Z(t, 1, !1, e, "http://www.w3.org/1999/xlink", !1, !1);
  }), ["xml:base", "xml:lang", "xml:space"].forEach(function(e) {
    var t = e.replace(ve, ae);
    U[t] = new Z(t, 1, !1, e, "http://www.w3.org/XML/1998/namespace", !1, !1);
  }), ["tabIndex", "crossOrigin"].forEach(function(e) {
    U[e] = new Z(e, 1, !1, e.toLowerCase(), null, !1, !1);
  }), U.xlinkHref = new Z("xlinkHref", 1, !1, "xlink:href", "http://www.w3.org/1999/xlink", !0, !1), ["src", "href", "action", "formAction"].forEach(function(e) {
    U[e] = new Z(e, 1, !1, e.toLowerCase(), null, !0, !0);
  });
  function ke(e, t, n, r) {
    var l = U.hasOwnProperty(t) ? U[t] : null;
    (l !== null ? l.type !== 0 : r || !(2 < t.length) || t[0] !== "o" && t[0] !== "O" || t[1] !== "n" && t[1] !== "N") && (A(t, n, l, r) && (n = null), r || l === null ? X(t) && (n === null ? e.removeAttribute(t) : e.setAttribute(t, "" + n)) : l.mustUseProperty ? e[l.propertyName] = n === null ? l.type === 3 ? !1 : "" : n : (t = l.attributeName, r = l.attributeNamespace, n === null ? e.removeAttribute(t) : (l = l.type, n = l === 3 || l === 4 && n === !0 ? "" : "" + n, r ? e.setAttributeNS(r, t, n) : e.setAttribute(t, n))));
  }
  var xe = u.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED, te = Symbol.for("react.element"), Ne = Symbol.for("react.portal"), B = Symbol.for("react.fragment"), C = Symbol.for("react.strict_mode"), de = Symbol.for("react.profiler"), re = Symbol.for("react.provider"), he = Symbol.for("react.context"), Pe = Symbol.for("react.forward_ref"), we = Symbol.for("react.suspense"), ce = Symbol.for("react.suspense_list"), Re = Symbol.for("react.memo"), Ce = Symbol.for("react.lazy"), se = Symbol.for("react.offscreen"), z = Symbol.iterator;
  function K(e) {
    return e === null || typeof e != "object" ? null : (e = z && e[z] || e["@@iterator"], typeof e == "function" ? e : null);
  }
  var O = Object.assign, a;
  function p(e) {
    if (a === void 0) try {
      throw Error();
    } catch (n) {
      var t = n.stack.trim().match(/\n( *(at )?)/);
      a = t && t[1] || "";
    }
    return `
` + a + e;
  }
  var v = !1;
  function k(e, t) {
    if (!e || v) return "";
    v = !0;
    var n = Error.prepareStackTrace;
    Error.prepareStackTrace = void 0;
    try {
      if (t) if (t = function() {
        throw Error();
      }, Object.defineProperty(t.prototype, "props", { set: function() {
        throw Error();
      } }), typeof Reflect == "object" && Reflect.construct) {
        try {
          Reflect.construct(t, []);
        } catch (w) {
          var r = w;
        }
        Reflect.construct(e, [], t);
      } else {
        try {
          t.call();
        } catch (w) {
          r = w;
        }
        e.call(t.prototype);
      }
      else {
        try {
          throw Error();
        } catch (w) {
          r = w;
        }
        e();
      }
    } catch (w) {
      if (w && r && typeof w.stack == "string") {
        for (var l = w.stack.split(`
`), i = r.stack.split(`
`), o = l.length - 1, c = i.length - 1; 1 <= o && 0 <= c && l[o] !== i[c]; ) c--;
        for (; 1 <= o && 0 <= c; o--, c--) if (l[o] !== i[c]) {
          if (o !== 1 || c !== 1)
            do
              if (o--, c--, 0 > c || l[o] !== i[c]) {
                var d = `
` + l[o].replace(" at new ", " at ");
                return e.displayName && d.includes("<anonymous>") && (d = d.replace("<anonymous>", e.displayName)), d;
              }
            while (1 <= o && 0 <= c);
          break;
        }
      }
    } finally {
      v = !1, Error.prepareStackTrace = n;
    }
    return (e = e ? e.displayName || e.name : "") ? p(e) : "";
  }
  function E(e) {
    switch (e.tag) {
      case 5:
        return p(e.type);
      case 16:
        return p("Lazy");
      case 13:
        return p("Suspense");
      case 19:
        return p("SuspenseList");
      case 0:
      case 2:
      case 15:
        return e = k(e.type, !1), e;
      case 11:
        return e = k(e.type.render, !1), e;
      case 1:
        return e = k(e.type, !0), e;
      default:
        return "";
    }
  }
  function D(e) {
    if (e == null) return null;
    if (typeof e == "function") return e.displayName || e.name || null;
    if (typeof e == "string") return e;
    switch (e) {
      case B:
        return "Fragment";
      case Ne:
        return "Portal";
      case de:
        return "Profiler";
      case C:
        return "StrictMode";
      case we:
        return "Suspense";
      case ce:
        return "SuspenseList";
    }
    if (typeof e == "object") switch (e.$$typeof) {
      case he:
        return (e.displayName || "Context") + ".Consumer";
      case re:
        return (e._context.displayName || "Context") + ".Provider";
      case Pe:
        var t = e.render;
        return e = e.displayName, e || (e = t.displayName || t.name || "", e = e !== "" ? "ForwardRef(" + e + ")" : "ForwardRef"), e;
      case Re:
        return t = e.displayName || null, t !== null ? t : D(e.type) || "Memo";
      case Ce:
        t = e._payload, e = e._init;
        try {
          return D(e(t));
        } catch {
        }
    }
    return null;
  }
  function q(e) {
    var t = e.type;
    switch (e.tag) {
      case 24:
        return "Cache";
      case 9:
        return (t.displayName || "Context") + ".Consumer";
      case 10:
        return (t._context.displayName || "Context") + ".Provider";
      case 18:
        return "DehydratedFragment";
      case 11:
        return e = t.render, e = e.displayName || e.name || "", t.displayName || (e !== "" ? "ForwardRef(" + e + ")" : "ForwardRef");
      case 7:
        return "Fragment";
      case 5:
        return t;
      case 4:
        return "Portal";
      case 3:
        return "Root";
      case 6:
        return "Text";
      case 16:
        return D(t);
      case 8:
        return t === C ? "StrictMode" : "Mode";
      case 22:
        return "Offscreen";
      case 12:
        return "Profiler";
      case 21:
        return "Scope";
      case 13:
        return "Suspense";
      case 19:
        return "SuspenseList";
      case 25:
        return "TracingMarker";
      case 1:
      case 0:
      case 17:
      case 2:
      case 14:
      case 15:
        if (typeof t == "function") return t.displayName || t.name || null;
        if (typeof t == "string") return t;
    }
    return null;
  }
  function le(e) {
    switch (typeof e) {
      case "boolean":
      case "number":
      case "string":
      case "undefined":
        return e;
      case "object":
        return e;
      default:
        return "";
    }
  }
  function b(e) {
    var t = e.type;
    return (e = e.nodeName) && e.toLowerCase() === "input" && (t === "checkbox" || t === "radio");
  }
  function ne(e) {
    var t = b(e) ? "checked" : "value", n = Object.getOwnPropertyDescriptor(e.constructor.prototype, t), r = "" + e[t];
    if (!e.hasOwnProperty(t) && typeof n < "u" && typeof n.get == "function" && typeof n.set == "function") {
      var l = n.get, i = n.set;
      return Object.defineProperty(e, t, { configurable: !0, get: function() {
        return l.call(this);
      }, set: function(o) {
        r = "" + o, i.call(this, o);
      } }), Object.defineProperty(e, t, { enumerable: n.enumerable }), { getValue: function() {
        return r;
      }, setValue: function(o) {
        r = "" + o;
      }, stopTracking: function() {
        e._valueTracker = null, delete e[t];
      } };
    }
  }
  function pe(e) {
    e._valueTracker || (e._valueTracker = ne(e));
  }
  function ge(e) {
    if (!e) return !1;
    var t = e._valueTracker;
    if (!t) return !0;
    var n = t.getValue(), r = "";
    return e && (r = b(e) ? e.checked ? "true" : "false" : e.value), e = r, e !== n ? (t.setValue(e), !0) : !1;
  }
  function Te(e) {
    if (e = e || (typeof document < "u" ? document : void 0), typeof e > "u") return null;
    try {
      return e.activeElement || e.body;
    } catch {
      return e.body;
    }
  }
  function Xe(e, t) {
    var n = t.checked;
    return O({}, t, { defaultChecked: void 0, defaultValue: void 0, value: void 0, checked: n ?? e._wrapperState.initialChecked });
  }
  function Le(e, t) {
    var n = t.defaultValue == null ? "" : t.defaultValue, r = t.checked != null ? t.checked : t.defaultChecked;
    n = le(t.value != null ? t.value : n), e._wrapperState = { initialChecked: r, initialValue: n, controlled: t.type === "checkbox" || t.type === "radio" ? t.checked != null : t.value != null };
  }
  function ln(e, t) {
    t = t.checked, t != null && ke(e, "checked", t, !1);
  }
  function Fe(e, t) {
    ln(e, t);
    var n = le(t.value), r = t.type;
    if (n != null) r === "number" ? (n === 0 && e.value === "" || e.value != n) && (e.value = "" + n) : e.value !== "" + n && (e.value = "" + n);
    else if (r === "submit" || r === "reset") {
      e.removeAttribute("value");
      return;
    }
    t.hasOwnProperty("value") ? Ie(e, t.type, n) : t.hasOwnProperty("defaultValue") && Ie(e, t.type, le(t.defaultValue)), t.checked == null && t.defaultChecked != null && (e.defaultChecked = !!t.defaultChecked);
  }
  function tt(e, t, n) {
    if (t.hasOwnProperty("value") || t.hasOwnProperty("defaultValue")) {
      var r = t.type;
      if (!(r !== "submit" && r !== "reset" || t.value !== void 0 && t.value !== null)) return;
      t = "" + e._wrapperState.initialValue, n || t === e.value || (e.value = t), e.defaultValue = t;
    }
    n = e.name, n !== "" && (e.name = ""), e.defaultChecked = !!e._wrapperState.initialChecked, n !== "" && (e.name = n);
  }
  function Ie(e, t, n) {
    (t !== "number" || Te(e.ownerDocument) !== e) && (n == null ? e.defaultValue = "" + e._wrapperState.initialValue : e.defaultValue !== "" + n && (e.defaultValue = "" + n));
  }
  var Se = Array.isArray;
  function pt(e, t, n, r) {
    if (e = e.options, t) {
      t = {};
      for (var l = 0; l < n.length; l++) t["$" + n[l]] = !0;
      for (n = 0; n < e.length; n++) l = t.hasOwnProperty("$" + e[n].value), e[n].selected !== l && (e[n].selected = l), l && r && (e[n].defaultSelected = !0);
    } else {
      for (n = "" + le(n), t = null, l = 0; l < e.length; l++) {
        if (e[l].value === n) {
          e[l].selected = !0, r && (e[l].defaultSelected = !0);
          return;
        }
        t !== null || e[l].disabled || (t = e[l]);
      }
      t !== null && (t.selected = !0);
    }
  }
  function Et(e, t) {
    if (t.dangerouslySetInnerHTML != null) throw Error(f(91));
    return O({}, t, { value: void 0, defaultValue: void 0, children: "" + e._wrapperState.initialValue });
  }
  function At(e, t) {
    var n = t.value;
    if (n == null) {
      if (n = t.children, t = t.defaultValue, n != null) {
        if (t != null) throw Error(f(92));
        if (Se(n)) {
          if (1 < n.length) throw Error(f(93));
          n = n[0];
        }
        t = n;
      }
      t == null && (t = ""), n = t;
    }
    e._wrapperState = { initialValue: le(n) };
  }
  function Dt(e, t) {
    var n = le(t.value), r = le(t.defaultValue);
    n != null && (n = "" + n, n !== e.value && (e.value = n), t.defaultValue == null && e.defaultValue !== n && (e.defaultValue = n)), r != null && (e.defaultValue = "" + r);
  }
  function on(e) {
    var t = e.textContent;
    t === e._wrapperState.initialValue && t !== "" && t !== null && (e.value = t);
  }
  function ht(e) {
    switch (e) {
      case "svg":
        return "http://www.w3.org/2000/svg";
      case "math":
        return "http://www.w3.org/1998/Math/MathML";
      default:
        return "http://www.w3.org/1999/xhtml";
    }
  }
  function sn(e, t) {
    return e == null || e === "http://www.w3.org/1999/xhtml" ? ht(t) : e === "http://www.w3.org/2000/svg" && t === "foreignObject" ? "http://www.w3.org/1999/xhtml" : e;
  }
  var Gt, kn = (function(e) {
    return typeof MSApp < "u" && MSApp.execUnsafeLocalFunction ? function(t, n, r, l) {
      MSApp.execUnsafeLocalFunction(function() {
        return e(t, n, r, l);
      });
    } : e;
  })(function(e, t) {
    if (e.namespaceURI !== "http://www.w3.org/2000/svg" || "innerHTML" in e) e.innerHTML = t;
    else {
      for (Gt = Gt || document.createElement("div"), Gt.innerHTML = "<svg>" + t.valueOf().toString() + "</svg>", t = Gt.firstChild; e.firstChild; ) e.removeChild(e.firstChild);
      for (; t.firstChild; ) e.appendChild(t.firstChild);
    }
  });
  function nt(e, t) {
    if (t) {
      var n = e.firstChild;
      if (n && n === e.lastChild && n.nodeType === 3) {
        n.nodeValue = t;
        return;
      }
    }
    e.textContent = t;
  }
  var qt = {
    animationIterationCount: !0,
    aspectRatio: !0,
    borderImageOutset: !0,
    borderImageSlice: !0,
    borderImageWidth: !0,
    boxFlex: !0,
    boxFlexGroup: !0,
    boxOrdinalGroup: !0,
    columnCount: !0,
    columns: !0,
    flex: !0,
    flexGrow: !0,
    flexPositive: !0,
    flexShrink: !0,
    flexNegative: !0,
    flexOrder: !0,
    gridArea: !0,
    gridRow: !0,
    gridRowEnd: !0,
    gridRowSpan: !0,
    gridRowStart: !0,
    gridColumn: !0,
    gridColumnEnd: !0,
    gridColumnSpan: !0,
    gridColumnStart: !0,
    fontWeight: !0,
    lineClamp: !0,
    lineHeight: !0,
    opacity: !0,
    order: !0,
    orphans: !0,
    tabSize: !0,
    widows: !0,
    zIndex: !0,
    zoom: !0,
    fillOpacity: !0,
    floodOpacity: !0,
    stopOpacity: !0,
    strokeDasharray: !0,
    strokeDashoffset: !0,
    strokeMiterlimit: !0,
    strokeOpacity: !0,
    strokeWidth: !0
  }, Oi = ["Webkit", "ms", "Moz", "O"];
  Object.keys(qt).forEach(function(e) {
    Oi.forEach(function(t) {
      t = t + e.charAt(0).toUpperCase() + e.substring(1), qt[t] = qt[e];
    });
  });
  function Fr(e, t, n) {
    return t == null || typeof t == "boolean" || t === "" ? "" : n || typeof t != "number" || t === 0 || qt.hasOwnProperty(e) && qt[e] ? ("" + t).trim() : t + "px";
  }
  function un(e, t) {
    e = e.style;
    for (var n in t) if (t.hasOwnProperty(n)) {
      var r = n.indexOf("--") === 0, l = Fr(n, t[n], r);
      n === "float" && (n = "cssFloat"), r ? e.setProperty(n, l) : e[n] = l;
    }
  }
  var Hn = O({ menuitem: !0 }, { area: !0, base: !0, br: !0, col: !0, embed: !0, hr: !0, img: !0, input: !0, keygen: !0, link: !0, meta: !0, param: !0, source: !0, track: !0, wbr: !0 });
  function an(e, t) {
    if (t) {
      if (Hn[e] && (t.children != null || t.dangerouslySetInnerHTML != null)) throw Error(f(137, e));
      if (t.dangerouslySetInnerHTML != null) {
        if (t.children != null) throw Error(f(60));
        if (typeof t.dangerouslySetInnerHTML != "object" || !("__html" in t.dangerouslySetInnerHTML)) throw Error(f(61));
      }
      if (t.style != null && typeof t.style != "object") throw Error(f(62));
    }
  }
  function cn(e, t) {
    if (e.indexOf("-") === -1) return typeof t.is == "string";
    switch (e) {
      case "annotation-xml":
      case "color-profile":
      case "font-face":
      case "font-face-src":
      case "font-face-uri":
      case "font-face-format":
      case "font-face-name":
      case "missing-glyph":
        return !1;
      default:
        return !0;
    }
  }
  var Zt = null;
  function $t(e) {
    return e = e.target || e.srcElement || window, e.correspondingUseElement && (e = e.correspondingUseElement), e.nodeType === 3 ? e.parentNode : e;
  }
  var Vn = null, mt = null, Wt = null;
  function ir(e) {
    if (e = ll(e)) {
      if (typeof Vn != "function") throw Error(f(280));
      var t = e.stateNode;
      t && (t = Kl(t), Vn(e.stateNode, e.type, t));
    }
  }
  function Ir(e) {
    mt ? Wt ? Wt.push(e) : Wt = [e] : mt = e;
  }
  function _l() {
    if (mt) {
      var e = mt, t = Wt;
      if (Wt = mt = null, ir(e), t) for (e = 0; e < t.length; e++) ir(t[e]);
    }
  }
  function El(e, t) {
    return e(t);
  }
  function I() {
  }
  var me = !1;
  function fe(e, t, n) {
    if (me) return e(t, n);
    me = !0;
    try {
      return El(e, t, n);
    } finally {
      me = !1, (mt !== null || Wt !== null) && (I(), _l());
    }
  }
  function We(e, t) {
    var n = e.stateNode;
    if (n === null) return null;
    var r = Kl(n);
    if (r === null) return null;
    n = r[t];
    e: switch (t) {
      case "onClick":
      case "onClickCapture":
      case "onDoubleClick":
      case "onDoubleClickCapture":
      case "onMouseDown":
      case "onMouseDownCapture":
      case "onMouseMove":
      case "onMouseMoveCapture":
      case "onMouseUp":
      case "onMouseUpCapture":
      case "onMouseEnter":
        (r = !r.disabled) || (e = e.type, r = !(e === "button" || e === "input" || e === "select" || e === "textarea")), e = !r;
        break e;
      default:
        e = !1;
    }
    if (e) return null;
    if (n && typeof n != "function") throw Error(f(231, t, typeof n));
    return n;
  }
  var Oe = !1;
  if (V) try {
    var rt = {};
    Object.defineProperty(rt, "passive", { get: function() {
      Oe = !0;
    } }), window.addEventListener("test", rt, rt), window.removeEventListener("test", rt, rt);
  } catch {
    Oe = !1;
  }
  function Ct(e, t, n, r, l, i, o, c, d) {
    var w = Array.prototype.slice.call(arguments, 3);
    try {
      t.apply(n, w);
    } catch (N) {
      this.onError(N);
    }
  }
  var ct = !1, _e = null, Ze = !1, Jt = null, Sn = { onError: function(e) {
    ct = !0, _e = e;
  } };
  function _n(e, t, n, r, l, i, o, c, d) {
    ct = !1, _e = null, Ct.apply(Sn, arguments);
  }
  function or(e, t, n, r, l, i, o, c, d) {
    if (_n.apply(this, arguments), ct) {
      if (ct) {
        var w = _e;
        ct = !1, _e = null;
      } else throw Error(f(198));
      Ze || (Ze = !0, Jt = w);
    }
  }
  function vt(e) {
    var t = e, n = e;
    if (e.alternate) for (; t.return; ) t = t.return;
    else {
      e = t;
      do
        t = e, (t.flags & 4098) !== 0 && (n = t.return), e = t.return;
      while (e);
    }
    return t.tag === 3 ? n : null;
  }
  function sr(e) {
    if (e.tag === 13) {
      var t = e.memoizedState;
      if (t === null && (e = e.alternate, e !== null && (t = e.memoizedState)), t !== null) return t.dehydrated;
    }
    return null;
  }
  function ur(e) {
    if (vt(e) !== e) throw Error(f(188));
  }
  function Cl(e) {
    var t = e.alternate;
    if (!t) {
      if (t = vt(e), t === null) throw Error(f(188));
      return t !== e ? null : e;
    }
    for (var n = e, r = t; ; ) {
      var l = n.return;
      if (l === null) break;
      var i = l.alternate;
      if (i === null) {
        if (r = l.return, r !== null) {
          n = r;
          continue;
        }
        break;
      }
      if (l.child === i.child) {
        for (i = l.child; i; ) {
          if (i === n) return ur(l), e;
          if (i === r) return ur(l), t;
          i = i.sibling;
        }
        throw Error(f(188));
      }
      if (n.return !== r.return) n = l, r = i;
      else {
        for (var o = !1, c = l.child; c; ) {
          if (c === n) {
            o = !0, n = l, r = i;
            break;
          }
          if (c === r) {
            o = !0, r = l, n = i;
            break;
          }
          c = c.sibling;
        }
        if (!o) {
          for (c = i.child; c; ) {
            if (c === n) {
              o = !0, n = i, r = l;
              break;
            }
            if (c === r) {
              o = !0, r = i, n = l;
              break;
            }
            c = c.sibling;
          }
          if (!o) throw Error(f(189));
        }
      }
      if (n.alternate !== r) throw Error(f(190));
    }
    if (n.tag !== 3) throw Error(f(188));
    return n.stateNode.current === n ? e : t;
  }
  function Ar(e) {
    return e = Cl(e), e !== null ? Dr(e) : null;
  }
  function Dr(e) {
    if (e.tag === 5 || e.tag === 6) return e;
    for (e = e.child; e !== null; ) {
      var t = Dr(e);
      if (t !== null) return t;
      e = e.sibling;
    }
    return null;
  }
  var $r = y.unstable_scheduleCallback, ze = y.unstable_cancelCallback, yt = y.unstable_shouldYield, fn = y.unstable_requestPaint, Qe = y.unstable_now, Rc = y.unstable_getCurrentPriorityLevel, Fi = y.unstable_ImmediatePriority, Ns = y.unstable_UserBlockingPriority, jl = y.unstable_NormalPriority, Lc = y.unstable_LowPriority, Rs = y.unstable_IdlePriority, Nl = null, bt = null;
  function zc(e) {
    if (bt && typeof bt.onCommitFiberRoot == "function") try {
      bt.onCommitFiberRoot(Nl, e, void 0, (e.current.flags & 128) === 128);
    } catch {
    }
  }
  var Ut = Math.clz32 ? Math.clz32 : Tc, Mc = Math.log, Pc = Math.LN2;
  function Tc(e) {
    return e >>>= 0, e === 0 ? 32 : 31 - (Mc(e) / Pc | 0) | 0;
  }
  var Rl = 64, Ll = 4194304;
  function Wr(e) {
    switch (e & -e) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 4:
        return 4;
      case 8:
        return 8;
      case 16:
        return 16;
      case 32:
        return 32;
      case 64:
      case 128:
      case 256:
      case 512:
      case 1024:
      case 2048:
      case 4096:
      case 8192:
      case 16384:
      case 32768:
      case 65536:
      case 131072:
      case 262144:
      case 524288:
      case 1048576:
      case 2097152:
        return e & 4194240;
      case 4194304:
      case 8388608:
      case 16777216:
      case 33554432:
      case 67108864:
        return e & 130023424;
      case 134217728:
        return 134217728;
      case 268435456:
        return 268435456;
      case 536870912:
        return 536870912;
      case 1073741824:
        return 1073741824;
      default:
        return e;
    }
  }
  function zl(e, t) {
    var n = e.pendingLanes;
    if (n === 0) return 0;
    var r = 0, l = e.suspendedLanes, i = e.pingedLanes, o = n & 268435455;
    if (o !== 0) {
      var c = o & ~l;
      c !== 0 ? r = Wr(c) : (i &= o, i !== 0 && (r = Wr(i)));
    } else o = n & ~l, o !== 0 ? r = Wr(o) : i !== 0 && (r = Wr(i));
    if (r === 0) return 0;
    if (t !== 0 && t !== r && (t & l) === 0 && (l = r & -r, i = t & -t, l >= i || l === 16 && (i & 4194240) !== 0)) return t;
    if ((r & 4) !== 0 && (r |= n & 16), t = e.entangledLanes, t !== 0) for (e = e.entanglements, t &= r; 0 < t; ) n = 31 - Ut(t), l = 1 << n, r |= e[n], t &= ~l;
    return r;
  }
  function Oc(e, t) {
    switch (e) {
      case 1:
      case 2:
      case 4:
        return t + 250;
      case 8:
      case 16:
      case 32:
      case 64:
      case 128:
      case 256:
      case 512:
      case 1024:
      case 2048:
      case 4096:
      case 8192:
      case 16384:
      case 32768:
      case 65536:
      case 131072:
      case 262144:
      case 524288:
      case 1048576:
      case 2097152:
        return t + 5e3;
      case 4194304:
      case 8388608:
      case 16777216:
      case 33554432:
      case 67108864:
        return -1;
      case 134217728:
      case 268435456:
      case 536870912:
      case 1073741824:
        return -1;
      default:
        return -1;
    }
  }
  function Fc(e, t) {
    for (var n = e.suspendedLanes, r = e.pingedLanes, l = e.expirationTimes, i = e.pendingLanes; 0 < i; ) {
      var o = 31 - Ut(i), c = 1 << o, d = l[o];
      d === -1 ? ((c & n) === 0 || (c & r) !== 0) && (l[o] = Oc(c, t)) : d <= t && (e.expiredLanes |= c), i &= ~c;
    }
  }
  function Ii(e) {
    return e = e.pendingLanes & -1073741825, e !== 0 ? e : e & 1073741824 ? 1073741824 : 0;
  }
  function Ls() {
    var e = Rl;
    return Rl <<= 1, (Rl & 4194240) === 0 && (Rl = 64), e;
  }
  function Ai(e) {
    for (var t = [], n = 0; 31 > n; n++) t.push(e);
    return t;
  }
  function Ur(e, t, n) {
    e.pendingLanes |= t, t !== 536870912 && (e.suspendedLanes = 0, e.pingedLanes = 0), e = e.eventTimes, t = 31 - Ut(t), e[t] = n;
  }
  function Ic(e, t) {
    var n = e.pendingLanes & ~t;
    e.pendingLanes = t, e.suspendedLanes = 0, e.pingedLanes = 0, e.expiredLanes &= t, e.mutableReadLanes &= t, e.entangledLanes &= t, t = e.entanglements;
    var r = e.eventTimes;
    for (e = e.expirationTimes; 0 < n; ) {
      var l = 31 - Ut(n), i = 1 << l;
      t[l] = 0, r[l] = -1, e[l] = -1, n &= ~i;
    }
  }
  function Di(e, t) {
    var n = e.entangledLanes |= t;
    for (e = e.entanglements; n; ) {
      var r = 31 - Ut(n), l = 1 << r;
      l & t | e[r] & t && (e[r] |= t), n &= ~l;
    }
  }
  var Me = 0;
  function zs(e) {
    return e &= -e, 1 < e ? 4 < e ? (e & 268435455) !== 0 ? 16 : 536870912 : 4 : 1;
  }
  var Ms, $i, Ps, Ts, Os, Wi = !1, Ml = [], En = null, Cn = null, jn = null, Br = /* @__PURE__ */ new Map(), Hr = /* @__PURE__ */ new Map(), Nn = [], Ac = "mousedown mouseup touchcancel touchend touchstart auxclick dblclick pointercancel pointerdown pointerup dragend dragstart drop compositionend compositionstart keydown keypress keyup input textInput copy cut paste click change contextmenu reset submit".split(" ");
  function Fs(e, t) {
    switch (e) {
      case "focusin":
      case "focusout":
        En = null;
        break;
      case "dragenter":
      case "dragleave":
        Cn = null;
        break;
      case "mouseover":
      case "mouseout":
        jn = null;
        break;
      case "pointerover":
      case "pointerout":
        Br.delete(t.pointerId);
        break;
      case "gotpointercapture":
      case "lostpointercapture":
        Hr.delete(t.pointerId);
    }
  }
  function Vr(e, t, n, r, l, i) {
    return e === null || e.nativeEvent !== i ? (e = { blockedOn: t, domEventName: n, eventSystemFlags: r, nativeEvent: i, targetContainers: [l] }, t !== null && (t = ll(t), t !== null && $i(t)), e) : (e.eventSystemFlags |= r, t = e.targetContainers, l !== null && t.indexOf(l) === -1 && t.push(l), e);
  }
  function Dc(e, t, n, r, l) {
    switch (t) {
      case "focusin":
        return En = Vr(En, e, t, n, r, l), !0;
      case "dragenter":
        return Cn = Vr(Cn, e, t, n, r, l), !0;
      case "mouseover":
        return jn = Vr(jn, e, t, n, r, l), !0;
      case "pointerover":
        var i = l.pointerId;
        return Br.set(i, Vr(Br.get(i) || null, e, t, n, r, l)), !0;
      case "gotpointercapture":
        return i = l.pointerId, Hr.set(i, Vr(Hr.get(i) || null, e, t, n, r, l)), !0;
    }
    return !1;
  }
  function Is(e) {
    var t = Qn(e.target);
    if (t !== null) {
      var n = vt(t);
      if (n !== null) {
        if (t = n.tag, t === 13) {
          if (t = sr(n), t !== null) {
            e.blockedOn = t, Os(e.priority, function() {
              Ps(n);
            });
            return;
          }
        } else if (t === 3 && n.stateNode.current.memoizedState.isDehydrated) {
          e.blockedOn = n.tag === 3 ? n.stateNode.containerInfo : null;
          return;
        }
      }
    }
    e.blockedOn = null;
  }
  function Pl(e) {
    if (e.blockedOn !== null) return !1;
    for (var t = e.targetContainers; 0 < t.length; ) {
      var n = Bi(e.domEventName, e.eventSystemFlags, t[0], e.nativeEvent);
      if (n === null) {
        n = e.nativeEvent;
        var r = new n.constructor(n.type, n);
        Zt = r, n.target.dispatchEvent(r), Zt = null;
      } else return t = ll(n), t !== null && $i(t), e.blockedOn = n, !1;
      t.shift();
    }
    return !0;
  }
  function As(e, t, n) {
    Pl(e) && n.delete(t);
  }
  function $c() {
    Wi = !1, En !== null && Pl(En) && (En = null), Cn !== null && Pl(Cn) && (Cn = null), jn !== null && Pl(jn) && (jn = null), Br.forEach(As), Hr.forEach(As);
  }
  function Qr(e, t) {
    e.blockedOn === t && (e.blockedOn = null, Wi || (Wi = !0, y.unstable_scheduleCallback(y.unstable_NormalPriority, $c)));
  }
  function Kr(e) {
    function t(l) {
      return Qr(l, e);
    }
    if (0 < Ml.length) {
      Qr(Ml[0], e);
      for (var n = 1; n < Ml.length; n++) {
        var r = Ml[n];
        r.blockedOn === e && (r.blockedOn = null);
      }
    }
    for (En !== null && Qr(En, e), Cn !== null && Qr(Cn, e), jn !== null && Qr(jn, e), Br.forEach(t), Hr.forEach(t), n = 0; n < Nn.length; n++) r = Nn[n], r.blockedOn === e && (r.blockedOn = null);
    for (; 0 < Nn.length && (n = Nn[0], n.blockedOn === null); ) Is(n), n.blockedOn === null && Nn.shift();
  }
  var ar = xe.ReactCurrentBatchConfig, Tl = !0;
  function Wc(e, t, n, r) {
    var l = Me, i = ar.transition;
    ar.transition = null;
    try {
      Me = 1, Ui(e, t, n, r);
    } finally {
      Me = l, ar.transition = i;
    }
  }
  function Uc(e, t, n, r) {
    var l = Me, i = ar.transition;
    ar.transition = null;
    try {
      Me = 4, Ui(e, t, n, r);
    } finally {
      Me = l, ar.transition = i;
    }
  }
  function Ui(e, t, n, r) {
    if (Tl) {
      var l = Bi(e, t, n, r);
      if (l === null) io(e, t, r, Ol, n), Fs(e, r);
      else if (Dc(l, e, t, n, r)) r.stopPropagation();
      else if (Fs(e, r), t & 4 && -1 < Ac.indexOf(e)) {
        for (; l !== null; ) {
          var i = ll(l);
          if (i !== null && Ms(i), i = Bi(e, t, n, r), i === null && io(e, t, r, Ol, n), i === l) break;
          l = i;
        }
        l !== null && r.stopPropagation();
      } else io(e, t, r, null, n);
    }
  }
  var Ol = null;
  function Bi(e, t, n, r) {
    if (Ol = null, e = $t(r), e = Qn(e), e !== null) if (t = vt(e), t === null) e = null;
    else if (n = t.tag, n === 13) {
      if (e = sr(t), e !== null) return e;
      e = null;
    } else if (n === 3) {
      if (t.stateNode.current.memoizedState.isDehydrated) return t.tag === 3 ? t.stateNode.containerInfo : null;
      e = null;
    } else t !== e && (e = null);
    return Ol = e, null;
  }
  function Ds(e) {
    switch (e) {
      case "cancel":
      case "click":
      case "close":
      case "contextmenu":
      case "copy":
      case "cut":
      case "auxclick":
      case "dblclick":
      case "dragend":
      case "dragstart":
      case "drop":
      case "focusin":
      case "focusout":
      case "input":
      case "invalid":
      case "keydown":
      case "keypress":
      case "keyup":
      case "mousedown":
      case "mouseup":
      case "paste":
      case "pause":
      case "play":
      case "pointercancel":
      case "pointerdown":
      case "pointerup":
      case "ratechange":
      case "reset":
      case "resize":
      case "seeked":
      case "submit":
      case "touchcancel":
      case "touchend":
      case "touchstart":
      case "volumechange":
      case "change":
      case "selectionchange":
      case "textInput":
      case "compositionstart":
      case "compositionend":
      case "compositionupdate":
      case "beforeblur":
      case "afterblur":
      case "beforeinput":
      case "blur":
      case "fullscreenchange":
      case "focus":
      case "hashchange":
      case "popstate":
      case "select":
      case "selectstart":
        return 1;
      case "drag":
      case "dragenter":
      case "dragexit":
      case "dragleave":
      case "dragover":
      case "mousemove":
      case "mouseout":
      case "mouseover":
      case "pointermove":
      case "pointerout":
      case "pointerover":
      case "scroll":
      case "toggle":
      case "touchmove":
      case "wheel":
      case "mouseenter":
      case "mouseleave":
      case "pointerenter":
      case "pointerleave":
        return 4;
      case "message":
        switch (Rc()) {
          case Fi:
            return 1;
          case Ns:
            return 4;
          case jl:
          case Lc:
            return 16;
          case Rs:
            return 536870912;
          default:
            return 16;
        }
      default:
        return 16;
    }
  }
  var Rn = null, Hi = null, Fl = null;
  function $s() {
    if (Fl) return Fl;
    var e, t = Hi, n = t.length, r, l = "value" in Rn ? Rn.value : Rn.textContent, i = l.length;
    for (e = 0; e < n && t[e] === l[e]; e++) ;
    var o = n - e;
    for (r = 1; r <= o && t[n - r] === l[i - r]; r++) ;
    return Fl = l.slice(e, 1 < r ? 1 - r : void 0);
  }
  function Il(e) {
    var t = e.keyCode;
    return "charCode" in e ? (e = e.charCode, e === 0 && t === 13 && (e = 13)) : e = t, e === 10 && (e = 13), 32 <= e || e === 13 ? e : 0;
  }
  function Al() {
    return !0;
  }
  function Ws() {
    return !1;
  }
  function jt(e) {
    function t(n, r, l, i, o) {
      this._reactName = n, this._targetInst = l, this.type = r, this.nativeEvent = i, this.target = o, this.currentTarget = null;
      for (var c in e) e.hasOwnProperty(c) && (n = e[c], this[c] = n ? n(i) : i[c]);
      return this.isDefaultPrevented = (i.defaultPrevented != null ? i.defaultPrevented : i.returnValue === !1) ? Al : Ws, this.isPropagationStopped = Ws, this;
    }
    return O(t.prototype, { preventDefault: function() {
      this.defaultPrevented = !0;
      var n = this.nativeEvent;
      n && (n.preventDefault ? n.preventDefault() : typeof n.returnValue != "unknown" && (n.returnValue = !1), this.isDefaultPrevented = Al);
    }, stopPropagation: function() {
      var n = this.nativeEvent;
      n && (n.stopPropagation ? n.stopPropagation() : typeof n.cancelBubble != "unknown" && (n.cancelBubble = !0), this.isPropagationStopped = Al);
    }, persist: function() {
    }, isPersistent: Al }), t;
  }
  var cr = { eventPhase: 0, bubbles: 0, cancelable: 0, timeStamp: function(e) {
    return e.timeStamp || Date.now();
  }, defaultPrevented: 0, isTrusted: 0 }, Vi = jt(cr), Yr = O({}, cr, { view: 0, detail: 0 }), Bc = jt(Yr), Qi, Ki, Xr, Dl = O({}, Yr, { screenX: 0, screenY: 0, clientX: 0, clientY: 0, pageX: 0, pageY: 0, ctrlKey: 0, shiftKey: 0, altKey: 0, metaKey: 0, getModifierState: Xi, button: 0, buttons: 0, relatedTarget: function(e) {
    return e.relatedTarget === void 0 ? e.fromElement === e.srcElement ? e.toElement : e.fromElement : e.relatedTarget;
  }, movementX: function(e) {
    return "movementX" in e ? e.movementX : (e !== Xr && (Xr && e.type === "mousemove" ? (Qi = e.screenX - Xr.screenX, Ki = e.screenY - Xr.screenY) : Ki = Qi = 0, Xr = e), Qi);
  }, movementY: function(e) {
    return "movementY" in e ? e.movementY : Ki;
  } }), Us = jt(Dl), Hc = O({}, Dl, { dataTransfer: 0 }), Vc = jt(Hc), Qc = O({}, Yr, { relatedTarget: 0 }), Yi = jt(Qc), Kc = O({}, cr, { animationName: 0, elapsedTime: 0, pseudoElement: 0 }), Yc = jt(Kc), Xc = O({}, cr, { clipboardData: function(e) {
    return "clipboardData" in e ? e.clipboardData : window.clipboardData;
  } }), Gc = jt(Xc), qc = O({}, cr, { data: 0 }), Bs = jt(qc), Zc = {
    Esc: "Escape",
    Spacebar: " ",
    Left: "ArrowLeft",
    Up: "ArrowUp",
    Right: "ArrowRight",
    Down: "ArrowDown",
    Del: "Delete",
    Win: "OS",
    Menu: "ContextMenu",
    Apps: "ContextMenu",
    Scroll: "ScrollLock",
    MozPrintableKey: "Unidentified"
  }, Jc = {
    8: "Backspace",
    9: "Tab",
    12: "Clear",
    13: "Enter",
    16: "Shift",
    17: "Control",
    18: "Alt",
    19: "Pause",
    20: "CapsLock",
    27: "Escape",
    32: " ",
    33: "PageUp",
    34: "PageDown",
    35: "End",
    36: "Home",
    37: "ArrowLeft",
    38: "ArrowUp",
    39: "ArrowRight",
    40: "ArrowDown",
    45: "Insert",
    46: "Delete",
    112: "F1",
    113: "F2",
    114: "F3",
    115: "F4",
    116: "F5",
    117: "F6",
    118: "F7",
    119: "F8",
    120: "F9",
    121: "F10",
    122: "F11",
    123: "F12",
    144: "NumLock",
    145: "ScrollLock",
    224: "Meta"
  }, bc = { Alt: "altKey", Control: "ctrlKey", Meta: "metaKey", Shift: "shiftKey" };
  function ef(e) {
    var t = this.nativeEvent;
    return t.getModifierState ? t.getModifierState(e) : (e = bc[e]) ? !!t[e] : !1;
  }
  function Xi() {
    return ef;
  }
  var tf = O({}, Yr, { key: function(e) {
    if (e.key) {
      var t = Zc[e.key] || e.key;
      if (t !== "Unidentified") return t;
    }
    return e.type === "keypress" ? (e = Il(e), e === 13 ? "Enter" : String.fromCharCode(e)) : e.type === "keydown" || e.type === "keyup" ? Jc[e.keyCode] || "Unidentified" : "";
  }, code: 0, location: 0, ctrlKey: 0, shiftKey: 0, altKey: 0, metaKey: 0, repeat: 0, locale: 0, getModifierState: Xi, charCode: function(e) {
    return e.type === "keypress" ? Il(e) : 0;
  }, keyCode: function(e) {
    return e.type === "keydown" || e.type === "keyup" ? e.keyCode : 0;
  }, which: function(e) {
    return e.type === "keypress" ? Il(e) : e.type === "keydown" || e.type === "keyup" ? e.keyCode : 0;
  } }), nf = jt(tf), rf = O({}, Dl, { pointerId: 0, width: 0, height: 0, pressure: 0, tangentialPressure: 0, tiltX: 0, tiltY: 0, twist: 0, pointerType: 0, isPrimary: 0 }), Hs = jt(rf), lf = O({}, Yr, { touches: 0, targetTouches: 0, changedTouches: 0, altKey: 0, metaKey: 0, ctrlKey: 0, shiftKey: 0, getModifierState: Xi }), of = jt(lf), sf = O({}, cr, { propertyName: 0, elapsedTime: 0, pseudoElement: 0 }), uf = jt(sf), af = O({}, Dl, {
    deltaX: function(e) {
      return "deltaX" in e ? e.deltaX : "wheelDeltaX" in e ? -e.wheelDeltaX : 0;
    },
    deltaY: function(e) {
      return "deltaY" in e ? e.deltaY : "wheelDeltaY" in e ? -e.wheelDeltaY : "wheelDelta" in e ? -e.wheelDelta : 0;
    },
    deltaZ: 0,
    deltaMode: 0
  }), cf = jt(af), ff = [9, 13, 27, 32], Gi = V && "CompositionEvent" in window, Gr = null;
  V && "documentMode" in document && (Gr = document.documentMode);
  var df = V && "TextEvent" in window && !Gr, Vs = V && (!Gi || Gr && 8 < Gr && 11 >= Gr), Qs = " ", Ks = !1;
  function Ys(e, t) {
    switch (e) {
      case "keyup":
        return ff.indexOf(t.keyCode) !== -1;
      case "keydown":
        return t.keyCode !== 229;
      case "keypress":
      case "mousedown":
      case "focusout":
        return !0;
      default:
        return !1;
    }
  }
  function Xs(e) {
    return e = e.detail, typeof e == "object" && "data" in e ? e.data : null;
  }
  var fr = !1;
  function pf(e, t) {
    switch (e) {
      case "compositionend":
        return Xs(t);
      case "keypress":
        return t.which !== 32 ? null : (Ks = !0, Qs);
      case "textInput":
        return e = t.data, e === Qs && Ks ? null : e;
      default:
        return null;
    }
  }
  function hf(e, t) {
    if (fr) return e === "compositionend" || !Gi && Ys(e, t) ? (e = $s(), Fl = Hi = Rn = null, fr = !1, e) : null;
    switch (e) {
      case "paste":
        return null;
      case "keypress":
        if (!(t.ctrlKey || t.altKey || t.metaKey) || t.ctrlKey && t.altKey) {
          if (t.char && 1 < t.char.length) return t.char;
          if (t.which) return String.fromCharCode(t.which);
        }
        return null;
      case "compositionend":
        return Vs && t.locale !== "ko" ? null : t.data;
      default:
        return null;
    }
  }
  var mf = { color: !0, date: !0, datetime: !0, "datetime-local": !0, email: !0, month: !0, number: !0, password: !0, range: !0, search: !0, tel: !0, text: !0, time: !0, url: !0, week: !0 };
  function Gs(e) {
    var t = e && e.nodeName && e.nodeName.toLowerCase();
    return t === "input" ? !!mf[e.type] : t === "textarea";
  }
  function qs(e, t, n, r) {
    Ir(r), t = Hl(t, "onChange"), 0 < t.length && (n = new Vi("onChange", "change", null, n, r), e.push({ event: n, listeners: t }));
  }
  var qr = null, Zr = null;
  function vf(e) {
    hu(e, 0);
  }
  function $l(e) {
    var t = vr(e);
    if (ge(t)) return e;
  }
  function yf(e, t) {
    if (e === "change") return t;
  }
  var Zs = !1;
  if (V) {
    var qi;
    if (V) {
      var Zi = "oninput" in document;
      if (!Zi) {
        var Js = document.createElement("div");
        Js.setAttribute("oninput", "return;"), Zi = typeof Js.oninput == "function";
      }
      qi = Zi;
    } else qi = !1;
    Zs = qi && (!document.documentMode || 9 < document.documentMode);
  }
  function bs() {
    qr && (qr.detachEvent("onpropertychange", eu), Zr = qr = null);
  }
  function eu(e) {
    if (e.propertyName === "value" && $l(Zr)) {
      var t = [];
      qs(t, Zr, e, $t(e)), fe(vf, t);
    }
  }
  function gf(e, t, n) {
    e === "focusin" ? (bs(), qr = t, Zr = n, qr.attachEvent("onpropertychange", eu)) : e === "focusout" && bs();
  }
  function wf(e) {
    if (e === "selectionchange" || e === "keyup" || e === "keydown") return $l(Zr);
  }
  function xf(e, t) {
    if (e === "click") return $l(t);
  }
  function kf(e, t) {
    if (e === "input" || e === "change") return $l(t);
  }
  function Sf(e, t) {
    return e === t && (e !== 0 || 1 / e === 1 / t) || e !== e && t !== t;
  }
  var Bt = typeof Object.is == "function" ? Object.is : Sf;
  function Jr(e, t) {
    if (Bt(e, t)) return !0;
    if (typeof e != "object" || e === null || typeof t != "object" || t === null) return !1;
    var n = Object.keys(e), r = Object.keys(t);
    if (n.length !== r.length) return !1;
    for (r = 0; r < n.length; r++) {
      var l = n[r];
      if (!P.call(t, l) || !Bt(e[l], t[l])) return !1;
    }
    return !0;
  }
  function tu(e) {
    for (; e && e.firstChild; ) e = e.firstChild;
    return e;
  }
  function nu(e, t) {
    var n = tu(e);
    e = 0;
    for (var r; n; ) {
      if (n.nodeType === 3) {
        if (r = e + n.textContent.length, e <= t && r >= t) return { node: n, offset: t - e };
        e = r;
      }
      e: {
        for (; n; ) {
          if (n.nextSibling) {
            n = n.nextSibling;
            break e;
          }
          n = n.parentNode;
        }
        n = void 0;
      }
      n = tu(n);
    }
  }
  function ru(e, t) {
    return e && t ? e === t ? !0 : e && e.nodeType === 3 ? !1 : t && t.nodeType === 3 ? ru(e, t.parentNode) : "contains" in e ? e.contains(t) : e.compareDocumentPosition ? !!(e.compareDocumentPosition(t) & 16) : !1 : !1;
  }
  function lu() {
    for (var e = window, t = Te(); t instanceof e.HTMLIFrameElement; ) {
      try {
        var n = typeof t.contentWindow.location.href == "string";
      } catch {
        n = !1;
      }
      if (n) e = t.contentWindow;
      else break;
      t = Te(e.document);
    }
    return t;
  }
  function Ji(e) {
    var t = e && e.nodeName && e.nodeName.toLowerCase();
    return t && (t === "input" && (e.type === "text" || e.type === "search" || e.type === "tel" || e.type === "url" || e.type === "password") || t === "textarea" || e.contentEditable === "true");
  }
  function _f(e) {
    var t = lu(), n = e.focusedElem, r = e.selectionRange;
    if (t !== n && n && n.ownerDocument && ru(n.ownerDocument.documentElement, n)) {
      if (r !== null && Ji(n)) {
        if (t = r.start, e = r.end, e === void 0 && (e = t), "selectionStart" in n) n.selectionStart = t, n.selectionEnd = Math.min(e, n.value.length);
        else if (e = (t = n.ownerDocument || document) && t.defaultView || window, e.getSelection) {
          e = e.getSelection();
          var l = n.textContent.length, i = Math.min(r.start, l);
          r = r.end === void 0 ? i : Math.min(r.end, l), !e.extend && i > r && (l = r, r = i, i = l), l = nu(n, i);
          var o = nu(
            n,
            r
          );
          l && o && (e.rangeCount !== 1 || e.anchorNode !== l.node || e.anchorOffset !== l.offset || e.focusNode !== o.node || e.focusOffset !== o.offset) && (t = t.createRange(), t.setStart(l.node, l.offset), e.removeAllRanges(), i > r ? (e.addRange(t), e.extend(o.node, o.offset)) : (t.setEnd(o.node, o.offset), e.addRange(t)));
        }
      }
      for (t = [], e = n; e = e.parentNode; ) e.nodeType === 1 && t.push({ element: e, left: e.scrollLeft, top: e.scrollTop });
      for (typeof n.focus == "function" && n.focus(), n = 0; n < t.length; n++) e = t[n], e.element.scrollLeft = e.left, e.element.scrollTop = e.top;
    }
  }
  var Ef = V && "documentMode" in document && 11 >= document.documentMode, dr = null, bi = null, br = null, eo = !1;
  function iu(e, t, n) {
    var r = n.window === n ? n.document : n.nodeType === 9 ? n : n.ownerDocument;
    eo || dr == null || dr !== Te(r) || (r = dr, "selectionStart" in r && Ji(r) ? r = { start: r.selectionStart, end: r.selectionEnd } : (r = (r.ownerDocument && r.ownerDocument.defaultView || window).getSelection(), r = { anchorNode: r.anchorNode, anchorOffset: r.anchorOffset, focusNode: r.focusNode, focusOffset: r.focusOffset }), br && Jr(br, r) || (br = r, r = Hl(bi, "onSelect"), 0 < r.length && (t = new Vi("onSelect", "select", null, t, n), e.push({ event: t, listeners: r }), t.target = dr)));
  }
  function Wl(e, t) {
    var n = {};
    return n[e.toLowerCase()] = t.toLowerCase(), n["Webkit" + e] = "webkit" + t, n["Moz" + e] = "moz" + t, n;
  }
  var pr = { animationend: Wl("Animation", "AnimationEnd"), animationiteration: Wl("Animation", "AnimationIteration"), animationstart: Wl("Animation", "AnimationStart"), transitionend: Wl("Transition", "TransitionEnd") }, to = {}, ou = {};
  V && (ou = document.createElement("div").style, "AnimationEvent" in window || (delete pr.animationend.animation, delete pr.animationiteration.animation, delete pr.animationstart.animation), "TransitionEvent" in window || delete pr.transitionend.transition);
  function Ul(e) {
    if (to[e]) return to[e];
    if (!pr[e]) return e;
    var t = pr[e], n;
    for (n in t) if (t.hasOwnProperty(n) && n in ou) return to[e] = t[n];
    return e;
  }
  var su = Ul("animationend"), uu = Ul("animationiteration"), au = Ul("animationstart"), cu = Ul("transitionend"), fu = /* @__PURE__ */ new Map(), du = "abort auxClick cancel canPlay canPlayThrough click close contextMenu copy cut drag dragEnd dragEnter dragExit dragLeave dragOver dragStart drop durationChange emptied encrypted ended error gotPointerCapture input invalid keyDown keyPress keyUp load loadedData loadedMetadata loadStart lostPointerCapture mouseDown mouseMove mouseOut mouseOver mouseUp paste pause play playing pointerCancel pointerDown pointerMove pointerOut pointerOver pointerUp progress rateChange reset resize seeked seeking stalled submit suspend timeUpdate touchCancel touchEnd touchStart volumeChange scroll toggle touchMove waiting wheel".split(" ");
  function Ln(e, t) {
    fu.set(e, t), S(t, [e]);
  }
  for (var no = 0; no < du.length; no++) {
    var ro = du[no], Cf = ro.toLowerCase(), jf = ro[0].toUpperCase() + ro.slice(1);
    Ln(Cf, "on" + jf);
  }
  Ln(su, "onAnimationEnd"), Ln(uu, "onAnimationIteration"), Ln(au, "onAnimationStart"), Ln("dblclick", "onDoubleClick"), Ln("focusin", "onFocus"), Ln("focusout", "onBlur"), Ln(cu, "onTransitionEnd"), F("onMouseEnter", ["mouseout", "mouseover"]), F("onMouseLeave", ["mouseout", "mouseover"]), F("onPointerEnter", ["pointerout", "pointerover"]), F("onPointerLeave", ["pointerout", "pointerover"]), S("onChange", "change click focusin focusout input keydown keyup selectionchange".split(" ")), S("onSelect", "focusout contextmenu dragend focusin keydown keyup mousedown mouseup selectionchange".split(" ")), S("onBeforeInput", ["compositionend", "keypress", "textInput", "paste"]), S("onCompositionEnd", "compositionend focusout keydown keypress keyup mousedown".split(" ")), S("onCompositionStart", "compositionstart focusout keydown keypress keyup mousedown".split(" ")), S("onCompositionUpdate", "compositionupdate focusout keydown keypress keyup mousedown".split(" "));
  var el = "abort canplay canplaythrough durationchange emptied encrypted ended error loadeddata loadedmetadata loadstart pause play playing progress ratechange resize seeked seeking stalled suspend timeupdate volumechange waiting".split(" "), Nf = new Set("cancel close invalid load scroll toggle".split(" ").concat(el));
  function pu(e, t, n) {
    var r = e.type || "unknown-event";
    e.currentTarget = n, or(r, t, void 0, e), e.currentTarget = null;
  }
  function hu(e, t) {
    t = (t & 4) !== 0;
    for (var n = 0; n < e.length; n++) {
      var r = e[n], l = r.event;
      r = r.listeners;
      e: {
        var i = void 0;
        if (t) for (var o = r.length - 1; 0 <= o; o--) {
          var c = r[o], d = c.instance, w = c.currentTarget;
          if (c = c.listener, d !== i && l.isPropagationStopped()) break e;
          pu(l, c, w), i = d;
        }
        else for (o = 0; o < r.length; o++) {
          if (c = r[o], d = c.instance, w = c.currentTarget, c = c.listener, d !== i && l.isPropagationStopped()) break e;
          pu(l, c, w), i = d;
        }
      }
    }
    if (Ze) throw e = Jt, Ze = !1, Jt = null, e;
  }
  function De(e, t) {
    var n = t[fo];
    n === void 0 && (n = t[fo] = /* @__PURE__ */ new Set());
    var r = e + "__bubble";
    n.has(r) || (mu(t, e, 2, !1), n.add(r));
  }
  function lo(e, t, n) {
    var r = 0;
    t && (r |= 4), mu(n, e, r, t);
  }
  var Bl = "_reactListening" + Math.random().toString(36).slice(2);
  function tl(e) {
    if (!e[Bl]) {
      e[Bl] = !0, x.forEach(function(n) {
        n !== "selectionchange" && (Nf.has(n) || lo(n, !1, e), lo(n, !0, e));
      });
      var t = e.nodeType === 9 ? e : e.ownerDocument;
      t === null || t[Bl] || (t[Bl] = !0, lo("selectionchange", !1, t));
    }
  }
  function mu(e, t, n, r) {
    switch (Ds(t)) {
      case 1:
        var l = Wc;
        break;
      case 4:
        l = Uc;
        break;
      default:
        l = Ui;
    }
    n = l.bind(null, t, n, e), l = void 0, !Oe || t !== "touchstart" && t !== "touchmove" && t !== "wheel" || (l = !0), r ? l !== void 0 ? e.addEventListener(t, n, { capture: !0, passive: l }) : e.addEventListener(t, n, !0) : l !== void 0 ? e.addEventListener(t, n, { passive: l }) : e.addEventListener(t, n, !1);
  }
  function io(e, t, n, r, l) {
    var i = r;
    if ((t & 1) === 0 && (t & 2) === 0 && r !== null) e: for (; ; ) {
      if (r === null) return;
      var o = r.tag;
      if (o === 3 || o === 4) {
        var c = r.stateNode.containerInfo;
        if (c === l || c.nodeType === 8 && c.parentNode === l) break;
        if (o === 4) for (o = r.return; o !== null; ) {
          var d = o.tag;
          if ((d === 3 || d === 4) && (d = o.stateNode.containerInfo, d === l || d.nodeType === 8 && d.parentNode === l)) return;
          o = o.return;
        }
        for (; c !== null; ) {
          if (o = Qn(c), o === null) return;
          if (d = o.tag, d === 5 || d === 6) {
            r = i = o;
            continue e;
          }
          c = c.parentNode;
        }
      }
      r = r.return;
    }
    fe(function() {
      var w = i, N = $t(n), R = [];
      e: {
        var j = fu.get(e);
        if (j !== void 0) {
          var $ = Vi, H = e;
          switch (e) {
            case "keypress":
              if (Il(n) === 0) break e;
            case "keydown":
            case "keyup":
              $ = nf;
              break;
            case "focusin":
              H = "focus", $ = Yi;
              break;
            case "focusout":
              H = "blur", $ = Yi;
              break;
            case "beforeblur":
            case "afterblur":
              $ = Yi;
              break;
            case "click":
              if (n.button === 2) break e;
            case "auxclick":
            case "dblclick":
            case "mousedown":
            case "mousemove":
            case "mouseup":
            case "mouseout":
            case "mouseover":
            case "contextmenu":
              $ = Us;
              break;
            case "drag":
            case "dragend":
            case "dragenter":
            case "dragexit":
            case "dragleave":
            case "dragover":
            case "dragstart":
            case "drop":
              $ = Vc;
              break;
            case "touchcancel":
            case "touchend":
            case "touchmove":
            case "touchstart":
              $ = of;
              break;
            case su:
            case uu:
            case au:
              $ = Yc;
              break;
            case cu:
              $ = uf;
              break;
            case "scroll":
              $ = Bc;
              break;
            case "wheel":
              $ = cf;
              break;
            case "copy":
            case "cut":
            case "paste":
              $ = Gc;
              break;
            case "gotpointercapture":
            case "lostpointercapture":
            case "pointercancel":
            case "pointerdown":
            case "pointermove":
            case "pointerout":
            case "pointerover":
            case "pointerup":
              $ = Hs;
          }
          var Q = (t & 4) !== 0, Ke = !Q && e === "scroll", m = Q ? j !== null ? j + "Capture" : null : j;
          Q = [];
          for (var h = w, g; h !== null; ) {
            g = h;
            var L = g.stateNode;
            if (g.tag === 5 && L !== null && (g = L, m !== null && (L = We(h, m), L != null && Q.push(nl(h, L, g)))), Ke) break;
            h = h.return;
          }
          0 < Q.length && (j = new $(j, H, null, n, N), R.push({ event: j, listeners: Q }));
        }
      }
      if ((t & 7) === 0) {
        e: {
          if (j = e === "mouseover" || e === "pointerover", $ = e === "mouseout" || e === "pointerout", j && n !== Zt && (H = n.relatedTarget || n.fromElement) && (Qn(H) || H[dn])) break e;
          if (($ || j) && (j = N.window === N ? N : (j = N.ownerDocument) ? j.defaultView || j.parentWindow : window, $ ? (H = n.relatedTarget || n.toElement, $ = w, H = H ? Qn(H) : null, H !== null && (Ke = vt(H), H !== Ke || H.tag !== 5 && H.tag !== 6) && (H = null)) : ($ = null, H = w), $ !== H)) {
            if (Q = Us, L = "onMouseLeave", m = "onMouseEnter", h = "mouse", (e === "pointerout" || e === "pointerover") && (Q = Hs, L = "onPointerLeave", m = "onPointerEnter", h = "pointer"), Ke = $ == null ? j : vr($), g = H == null ? j : vr(H), j = new Q(L, h + "leave", $, n, N), j.target = Ke, j.relatedTarget = g, L = null, Qn(N) === w && (Q = new Q(m, h + "enter", H, n, N), Q.target = g, Q.relatedTarget = Ke, L = Q), Ke = L, $ && H) t: {
              for (Q = $, m = H, h = 0, g = Q; g; g = hr(g)) h++;
              for (g = 0, L = m; L; L = hr(L)) g++;
              for (; 0 < h - g; ) Q = hr(Q), h--;
              for (; 0 < g - h; ) m = hr(m), g--;
              for (; h--; ) {
                if (Q === m || m !== null && Q === m.alternate) break t;
                Q = hr(Q), m = hr(m);
              }
              Q = null;
            }
            else Q = null;
            $ !== null && vu(R, j, $, Q, !1), H !== null && Ke !== null && vu(R, Ke, H, Q, !0);
          }
        }
        e: {
          if (j = w ? vr(w) : window, $ = j.nodeName && j.nodeName.toLowerCase(), $ === "select" || $ === "input" && j.type === "file") var G = yf;
          else if (Gs(j)) if (Zs) G = kf;
          else {
            G = wf;
            var ie = gf;
          }
          else ($ = j.nodeName) && $.toLowerCase() === "input" && (j.type === "checkbox" || j.type === "radio") && (G = xf);
          if (G && (G = G(e, w))) {
            qs(R, G, n, N);
            break e;
          }
          ie && ie(e, j, w), e === "focusout" && (ie = j._wrapperState) && ie.controlled && j.type === "number" && Ie(j, "number", j.value);
        }
        switch (ie = w ? vr(w) : window, e) {
          case "focusin":
            (Gs(ie) || ie.contentEditable === "true") && (dr = ie, bi = w, br = null);
            break;
          case "focusout":
            br = bi = dr = null;
            break;
          case "mousedown":
            eo = !0;
            break;
          case "contextmenu":
          case "mouseup":
          case "dragend":
            eo = !1, iu(R, n, N);
            break;
          case "selectionchange":
            if (Ef) break;
          case "keydown":
          case "keyup":
            iu(R, n, N);
        }
        var oe;
        if (Gi) e: {
          switch (e) {
            case "compositionstart":
              var ue = "onCompositionStart";
              break e;
            case "compositionend":
              ue = "onCompositionEnd";
              break e;
            case "compositionupdate":
              ue = "onCompositionUpdate";
              break e;
          }
          ue = void 0;
        }
        else fr ? Ys(e, n) && (ue = "onCompositionEnd") : e === "keydown" && n.keyCode === 229 && (ue = "onCompositionStart");
        ue && (Vs && n.locale !== "ko" && (fr || ue !== "onCompositionStart" ? ue === "onCompositionEnd" && fr && (oe = $s()) : (Rn = N, Hi = "value" in Rn ? Rn.value : Rn.textContent, fr = !0)), ie = Hl(w, ue), 0 < ie.length && (ue = new Bs(ue, e, null, n, N), R.push({ event: ue, listeners: ie }), oe ? ue.data = oe : (oe = Xs(n), oe !== null && (ue.data = oe)))), (oe = df ? pf(e, n) : hf(e, n)) && (w = Hl(w, "onBeforeInput"), 0 < w.length && (N = new Bs("onBeforeInput", "beforeinput", null, n, N), R.push({ event: N, listeners: w }), N.data = oe));
      }
      hu(R, t);
    });
  }
  function nl(e, t, n) {
    return { instance: e, listener: t, currentTarget: n };
  }
  function Hl(e, t) {
    for (var n = t + "Capture", r = []; e !== null; ) {
      var l = e, i = l.stateNode;
      l.tag === 5 && i !== null && (l = i, i = We(e, n), i != null && r.unshift(nl(e, i, l)), i = We(e, t), i != null && r.push(nl(e, i, l))), e = e.return;
    }
    return r;
  }
  function hr(e) {
    if (e === null) return null;
    do
      e = e.return;
    while (e && e.tag !== 5);
    return e || null;
  }
  function vu(e, t, n, r, l) {
    for (var i = t._reactName, o = []; n !== null && n !== r; ) {
      var c = n, d = c.alternate, w = c.stateNode;
      if (d !== null && d === r) break;
      c.tag === 5 && w !== null && (c = w, l ? (d = We(n, i), d != null && o.unshift(nl(n, d, c))) : l || (d = We(n, i), d != null && o.push(nl(n, d, c)))), n = n.return;
    }
    o.length !== 0 && e.push({ event: t, listeners: o });
  }
  var Rf = /\r\n?/g, Lf = /\u0000|\uFFFD/g;
  function yu(e) {
    return (typeof e == "string" ? e : "" + e).replace(Rf, `
`).replace(Lf, "");
  }
  function Vl(e, t, n) {
    if (t = yu(t), yu(e) !== t && n) throw Error(f(425));
  }
  function Ql() {
  }
  var oo = null, so = null;
  function uo(e, t) {
    return e === "textarea" || e === "noscript" || typeof t.children == "string" || typeof t.children == "number" || typeof t.dangerouslySetInnerHTML == "object" && t.dangerouslySetInnerHTML !== null && t.dangerouslySetInnerHTML.__html != null;
  }
  var ao = typeof setTimeout == "function" ? setTimeout : void 0, zf = typeof clearTimeout == "function" ? clearTimeout : void 0, gu = typeof Promise == "function" ? Promise : void 0, Mf = typeof queueMicrotask == "function" ? queueMicrotask : typeof gu < "u" ? function(e) {
    return gu.resolve(null).then(e).catch(Pf);
  } : ao;
  function Pf(e) {
    setTimeout(function() {
      throw e;
    });
  }
  function co(e, t) {
    var n = t, r = 0;
    do {
      var l = n.nextSibling;
      if (e.removeChild(n), l && l.nodeType === 8) if (n = l.data, n === "/$") {
        if (r === 0) {
          e.removeChild(l), Kr(t);
          return;
        }
        r--;
      } else n !== "$" && n !== "$?" && n !== "$!" || r++;
      n = l;
    } while (n);
    Kr(t);
  }
  function zn(e) {
    for (; e != null; e = e.nextSibling) {
      var t = e.nodeType;
      if (t === 1 || t === 3) break;
      if (t === 8) {
        if (t = e.data, t === "$" || t === "$!" || t === "$?") break;
        if (t === "/$") return null;
      }
    }
    return e;
  }
  function wu(e) {
    e = e.previousSibling;
    for (var t = 0; e; ) {
      if (e.nodeType === 8) {
        var n = e.data;
        if (n === "$" || n === "$!" || n === "$?") {
          if (t === 0) return e;
          t--;
        } else n === "/$" && t++;
      }
      e = e.previousSibling;
    }
    return null;
  }
  var mr = Math.random().toString(36).slice(2), en = "__reactFiber$" + mr, rl = "__reactProps$" + mr, dn = "__reactContainer$" + mr, fo = "__reactEvents$" + mr, Tf = "__reactListeners$" + mr, Of = "__reactHandles$" + mr;
  function Qn(e) {
    var t = e[en];
    if (t) return t;
    for (var n = e.parentNode; n; ) {
      if (t = n[dn] || n[en]) {
        if (n = t.alternate, t.child !== null || n !== null && n.child !== null) for (e = wu(e); e !== null; ) {
          if (n = e[en]) return n;
          e = wu(e);
        }
        return t;
      }
      e = n, n = e.parentNode;
    }
    return null;
  }
  function ll(e) {
    return e = e[en] || e[dn], !e || e.tag !== 5 && e.tag !== 6 && e.tag !== 13 && e.tag !== 3 ? null : e;
  }
  function vr(e) {
    if (e.tag === 5 || e.tag === 6) return e.stateNode;
    throw Error(f(33));
  }
  function Kl(e) {
    return e[rl] || null;
  }
  var po = [], yr = -1;
  function Mn(e) {
    return { current: e };
  }
  function $e(e) {
    0 > yr || (e.current = po[yr], po[yr] = null, yr--);
  }
  function Ae(e, t) {
    yr++, po[yr] = e.current, e.current = t;
  }
  var Pn = {}, ot = Mn(Pn), gt = Mn(!1), Kn = Pn;
  function gr(e, t) {
    var n = e.type.contextTypes;
    if (!n) return Pn;
    var r = e.stateNode;
    if (r && r.__reactInternalMemoizedUnmaskedChildContext === t) return r.__reactInternalMemoizedMaskedChildContext;
    var l = {}, i;
    for (i in n) l[i] = t[i];
    return r && (e = e.stateNode, e.__reactInternalMemoizedUnmaskedChildContext = t, e.__reactInternalMemoizedMaskedChildContext = l), l;
  }
  function wt(e) {
    return e = e.childContextTypes, e != null;
  }
  function Yl() {
    $e(gt), $e(ot);
  }
  function xu(e, t, n) {
    if (ot.current !== Pn) throw Error(f(168));
    Ae(ot, t), Ae(gt, n);
  }
  function ku(e, t, n) {
    var r = e.stateNode;
    if (t = t.childContextTypes, typeof r.getChildContext != "function") return n;
    r = r.getChildContext();
    for (var l in r) if (!(l in t)) throw Error(f(108, q(e) || "Unknown", l));
    return O({}, n, r);
  }
  function Xl(e) {
    return e = (e = e.stateNode) && e.__reactInternalMemoizedMergedChildContext || Pn, Kn = ot.current, Ae(ot, e), Ae(gt, gt.current), !0;
  }
  function Su(e, t, n) {
    var r = e.stateNode;
    if (!r) throw Error(f(169));
    n ? (e = ku(e, t, Kn), r.__reactInternalMemoizedMergedChildContext = e, $e(gt), $e(ot), Ae(ot, e)) : $e(gt), Ae(gt, n);
  }
  var pn = null, Gl = !1, ho = !1;
  function _u(e) {
    pn === null ? pn = [e] : pn.push(e);
  }
  function Ff(e) {
    Gl = !0, _u(e);
  }
  function Tn() {
    if (!ho && pn !== null) {
      ho = !0;
      var e = 0, t = Me;
      try {
        var n = pn;
        for (Me = 1; e < n.length; e++) {
          var r = n[e];
          do
            r = r(!0);
          while (r !== null);
        }
        pn = null, Gl = !1;
      } catch (l) {
        throw pn !== null && (pn = pn.slice(e + 1)), $r(Fi, Tn), l;
      } finally {
        Me = t, ho = !1;
      }
    }
    return null;
  }
  var wr = [], xr = 0, ql = null, Zl = 0, Mt = [], Pt = 0, Yn = null, hn = 1, mn = "";
  function Xn(e, t) {
    wr[xr++] = Zl, wr[xr++] = ql, ql = e, Zl = t;
  }
  function Eu(e, t, n) {
    Mt[Pt++] = hn, Mt[Pt++] = mn, Mt[Pt++] = Yn, Yn = e;
    var r = hn;
    e = mn;
    var l = 32 - Ut(r) - 1;
    r &= ~(1 << l), n += 1;
    var i = 32 - Ut(t) + l;
    if (30 < i) {
      var o = l - l % 5;
      i = (r & (1 << o) - 1).toString(32), r >>= o, l -= o, hn = 1 << 32 - Ut(t) + l | n << l | r, mn = i + e;
    } else hn = 1 << i | n << l | r, mn = e;
  }
  function mo(e) {
    e.return !== null && (Xn(e, 1), Eu(e, 1, 0));
  }
  function vo(e) {
    for (; e === ql; ) ql = wr[--xr], wr[xr] = null, Zl = wr[--xr], wr[xr] = null;
    for (; e === Yn; ) Yn = Mt[--Pt], Mt[Pt] = null, mn = Mt[--Pt], Mt[Pt] = null, hn = Mt[--Pt], Mt[Pt] = null;
  }
  var Nt = null, Rt = null, Ue = !1, Ht = null;
  function Cu(e, t) {
    var n = It(5, null, null, 0);
    n.elementType = "DELETED", n.stateNode = t, n.return = e, t = e.deletions, t === null ? (e.deletions = [n], e.flags |= 16) : t.push(n);
  }
  function ju(e, t) {
    switch (e.tag) {
      case 5:
        var n = e.type;
        return t = t.nodeType !== 1 || n.toLowerCase() !== t.nodeName.toLowerCase() ? null : t, t !== null ? (e.stateNode = t, Nt = e, Rt = zn(t.firstChild), !0) : !1;
      case 6:
        return t = e.pendingProps === "" || t.nodeType !== 3 ? null : t, t !== null ? (e.stateNode = t, Nt = e, Rt = null, !0) : !1;
      case 13:
        return t = t.nodeType !== 8 ? null : t, t !== null ? (n = Yn !== null ? { id: hn, overflow: mn } : null, e.memoizedState = { dehydrated: t, treeContext: n, retryLane: 1073741824 }, n = It(18, null, null, 0), n.stateNode = t, n.return = e, e.child = n, Nt = e, Rt = null, !0) : !1;
      default:
        return !1;
    }
  }
  function yo(e) {
    return (e.mode & 1) !== 0 && (e.flags & 128) === 0;
  }
  function go(e) {
    if (Ue) {
      var t = Rt;
      if (t) {
        var n = t;
        if (!ju(e, t)) {
          if (yo(e)) throw Error(f(418));
          t = zn(n.nextSibling);
          var r = Nt;
          t && ju(e, t) ? Cu(r, n) : (e.flags = e.flags & -4097 | 2, Ue = !1, Nt = e);
        }
      } else {
        if (yo(e)) throw Error(f(418));
        e.flags = e.flags & -4097 | 2, Ue = !1, Nt = e;
      }
    }
  }
  function Nu(e) {
    for (e = e.return; e !== null && e.tag !== 5 && e.tag !== 3 && e.tag !== 13; ) e = e.return;
    Nt = e;
  }
  function Jl(e) {
    if (e !== Nt) return !1;
    if (!Ue) return Nu(e), Ue = !0, !1;
    var t;
    if ((t = e.tag !== 3) && !(t = e.tag !== 5) && (t = e.type, t = t !== "head" && t !== "body" && !uo(e.type, e.memoizedProps)), t && (t = Rt)) {
      if (yo(e)) throw Ru(), Error(f(418));
      for (; t; ) Cu(e, t), t = zn(t.nextSibling);
    }
    if (Nu(e), e.tag === 13) {
      if (e = e.memoizedState, e = e !== null ? e.dehydrated : null, !e) throw Error(f(317));
      e: {
        for (e = e.nextSibling, t = 0; e; ) {
          if (e.nodeType === 8) {
            var n = e.data;
            if (n === "/$") {
              if (t === 0) {
                Rt = zn(e.nextSibling);
                break e;
              }
              t--;
            } else n !== "$" && n !== "$!" && n !== "$?" || t++;
          }
          e = e.nextSibling;
        }
        Rt = null;
      }
    } else Rt = Nt ? zn(e.stateNode.nextSibling) : null;
    return !0;
  }
  function Ru() {
    for (var e = Rt; e; ) e = zn(e.nextSibling);
  }
  function kr() {
    Rt = Nt = null, Ue = !1;
  }
  function wo(e) {
    Ht === null ? Ht = [e] : Ht.push(e);
  }
  var If = xe.ReactCurrentBatchConfig;
  function il(e, t, n) {
    if (e = n.ref, e !== null && typeof e != "function" && typeof e != "object") {
      if (n._owner) {
        if (n = n._owner, n) {
          if (n.tag !== 1) throw Error(f(309));
          var r = n.stateNode;
        }
        if (!r) throw Error(f(147, e));
        var l = r, i = "" + e;
        return t !== null && t.ref !== null && typeof t.ref == "function" && t.ref._stringRef === i ? t.ref : (t = function(o) {
          var c = l.refs;
          o === null ? delete c[i] : c[i] = o;
        }, t._stringRef = i, t);
      }
      if (typeof e != "string") throw Error(f(284));
      if (!n._owner) throw Error(f(290, e));
    }
    return e;
  }
  function bl(e, t) {
    throw e = Object.prototype.toString.call(t), Error(f(31, e === "[object Object]" ? "object with keys {" + Object.keys(t).join(", ") + "}" : e));
  }
  function Lu(e) {
    var t = e._init;
    return t(e._payload);
  }
  function zu(e) {
    function t(m, h) {
      if (e) {
        var g = m.deletions;
        g === null ? (m.deletions = [h], m.flags |= 16) : g.push(h);
      }
    }
    function n(m, h) {
      if (!e) return null;
      for (; h !== null; ) t(m, h), h = h.sibling;
      return null;
    }
    function r(m, h) {
      for (m = /* @__PURE__ */ new Map(); h !== null; ) h.key !== null ? m.set(h.key, h) : m.set(h.index, h), h = h.sibling;
      return m;
    }
    function l(m, h) {
      return m = Un(m, h), m.index = 0, m.sibling = null, m;
    }
    function i(m, h, g) {
      return m.index = g, e ? (g = m.alternate, g !== null ? (g = g.index, g < h ? (m.flags |= 2, h) : g) : (m.flags |= 2, h)) : (m.flags |= 1048576, h);
    }
    function o(m) {
      return e && m.alternate === null && (m.flags |= 2), m;
    }
    function c(m, h, g, L) {
      return h === null || h.tag !== 6 ? (h = cs(g, m.mode, L), h.return = m, h) : (h = l(h, g), h.return = m, h);
    }
    function d(m, h, g, L) {
      var G = g.type;
      return G === B ? N(m, h, g.props.children, L, g.key) : h !== null && (h.elementType === G || typeof G == "object" && G !== null && G.$$typeof === Ce && Lu(G) === h.type) ? (L = l(h, g.props), L.ref = il(m, h, g), L.return = m, L) : (L = _i(g.type, g.key, g.props, null, m.mode, L), L.ref = il(m, h, g), L.return = m, L);
    }
    function w(m, h, g, L) {
      return h === null || h.tag !== 4 || h.stateNode.containerInfo !== g.containerInfo || h.stateNode.implementation !== g.implementation ? (h = fs(g, m.mode, L), h.return = m, h) : (h = l(h, g.children || []), h.return = m, h);
    }
    function N(m, h, g, L, G) {
      return h === null || h.tag !== 7 ? (h = nr(g, m.mode, L, G), h.return = m, h) : (h = l(h, g), h.return = m, h);
    }
    function R(m, h, g) {
      if (typeof h == "string" && h !== "" || typeof h == "number") return h = cs("" + h, m.mode, g), h.return = m, h;
      if (typeof h == "object" && h !== null) {
        switch (h.$$typeof) {
          case te:
            return g = _i(h.type, h.key, h.props, null, m.mode, g), g.ref = il(m, null, h), g.return = m, g;
          case Ne:
            return h = fs(h, m.mode, g), h.return = m, h;
          case Ce:
            var L = h._init;
            return R(m, L(h._payload), g);
        }
        if (Se(h) || K(h)) return h = nr(h, m.mode, g, null), h.return = m, h;
        bl(m, h);
      }
      return null;
    }
    function j(m, h, g, L) {
      var G = h !== null ? h.key : null;
      if (typeof g == "string" && g !== "" || typeof g == "number") return G !== null ? null : c(m, h, "" + g, L);
      if (typeof g == "object" && g !== null) {
        switch (g.$$typeof) {
          case te:
            return g.key === G ? d(m, h, g, L) : null;
          case Ne:
            return g.key === G ? w(m, h, g, L) : null;
          case Ce:
            return G = g._init, j(
              m,
              h,
              G(g._payload),
              L
            );
        }
        if (Se(g) || K(g)) return G !== null ? null : N(m, h, g, L, null);
        bl(m, g);
      }
      return null;
    }
    function $(m, h, g, L, G) {
      if (typeof L == "string" && L !== "" || typeof L == "number") return m = m.get(g) || null, c(h, m, "" + L, G);
      if (typeof L == "object" && L !== null) {
        switch (L.$$typeof) {
          case te:
            return m = m.get(L.key === null ? g : L.key) || null, d(h, m, L, G);
          case Ne:
            return m = m.get(L.key === null ? g : L.key) || null, w(h, m, L, G);
          case Ce:
            var ie = L._init;
            return $(m, h, g, ie(L._payload), G);
        }
        if (Se(L) || K(L)) return m = m.get(g) || null, N(h, m, L, G, null);
        bl(h, L);
      }
      return null;
    }
    function H(m, h, g, L) {
      for (var G = null, ie = null, oe = h, ue = h = 0, et = null; oe !== null && ue < g.length; ue++) {
        oe.index > ue ? (et = oe, oe = null) : et = oe.sibling;
        var je = j(m, oe, g[ue], L);
        if (je === null) {
          oe === null && (oe = et);
          break;
        }
        e && oe && je.alternate === null && t(m, oe), h = i(je, h, ue), ie === null ? G = je : ie.sibling = je, ie = je, oe = et;
      }
      if (ue === g.length) return n(m, oe), Ue && Xn(m, ue), G;
      if (oe === null) {
        for (; ue < g.length; ue++) oe = R(m, g[ue], L), oe !== null && (h = i(oe, h, ue), ie === null ? G = oe : ie.sibling = oe, ie = oe);
        return Ue && Xn(m, ue), G;
      }
      for (oe = r(m, oe); ue < g.length; ue++) et = $(oe, m, ue, g[ue], L), et !== null && (e && et.alternate !== null && oe.delete(et.key === null ? ue : et.key), h = i(et, h, ue), ie === null ? G = et : ie.sibling = et, ie = et);
      return e && oe.forEach(function(Bn) {
        return t(m, Bn);
      }), Ue && Xn(m, ue), G;
    }
    function Q(m, h, g, L) {
      var G = K(g);
      if (typeof G != "function") throw Error(f(150));
      if (g = G.call(g), g == null) throw Error(f(151));
      for (var ie = G = null, oe = h, ue = h = 0, et = null, je = g.next(); oe !== null && !je.done; ue++, je = g.next()) {
        oe.index > ue ? (et = oe, oe = null) : et = oe.sibling;
        var Bn = j(m, oe, je.value, L);
        if (Bn === null) {
          oe === null && (oe = et);
          break;
        }
        e && oe && Bn.alternate === null && t(m, oe), h = i(Bn, h, ue), ie === null ? G = Bn : ie.sibling = Bn, ie = Bn, oe = et;
      }
      if (je.done) return n(
        m,
        oe
      ), Ue && Xn(m, ue), G;
      if (oe === null) {
        for (; !je.done; ue++, je = g.next()) je = R(m, je.value, L), je !== null && (h = i(je, h, ue), ie === null ? G = je : ie.sibling = je, ie = je);
        return Ue && Xn(m, ue), G;
      }
      for (oe = r(m, oe); !je.done; ue++, je = g.next()) je = $(oe, m, ue, je.value, L), je !== null && (e && je.alternate !== null && oe.delete(je.key === null ? ue : je.key), h = i(je, h, ue), ie === null ? G = je : ie.sibling = je, ie = je);
      return e && oe.forEach(function(md) {
        return t(m, md);
      }), Ue && Xn(m, ue), G;
    }
    function Ke(m, h, g, L) {
      if (typeof g == "object" && g !== null && g.type === B && g.key === null && (g = g.props.children), typeof g == "object" && g !== null) {
        switch (g.$$typeof) {
          case te:
            e: {
              for (var G = g.key, ie = h; ie !== null; ) {
                if (ie.key === G) {
                  if (G = g.type, G === B) {
                    if (ie.tag === 7) {
                      n(m, ie.sibling), h = l(ie, g.props.children), h.return = m, m = h;
                      break e;
                    }
                  } else if (ie.elementType === G || typeof G == "object" && G !== null && G.$$typeof === Ce && Lu(G) === ie.type) {
                    n(m, ie.sibling), h = l(ie, g.props), h.ref = il(m, ie, g), h.return = m, m = h;
                    break e;
                  }
                  n(m, ie);
                  break;
                } else t(m, ie);
                ie = ie.sibling;
              }
              g.type === B ? (h = nr(g.props.children, m.mode, L, g.key), h.return = m, m = h) : (L = _i(g.type, g.key, g.props, null, m.mode, L), L.ref = il(m, h, g), L.return = m, m = L);
            }
            return o(m);
          case Ne:
            e: {
              for (ie = g.key; h !== null; ) {
                if (h.key === ie) if (h.tag === 4 && h.stateNode.containerInfo === g.containerInfo && h.stateNode.implementation === g.implementation) {
                  n(m, h.sibling), h = l(h, g.children || []), h.return = m, m = h;
                  break e;
                } else {
                  n(m, h);
                  break;
                }
                else t(m, h);
                h = h.sibling;
              }
              h = fs(g, m.mode, L), h.return = m, m = h;
            }
            return o(m);
          case Ce:
            return ie = g._init, Ke(m, h, ie(g._payload), L);
        }
        if (Se(g)) return H(m, h, g, L);
        if (K(g)) return Q(m, h, g, L);
        bl(m, g);
      }
      return typeof g == "string" && g !== "" || typeof g == "number" ? (g = "" + g, h !== null && h.tag === 6 ? (n(m, h.sibling), h = l(h, g), h.return = m, m = h) : (n(m, h), h = cs(g, m.mode, L), h.return = m, m = h), o(m)) : n(m, h);
    }
    return Ke;
  }
  var Sr = zu(!0), Mu = zu(!1), ei = Mn(null), ti = null, _r = null, xo = null;
  function ko() {
    xo = _r = ti = null;
  }
  function So(e) {
    var t = ei.current;
    $e(ei), e._currentValue = t;
  }
  function _o(e, t, n) {
    for (; e !== null; ) {
      var r = e.alternate;
      if ((e.childLanes & t) !== t ? (e.childLanes |= t, r !== null && (r.childLanes |= t)) : r !== null && (r.childLanes & t) !== t && (r.childLanes |= t), e === n) break;
      e = e.return;
    }
  }
  function Er(e, t) {
    ti = e, xo = _r = null, e = e.dependencies, e !== null && e.firstContext !== null && ((e.lanes & t) !== 0 && (xt = !0), e.firstContext = null);
  }
  function Tt(e) {
    var t = e._currentValue;
    if (xo !== e) if (e = { context: e, memoizedValue: t, next: null }, _r === null) {
      if (ti === null) throw Error(f(308));
      _r = e, ti.dependencies = { lanes: 0, firstContext: e };
    } else _r = _r.next = e;
    return t;
  }
  var Gn = null;
  function Eo(e) {
    Gn === null ? Gn = [e] : Gn.push(e);
  }
  function Pu(e, t, n, r) {
    var l = t.interleaved;
    return l === null ? (n.next = n, Eo(t)) : (n.next = l.next, l.next = n), t.interleaved = n, vn(e, r);
  }
  function vn(e, t) {
    e.lanes |= t;
    var n = e.alternate;
    for (n !== null && (n.lanes |= t), n = e, e = e.return; e !== null; ) e.childLanes |= t, n = e.alternate, n !== null && (n.childLanes |= t), n = e, e = e.return;
    return n.tag === 3 ? n.stateNode : null;
  }
  var On = !1;
  function Co(e) {
    e.updateQueue = { baseState: e.memoizedState, firstBaseUpdate: null, lastBaseUpdate: null, shared: { pending: null, interleaved: null, lanes: 0 }, effects: null };
  }
  function Tu(e, t) {
    e = e.updateQueue, t.updateQueue === e && (t.updateQueue = { baseState: e.baseState, firstBaseUpdate: e.firstBaseUpdate, lastBaseUpdate: e.lastBaseUpdate, shared: e.shared, effects: e.effects });
  }
  function yn(e, t) {
    return { eventTime: e, lane: t, tag: 0, payload: null, callback: null, next: null };
  }
  function Fn(e, t, n) {
    var r = e.updateQueue;
    if (r === null) return null;
    if (r = r.shared, (Ee & 2) !== 0) {
      var l = r.pending;
      return l === null ? t.next = t : (t.next = l.next, l.next = t), r.pending = t, vn(e, n);
    }
    return l = r.interleaved, l === null ? (t.next = t, Eo(r)) : (t.next = l.next, l.next = t), r.interleaved = t, vn(e, n);
  }
  function ni(e, t, n) {
    if (t = t.updateQueue, t !== null && (t = t.shared, (n & 4194240) !== 0)) {
      var r = t.lanes;
      r &= e.pendingLanes, n |= r, t.lanes = n, Di(e, n);
    }
  }
  function Ou(e, t) {
    var n = e.updateQueue, r = e.alternate;
    if (r !== null && (r = r.updateQueue, n === r)) {
      var l = null, i = null;
      if (n = n.firstBaseUpdate, n !== null) {
        do {
          var o = { eventTime: n.eventTime, lane: n.lane, tag: n.tag, payload: n.payload, callback: n.callback, next: null };
          i === null ? l = i = o : i = i.next = o, n = n.next;
        } while (n !== null);
        i === null ? l = i = t : i = i.next = t;
      } else l = i = t;
      n = { baseState: r.baseState, firstBaseUpdate: l, lastBaseUpdate: i, shared: r.shared, effects: r.effects }, e.updateQueue = n;
      return;
    }
    e = n.lastBaseUpdate, e === null ? n.firstBaseUpdate = t : e.next = t, n.lastBaseUpdate = t;
  }
  function ri(e, t, n, r) {
    var l = e.updateQueue;
    On = !1;
    var i = l.firstBaseUpdate, o = l.lastBaseUpdate, c = l.shared.pending;
    if (c !== null) {
      l.shared.pending = null;
      var d = c, w = d.next;
      d.next = null, o === null ? i = w : o.next = w, o = d;
      var N = e.alternate;
      N !== null && (N = N.updateQueue, c = N.lastBaseUpdate, c !== o && (c === null ? N.firstBaseUpdate = w : c.next = w, N.lastBaseUpdate = d));
    }
    if (i !== null) {
      var R = l.baseState;
      o = 0, N = w = d = null, c = i;
      do {
        var j = c.lane, $ = c.eventTime;
        if ((r & j) === j) {
          N !== null && (N = N.next = {
            eventTime: $,
            lane: 0,
            tag: c.tag,
            payload: c.payload,
            callback: c.callback,
            next: null
          });
          e: {
            var H = e, Q = c;
            switch (j = t, $ = n, Q.tag) {
              case 1:
                if (H = Q.payload, typeof H == "function") {
                  R = H.call($, R, j);
                  break e;
                }
                R = H;
                break e;
              case 3:
                H.flags = H.flags & -65537 | 128;
              case 0:
                if (H = Q.payload, j = typeof H == "function" ? H.call($, R, j) : H, j == null) break e;
                R = O({}, R, j);
                break e;
              case 2:
                On = !0;
            }
          }
          c.callback !== null && c.lane !== 0 && (e.flags |= 64, j = l.effects, j === null ? l.effects = [c] : j.push(c));
        } else $ = { eventTime: $, lane: j, tag: c.tag, payload: c.payload, callback: c.callback, next: null }, N === null ? (w = N = $, d = R) : N = N.next = $, o |= j;
        if (c = c.next, c === null) {
          if (c = l.shared.pending, c === null) break;
          j = c, c = j.next, j.next = null, l.lastBaseUpdate = j, l.shared.pending = null;
        }
      } while (!0);
      if (N === null && (d = R), l.baseState = d, l.firstBaseUpdate = w, l.lastBaseUpdate = N, t = l.shared.interleaved, t !== null) {
        l = t;
        do
          o |= l.lane, l = l.next;
        while (l !== t);
      } else i === null && (l.shared.lanes = 0);
      Jn |= o, e.lanes = o, e.memoizedState = R;
    }
  }
  function Fu(e, t, n) {
    if (e = t.effects, t.effects = null, e !== null) for (t = 0; t < e.length; t++) {
      var r = e[t], l = r.callback;
      if (l !== null) {
        if (r.callback = null, r = n, typeof l != "function") throw Error(f(191, l));
        l.call(r);
      }
    }
  }
  var ol = {}, tn = Mn(ol), sl = Mn(ol), ul = Mn(ol);
  function qn(e) {
    if (e === ol) throw Error(f(174));
    return e;
  }
  function jo(e, t) {
    switch (Ae(ul, t), Ae(sl, e), Ae(tn, ol), e = t.nodeType, e) {
      case 9:
      case 11:
        t = (t = t.documentElement) ? t.namespaceURI : sn(null, "");
        break;
      default:
        e = e === 8 ? t.parentNode : t, t = e.namespaceURI || null, e = e.tagName, t = sn(t, e);
    }
    $e(tn), Ae(tn, t);
  }
  function Cr() {
    $e(tn), $e(sl), $e(ul);
  }
  function Iu(e) {
    qn(ul.current);
    var t = qn(tn.current), n = sn(t, e.type);
    t !== n && (Ae(sl, e), Ae(tn, n));
  }
  function No(e) {
    sl.current === e && ($e(tn), $e(sl));
  }
  var Be = Mn(0);
  function li(e) {
    for (var t = e; t !== null; ) {
      if (t.tag === 13) {
        var n = t.memoizedState;
        if (n !== null && (n = n.dehydrated, n === null || n.data === "$?" || n.data === "$!")) return t;
      } else if (t.tag === 19 && t.memoizedProps.revealOrder !== void 0) {
        if ((t.flags & 128) !== 0) return t;
      } else if (t.child !== null) {
        t.child.return = t, t = t.child;
        continue;
      }
      if (t === e) break;
      for (; t.sibling === null; ) {
        if (t.return === null || t.return === e) return null;
        t = t.return;
      }
      t.sibling.return = t.return, t = t.sibling;
    }
    return null;
  }
  var Ro = [];
  function Lo() {
    for (var e = 0; e < Ro.length; e++) Ro[e]._workInProgressVersionPrimary = null;
    Ro.length = 0;
  }
  var ii = xe.ReactCurrentDispatcher, zo = xe.ReactCurrentBatchConfig, Zn = 0, He = null, Ge = null, Je = null, oi = !1, al = !1, cl = 0, Af = 0;
  function st() {
    throw Error(f(321));
  }
  function Mo(e, t) {
    if (t === null) return !1;
    for (var n = 0; n < t.length && n < e.length; n++) if (!Bt(e[n], t[n])) return !1;
    return !0;
  }
  function Po(e, t, n, r, l, i) {
    if (Zn = i, He = t, t.memoizedState = null, t.updateQueue = null, t.lanes = 0, ii.current = e === null || e.memoizedState === null ? Uf : Bf, e = n(r, l), al) {
      i = 0;
      do {
        if (al = !1, cl = 0, 25 <= i) throw Error(f(301));
        i += 1, Je = Ge = null, t.updateQueue = null, ii.current = Hf, e = n(r, l);
      } while (al);
    }
    if (ii.current = ai, t = Ge !== null && Ge.next !== null, Zn = 0, Je = Ge = He = null, oi = !1, t) throw Error(f(300));
    return e;
  }
  function To() {
    var e = cl !== 0;
    return cl = 0, e;
  }
  function nn() {
    var e = { memoizedState: null, baseState: null, baseQueue: null, queue: null, next: null };
    return Je === null ? He.memoizedState = Je = e : Je = Je.next = e, Je;
  }
  function Ot() {
    if (Ge === null) {
      var e = He.alternate;
      e = e !== null ? e.memoizedState : null;
    } else e = Ge.next;
    var t = Je === null ? He.memoizedState : Je.next;
    if (t !== null) Je = t, Ge = e;
    else {
      if (e === null) throw Error(f(310));
      Ge = e, e = { memoizedState: Ge.memoizedState, baseState: Ge.baseState, baseQueue: Ge.baseQueue, queue: Ge.queue, next: null }, Je === null ? He.memoizedState = Je = e : Je = Je.next = e;
    }
    return Je;
  }
  function fl(e, t) {
    return typeof t == "function" ? t(e) : t;
  }
  function Oo(e) {
    var t = Ot(), n = t.queue;
    if (n === null) throw Error(f(311));
    n.lastRenderedReducer = e;
    var r = Ge, l = r.baseQueue, i = n.pending;
    if (i !== null) {
      if (l !== null) {
        var o = l.next;
        l.next = i.next, i.next = o;
      }
      r.baseQueue = l = i, n.pending = null;
    }
    if (l !== null) {
      i = l.next, r = r.baseState;
      var c = o = null, d = null, w = i;
      do {
        var N = w.lane;
        if ((Zn & N) === N) d !== null && (d = d.next = { lane: 0, action: w.action, hasEagerState: w.hasEagerState, eagerState: w.eagerState, next: null }), r = w.hasEagerState ? w.eagerState : e(r, w.action);
        else {
          var R = {
            lane: N,
            action: w.action,
            hasEagerState: w.hasEagerState,
            eagerState: w.eagerState,
            next: null
          };
          d === null ? (c = d = R, o = r) : d = d.next = R, He.lanes |= N, Jn |= N;
        }
        w = w.next;
      } while (w !== null && w !== i);
      d === null ? o = r : d.next = c, Bt(r, t.memoizedState) || (xt = !0), t.memoizedState = r, t.baseState = o, t.baseQueue = d, n.lastRenderedState = r;
    }
    if (e = n.interleaved, e !== null) {
      l = e;
      do
        i = l.lane, He.lanes |= i, Jn |= i, l = l.next;
      while (l !== e);
    } else l === null && (n.lanes = 0);
    return [t.memoizedState, n.dispatch];
  }
  function Fo(e) {
    var t = Ot(), n = t.queue;
    if (n === null) throw Error(f(311));
    n.lastRenderedReducer = e;
    var r = n.dispatch, l = n.pending, i = t.memoizedState;
    if (l !== null) {
      n.pending = null;
      var o = l = l.next;
      do
        i = e(i, o.action), o = o.next;
      while (o !== l);
      Bt(i, t.memoizedState) || (xt = !0), t.memoizedState = i, t.baseQueue === null && (t.baseState = i), n.lastRenderedState = i;
    }
    return [i, r];
  }
  function Au() {
  }
  function Du(e, t) {
    var n = He, r = Ot(), l = t(), i = !Bt(r.memoizedState, l);
    if (i && (r.memoizedState = l, xt = !0), r = r.queue, Io(Uu.bind(null, n, r, e), [e]), r.getSnapshot !== t || i || Je !== null && Je.memoizedState.tag & 1) {
      if (n.flags |= 2048, dl(9, Wu.bind(null, n, r, l, t), void 0, null), be === null) throw Error(f(349));
      (Zn & 30) !== 0 || $u(n, t, l);
    }
    return l;
  }
  function $u(e, t, n) {
    e.flags |= 16384, e = { getSnapshot: t, value: n }, t = He.updateQueue, t === null ? (t = { lastEffect: null, stores: null }, He.updateQueue = t, t.stores = [e]) : (n = t.stores, n === null ? t.stores = [e] : n.push(e));
  }
  function Wu(e, t, n, r) {
    t.value = n, t.getSnapshot = r, Bu(t) && Hu(e);
  }
  function Uu(e, t, n) {
    return n(function() {
      Bu(t) && Hu(e);
    });
  }
  function Bu(e) {
    var t = e.getSnapshot;
    e = e.value;
    try {
      var n = t();
      return !Bt(e, n);
    } catch {
      return !0;
    }
  }
  function Hu(e) {
    var t = vn(e, 1);
    t !== null && Yt(t, e, 1, -1);
  }
  function Vu(e) {
    var t = nn();
    return typeof e == "function" && (e = e()), t.memoizedState = t.baseState = e, e = { pending: null, interleaved: null, lanes: 0, dispatch: null, lastRenderedReducer: fl, lastRenderedState: e }, t.queue = e, e = e.dispatch = Wf.bind(null, He, e), [t.memoizedState, e];
  }
  function dl(e, t, n, r) {
    return e = { tag: e, create: t, destroy: n, deps: r, next: null }, t = He.updateQueue, t === null ? (t = { lastEffect: null, stores: null }, He.updateQueue = t, t.lastEffect = e.next = e) : (n = t.lastEffect, n === null ? t.lastEffect = e.next = e : (r = n.next, n.next = e, e.next = r, t.lastEffect = e)), e;
  }
  function Qu() {
    return Ot().memoizedState;
  }
  function si(e, t, n, r) {
    var l = nn();
    He.flags |= e, l.memoizedState = dl(1 | t, n, void 0, r === void 0 ? null : r);
  }
  function ui(e, t, n, r) {
    var l = Ot();
    r = r === void 0 ? null : r;
    var i = void 0;
    if (Ge !== null) {
      var o = Ge.memoizedState;
      if (i = o.destroy, r !== null && Mo(r, o.deps)) {
        l.memoizedState = dl(t, n, i, r);
        return;
      }
    }
    He.flags |= e, l.memoizedState = dl(1 | t, n, i, r);
  }
  function Ku(e, t) {
    return si(8390656, 8, e, t);
  }
  function Io(e, t) {
    return ui(2048, 8, e, t);
  }
  function Yu(e, t) {
    return ui(4, 2, e, t);
  }
  function Xu(e, t) {
    return ui(4, 4, e, t);
  }
  function Gu(e, t) {
    if (typeof t == "function") return e = e(), t(e), function() {
      t(null);
    };
    if (t != null) return e = e(), t.current = e, function() {
      t.current = null;
    };
  }
  function qu(e, t, n) {
    return n = n != null ? n.concat([e]) : null, ui(4, 4, Gu.bind(null, t, e), n);
  }
  function Ao() {
  }
  function Zu(e, t) {
    var n = Ot();
    t = t === void 0 ? null : t;
    var r = n.memoizedState;
    return r !== null && t !== null && Mo(t, r[1]) ? r[0] : (n.memoizedState = [e, t], e);
  }
  function Ju(e, t) {
    var n = Ot();
    t = t === void 0 ? null : t;
    var r = n.memoizedState;
    return r !== null && t !== null && Mo(t, r[1]) ? r[0] : (e = e(), n.memoizedState = [e, t], e);
  }
  function bu(e, t, n) {
    return (Zn & 21) === 0 ? (e.baseState && (e.baseState = !1, xt = !0), e.memoizedState = n) : (Bt(n, t) || (n = Ls(), He.lanes |= n, Jn |= n, e.baseState = !0), t);
  }
  function Df(e, t) {
    var n = Me;
    Me = n !== 0 && 4 > n ? n : 4, e(!0);
    var r = zo.transition;
    zo.transition = {};
    try {
      e(!1), t();
    } finally {
      Me = n, zo.transition = r;
    }
  }
  function ea() {
    return Ot().memoizedState;
  }
  function $f(e, t, n) {
    var r = $n(e);
    if (n = { lane: r, action: n, hasEagerState: !1, eagerState: null, next: null }, ta(e)) na(t, n);
    else if (n = Pu(e, t, n, r), n !== null) {
      var l = dt();
      Yt(n, e, r, l), ra(n, t, r);
    }
  }
  function Wf(e, t, n) {
    var r = $n(e), l = { lane: r, action: n, hasEagerState: !1, eagerState: null, next: null };
    if (ta(e)) na(t, l);
    else {
      var i = e.alternate;
      if (e.lanes === 0 && (i === null || i.lanes === 0) && (i = t.lastRenderedReducer, i !== null)) try {
        var o = t.lastRenderedState, c = i(o, n);
        if (l.hasEagerState = !0, l.eagerState = c, Bt(c, o)) {
          var d = t.interleaved;
          d === null ? (l.next = l, Eo(t)) : (l.next = d.next, d.next = l), t.interleaved = l;
          return;
        }
      } catch {
      } finally {
      }
      n = Pu(e, t, l, r), n !== null && (l = dt(), Yt(n, e, r, l), ra(n, t, r));
    }
  }
  function ta(e) {
    var t = e.alternate;
    return e === He || t !== null && t === He;
  }
  function na(e, t) {
    al = oi = !0;
    var n = e.pending;
    n === null ? t.next = t : (t.next = n.next, n.next = t), e.pending = t;
  }
  function ra(e, t, n) {
    if ((n & 4194240) !== 0) {
      var r = t.lanes;
      r &= e.pendingLanes, n |= r, t.lanes = n, Di(e, n);
    }
  }
  var ai = { readContext: Tt, useCallback: st, useContext: st, useEffect: st, useImperativeHandle: st, useInsertionEffect: st, useLayoutEffect: st, useMemo: st, useReducer: st, useRef: st, useState: st, useDebugValue: st, useDeferredValue: st, useTransition: st, useMutableSource: st, useSyncExternalStore: st, useId: st, unstable_isNewReconciler: !1 }, Uf = { readContext: Tt, useCallback: function(e, t) {
    return nn().memoizedState = [e, t === void 0 ? null : t], e;
  }, useContext: Tt, useEffect: Ku, useImperativeHandle: function(e, t, n) {
    return n = n != null ? n.concat([e]) : null, si(
      4194308,
      4,
      Gu.bind(null, t, e),
      n
    );
  }, useLayoutEffect: function(e, t) {
    return si(4194308, 4, e, t);
  }, useInsertionEffect: function(e, t) {
    return si(4, 2, e, t);
  }, useMemo: function(e, t) {
    var n = nn();
    return t = t === void 0 ? null : t, e = e(), n.memoizedState = [e, t], e;
  }, useReducer: function(e, t, n) {
    var r = nn();
    return t = n !== void 0 ? n(t) : t, r.memoizedState = r.baseState = t, e = { pending: null, interleaved: null, lanes: 0, dispatch: null, lastRenderedReducer: e, lastRenderedState: t }, r.queue = e, e = e.dispatch = $f.bind(null, He, e), [r.memoizedState, e];
  }, useRef: function(e) {
    var t = nn();
    return e = { current: e }, t.memoizedState = e;
  }, useState: Vu, useDebugValue: Ao, useDeferredValue: function(e) {
    return nn().memoizedState = e;
  }, useTransition: function() {
    var e = Vu(!1), t = e[0];
    return e = Df.bind(null, e[1]), nn().memoizedState = e, [t, e];
  }, useMutableSource: function() {
  }, useSyncExternalStore: function(e, t, n) {
    var r = He, l = nn();
    if (Ue) {
      if (n === void 0) throw Error(f(407));
      n = n();
    } else {
      if (n = t(), be === null) throw Error(f(349));
      (Zn & 30) !== 0 || $u(r, t, n);
    }
    l.memoizedState = n;
    var i = { value: n, getSnapshot: t };
    return l.queue = i, Ku(Uu.bind(
      null,
      r,
      i,
      e
    ), [e]), r.flags |= 2048, dl(9, Wu.bind(null, r, i, n, t), void 0, null), n;
  }, useId: function() {
    var e = nn(), t = be.identifierPrefix;
    if (Ue) {
      var n = mn, r = hn;
      n = (r & ~(1 << 32 - Ut(r) - 1)).toString(32) + n, t = ":" + t + "R" + n, n = cl++, 0 < n && (t += "H" + n.toString(32)), t += ":";
    } else n = Af++, t = ":" + t + "r" + n.toString(32) + ":";
    return e.memoizedState = t;
  }, unstable_isNewReconciler: !1 }, Bf = {
    readContext: Tt,
    useCallback: Zu,
    useContext: Tt,
    useEffect: Io,
    useImperativeHandle: qu,
    useInsertionEffect: Yu,
    useLayoutEffect: Xu,
    useMemo: Ju,
    useReducer: Oo,
    useRef: Qu,
    useState: function() {
      return Oo(fl);
    },
    useDebugValue: Ao,
    useDeferredValue: function(e) {
      var t = Ot();
      return bu(t, Ge.memoizedState, e);
    },
    useTransition: function() {
      var e = Oo(fl)[0], t = Ot().memoizedState;
      return [e, t];
    },
    useMutableSource: Au,
    useSyncExternalStore: Du,
    useId: ea,
    unstable_isNewReconciler: !1
  }, Hf = { readContext: Tt, useCallback: Zu, useContext: Tt, useEffect: Io, useImperativeHandle: qu, useInsertionEffect: Yu, useLayoutEffect: Xu, useMemo: Ju, useReducer: Fo, useRef: Qu, useState: function() {
    return Fo(fl);
  }, useDebugValue: Ao, useDeferredValue: function(e) {
    var t = Ot();
    return Ge === null ? t.memoizedState = e : bu(t, Ge.memoizedState, e);
  }, useTransition: function() {
    var e = Fo(fl)[0], t = Ot().memoizedState;
    return [e, t];
  }, useMutableSource: Au, useSyncExternalStore: Du, useId: ea, unstable_isNewReconciler: !1 };
  function Vt(e, t) {
    if (e && e.defaultProps) {
      t = O({}, t), e = e.defaultProps;
      for (var n in e) t[n] === void 0 && (t[n] = e[n]);
      return t;
    }
    return t;
  }
  function Do(e, t, n, r) {
    t = e.memoizedState, n = n(r, t), n = n == null ? t : O({}, t, n), e.memoizedState = n, e.lanes === 0 && (e.updateQueue.baseState = n);
  }
  var ci = { isMounted: function(e) {
    return (e = e._reactInternals) ? vt(e) === e : !1;
  }, enqueueSetState: function(e, t, n) {
    e = e._reactInternals;
    var r = dt(), l = $n(e), i = yn(r, l);
    i.payload = t, n != null && (i.callback = n), t = Fn(e, i, l), t !== null && (Yt(t, e, l, r), ni(t, e, l));
  }, enqueueReplaceState: function(e, t, n) {
    e = e._reactInternals;
    var r = dt(), l = $n(e), i = yn(r, l);
    i.tag = 1, i.payload = t, n != null && (i.callback = n), t = Fn(e, i, l), t !== null && (Yt(t, e, l, r), ni(t, e, l));
  }, enqueueForceUpdate: function(e, t) {
    e = e._reactInternals;
    var n = dt(), r = $n(e), l = yn(n, r);
    l.tag = 2, t != null && (l.callback = t), t = Fn(e, l, r), t !== null && (Yt(t, e, r, n), ni(t, e, r));
  } };
  function la(e, t, n, r, l, i, o) {
    return e = e.stateNode, typeof e.shouldComponentUpdate == "function" ? e.shouldComponentUpdate(r, i, o) : t.prototype && t.prototype.isPureReactComponent ? !Jr(n, r) || !Jr(l, i) : !0;
  }
  function ia(e, t, n) {
    var r = !1, l = Pn, i = t.contextType;
    return typeof i == "object" && i !== null ? i = Tt(i) : (l = wt(t) ? Kn : ot.current, r = t.contextTypes, i = (r = r != null) ? gr(e, l) : Pn), t = new t(n, i), e.memoizedState = t.state !== null && t.state !== void 0 ? t.state : null, t.updater = ci, e.stateNode = t, t._reactInternals = e, r && (e = e.stateNode, e.__reactInternalMemoizedUnmaskedChildContext = l, e.__reactInternalMemoizedMaskedChildContext = i), t;
  }
  function oa(e, t, n, r) {
    e = t.state, typeof t.componentWillReceiveProps == "function" && t.componentWillReceiveProps(n, r), typeof t.UNSAFE_componentWillReceiveProps == "function" && t.UNSAFE_componentWillReceiveProps(n, r), t.state !== e && ci.enqueueReplaceState(t, t.state, null);
  }
  function $o(e, t, n, r) {
    var l = e.stateNode;
    l.props = n, l.state = e.memoizedState, l.refs = {}, Co(e);
    var i = t.contextType;
    typeof i == "object" && i !== null ? l.context = Tt(i) : (i = wt(t) ? Kn : ot.current, l.context = gr(e, i)), l.state = e.memoizedState, i = t.getDerivedStateFromProps, typeof i == "function" && (Do(e, t, i, n), l.state = e.memoizedState), typeof t.getDerivedStateFromProps == "function" || typeof l.getSnapshotBeforeUpdate == "function" || typeof l.UNSAFE_componentWillMount != "function" && typeof l.componentWillMount != "function" || (t = l.state, typeof l.componentWillMount == "function" && l.componentWillMount(), typeof l.UNSAFE_componentWillMount == "function" && l.UNSAFE_componentWillMount(), t !== l.state && ci.enqueueReplaceState(l, l.state, null), ri(e, n, l, r), l.state = e.memoizedState), typeof l.componentDidMount == "function" && (e.flags |= 4194308);
  }
  function jr(e, t) {
    try {
      var n = "", r = t;
      do
        n += E(r), r = r.return;
      while (r);
      var l = n;
    } catch (i) {
      l = `
Error generating stack: ` + i.message + `
` + i.stack;
    }
    return { value: e, source: t, stack: l, digest: null };
  }
  function Wo(e, t, n) {
    return { value: e, source: null, stack: n ?? null, digest: t ?? null };
  }
  function Uo(e, t) {
    try {
      console.error(t.value);
    } catch (n) {
      setTimeout(function() {
        throw n;
      });
    }
  }
  var Vf = typeof WeakMap == "function" ? WeakMap : Map;
  function sa(e, t, n) {
    n = yn(-1, n), n.tag = 3, n.payload = { element: null };
    var r = t.value;
    return n.callback = function() {
      yi || (yi = !0, ns = r), Uo(e, t);
    }, n;
  }
  function ua(e, t, n) {
    n = yn(-1, n), n.tag = 3;
    var r = e.type.getDerivedStateFromError;
    if (typeof r == "function") {
      var l = t.value;
      n.payload = function() {
        return r(l);
      }, n.callback = function() {
        Uo(e, t);
      };
    }
    var i = e.stateNode;
    return i !== null && typeof i.componentDidCatch == "function" && (n.callback = function() {
      Uo(e, t), typeof r != "function" && (An === null ? An = /* @__PURE__ */ new Set([this]) : An.add(this));
      var o = t.stack;
      this.componentDidCatch(t.value, { componentStack: o !== null ? o : "" });
    }), n;
  }
  function aa(e, t, n) {
    var r = e.pingCache;
    if (r === null) {
      r = e.pingCache = new Vf();
      var l = /* @__PURE__ */ new Set();
      r.set(t, l);
    } else l = r.get(t), l === void 0 && (l = /* @__PURE__ */ new Set(), r.set(t, l));
    l.has(n) || (l.add(n), e = ld.bind(null, e, t, n), t.then(e, e));
  }
  function ca(e) {
    do {
      var t;
      if ((t = e.tag === 13) && (t = e.memoizedState, t = t !== null ? t.dehydrated !== null : !0), t) return e;
      e = e.return;
    } while (e !== null);
    return null;
  }
  function fa(e, t, n, r, l) {
    return (e.mode & 1) === 0 ? (e === t ? e.flags |= 65536 : (e.flags |= 128, n.flags |= 131072, n.flags &= -52805, n.tag === 1 && (n.alternate === null ? n.tag = 17 : (t = yn(-1, 1), t.tag = 2, Fn(n, t, 1))), n.lanes |= 1), e) : (e.flags |= 65536, e.lanes = l, e);
  }
  var Qf = xe.ReactCurrentOwner, xt = !1;
  function ft(e, t, n, r) {
    t.child = e === null ? Mu(t, null, n, r) : Sr(t, e.child, n, r);
  }
  function da(e, t, n, r, l) {
    n = n.render;
    var i = t.ref;
    return Er(t, l), r = Po(e, t, n, r, i, l), n = To(), e !== null && !xt ? (t.updateQueue = e.updateQueue, t.flags &= -2053, e.lanes &= ~l, gn(e, t, l)) : (Ue && n && mo(t), t.flags |= 1, ft(e, t, r, l), t.child);
  }
  function pa(e, t, n, r, l) {
    if (e === null) {
      var i = n.type;
      return typeof i == "function" && !as(i) && i.defaultProps === void 0 && n.compare === null && n.defaultProps === void 0 ? (t.tag = 15, t.type = i, ha(e, t, i, r, l)) : (e = _i(n.type, null, r, t, t.mode, l), e.ref = t.ref, e.return = t, t.child = e);
    }
    if (i = e.child, (e.lanes & l) === 0) {
      var o = i.memoizedProps;
      if (n = n.compare, n = n !== null ? n : Jr, n(o, r) && e.ref === t.ref) return gn(e, t, l);
    }
    return t.flags |= 1, e = Un(i, r), e.ref = t.ref, e.return = t, t.child = e;
  }
  function ha(e, t, n, r, l) {
    if (e !== null) {
      var i = e.memoizedProps;
      if (Jr(i, r) && e.ref === t.ref) if (xt = !1, t.pendingProps = r = i, (e.lanes & l) !== 0) (e.flags & 131072) !== 0 && (xt = !0);
      else return t.lanes = e.lanes, gn(e, t, l);
    }
    return Bo(e, t, n, r, l);
  }
  function ma(e, t, n) {
    var r = t.pendingProps, l = r.children, i = e !== null ? e.memoizedState : null;
    if (r.mode === "hidden") if ((t.mode & 1) === 0) t.memoizedState = { baseLanes: 0, cachePool: null, transitions: null }, Ae(Rr, Lt), Lt |= n;
    else {
      if ((n & 1073741824) === 0) return e = i !== null ? i.baseLanes | n : n, t.lanes = t.childLanes = 1073741824, t.memoizedState = { baseLanes: e, cachePool: null, transitions: null }, t.updateQueue = null, Ae(Rr, Lt), Lt |= e, null;
      t.memoizedState = { baseLanes: 0, cachePool: null, transitions: null }, r = i !== null ? i.baseLanes : n, Ae(Rr, Lt), Lt |= r;
    }
    else i !== null ? (r = i.baseLanes | n, t.memoizedState = null) : r = n, Ae(Rr, Lt), Lt |= r;
    return ft(e, t, l, n), t.child;
  }
  function va(e, t) {
    var n = t.ref;
    (e === null && n !== null || e !== null && e.ref !== n) && (t.flags |= 512, t.flags |= 2097152);
  }
  function Bo(e, t, n, r, l) {
    var i = wt(n) ? Kn : ot.current;
    return i = gr(t, i), Er(t, l), n = Po(e, t, n, r, i, l), r = To(), e !== null && !xt ? (t.updateQueue = e.updateQueue, t.flags &= -2053, e.lanes &= ~l, gn(e, t, l)) : (Ue && r && mo(t), t.flags |= 1, ft(e, t, n, l), t.child);
  }
  function ya(e, t, n, r, l) {
    if (wt(n)) {
      var i = !0;
      Xl(t);
    } else i = !1;
    if (Er(t, l), t.stateNode === null) di(e, t), ia(t, n, r), $o(t, n, r, l), r = !0;
    else if (e === null) {
      var o = t.stateNode, c = t.memoizedProps;
      o.props = c;
      var d = o.context, w = n.contextType;
      typeof w == "object" && w !== null ? w = Tt(w) : (w = wt(n) ? Kn : ot.current, w = gr(t, w));
      var N = n.getDerivedStateFromProps, R = typeof N == "function" || typeof o.getSnapshotBeforeUpdate == "function";
      R || typeof o.UNSAFE_componentWillReceiveProps != "function" && typeof o.componentWillReceiveProps != "function" || (c !== r || d !== w) && oa(t, o, r, w), On = !1;
      var j = t.memoizedState;
      o.state = j, ri(t, r, o, l), d = t.memoizedState, c !== r || j !== d || gt.current || On ? (typeof N == "function" && (Do(t, n, N, r), d = t.memoizedState), (c = On || la(t, n, c, r, j, d, w)) ? (R || typeof o.UNSAFE_componentWillMount != "function" && typeof o.componentWillMount != "function" || (typeof o.componentWillMount == "function" && o.componentWillMount(), typeof o.UNSAFE_componentWillMount == "function" && o.UNSAFE_componentWillMount()), typeof o.componentDidMount == "function" && (t.flags |= 4194308)) : (typeof o.componentDidMount == "function" && (t.flags |= 4194308), t.memoizedProps = r, t.memoizedState = d), o.props = r, o.state = d, o.context = w, r = c) : (typeof o.componentDidMount == "function" && (t.flags |= 4194308), r = !1);
    } else {
      o = t.stateNode, Tu(e, t), c = t.memoizedProps, w = t.type === t.elementType ? c : Vt(t.type, c), o.props = w, R = t.pendingProps, j = o.context, d = n.contextType, typeof d == "object" && d !== null ? d = Tt(d) : (d = wt(n) ? Kn : ot.current, d = gr(t, d));
      var $ = n.getDerivedStateFromProps;
      (N = typeof $ == "function" || typeof o.getSnapshotBeforeUpdate == "function") || typeof o.UNSAFE_componentWillReceiveProps != "function" && typeof o.componentWillReceiveProps != "function" || (c !== R || j !== d) && oa(t, o, r, d), On = !1, j = t.memoizedState, o.state = j, ri(t, r, o, l);
      var H = t.memoizedState;
      c !== R || j !== H || gt.current || On ? (typeof $ == "function" && (Do(t, n, $, r), H = t.memoizedState), (w = On || la(t, n, w, r, j, H, d) || !1) ? (N || typeof o.UNSAFE_componentWillUpdate != "function" && typeof o.componentWillUpdate != "function" || (typeof o.componentWillUpdate == "function" && o.componentWillUpdate(r, H, d), typeof o.UNSAFE_componentWillUpdate == "function" && o.UNSAFE_componentWillUpdate(r, H, d)), typeof o.componentDidUpdate == "function" && (t.flags |= 4), typeof o.getSnapshotBeforeUpdate == "function" && (t.flags |= 1024)) : (typeof o.componentDidUpdate != "function" || c === e.memoizedProps && j === e.memoizedState || (t.flags |= 4), typeof o.getSnapshotBeforeUpdate != "function" || c === e.memoizedProps && j === e.memoizedState || (t.flags |= 1024), t.memoizedProps = r, t.memoizedState = H), o.props = r, o.state = H, o.context = d, r = w) : (typeof o.componentDidUpdate != "function" || c === e.memoizedProps && j === e.memoizedState || (t.flags |= 4), typeof o.getSnapshotBeforeUpdate != "function" || c === e.memoizedProps && j === e.memoizedState || (t.flags |= 1024), r = !1);
    }
    return Ho(e, t, n, r, i, l);
  }
  function Ho(e, t, n, r, l, i) {
    va(e, t);
    var o = (t.flags & 128) !== 0;
    if (!r && !o) return l && Su(t, n, !1), gn(e, t, i);
    r = t.stateNode, Qf.current = t;
    var c = o && typeof n.getDerivedStateFromError != "function" ? null : r.render();
    return t.flags |= 1, e !== null && o ? (t.child = Sr(t, e.child, null, i), t.child = Sr(t, null, c, i)) : ft(e, t, c, i), t.memoizedState = r.state, l && Su(t, n, !0), t.child;
  }
  function ga(e) {
    var t = e.stateNode;
    t.pendingContext ? xu(e, t.pendingContext, t.pendingContext !== t.context) : t.context && xu(e, t.context, !1), jo(e, t.containerInfo);
  }
  function wa(e, t, n, r, l) {
    return kr(), wo(l), t.flags |= 256, ft(e, t, n, r), t.child;
  }
  var Vo = { dehydrated: null, treeContext: null, retryLane: 0 };
  function Qo(e) {
    return { baseLanes: e, cachePool: null, transitions: null };
  }
  function xa(e, t, n) {
    var r = t.pendingProps, l = Be.current, i = !1, o = (t.flags & 128) !== 0, c;
    if ((c = o) || (c = e !== null && e.memoizedState === null ? !1 : (l & 2) !== 0), c ? (i = !0, t.flags &= -129) : (e === null || e.memoizedState !== null) && (l |= 1), Ae(Be, l & 1), e === null)
      return go(t), e = t.memoizedState, e !== null && (e = e.dehydrated, e !== null) ? ((t.mode & 1) === 0 ? t.lanes = 1 : e.data === "$!" ? t.lanes = 8 : t.lanes = 1073741824, null) : (o = r.children, e = r.fallback, i ? (r = t.mode, i = t.child, o = { mode: "hidden", children: o }, (r & 1) === 0 && i !== null ? (i.childLanes = 0, i.pendingProps = o) : i = Ei(o, r, 0, null), e = nr(e, r, n, null), i.return = t, e.return = t, i.sibling = e, t.child = i, t.child.memoizedState = Qo(n), t.memoizedState = Vo, e) : Ko(t, o));
    if (l = e.memoizedState, l !== null && (c = l.dehydrated, c !== null)) return Kf(e, t, o, r, c, l, n);
    if (i) {
      i = r.fallback, o = t.mode, l = e.child, c = l.sibling;
      var d = { mode: "hidden", children: r.children };
      return (o & 1) === 0 && t.child !== l ? (r = t.child, r.childLanes = 0, r.pendingProps = d, t.deletions = null) : (r = Un(l, d), r.subtreeFlags = l.subtreeFlags & 14680064), c !== null ? i = Un(c, i) : (i = nr(i, o, n, null), i.flags |= 2), i.return = t, r.return = t, r.sibling = i, t.child = r, r = i, i = t.child, o = e.child.memoizedState, o = o === null ? Qo(n) : { baseLanes: o.baseLanes | n, cachePool: null, transitions: o.transitions }, i.memoizedState = o, i.childLanes = e.childLanes & ~n, t.memoizedState = Vo, r;
    }
    return i = e.child, e = i.sibling, r = Un(i, { mode: "visible", children: r.children }), (t.mode & 1) === 0 && (r.lanes = n), r.return = t, r.sibling = null, e !== null && (n = t.deletions, n === null ? (t.deletions = [e], t.flags |= 16) : n.push(e)), t.child = r, t.memoizedState = null, r;
  }
  function Ko(e, t) {
    return t = Ei({ mode: "visible", children: t }, e.mode, 0, null), t.return = e, e.child = t;
  }
  function fi(e, t, n, r) {
    return r !== null && wo(r), Sr(t, e.child, null, n), e = Ko(t, t.pendingProps.children), e.flags |= 2, t.memoizedState = null, e;
  }
  function Kf(e, t, n, r, l, i, o) {
    if (n)
      return t.flags & 256 ? (t.flags &= -257, r = Wo(Error(f(422))), fi(e, t, o, r)) : t.memoizedState !== null ? (t.child = e.child, t.flags |= 128, null) : (i = r.fallback, l = t.mode, r = Ei({ mode: "visible", children: r.children }, l, 0, null), i = nr(i, l, o, null), i.flags |= 2, r.return = t, i.return = t, r.sibling = i, t.child = r, (t.mode & 1) !== 0 && Sr(t, e.child, null, o), t.child.memoizedState = Qo(o), t.memoizedState = Vo, i);
    if ((t.mode & 1) === 0) return fi(e, t, o, null);
    if (l.data === "$!") {
      if (r = l.nextSibling && l.nextSibling.dataset, r) var c = r.dgst;
      return r = c, i = Error(f(419)), r = Wo(i, r, void 0), fi(e, t, o, r);
    }
    if (c = (o & e.childLanes) !== 0, xt || c) {
      if (r = be, r !== null) {
        switch (o & -o) {
          case 4:
            l = 2;
            break;
          case 16:
            l = 8;
            break;
          case 64:
          case 128:
          case 256:
          case 512:
          case 1024:
          case 2048:
          case 4096:
          case 8192:
          case 16384:
          case 32768:
          case 65536:
          case 131072:
          case 262144:
          case 524288:
          case 1048576:
          case 2097152:
          case 4194304:
          case 8388608:
          case 16777216:
          case 33554432:
          case 67108864:
            l = 32;
            break;
          case 536870912:
            l = 268435456;
            break;
          default:
            l = 0;
        }
        l = (l & (r.suspendedLanes | o)) !== 0 ? 0 : l, l !== 0 && l !== i.retryLane && (i.retryLane = l, vn(e, l), Yt(r, e, l, -1));
      }
      return us(), r = Wo(Error(f(421))), fi(e, t, o, r);
    }
    return l.data === "$?" ? (t.flags |= 128, t.child = e.child, t = id.bind(null, e), l._reactRetry = t, null) : (e = i.treeContext, Rt = zn(l.nextSibling), Nt = t, Ue = !0, Ht = null, e !== null && (Mt[Pt++] = hn, Mt[Pt++] = mn, Mt[Pt++] = Yn, hn = e.id, mn = e.overflow, Yn = t), t = Ko(t, r.children), t.flags |= 4096, t);
  }
  function ka(e, t, n) {
    e.lanes |= t;
    var r = e.alternate;
    r !== null && (r.lanes |= t), _o(e.return, t, n);
  }
  function Yo(e, t, n, r, l) {
    var i = e.memoizedState;
    i === null ? e.memoizedState = { isBackwards: t, rendering: null, renderingStartTime: 0, last: r, tail: n, tailMode: l } : (i.isBackwards = t, i.rendering = null, i.renderingStartTime = 0, i.last = r, i.tail = n, i.tailMode = l);
  }
  function Sa(e, t, n) {
    var r = t.pendingProps, l = r.revealOrder, i = r.tail;
    if (ft(e, t, r.children, n), r = Be.current, (r & 2) !== 0) r = r & 1 | 2, t.flags |= 128;
    else {
      if (e !== null && (e.flags & 128) !== 0) e: for (e = t.child; e !== null; ) {
        if (e.tag === 13) e.memoizedState !== null && ka(e, n, t);
        else if (e.tag === 19) ka(e, n, t);
        else if (e.child !== null) {
          e.child.return = e, e = e.child;
          continue;
        }
        if (e === t) break e;
        for (; e.sibling === null; ) {
          if (e.return === null || e.return === t) break e;
          e = e.return;
        }
        e.sibling.return = e.return, e = e.sibling;
      }
      r &= 1;
    }
    if (Ae(Be, r), (t.mode & 1) === 0) t.memoizedState = null;
    else switch (l) {
      case "forwards":
        for (n = t.child, l = null; n !== null; ) e = n.alternate, e !== null && li(e) === null && (l = n), n = n.sibling;
        n = l, n === null ? (l = t.child, t.child = null) : (l = n.sibling, n.sibling = null), Yo(t, !1, l, n, i);
        break;
      case "backwards":
        for (n = null, l = t.child, t.child = null; l !== null; ) {
          if (e = l.alternate, e !== null && li(e) === null) {
            t.child = l;
            break;
          }
          e = l.sibling, l.sibling = n, n = l, l = e;
        }
        Yo(t, !0, n, null, i);
        break;
      case "together":
        Yo(t, !1, null, null, void 0);
        break;
      default:
        t.memoizedState = null;
    }
    return t.child;
  }
  function di(e, t) {
    (t.mode & 1) === 0 && e !== null && (e.alternate = null, t.alternate = null, t.flags |= 2);
  }
  function gn(e, t, n) {
    if (e !== null && (t.dependencies = e.dependencies), Jn |= t.lanes, (n & t.childLanes) === 0) return null;
    if (e !== null && t.child !== e.child) throw Error(f(153));
    if (t.child !== null) {
      for (e = t.child, n = Un(e, e.pendingProps), t.child = n, n.return = t; e.sibling !== null; ) e = e.sibling, n = n.sibling = Un(e, e.pendingProps), n.return = t;
      n.sibling = null;
    }
    return t.child;
  }
  function Yf(e, t, n) {
    switch (t.tag) {
      case 3:
        ga(t), kr();
        break;
      case 5:
        Iu(t);
        break;
      case 1:
        wt(t.type) && Xl(t);
        break;
      case 4:
        jo(t, t.stateNode.containerInfo);
        break;
      case 10:
        var r = t.type._context, l = t.memoizedProps.value;
        Ae(ei, r._currentValue), r._currentValue = l;
        break;
      case 13:
        if (r = t.memoizedState, r !== null)
          return r.dehydrated !== null ? (Ae(Be, Be.current & 1), t.flags |= 128, null) : (n & t.child.childLanes) !== 0 ? xa(e, t, n) : (Ae(Be, Be.current & 1), e = gn(e, t, n), e !== null ? e.sibling : null);
        Ae(Be, Be.current & 1);
        break;
      case 19:
        if (r = (n & t.childLanes) !== 0, (e.flags & 128) !== 0) {
          if (r) return Sa(e, t, n);
          t.flags |= 128;
        }
        if (l = t.memoizedState, l !== null && (l.rendering = null, l.tail = null, l.lastEffect = null), Ae(Be, Be.current), r) break;
        return null;
      case 22:
      case 23:
        return t.lanes = 0, ma(e, t, n);
    }
    return gn(e, t, n);
  }
  var _a, Xo, Ea, Ca;
  _a = function(e, t) {
    for (var n = t.child; n !== null; ) {
      if (n.tag === 5 || n.tag === 6) e.appendChild(n.stateNode);
      else if (n.tag !== 4 && n.child !== null) {
        n.child.return = n, n = n.child;
        continue;
      }
      if (n === t) break;
      for (; n.sibling === null; ) {
        if (n.return === null || n.return === t) return;
        n = n.return;
      }
      n.sibling.return = n.return, n = n.sibling;
    }
  }, Xo = function() {
  }, Ea = function(e, t, n, r) {
    var l = e.memoizedProps;
    if (l !== r) {
      e = t.stateNode, qn(tn.current);
      var i = null;
      switch (n) {
        case "input":
          l = Xe(e, l), r = Xe(e, r), i = [];
          break;
        case "select":
          l = O({}, l, { value: void 0 }), r = O({}, r, { value: void 0 }), i = [];
          break;
        case "textarea":
          l = Et(e, l), r = Et(e, r), i = [];
          break;
        default:
          typeof l.onClick != "function" && typeof r.onClick == "function" && (e.onclick = Ql);
      }
      an(n, r);
      var o;
      n = null;
      for (w in l) if (!r.hasOwnProperty(w) && l.hasOwnProperty(w) && l[w] != null) if (w === "style") {
        var c = l[w];
        for (o in c) c.hasOwnProperty(o) && (n || (n = {}), n[o] = "");
      } else w !== "dangerouslySetInnerHTML" && w !== "children" && w !== "suppressContentEditableWarning" && w !== "suppressHydrationWarning" && w !== "autoFocus" && (_.hasOwnProperty(w) ? i || (i = []) : (i = i || []).push(w, null));
      for (w in r) {
        var d = r[w];
        if (c = l != null ? l[w] : void 0, r.hasOwnProperty(w) && d !== c && (d != null || c != null)) if (w === "style") if (c) {
          for (o in c) !c.hasOwnProperty(o) || d && d.hasOwnProperty(o) || (n || (n = {}), n[o] = "");
          for (o in d) d.hasOwnProperty(o) && c[o] !== d[o] && (n || (n = {}), n[o] = d[o]);
        } else n || (i || (i = []), i.push(
          w,
          n
        )), n = d;
        else w === "dangerouslySetInnerHTML" ? (d = d ? d.__html : void 0, c = c ? c.__html : void 0, d != null && c !== d && (i = i || []).push(w, d)) : w === "children" ? typeof d != "string" && typeof d != "number" || (i = i || []).push(w, "" + d) : w !== "suppressContentEditableWarning" && w !== "suppressHydrationWarning" && (_.hasOwnProperty(w) ? (d != null && w === "onScroll" && De("scroll", e), i || c === d || (i = [])) : (i = i || []).push(w, d));
      }
      n && (i = i || []).push("style", n);
      var w = i;
      (t.updateQueue = w) && (t.flags |= 4);
    }
  }, Ca = function(e, t, n, r) {
    n !== r && (t.flags |= 4);
  };
  function pl(e, t) {
    if (!Ue) switch (e.tailMode) {
      case "hidden":
        t = e.tail;
        for (var n = null; t !== null; ) t.alternate !== null && (n = t), t = t.sibling;
        n === null ? e.tail = null : n.sibling = null;
        break;
      case "collapsed":
        n = e.tail;
        for (var r = null; n !== null; ) n.alternate !== null && (r = n), n = n.sibling;
        r === null ? t || e.tail === null ? e.tail = null : e.tail.sibling = null : r.sibling = null;
    }
  }
  function ut(e) {
    var t = e.alternate !== null && e.alternate.child === e.child, n = 0, r = 0;
    if (t) for (var l = e.child; l !== null; ) n |= l.lanes | l.childLanes, r |= l.subtreeFlags & 14680064, r |= l.flags & 14680064, l.return = e, l = l.sibling;
    else for (l = e.child; l !== null; ) n |= l.lanes | l.childLanes, r |= l.subtreeFlags, r |= l.flags, l.return = e, l = l.sibling;
    return e.subtreeFlags |= r, e.childLanes = n, t;
  }
  function Xf(e, t, n) {
    var r = t.pendingProps;
    switch (vo(t), t.tag) {
      case 2:
      case 16:
      case 15:
      case 0:
      case 11:
      case 7:
      case 8:
      case 12:
      case 9:
      case 14:
        return ut(t), null;
      case 1:
        return wt(t.type) && Yl(), ut(t), null;
      case 3:
        return r = t.stateNode, Cr(), $e(gt), $e(ot), Lo(), r.pendingContext && (r.context = r.pendingContext, r.pendingContext = null), (e === null || e.child === null) && (Jl(t) ? t.flags |= 4 : e === null || e.memoizedState.isDehydrated && (t.flags & 256) === 0 || (t.flags |= 1024, Ht !== null && (is(Ht), Ht = null))), Xo(e, t), ut(t), null;
      case 5:
        No(t);
        var l = qn(ul.current);
        if (n = t.type, e !== null && t.stateNode != null) Ea(e, t, n, r, l), e.ref !== t.ref && (t.flags |= 512, t.flags |= 2097152);
        else {
          if (!r) {
            if (t.stateNode === null) throw Error(f(166));
            return ut(t), null;
          }
          if (e = qn(tn.current), Jl(t)) {
            r = t.stateNode, n = t.type;
            var i = t.memoizedProps;
            switch (r[en] = t, r[rl] = i, e = (t.mode & 1) !== 0, n) {
              case "dialog":
                De("cancel", r), De("close", r);
                break;
              case "iframe":
              case "object":
              case "embed":
                De("load", r);
                break;
              case "video":
              case "audio":
                for (l = 0; l < el.length; l++) De(el[l], r);
                break;
              case "source":
                De("error", r);
                break;
              case "img":
              case "image":
              case "link":
                De(
                  "error",
                  r
                ), De("load", r);
                break;
              case "details":
                De("toggle", r);
                break;
              case "input":
                Le(r, i), De("invalid", r);
                break;
              case "select":
                r._wrapperState = { wasMultiple: !!i.multiple }, De("invalid", r);
                break;
              case "textarea":
                At(r, i), De("invalid", r);
            }
            an(n, i), l = null;
            for (var o in i) if (i.hasOwnProperty(o)) {
              var c = i[o];
              o === "children" ? typeof c == "string" ? r.textContent !== c && (i.suppressHydrationWarning !== !0 && Vl(r.textContent, c, e), l = ["children", c]) : typeof c == "number" && r.textContent !== "" + c && (i.suppressHydrationWarning !== !0 && Vl(
                r.textContent,
                c,
                e
              ), l = ["children", "" + c]) : _.hasOwnProperty(o) && c != null && o === "onScroll" && De("scroll", r);
            }
            switch (n) {
              case "input":
                pe(r), tt(r, i, !0);
                break;
              case "textarea":
                pe(r), on(r);
                break;
              case "select":
              case "option":
                break;
              default:
                typeof i.onClick == "function" && (r.onclick = Ql);
            }
            r = l, t.updateQueue = r, r !== null && (t.flags |= 4);
          } else {
            o = l.nodeType === 9 ? l : l.ownerDocument, e === "http://www.w3.org/1999/xhtml" && (e = ht(n)), e === "http://www.w3.org/1999/xhtml" ? n === "script" ? (e = o.createElement("div"), e.innerHTML = "<script><\/script>", e = e.removeChild(e.firstChild)) : typeof r.is == "string" ? e = o.createElement(n, { is: r.is }) : (e = o.createElement(n), n === "select" && (o = e, r.multiple ? o.multiple = !0 : r.size && (o.size = r.size))) : e = o.createElementNS(e, n), e[en] = t, e[rl] = r, _a(e, t, !1, !1), t.stateNode = e;
            e: {
              switch (o = cn(n, r), n) {
                case "dialog":
                  De("cancel", e), De("close", e), l = r;
                  break;
                case "iframe":
                case "object":
                case "embed":
                  De("load", e), l = r;
                  break;
                case "video":
                case "audio":
                  for (l = 0; l < el.length; l++) De(el[l], e);
                  l = r;
                  break;
                case "source":
                  De("error", e), l = r;
                  break;
                case "img":
                case "image":
                case "link":
                  De(
                    "error",
                    e
                  ), De("load", e), l = r;
                  break;
                case "details":
                  De("toggle", e), l = r;
                  break;
                case "input":
                  Le(e, r), l = Xe(e, r), De("invalid", e);
                  break;
                case "option":
                  l = r;
                  break;
                case "select":
                  e._wrapperState = { wasMultiple: !!r.multiple }, l = O({}, r, { value: void 0 }), De("invalid", e);
                  break;
                case "textarea":
                  At(e, r), l = Et(e, r), De("invalid", e);
                  break;
                default:
                  l = r;
              }
              an(n, l), c = l;
              for (i in c) if (c.hasOwnProperty(i)) {
                var d = c[i];
                i === "style" ? un(e, d) : i === "dangerouslySetInnerHTML" ? (d = d ? d.__html : void 0, d != null && kn(e, d)) : i === "children" ? typeof d == "string" ? (n !== "textarea" || d !== "") && nt(e, d) : typeof d == "number" && nt(e, "" + d) : i !== "suppressContentEditableWarning" && i !== "suppressHydrationWarning" && i !== "autoFocus" && (_.hasOwnProperty(i) ? d != null && i === "onScroll" && De("scroll", e) : d != null && ke(e, i, d, o));
              }
              switch (n) {
                case "input":
                  pe(e), tt(e, r, !1);
                  break;
                case "textarea":
                  pe(e), on(e);
                  break;
                case "option":
                  r.value != null && e.setAttribute("value", "" + le(r.value));
                  break;
                case "select":
                  e.multiple = !!r.multiple, i = r.value, i != null ? pt(e, !!r.multiple, i, !1) : r.defaultValue != null && pt(
                    e,
                    !!r.multiple,
                    r.defaultValue,
                    !0
                  );
                  break;
                default:
                  typeof l.onClick == "function" && (e.onclick = Ql);
              }
              switch (n) {
                case "button":
                case "input":
                case "select":
                case "textarea":
                  r = !!r.autoFocus;
                  break e;
                case "img":
                  r = !0;
                  break e;
                default:
                  r = !1;
              }
            }
            r && (t.flags |= 4);
          }
          t.ref !== null && (t.flags |= 512, t.flags |= 2097152);
        }
        return ut(t), null;
      case 6:
        if (e && t.stateNode != null) Ca(e, t, e.memoizedProps, r);
        else {
          if (typeof r != "string" && t.stateNode === null) throw Error(f(166));
          if (n = qn(ul.current), qn(tn.current), Jl(t)) {
            if (r = t.stateNode, n = t.memoizedProps, r[en] = t, (i = r.nodeValue !== n) && (e = Nt, e !== null)) switch (e.tag) {
              case 3:
                Vl(r.nodeValue, n, (e.mode & 1) !== 0);
                break;
              case 5:
                e.memoizedProps.suppressHydrationWarning !== !0 && Vl(r.nodeValue, n, (e.mode & 1) !== 0);
            }
            i && (t.flags |= 4);
          } else r = (n.nodeType === 9 ? n : n.ownerDocument).createTextNode(r), r[en] = t, t.stateNode = r;
        }
        return ut(t), null;
      case 13:
        if ($e(Be), r = t.memoizedState, e === null || e.memoizedState !== null && e.memoizedState.dehydrated !== null) {
          if (Ue && Rt !== null && (t.mode & 1) !== 0 && (t.flags & 128) === 0) Ru(), kr(), t.flags |= 98560, i = !1;
          else if (i = Jl(t), r !== null && r.dehydrated !== null) {
            if (e === null) {
              if (!i) throw Error(f(318));
              if (i = t.memoizedState, i = i !== null ? i.dehydrated : null, !i) throw Error(f(317));
              i[en] = t;
            } else kr(), (t.flags & 128) === 0 && (t.memoizedState = null), t.flags |= 4;
            ut(t), i = !1;
          } else Ht !== null && (is(Ht), Ht = null), i = !0;
          if (!i) return t.flags & 65536 ? t : null;
        }
        return (t.flags & 128) !== 0 ? (t.lanes = n, t) : (r = r !== null, r !== (e !== null && e.memoizedState !== null) && r && (t.child.flags |= 8192, (t.mode & 1) !== 0 && (e === null || (Be.current & 1) !== 0 ? qe === 0 && (qe = 3) : us())), t.updateQueue !== null && (t.flags |= 4), ut(t), null);
      case 4:
        return Cr(), Xo(e, t), e === null && tl(t.stateNode.containerInfo), ut(t), null;
      case 10:
        return So(t.type._context), ut(t), null;
      case 17:
        return wt(t.type) && Yl(), ut(t), null;
      case 19:
        if ($e(Be), i = t.memoizedState, i === null) return ut(t), null;
        if (r = (t.flags & 128) !== 0, o = i.rendering, o === null) if (r) pl(i, !1);
        else {
          if (qe !== 0 || e !== null && (e.flags & 128) !== 0) for (e = t.child; e !== null; ) {
            if (o = li(e), o !== null) {
              for (t.flags |= 128, pl(i, !1), r = o.updateQueue, r !== null && (t.updateQueue = r, t.flags |= 4), t.subtreeFlags = 0, r = n, n = t.child; n !== null; ) i = n, e = r, i.flags &= 14680066, o = i.alternate, o === null ? (i.childLanes = 0, i.lanes = e, i.child = null, i.subtreeFlags = 0, i.memoizedProps = null, i.memoizedState = null, i.updateQueue = null, i.dependencies = null, i.stateNode = null) : (i.childLanes = o.childLanes, i.lanes = o.lanes, i.child = o.child, i.subtreeFlags = 0, i.deletions = null, i.memoizedProps = o.memoizedProps, i.memoizedState = o.memoizedState, i.updateQueue = o.updateQueue, i.type = o.type, e = o.dependencies, i.dependencies = e === null ? null : { lanes: e.lanes, firstContext: e.firstContext }), n = n.sibling;
              return Ae(Be, Be.current & 1 | 2), t.child;
            }
            e = e.sibling;
          }
          i.tail !== null && Qe() > Lr && (t.flags |= 128, r = !0, pl(i, !1), t.lanes = 4194304);
        }
        else {
          if (!r) if (e = li(o), e !== null) {
            if (t.flags |= 128, r = !0, n = e.updateQueue, n !== null && (t.updateQueue = n, t.flags |= 4), pl(i, !0), i.tail === null && i.tailMode === "hidden" && !o.alternate && !Ue) return ut(t), null;
          } else 2 * Qe() - i.renderingStartTime > Lr && n !== 1073741824 && (t.flags |= 128, r = !0, pl(i, !1), t.lanes = 4194304);
          i.isBackwards ? (o.sibling = t.child, t.child = o) : (n = i.last, n !== null ? n.sibling = o : t.child = o, i.last = o);
        }
        return i.tail !== null ? (t = i.tail, i.rendering = t, i.tail = t.sibling, i.renderingStartTime = Qe(), t.sibling = null, n = Be.current, Ae(Be, r ? n & 1 | 2 : n & 1), t) : (ut(t), null);
      case 22:
      case 23:
        return ss(), r = t.memoizedState !== null, e !== null && e.memoizedState !== null !== r && (t.flags |= 8192), r && (t.mode & 1) !== 0 ? (Lt & 1073741824) !== 0 && (ut(t), t.subtreeFlags & 6 && (t.flags |= 8192)) : ut(t), null;
      case 24:
        return null;
      case 25:
        return null;
    }
    throw Error(f(156, t.tag));
  }
  function Gf(e, t) {
    switch (vo(t), t.tag) {
      case 1:
        return wt(t.type) && Yl(), e = t.flags, e & 65536 ? (t.flags = e & -65537 | 128, t) : null;
      case 3:
        return Cr(), $e(gt), $e(ot), Lo(), e = t.flags, (e & 65536) !== 0 && (e & 128) === 0 ? (t.flags = e & -65537 | 128, t) : null;
      case 5:
        return No(t), null;
      case 13:
        if ($e(Be), e = t.memoizedState, e !== null && e.dehydrated !== null) {
          if (t.alternate === null) throw Error(f(340));
          kr();
        }
        return e = t.flags, e & 65536 ? (t.flags = e & -65537 | 128, t) : null;
      case 19:
        return $e(Be), null;
      case 4:
        return Cr(), null;
      case 10:
        return So(t.type._context), null;
      case 22:
      case 23:
        return ss(), null;
      case 24:
        return null;
      default:
        return null;
    }
  }
  var pi = !1, at = !1, qf = typeof WeakSet == "function" ? WeakSet : Set, W = null;
  function Nr(e, t) {
    var n = e.ref;
    if (n !== null) if (typeof n == "function") try {
      n(null);
    } catch (r) {
      Ve(e, t, r);
    }
    else n.current = null;
  }
  function Go(e, t, n) {
    try {
      n();
    } catch (r) {
      Ve(e, t, r);
    }
  }
  var ja = !1;
  function Zf(e, t) {
    if (oo = Tl, e = lu(), Ji(e)) {
      if ("selectionStart" in e) var n = { start: e.selectionStart, end: e.selectionEnd };
      else e: {
        n = (n = e.ownerDocument) && n.defaultView || window;
        var r = n.getSelection && n.getSelection();
        if (r && r.rangeCount !== 0) {
          n = r.anchorNode;
          var l = r.anchorOffset, i = r.focusNode;
          r = r.focusOffset;
          try {
            n.nodeType, i.nodeType;
          } catch {
            n = null;
            break e;
          }
          var o = 0, c = -1, d = -1, w = 0, N = 0, R = e, j = null;
          t: for (; ; ) {
            for (var $; R !== n || l !== 0 && R.nodeType !== 3 || (c = o + l), R !== i || r !== 0 && R.nodeType !== 3 || (d = o + r), R.nodeType === 3 && (o += R.nodeValue.length), ($ = R.firstChild) !== null; )
              j = R, R = $;
            for (; ; ) {
              if (R === e) break t;
              if (j === n && ++w === l && (c = o), j === i && ++N === r && (d = o), ($ = R.nextSibling) !== null) break;
              R = j, j = R.parentNode;
            }
            R = $;
          }
          n = c === -1 || d === -1 ? null : { start: c, end: d };
        } else n = null;
      }
      n = n || { start: 0, end: 0 };
    } else n = null;
    for (so = { focusedElem: e, selectionRange: n }, Tl = !1, W = t; W !== null; ) if (t = W, e = t.child, (t.subtreeFlags & 1028) !== 0 && e !== null) e.return = t, W = e;
    else for (; W !== null; ) {
      t = W;
      try {
        var H = t.alternate;
        if ((t.flags & 1024) !== 0) switch (t.tag) {
          case 0:
          case 11:
          case 15:
            break;
          case 1:
            if (H !== null) {
              var Q = H.memoizedProps, Ke = H.memoizedState, m = t.stateNode, h = m.getSnapshotBeforeUpdate(t.elementType === t.type ? Q : Vt(t.type, Q), Ke);
              m.__reactInternalSnapshotBeforeUpdate = h;
            }
            break;
          case 3:
            var g = t.stateNode.containerInfo;
            g.nodeType === 1 ? g.textContent = "" : g.nodeType === 9 && g.documentElement && g.removeChild(g.documentElement);
            break;
          case 5:
          case 6:
          case 4:
          case 17:
            break;
          default:
            throw Error(f(163));
        }
      } catch (L) {
        Ve(t, t.return, L);
      }
      if (e = t.sibling, e !== null) {
        e.return = t.return, W = e;
        break;
      }
      W = t.return;
    }
    return H = ja, ja = !1, H;
  }
  function hl(e, t, n) {
    var r = t.updateQueue;
    if (r = r !== null ? r.lastEffect : null, r !== null) {
      var l = r = r.next;
      do {
        if ((l.tag & e) === e) {
          var i = l.destroy;
          l.destroy = void 0, i !== void 0 && Go(t, n, i);
        }
        l = l.next;
      } while (l !== r);
    }
  }
  function hi(e, t) {
    if (t = t.updateQueue, t = t !== null ? t.lastEffect : null, t !== null) {
      var n = t = t.next;
      do {
        if ((n.tag & e) === e) {
          var r = n.create;
          n.destroy = r();
        }
        n = n.next;
      } while (n !== t);
    }
  }
  function qo(e) {
    var t = e.ref;
    if (t !== null) {
      var n = e.stateNode;
      switch (e.tag) {
        case 5:
          e = n;
          break;
        default:
          e = n;
      }
      typeof t == "function" ? t(e) : t.current = e;
    }
  }
  function Na(e) {
    var t = e.alternate;
    t !== null && (e.alternate = null, Na(t)), e.child = null, e.deletions = null, e.sibling = null, e.tag === 5 && (t = e.stateNode, t !== null && (delete t[en], delete t[rl], delete t[fo], delete t[Tf], delete t[Of])), e.stateNode = null, e.return = null, e.dependencies = null, e.memoizedProps = null, e.memoizedState = null, e.pendingProps = null, e.stateNode = null, e.updateQueue = null;
  }
  function Ra(e) {
    return e.tag === 5 || e.tag === 3 || e.tag === 4;
  }
  function La(e) {
    e: for (; ; ) {
      for (; e.sibling === null; ) {
        if (e.return === null || Ra(e.return)) return null;
        e = e.return;
      }
      for (e.sibling.return = e.return, e = e.sibling; e.tag !== 5 && e.tag !== 6 && e.tag !== 18; ) {
        if (e.flags & 2 || e.child === null || e.tag === 4) continue e;
        e.child.return = e, e = e.child;
      }
      if (!(e.flags & 2)) return e.stateNode;
    }
  }
  function Zo(e, t, n) {
    var r = e.tag;
    if (r === 5 || r === 6) e = e.stateNode, t ? n.nodeType === 8 ? n.parentNode.insertBefore(e, t) : n.insertBefore(e, t) : (n.nodeType === 8 ? (t = n.parentNode, t.insertBefore(e, n)) : (t = n, t.appendChild(e)), n = n._reactRootContainer, n != null || t.onclick !== null || (t.onclick = Ql));
    else if (r !== 4 && (e = e.child, e !== null)) for (Zo(e, t, n), e = e.sibling; e !== null; ) Zo(e, t, n), e = e.sibling;
  }
  function Jo(e, t, n) {
    var r = e.tag;
    if (r === 5 || r === 6) e = e.stateNode, t ? n.insertBefore(e, t) : n.appendChild(e);
    else if (r !== 4 && (e = e.child, e !== null)) for (Jo(e, t, n), e = e.sibling; e !== null; ) Jo(e, t, n), e = e.sibling;
  }
  var lt = null, Qt = !1;
  function In(e, t, n) {
    for (n = n.child; n !== null; ) za(e, t, n), n = n.sibling;
  }
  function za(e, t, n) {
    if (bt && typeof bt.onCommitFiberUnmount == "function") try {
      bt.onCommitFiberUnmount(Nl, n);
    } catch {
    }
    switch (n.tag) {
      case 5:
        at || Nr(n, t);
      case 6:
        var r = lt, l = Qt;
        lt = null, In(e, t, n), lt = r, Qt = l, lt !== null && (Qt ? (e = lt, n = n.stateNode, e.nodeType === 8 ? e.parentNode.removeChild(n) : e.removeChild(n)) : lt.removeChild(n.stateNode));
        break;
      case 18:
        lt !== null && (Qt ? (e = lt, n = n.stateNode, e.nodeType === 8 ? co(e.parentNode, n) : e.nodeType === 1 && co(e, n), Kr(e)) : co(lt, n.stateNode));
        break;
      case 4:
        r = lt, l = Qt, lt = n.stateNode.containerInfo, Qt = !0, In(e, t, n), lt = r, Qt = l;
        break;
      case 0:
      case 11:
      case 14:
      case 15:
        if (!at && (r = n.updateQueue, r !== null && (r = r.lastEffect, r !== null))) {
          l = r = r.next;
          do {
            var i = l, o = i.destroy;
            i = i.tag, o !== void 0 && ((i & 2) !== 0 || (i & 4) !== 0) && Go(n, t, o), l = l.next;
          } while (l !== r);
        }
        In(e, t, n);
        break;
      case 1:
        if (!at && (Nr(n, t), r = n.stateNode, typeof r.componentWillUnmount == "function")) try {
          r.props = n.memoizedProps, r.state = n.memoizedState, r.componentWillUnmount();
        } catch (c) {
          Ve(n, t, c);
        }
        In(e, t, n);
        break;
      case 21:
        In(e, t, n);
        break;
      case 22:
        n.mode & 1 ? (at = (r = at) || n.memoizedState !== null, In(e, t, n), at = r) : In(e, t, n);
        break;
      default:
        In(e, t, n);
    }
  }
  function Ma(e) {
    var t = e.updateQueue;
    if (t !== null) {
      e.updateQueue = null;
      var n = e.stateNode;
      n === null && (n = e.stateNode = new qf()), t.forEach(function(r) {
        var l = od.bind(null, e, r);
        n.has(r) || (n.add(r), r.then(l, l));
      });
    }
  }
  function Kt(e, t) {
    var n = t.deletions;
    if (n !== null) for (var r = 0; r < n.length; r++) {
      var l = n[r];
      try {
        var i = e, o = t, c = o;
        e: for (; c !== null; ) {
          switch (c.tag) {
            case 5:
              lt = c.stateNode, Qt = !1;
              break e;
            case 3:
              lt = c.stateNode.containerInfo, Qt = !0;
              break e;
            case 4:
              lt = c.stateNode.containerInfo, Qt = !0;
              break e;
          }
          c = c.return;
        }
        if (lt === null) throw Error(f(160));
        za(i, o, l), lt = null, Qt = !1;
        var d = l.alternate;
        d !== null && (d.return = null), l.return = null;
      } catch (w) {
        Ve(l, t, w);
      }
    }
    if (t.subtreeFlags & 12854) for (t = t.child; t !== null; ) Pa(t, e), t = t.sibling;
  }
  function Pa(e, t) {
    var n = e.alternate, r = e.flags;
    switch (e.tag) {
      case 0:
      case 11:
      case 14:
      case 15:
        if (Kt(t, e), rn(e), r & 4) {
          try {
            hl(3, e, e.return), hi(3, e);
          } catch (Q) {
            Ve(e, e.return, Q);
          }
          try {
            hl(5, e, e.return);
          } catch (Q) {
            Ve(e, e.return, Q);
          }
        }
        break;
      case 1:
        Kt(t, e), rn(e), r & 512 && n !== null && Nr(n, n.return);
        break;
      case 5:
        if (Kt(t, e), rn(e), r & 512 && n !== null && Nr(n, n.return), e.flags & 32) {
          var l = e.stateNode;
          try {
            nt(l, "");
          } catch (Q) {
            Ve(e, e.return, Q);
          }
        }
        if (r & 4 && (l = e.stateNode, l != null)) {
          var i = e.memoizedProps, o = n !== null ? n.memoizedProps : i, c = e.type, d = e.updateQueue;
          if (e.updateQueue = null, d !== null) try {
            c === "input" && i.type === "radio" && i.name != null && ln(l, i), cn(c, o);
            var w = cn(c, i);
            for (o = 0; o < d.length; o += 2) {
              var N = d[o], R = d[o + 1];
              N === "style" ? un(l, R) : N === "dangerouslySetInnerHTML" ? kn(l, R) : N === "children" ? nt(l, R) : ke(l, N, R, w);
            }
            switch (c) {
              case "input":
                Fe(l, i);
                break;
              case "textarea":
                Dt(l, i);
                break;
              case "select":
                var j = l._wrapperState.wasMultiple;
                l._wrapperState.wasMultiple = !!i.multiple;
                var $ = i.value;
                $ != null ? pt(l, !!i.multiple, $, !1) : j !== !!i.multiple && (i.defaultValue != null ? pt(
                  l,
                  !!i.multiple,
                  i.defaultValue,
                  !0
                ) : pt(l, !!i.multiple, i.multiple ? [] : "", !1));
            }
            l[rl] = i;
          } catch (Q) {
            Ve(e, e.return, Q);
          }
        }
        break;
      case 6:
        if (Kt(t, e), rn(e), r & 4) {
          if (e.stateNode === null) throw Error(f(162));
          l = e.stateNode, i = e.memoizedProps;
          try {
            l.nodeValue = i;
          } catch (Q) {
            Ve(e, e.return, Q);
          }
        }
        break;
      case 3:
        if (Kt(t, e), rn(e), r & 4 && n !== null && n.memoizedState.isDehydrated) try {
          Kr(t.containerInfo);
        } catch (Q) {
          Ve(e, e.return, Q);
        }
        break;
      case 4:
        Kt(t, e), rn(e);
        break;
      case 13:
        Kt(t, e), rn(e), l = e.child, l.flags & 8192 && (i = l.memoizedState !== null, l.stateNode.isHidden = i, !i || l.alternate !== null && l.alternate.memoizedState !== null || (ts = Qe())), r & 4 && Ma(e);
        break;
      case 22:
        if (N = n !== null && n.memoizedState !== null, e.mode & 1 ? (at = (w = at) || N, Kt(t, e), at = w) : Kt(t, e), rn(e), r & 8192) {
          if (w = e.memoizedState !== null, (e.stateNode.isHidden = w) && !N && (e.mode & 1) !== 0) for (W = e, N = e.child; N !== null; ) {
            for (R = W = N; W !== null; ) {
              switch (j = W, $ = j.child, j.tag) {
                case 0:
                case 11:
                case 14:
                case 15:
                  hl(4, j, j.return);
                  break;
                case 1:
                  Nr(j, j.return);
                  var H = j.stateNode;
                  if (typeof H.componentWillUnmount == "function") {
                    r = j, n = j.return;
                    try {
                      t = r, H.props = t.memoizedProps, H.state = t.memoizedState, H.componentWillUnmount();
                    } catch (Q) {
                      Ve(r, n, Q);
                    }
                  }
                  break;
                case 5:
                  Nr(j, j.return);
                  break;
                case 22:
                  if (j.memoizedState !== null) {
                    Fa(R);
                    continue;
                  }
              }
              $ !== null ? ($.return = j, W = $) : Fa(R);
            }
            N = N.sibling;
          }
          e: for (N = null, R = e; ; ) {
            if (R.tag === 5) {
              if (N === null) {
                N = R;
                try {
                  l = R.stateNode, w ? (i = l.style, typeof i.setProperty == "function" ? i.setProperty("display", "none", "important") : i.display = "none") : (c = R.stateNode, d = R.memoizedProps.style, o = d != null && d.hasOwnProperty("display") ? d.display : null, c.style.display = Fr("display", o));
                } catch (Q) {
                  Ve(e, e.return, Q);
                }
              }
            } else if (R.tag === 6) {
              if (N === null) try {
                R.stateNode.nodeValue = w ? "" : R.memoizedProps;
              } catch (Q) {
                Ve(e, e.return, Q);
              }
            } else if ((R.tag !== 22 && R.tag !== 23 || R.memoizedState === null || R === e) && R.child !== null) {
              R.child.return = R, R = R.child;
              continue;
            }
            if (R === e) break e;
            for (; R.sibling === null; ) {
              if (R.return === null || R.return === e) break e;
              N === R && (N = null), R = R.return;
            }
            N === R && (N = null), R.sibling.return = R.return, R = R.sibling;
          }
        }
        break;
      case 19:
        Kt(t, e), rn(e), r & 4 && Ma(e);
        break;
      case 21:
        break;
      default:
        Kt(
          t,
          e
        ), rn(e);
    }
  }
  function rn(e) {
    var t = e.flags;
    if (t & 2) {
      try {
        e: {
          for (var n = e.return; n !== null; ) {
            if (Ra(n)) {
              var r = n;
              break e;
            }
            n = n.return;
          }
          throw Error(f(160));
        }
        switch (r.tag) {
          case 5:
            var l = r.stateNode;
            r.flags & 32 && (nt(l, ""), r.flags &= -33);
            var i = La(e);
            Jo(e, i, l);
            break;
          case 3:
          case 4:
            var o = r.stateNode.containerInfo, c = La(e);
            Zo(e, c, o);
            break;
          default:
            throw Error(f(161));
        }
      } catch (d) {
        Ve(e, e.return, d);
      }
      e.flags &= -3;
    }
    t & 4096 && (e.flags &= -4097);
  }
  function Jf(e, t, n) {
    W = e, Ta(e);
  }
  function Ta(e, t, n) {
    for (var r = (e.mode & 1) !== 0; W !== null; ) {
      var l = W, i = l.child;
      if (l.tag === 22 && r) {
        var o = l.memoizedState !== null || pi;
        if (!o) {
          var c = l.alternate, d = c !== null && c.memoizedState !== null || at;
          c = pi;
          var w = at;
          if (pi = o, (at = d) && !w) for (W = l; W !== null; ) o = W, d = o.child, o.tag === 22 && o.memoizedState !== null ? Ia(l) : d !== null ? (d.return = o, W = d) : Ia(l);
          for (; i !== null; ) W = i, Ta(i), i = i.sibling;
          W = l, pi = c, at = w;
        }
        Oa(e);
      } else (l.subtreeFlags & 8772) !== 0 && i !== null ? (i.return = l, W = i) : Oa(e);
    }
  }
  function Oa(e) {
    for (; W !== null; ) {
      var t = W;
      if ((t.flags & 8772) !== 0) {
        var n = t.alternate;
        try {
          if ((t.flags & 8772) !== 0) switch (t.tag) {
            case 0:
            case 11:
            case 15:
              at || hi(5, t);
              break;
            case 1:
              var r = t.stateNode;
              if (t.flags & 4 && !at) if (n === null) r.componentDidMount();
              else {
                var l = t.elementType === t.type ? n.memoizedProps : Vt(t.type, n.memoizedProps);
                r.componentDidUpdate(l, n.memoizedState, r.__reactInternalSnapshotBeforeUpdate);
              }
              var i = t.updateQueue;
              i !== null && Fu(t, i, r);
              break;
            case 3:
              var o = t.updateQueue;
              if (o !== null) {
                if (n = null, t.child !== null) switch (t.child.tag) {
                  case 5:
                    n = t.child.stateNode;
                    break;
                  case 1:
                    n = t.child.stateNode;
                }
                Fu(t, o, n);
              }
              break;
            case 5:
              var c = t.stateNode;
              if (n === null && t.flags & 4) {
                n = c;
                var d = t.memoizedProps;
                switch (t.type) {
                  case "button":
                  case "input":
                  case "select":
                  case "textarea":
                    d.autoFocus && n.focus();
                    break;
                  case "img":
                    d.src && (n.src = d.src);
                }
              }
              break;
            case 6:
              break;
            case 4:
              break;
            case 12:
              break;
            case 13:
              if (t.memoizedState === null) {
                var w = t.alternate;
                if (w !== null) {
                  var N = w.memoizedState;
                  if (N !== null) {
                    var R = N.dehydrated;
                    R !== null && Kr(R);
                  }
                }
              }
              break;
            case 19:
            case 17:
            case 21:
            case 22:
            case 23:
            case 25:
              break;
            default:
              throw Error(f(163));
          }
          at || t.flags & 512 && qo(t);
        } catch (j) {
          Ve(t, t.return, j);
        }
      }
      if (t === e) {
        W = null;
        break;
      }
      if (n = t.sibling, n !== null) {
        n.return = t.return, W = n;
        break;
      }
      W = t.return;
    }
  }
  function Fa(e) {
    for (; W !== null; ) {
      var t = W;
      if (t === e) {
        W = null;
        break;
      }
      var n = t.sibling;
      if (n !== null) {
        n.return = t.return, W = n;
        break;
      }
      W = t.return;
    }
  }
  function Ia(e) {
    for (; W !== null; ) {
      var t = W;
      try {
        switch (t.tag) {
          case 0:
          case 11:
          case 15:
            var n = t.return;
            try {
              hi(4, t);
            } catch (d) {
              Ve(t, n, d);
            }
            break;
          case 1:
            var r = t.stateNode;
            if (typeof r.componentDidMount == "function") {
              var l = t.return;
              try {
                r.componentDidMount();
              } catch (d) {
                Ve(t, l, d);
              }
            }
            var i = t.return;
            try {
              qo(t);
            } catch (d) {
              Ve(t, i, d);
            }
            break;
          case 5:
            var o = t.return;
            try {
              qo(t);
            } catch (d) {
              Ve(t, o, d);
            }
        }
      } catch (d) {
        Ve(t, t.return, d);
      }
      if (t === e) {
        W = null;
        break;
      }
      var c = t.sibling;
      if (c !== null) {
        c.return = t.return, W = c;
        break;
      }
      W = t.return;
    }
  }
  var bf = Math.ceil, mi = xe.ReactCurrentDispatcher, bo = xe.ReactCurrentOwner, Ft = xe.ReactCurrentBatchConfig, Ee = 0, be = null, Ye = null, it = 0, Lt = 0, Rr = Mn(0), qe = 0, ml = null, Jn = 0, vi = 0, es = 0, vl = null, kt = null, ts = 0, Lr = 1 / 0, wn = null, yi = !1, ns = null, An = null, gi = !1, Dn = null, wi = 0, yl = 0, rs = null, xi = -1, ki = 0;
  function dt() {
    return (Ee & 6) !== 0 ? Qe() : xi !== -1 ? xi : xi = Qe();
  }
  function $n(e) {
    return (e.mode & 1) === 0 ? 1 : (Ee & 2) !== 0 && it !== 0 ? it & -it : If.transition !== null ? (ki === 0 && (ki = Ls()), ki) : (e = Me, e !== 0 || (e = window.event, e = e === void 0 ? 16 : Ds(e.type)), e);
  }
  function Yt(e, t, n, r) {
    if (50 < yl) throw yl = 0, rs = null, Error(f(185));
    Ur(e, n, r), ((Ee & 2) === 0 || e !== be) && (e === be && ((Ee & 2) === 0 && (vi |= n), qe === 4 && Wn(e, it)), St(e, r), n === 1 && Ee === 0 && (t.mode & 1) === 0 && (Lr = Qe() + 500, Gl && Tn()));
  }
  function St(e, t) {
    var n = e.callbackNode;
    Fc(e, t);
    var r = zl(e, e === be ? it : 0);
    if (r === 0) n !== null && ze(n), e.callbackNode = null, e.callbackPriority = 0;
    else if (t = r & -r, e.callbackPriority !== t) {
      if (n != null && ze(n), t === 1) e.tag === 0 ? Ff(Da.bind(null, e)) : _u(Da.bind(null, e)), Mf(function() {
        (Ee & 6) === 0 && Tn();
      }), n = null;
      else {
        switch (zs(r)) {
          case 1:
            n = Fi;
            break;
          case 4:
            n = Ns;
            break;
          case 16:
            n = jl;
            break;
          case 536870912:
            n = Rs;
            break;
          default:
            n = jl;
        }
        n = Ka(n, Aa.bind(null, e));
      }
      e.callbackPriority = t, e.callbackNode = n;
    }
  }
  function Aa(e, t) {
    if (xi = -1, ki = 0, (Ee & 6) !== 0) throw Error(f(327));
    var n = e.callbackNode;
    if (zr() && e.callbackNode !== n) return null;
    var r = zl(e, e === be ? it : 0);
    if (r === 0) return null;
    if ((r & 30) !== 0 || (r & e.expiredLanes) !== 0 || t) t = Si(e, r);
    else {
      t = r;
      var l = Ee;
      Ee |= 2;
      var i = Wa();
      (be !== e || it !== t) && (wn = null, Lr = Qe() + 500, er(e, t));
      do
        try {
          nd();
          break;
        } catch (c) {
          $a(e, c);
        }
      while (!0);
      ko(), mi.current = i, Ee = l, Ye !== null ? t = 0 : (be = null, it = 0, t = qe);
    }
    if (t !== 0) {
      if (t === 2 && (l = Ii(e), l !== 0 && (r = l, t = ls(e, l))), t === 1) throw n = ml, er(e, 0), Wn(e, r), St(e, Qe()), n;
      if (t === 6) Wn(e, r);
      else {
        if (l = e.current.alternate, (r & 30) === 0 && !ed(l) && (t = Si(e, r), t === 2 && (i = Ii(e), i !== 0 && (r = i, t = ls(e, i))), t === 1)) throw n = ml, er(e, 0), Wn(e, r), St(e, Qe()), n;
        switch (e.finishedWork = l, e.finishedLanes = r, t) {
          case 0:
          case 1:
            throw Error(f(345));
          case 2:
            tr(e, kt, wn);
            break;
          case 3:
            if (Wn(e, r), (r & 130023424) === r && (t = ts + 500 - Qe(), 10 < t)) {
              if (zl(e, 0) !== 0) break;
              if (l = e.suspendedLanes, (l & r) !== r) {
                dt(), e.pingedLanes |= e.suspendedLanes & l;
                break;
              }
              e.timeoutHandle = ao(tr.bind(null, e, kt, wn), t);
              break;
            }
            tr(e, kt, wn);
            break;
          case 4:
            if (Wn(e, r), (r & 4194240) === r) break;
            for (t = e.eventTimes, l = -1; 0 < r; ) {
              var o = 31 - Ut(r);
              i = 1 << o, o = t[o], o > l && (l = o), r &= ~i;
            }
            if (r = l, r = Qe() - r, r = (120 > r ? 120 : 480 > r ? 480 : 1080 > r ? 1080 : 1920 > r ? 1920 : 3e3 > r ? 3e3 : 4320 > r ? 4320 : 1960 * bf(r / 1960)) - r, 10 < r) {
              e.timeoutHandle = ao(tr.bind(null, e, kt, wn), r);
              break;
            }
            tr(e, kt, wn);
            break;
          case 5:
            tr(e, kt, wn);
            break;
          default:
            throw Error(f(329));
        }
      }
    }
    return St(e, Qe()), e.callbackNode === n ? Aa.bind(null, e) : null;
  }
  function ls(e, t) {
    var n = vl;
    return e.current.memoizedState.isDehydrated && (er(e, t).flags |= 256), e = Si(e, t), e !== 2 && (t = kt, kt = n, t !== null && is(t)), e;
  }
  function is(e) {
    kt === null ? kt = e : kt.push.apply(kt, e);
  }
  function ed(e) {
    for (var t = e; ; ) {
      if (t.flags & 16384) {
        var n = t.updateQueue;
        if (n !== null && (n = n.stores, n !== null)) for (var r = 0; r < n.length; r++) {
          var l = n[r], i = l.getSnapshot;
          l = l.value;
          try {
            if (!Bt(i(), l)) return !1;
          } catch {
            return !1;
          }
        }
      }
      if (n = t.child, t.subtreeFlags & 16384 && n !== null) n.return = t, t = n;
      else {
        if (t === e) break;
        for (; t.sibling === null; ) {
          if (t.return === null || t.return === e) return !0;
          t = t.return;
        }
        t.sibling.return = t.return, t = t.sibling;
      }
    }
    return !0;
  }
  function Wn(e, t) {
    for (t &= ~es, t &= ~vi, e.suspendedLanes |= t, e.pingedLanes &= ~t, e = e.expirationTimes; 0 < t; ) {
      var n = 31 - Ut(t), r = 1 << n;
      e[n] = -1, t &= ~r;
    }
  }
  function Da(e) {
    if ((Ee & 6) !== 0) throw Error(f(327));
    zr();
    var t = zl(e, 0);
    if ((t & 1) === 0) return St(e, Qe()), null;
    var n = Si(e, t);
    if (e.tag !== 0 && n === 2) {
      var r = Ii(e);
      r !== 0 && (t = r, n = ls(e, r));
    }
    if (n === 1) throw n = ml, er(e, 0), Wn(e, t), St(e, Qe()), n;
    if (n === 6) throw Error(f(345));
    return e.finishedWork = e.current.alternate, e.finishedLanes = t, tr(e, kt, wn), St(e, Qe()), null;
  }
  function os(e, t) {
    var n = Ee;
    Ee |= 1;
    try {
      return e(t);
    } finally {
      Ee = n, Ee === 0 && (Lr = Qe() + 500, Gl && Tn());
    }
  }
  function bn(e) {
    Dn !== null && Dn.tag === 0 && (Ee & 6) === 0 && zr();
    var t = Ee;
    Ee |= 1;
    var n = Ft.transition, r = Me;
    try {
      if (Ft.transition = null, Me = 1, e) return e();
    } finally {
      Me = r, Ft.transition = n, Ee = t, (Ee & 6) === 0 && Tn();
    }
  }
  function ss() {
    Lt = Rr.current, $e(Rr);
  }
  function er(e, t) {
    e.finishedWork = null, e.finishedLanes = 0;
    var n = e.timeoutHandle;
    if (n !== -1 && (e.timeoutHandle = -1, zf(n)), Ye !== null) for (n = Ye.return; n !== null; ) {
      var r = n;
      switch (vo(r), r.tag) {
        case 1:
          r = r.type.childContextTypes, r != null && Yl();
          break;
        case 3:
          Cr(), $e(gt), $e(ot), Lo();
          break;
        case 5:
          No(r);
          break;
        case 4:
          Cr();
          break;
        case 13:
          $e(Be);
          break;
        case 19:
          $e(Be);
          break;
        case 10:
          So(r.type._context);
          break;
        case 22:
        case 23:
          ss();
      }
      n = n.return;
    }
    if (be = e, Ye = e = Un(e.current, null), it = Lt = t, qe = 0, ml = null, es = vi = Jn = 0, kt = vl = null, Gn !== null) {
      for (t = 0; t < Gn.length; t++) if (n = Gn[t], r = n.interleaved, r !== null) {
        n.interleaved = null;
        var l = r.next, i = n.pending;
        if (i !== null) {
          var o = i.next;
          i.next = l, r.next = o;
        }
        n.pending = r;
      }
      Gn = null;
    }
    return e;
  }
  function $a(e, t) {
    do {
      var n = Ye;
      try {
        if (ko(), ii.current = ai, oi) {
          for (var r = He.memoizedState; r !== null; ) {
            var l = r.queue;
            l !== null && (l.pending = null), r = r.next;
          }
          oi = !1;
        }
        if (Zn = 0, Je = Ge = He = null, al = !1, cl = 0, bo.current = null, n === null || n.return === null) {
          qe = 1, ml = t, Ye = null;
          break;
        }
        e: {
          var i = e, o = n.return, c = n, d = t;
          if (t = it, c.flags |= 32768, d !== null && typeof d == "object" && typeof d.then == "function") {
            var w = d, N = c, R = N.tag;
            if ((N.mode & 1) === 0 && (R === 0 || R === 11 || R === 15)) {
              var j = N.alternate;
              j ? (N.updateQueue = j.updateQueue, N.memoizedState = j.memoizedState, N.lanes = j.lanes) : (N.updateQueue = null, N.memoizedState = null);
            }
            var $ = ca(o);
            if ($ !== null) {
              $.flags &= -257, fa($, o, c, i, t), $.mode & 1 && aa(i, w, t), t = $, d = w;
              var H = t.updateQueue;
              if (H === null) {
                var Q = /* @__PURE__ */ new Set();
                Q.add(d), t.updateQueue = Q;
              } else H.add(d);
              break e;
            } else {
              if ((t & 1) === 0) {
                aa(i, w, t), us();
                break e;
              }
              d = Error(f(426));
            }
          } else if (Ue && c.mode & 1) {
            var Ke = ca(o);
            if (Ke !== null) {
              (Ke.flags & 65536) === 0 && (Ke.flags |= 256), fa(Ke, o, c, i, t), wo(jr(d, c));
              break e;
            }
          }
          i = d = jr(d, c), qe !== 4 && (qe = 2), vl === null ? vl = [i] : vl.push(i), i = o;
          do {
            switch (i.tag) {
              case 3:
                i.flags |= 65536, t &= -t, i.lanes |= t;
                var m = sa(i, d, t);
                Ou(i, m);
                break e;
              case 1:
                c = d;
                var h = i.type, g = i.stateNode;
                if ((i.flags & 128) === 0 && (typeof h.getDerivedStateFromError == "function" || g !== null && typeof g.componentDidCatch == "function" && (An === null || !An.has(g)))) {
                  i.flags |= 65536, t &= -t, i.lanes |= t;
                  var L = ua(i, c, t);
                  Ou(i, L);
                  break e;
                }
            }
            i = i.return;
          } while (i !== null);
        }
        Ba(n);
      } catch (G) {
        t = G, Ye === n && n !== null && (Ye = n = n.return);
        continue;
      }
      break;
    } while (!0);
  }
  function Wa() {
    var e = mi.current;
    return mi.current = ai, e === null ? ai : e;
  }
  function us() {
    (qe === 0 || qe === 3 || qe === 2) && (qe = 4), be === null || (Jn & 268435455) === 0 && (vi & 268435455) === 0 || Wn(be, it);
  }
  function Si(e, t) {
    var n = Ee;
    Ee |= 2;
    var r = Wa();
    (be !== e || it !== t) && (wn = null, er(e, t));
    do
      try {
        td();
        break;
      } catch (l) {
        $a(e, l);
      }
    while (!0);
    if (ko(), Ee = n, mi.current = r, Ye !== null) throw Error(f(261));
    return be = null, it = 0, qe;
  }
  function td() {
    for (; Ye !== null; ) Ua(Ye);
  }
  function nd() {
    for (; Ye !== null && !yt(); ) Ua(Ye);
  }
  function Ua(e) {
    var t = Qa(e.alternate, e, Lt);
    e.memoizedProps = e.pendingProps, t === null ? Ba(e) : Ye = t, bo.current = null;
  }
  function Ba(e) {
    var t = e;
    do {
      var n = t.alternate;
      if (e = t.return, (t.flags & 32768) === 0) {
        if (n = Xf(n, t, Lt), n !== null) {
          Ye = n;
          return;
        }
      } else {
        if (n = Gf(n, t), n !== null) {
          n.flags &= 32767, Ye = n;
          return;
        }
        if (e !== null) e.flags |= 32768, e.subtreeFlags = 0, e.deletions = null;
        else {
          qe = 6, Ye = null;
          return;
        }
      }
      if (t = t.sibling, t !== null) {
        Ye = t;
        return;
      }
      Ye = t = e;
    } while (t !== null);
    qe === 0 && (qe = 5);
  }
  function tr(e, t, n) {
    var r = Me, l = Ft.transition;
    try {
      Ft.transition = null, Me = 1, rd(e, t, n, r);
    } finally {
      Ft.transition = l, Me = r;
    }
    return null;
  }
  function rd(e, t, n, r) {
    do
      zr();
    while (Dn !== null);
    if ((Ee & 6) !== 0) throw Error(f(327));
    n = e.finishedWork;
    var l = e.finishedLanes;
    if (n === null) return null;
    if (e.finishedWork = null, e.finishedLanes = 0, n === e.current) throw Error(f(177));
    e.callbackNode = null, e.callbackPriority = 0;
    var i = n.lanes | n.childLanes;
    if (Ic(e, i), e === be && (Ye = be = null, it = 0), (n.subtreeFlags & 2064) === 0 && (n.flags & 2064) === 0 || gi || (gi = !0, Ka(jl, function() {
      return zr(), null;
    })), i = (n.flags & 15990) !== 0, (n.subtreeFlags & 15990) !== 0 || i) {
      i = Ft.transition, Ft.transition = null;
      var o = Me;
      Me = 1;
      var c = Ee;
      Ee |= 4, bo.current = null, Zf(e, n), Pa(n, e), _f(so), Tl = !!oo, so = oo = null, e.current = n, Jf(n), fn(), Ee = c, Me = o, Ft.transition = i;
    } else e.current = n;
    if (gi && (gi = !1, Dn = e, wi = l), i = e.pendingLanes, i === 0 && (An = null), zc(n.stateNode), St(e, Qe()), t !== null) for (r = e.onRecoverableError, n = 0; n < t.length; n++) l = t[n], r(l.value, { componentStack: l.stack, digest: l.digest });
    if (yi) throw yi = !1, e = ns, ns = null, e;
    return (wi & 1) !== 0 && e.tag !== 0 && zr(), i = e.pendingLanes, (i & 1) !== 0 ? e === rs ? yl++ : (yl = 0, rs = e) : yl = 0, Tn(), null;
  }
  function zr() {
    if (Dn !== null) {
      var e = zs(wi), t = Ft.transition, n = Me;
      try {
        if (Ft.transition = null, Me = 16 > e ? 16 : e, Dn === null) var r = !1;
        else {
          if (e = Dn, Dn = null, wi = 0, (Ee & 6) !== 0) throw Error(f(331));
          var l = Ee;
          for (Ee |= 4, W = e.current; W !== null; ) {
            var i = W, o = i.child;
            if ((W.flags & 16) !== 0) {
              var c = i.deletions;
              if (c !== null) {
                for (var d = 0; d < c.length; d++) {
                  var w = c[d];
                  for (W = w; W !== null; ) {
                    var N = W;
                    switch (N.tag) {
                      case 0:
                      case 11:
                      case 15:
                        hl(8, N, i);
                    }
                    var R = N.child;
                    if (R !== null) R.return = N, W = R;
                    else for (; W !== null; ) {
                      N = W;
                      var j = N.sibling, $ = N.return;
                      if (Na(N), N === w) {
                        W = null;
                        break;
                      }
                      if (j !== null) {
                        j.return = $, W = j;
                        break;
                      }
                      W = $;
                    }
                  }
                }
                var H = i.alternate;
                if (H !== null) {
                  var Q = H.child;
                  if (Q !== null) {
                    H.child = null;
                    do {
                      var Ke = Q.sibling;
                      Q.sibling = null, Q = Ke;
                    } while (Q !== null);
                  }
                }
                W = i;
              }
            }
            if ((i.subtreeFlags & 2064) !== 0 && o !== null) o.return = i, W = o;
            else e: for (; W !== null; ) {
              if (i = W, (i.flags & 2048) !== 0) switch (i.tag) {
                case 0:
                case 11:
                case 15:
                  hl(9, i, i.return);
              }
              var m = i.sibling;
              if (m !== null) {
                m.return = i.return, W = m;
                break e;
              }
              W = i.return;
            }
          }
          var h = e.current;
          for (W = h; W !== null; ) {
            o = W;
            var g = o.child;
            if ((o.subtreeFlags & 2064) !== 0 && g !== null) g.return = o, W = g;
            else e: for (o = h; W !== null; ) {
              if (c = W, (c.flags & 2048) !== 0) try {
                switch (c.tag) {
                  case 0:
                  case 11:
                  case 15:
                    hi(9, c);
                }
              } catch (G) {
                Ve(c, c.return, G);
              }
              if (c === o) {
                W = null;
                break e;
              }
              var L = c.sibling;
              if (L !== null) {
                L.return = c.return, W = L;
                break e;
              }
              W = c.return;
            }
          }
          if (Ee = l, Tn(), bt && typeof bt.onPostCommitFiberRoot == "function") try {
            bt.onPostCommitFiberRoot(Nl, e);
          } catch {
          }
          r = !0;
        }
        return r;
      } finally {
        Me = n, Ft.transition = t;
      }
    }
    return !1;
  }
  function Ha(e, t, n) {
    t = jr(n, t), t = sa(e, t, 1), e = Fn(e, t, 1), t = dt(), e !== null && (Ur(e, 1, t), St(e, t));
  }
  function Ve(e, t, n) {
    if (e.tag === 3) Ha(e, e, n);
    else for (; t !== null; ) {
      if (t.tag === 3) {
        Ha(t, e, n);
        break;
      } else if (t.tag === 1) {
        var r = t.stateNode;
        if (typeof t.type.getDerivedStateFromError == "function" || typeof r.componentDidCatch == "function" && (An === null || !An.has(r))) {
          e = jr(n, e), e = ua(t, e, 1), t = Fn(t, e, 1), e = dt(), t !== null && (Ur(t, 1, e), St(t, e));
          break;
        }
      }
      t = t.return;
    }
  }
  function ld(e, t, n) {
    var r = e.pingCache;
    r !== null && r.delete(t), t = dt(), e.pingedLanes |= e.suspendedLanes & n, be === e && (it & n) === n && (qe === 4 || qe === 3 && (it & 130023424) === it && 500 > Qe() - ts ? er(e, 0) : es |= n), St(e, t);
  }
  function Va(e, t) {
    t === 0 && ((e.mode & 1) === 0 ? t = 1 : (t = Ll, Ll <<= 1, (Ll & 130023424) === 0 && (Ll = 4194304)));
    var n = dt();
    e = vn(e, t), e !== null && (Ur(e, t, n), St(e, n));
  }
  function id(e) {
    var t = e.memoizedState, n = 0;
    t !== null && (n = t.retryLane), Va(e, n);
  }
  function od(e, t) {
    var n = 0;
    switch (e.tag) {
      case 13:
        var r = e.stateNode, l = e.memoizedState;
        l !== null && (n = l.retryLane);
        break;
      case 19:
        r = e.stateNode;
        break;
      default:
        throw Error(f(314));
    }
    r !== null && r.delete(t), Va(e, n);
  }
  var Qa;
  Qa = function(e, t, n) {
    if (e !== null) if (e.memoizedProps !== t.pendingProps || gt.current) xt = !0;
    else {
      if ((e.lanes & n) === 0 && (t.flags & 128) === 0) return xt = !1, Yf(e, t, n);
      xt = (e.flags & 131072) !== 0;
    }
    else xt = !1, Ue && (t.flags & 1048576) !== 0 && Eu(t, Zl, t.index);
    switch (t.lanes = 0, t.tag) {
      case 2:
        var r = t.type;
        di(e, t), e = t.pendingProps;
        var l = gr(t, ot.current);
        Er(t, n), l = Po(null, t, r, e, l, n);
        var i = To();
        return t.flags |= 1, typeof l == "object" && l !== null && typeof l.render == "function" && l.$$typeof === void 0 ? (t.tag = 1, t.memoizedState = null, t.updateQueue = null, wt(r) ? (i = !0, Xl(t)) : i = !1, t.memoizedState = l.state !== null && l.state !== void 0 ? l.state : null, Co(t), l.updater = ci, t.stateNode = l, l._reactInternals = t, $o(t, r, e, n), t = Ho(null, t, r, !0, i, n)) : (t.tag = 0, Ue && i && mo(t), ft(null, t, l, n), t = t.child), t;
      case 16:
        r = t.elementType;
        e: {
          switch (di(e, t), e = t.pendingProps, l = r._init, r = l(r._payload), t.type = r, l = t.tag = ud(r), e = Vt(r, e), l) {
            case 0:
              t = Bo(null, t, r, e, n);
              break e;
            case 1:
              t = ya(null, t, r, e, n);
              break e;
            case 11:
              t = da(null, t, r, e, n);
              break e;
            case 14:
              t = pa(null, t, r, Vt(r.type, e), n);
              break e;
          }
          throw Error(f(
            306,
            r,
            ""
          ));
        }
        return t;
      case 0:
        return r = t.type, l = t.pendingProps, l = t.elementType === r ? l : Vt(r, l), Bo(e, t, r, l, n);
      case 1:
        return r = t.type, l = t.pendingProps, l = t.elementType === r ? l : Vt(r, l), ya(e, t, r, l, n);
      case 3:
        e: {
          if (ga(t), e === null) throw Error(f(387));
          r = t.pendingProps, i = t.memoizedState, l = i.element, Tu(e, t), ri(t, r, null, n);
          var o = t.memoizedState;
          if (r = o.element, i.isDehydrated) if (i = { element: r, isDehydrated: !1, cache: o.cache, pendingSuspenseBoundaries: o.pendingSuspenseBoundaries, transitions: o.transitions }, t.updateQueue.baseState = i, t.memoizedState = i, t.flags & 256) {
            l = jr(Error(f(423)), t), t = wa(e, t, r, n, l);
            break e;
          } else if (r !== l) {
            l = jr(Error(f(424)), t), t = wa(e, t, r, n, l);
            break e;
          } else for (Rt = zn(t.stateNode.containerInfo.firstChild), Nt = t, Ue = !0, Ht = null, n = Mu(t, null, r, n), t.child = n; n; ) n.flags = n.flags & -3 | 4096, n = n.sibling;
          else {
            if (kr(), r === l) {
              t = gn(e, t, n);
              break e;
            }
            ft(e, t, r, n);
          }
          t = t.child;
        }
        return t;
      case 5:
        return Iu(t), e === null && go(t), r = t.type, l = t.pendingProps, i = e !== null ? e.memoizedProps : null, o = l.children, uo(r, l) ? o = null : i !== null && uo(r, i) && (t.flags |= 32), va(e, t), ft(e, t, o, n), t.child;
      case 6:
        return e === null && go(t), null;
      case 13:
        return xa(e, t, n);
      case 4:
        return jo(t, t.stateNode.containerInfo), r = t.pendingProps, e === null ? t.child = Sr(t, null, r, n) : ft(e, t, r, n), t.child;
      case 11:
        return r = t.type, l = t.pendingProps, l = t.elementType === r ? l : Vt(r, l), da(e, t, r, l, n);
      case 7:
        return ft(e, t, t.pendingProps, n), t.child;
      case 8:
        return ft(e, t, t.pendingProps.children, n), t.child;
      case 12:
        return ft(e, t, t.pendingProps.children, n), t.child;
      case 10:
        e: {
          if (r = t.type._context, l = t.pendingProps, i = t.memoizedProps, o = l.value, Ae(ei, r._currentValue), r._currentValue = o, i !== null) if (Bt(i.value, o)) {
            if (i.children === l.children && !gt.current) {
              t = gn(e, t, n);
              break e;
            }
          } else for (i = t.child, i !== null && (i.return = t); i !== null; ) {
            var c = i.dependencies;
            if (c !== null) {
              o = i.child;
              for (var d = c.firstContext; d !== null; ) {
                if (d.context === r) {
                  if (i.tag === 1) {
                    d = yn(-1, n & -n), d.tag = 2;
                    var w = i.updateQueue;
                    if (w !== null) {
                      w = w.shared;
                      var N = w.pending;
                      N === null ? d.next = d : (d.next = N.next, N.next = d), w.pending = d;
                    }
                  }
                  i.lanes |= n, d = i.alternate, d !== null && (d.lanes |= n), _o(
                    i.return,
                    n,
                    t
                  ), c.lanes |= n;
                  break;
                }
                d = d.next;
              }
            } else if (i.tag === 10) o = i.type === t.type ? null : i.child;
            else if (i.tag === 18) {
              if (o = i.return, o === null) throw Error(f(341));
              o.lanes |= n, c = o.alternate, c !== null && (c.lanes |= n), _o(o, n, t), o = i.sibling;
            } else o = i.child;
            if (o !== null) o.return = i;
            else for (o = i; o !== null; ) {
              if (o === t) {
                o = null;
                break;
              }
              if (i = o.sibling, i !== null) {
                i.return = o.return, o = i;
                break;
              }
              o = o.return;
            }
            i = o;
          }
          ft(e, t, l.children, n), t = t.child;
        }
        return t;
      case 9:
        return l = t.type, r = t.pendingProps.children, Er(t, n), l = Tt(l), r = r(l), t.flags |= 1, ft(e, t, r, n), t.child;
      case 14:
        return r = t.type, l = Vt(r, t.pendingProps), l = Vt(r.type, l), pa(e, t, r, l, n);
      case 15:
        return ha(e, t, t.type, t.pendingProps, n);
      case 17:
        return r = t.type, l = t.pendingProps, l = t.elementType === r ? l : Vt(r, l), di(e, t), t.tag = 1, wt(r) ? (e = !0, Xl(t)) : e = !1, Er(t, n), ia(t, r, l), $o(t, r, l, n), Ho(null, t, r, !0, e, n);
      case 19:
        return Sa(e, t, n);
      case 22:
        return ma(e, t, n);
    }
    throw Error(f(156, t.tag));
  };
  function Ka(e, t) {
    return $r(e, t);
  }
  function sd(e, t, n, r) {
    this.tag = e, this.key = n, this.sibling = this.child = this.return = this.stateNode = this.type = this.elementType = null, this.index = 0, this.ref = null, this.pendingProps = t, this.dependencies = this.memoizedState = this.updateQueue = this.memoizedProps = null, this.mode = r, this.subtreeFlags = this.flags = 0, this.deletions = null, this.childLanes = this.lanes = 0, this.alternate = null;
  }
  function It(e, t, n, r) {
    return new sd(e, t, n, r);
  }
  function as(e) {
    return e = e.prototype, !(!e || !e.isReactComponent);
  }
  function ud(e) {
    if (typeof e == "function") return as(e) ? 1 : 0;
    if (e != null) {
      if (e = e.$$typeof, e === Pe) return 11;
      if (e === Re) return 14;
    }
    return 2;
  }
  function Un(e, t) {
    var n = e.alternate;
    return n === null ? (n = It(e.tag, t, e.key, e.mode), n.elementType = e.elementType, n.type = e.type, n.stateNode = e.stateNode, n.alternate = e, e.alternate = n) : (n.pendingProps = t, n.type = e.type, n.flags = 0, n.subtreeFlags = 0, n.deletions = null), n.flags = e.flags & 14680064, n.childLanes = e.childLanes, n.lanes = e.lanes, n.child = e.child, n.memoizedProps = e.memoizedProps, n.memoizedState = e.memoizedState, n.updateQueue = e.updateQueue, t = e.dependencies, n.dependencies = t === null ? null : { lanes: t.lanes, firstContext: t.firstContext }, n.sibling = e.sibling, n.index = e.index, n.ref = e.ref, n;
  }
  function _i(e, t, n, r, l, i) {
    var o = 2;
    if (r = e, typeof e == "function") as(e) && (o = 1);
    else if (typeof e == "string") o = 5;
    else e: switch (e) {
      case B:
        return nr(n.children, l, i, t);
      case C:
        o = 8, l |= 8;
        break;
      case de:
        return e = It(12, n, t, l | 2), e.elementType = de, e.lanes = i, e;
      case we:
        return e = It(13, n, t, l), e.elementType = we, e.lanes = i, e;
      case ce:
        return e = It(19, n, t, l), e.elementType = ce, e.lanes = i, e;
      case se:
        return Ei(n, l, i, t);
      default:
        if (typeof e == "object" && e !== null) switch (e.$$typeof) {
          case re:
            o = 10;
            break e;
          case he:
            o = 9;
            break e;
          case Pe:
            o = 11;
            break e;
          case Re:
            o = 14;
            break e;
          case Ce:
            o = 16, r = null;
            break e;
        }
        throw Error(f(130, e == null ? e : typeof e, ""));
    }
    return t = It(o, n, t, l), t.elementType = e, t.type = r, t.lanes = i, t;
  }
  function nr(e, t, n, r) {
    return e = It(7, e, r, t), e.lanes = n, e;
  }
  function Ei(e, t, n, r) {
    return e = It(22, e, r, t), e.elementType = se, e.lanes = n, e.stateNode = { isHidden: !1 }, e;
  }
  function cs(e, t, n) {
    return e = It(6, e, null, t), e.lanes = n, e;
  }
  function fs(e, t, n) {
    return t = It(4, e.children !== null ? e.children : [], e.key, t), t.lanes = n, t.stateNode = { containerInfo: e.containerInfo, pendingChildren: null, implementation: e.implementation }, t;
  }
  function ad(e, t, n, r, l) {
    this.tag = t, this.containerInfo = e, this.finishedWork = this.pingCache = this.current = this.pendingChildren = null, this.timeoutHandle = -1, this.callbackNode = this.pendingContext = this.context = null, this.callbackPriority = 0, this.eventTimes = Ai(0), this.expirationTimes = Ai(-1), this.entangledLanes = this.finishedLanes = this.mutableReadLanes = this.expiredLanes = this.pingedLanes = this.suspendedLanes = this.pendingLanes = 0, this.entanglements = Ai(0), this.identifierPrefix = r, this.onRecoverableError = l, this.mutableSourceEagerHydrationData = null;
  }
  function ds(e, t, n, r, l, i, o, c, d) {
    return e = new ad(e, t, n, c, d), t === 1 ? (t = 1, i === !0 && (t |= 8)) : t = 0, i = It(3, null, null, t), e.current = i, i.stateNode = e, i.memoizedState = { element: r, isDehydrated: n, cache: null, transitions: null, pendingSuspenseBoundaries: null }, Co(i), e;
  }
  function cd(e, t, n) {
    var r = 3 < arguments.length && arguments[3] !== void 0 ? arguments[3] : null;
    return { $$typeof: Ne, key: r == null ? null : "" + r, children: e, containerInfo: t, implementation: n };
  }
  function Ya(e) {
    if (!e) return Pn;
    e = e._reactInternals;
    e: {
      if (vt(e) !== e || e.tag !== 1) throw Error(f(170));
      var t = e;
      do {
        switch (t.tag) {
          case 3:
            t = t.stateNode.context;
            break e;
          case 1:
            if (wt(t.type)) {
              t = t.stateNode.__reactInternalMemoizedMergedChildContext;
              break e;
            }
        }
        t = t.return;
      } while (t !== null);
      throw Error(f(171));
    }
    if (e.tag === 1) {
      var n = e.type;
      if (wt(n)) return ku(e, n, t);
    }
    return t;
  }
  function Xa(e, t, n, r, l, i, o, c, d) {
    return e = ds(n, r, !0, e, l, i, o, c, d), e.context = Ya(null), n = e.current, r = dt(), l = $n(n), i = yn(r, l), i.callback = t ?? null, Fn(n, i, l), e.current.lanes = l, Ur(e, l, r), St(e, r), e;
  }
  function Ci(e, t, n, r) {
    var l = t.current, i = dt(), o = $n(l);
    return n = Ya(n), t.context === null ? t.context = n : t.pendingContext = n, t = yn(i, o), t.payload = { element: e }, r = r === void 0 ? null : r, r !== null && (t.callback = r), e = Fn(l, t, o), e !== null && (Yt(e, l, o, i), ni(e, l, o)), o;
  }
  function ji(e) {
    if (e = e.current, !e.child) return null;
    switch (e.child.tag) {
      case 5:
        return e.child.stateNode;
      default:
        return e.child.stateNode;
    }
  }
  function Ga(e, t) {
    if (e = e.memoizedState, e !== null && e.dehydrated !== null) {
      var n = e.retryLane;
      e.retryLane = n !== 0 && n < t ? n : t;
    }
  }
  function ps(e, t) {
    Ga(e, t), (e = e.alternate) && Ga(e, t);
  }
  function fd() {
    return null;
  }
  var qa = typeof reportError == "function" ? reportError : function(e) {
    console.error(e);
  };
  function hs(e) {
    this._internalRoot = e;
  }
  Ni.prototype.render = hs.prototype.render = function(e) {
    var t = this._internalRoot;
    if (t === null) throw Error(f(409));
    Ci(e, t, null, null);
  }, Ni.prototype.unmount = hs.prototype.unmount = function() {
    var e = this._internalRoot;
    if (e !== null) {
      this._internalRoot = null;
      var t = e.containerInfo;
      bn(function() {
        Ci(null, e, null, null);
      }), t[dn] = null;
    }
  };
  function Ni(e) {
    this._internalRoot = e;
  }
  Ni.prototype.unstable_scheduleHydration = function(e) {
    if (e) {
      var t = Ts();
      e = { blockedOn: null, target: e, priority: t };
      for (var n = 0; n < Nn.length && t !== 0 && t < Nn[n].priority; n++) ;
      Nn.splice(n, 0, e), n === 0 && Is(e);
    }
  };
  function ms(e) {
    return !(!e || e.nodeType !== 1 && e.nodeType !== 9 && e.nodeType !== 11);
  }
  function Ri(e) {
    return !(!e || e.nodeType !== 1 && e.nodeType !== 9 && e.nodeType !== 11 && (e.nodeType !== 8 || e.nodeValue !== " react-mount-point-unstable "));
  }
  function Za() {
  }
  function dd(e, t, n, r, l) {
    if (l) {
      if (typeof r == "function") {
        var i = r;
        r = function() {
          var w = ji(o);
          i.call(w);
        };
      }
      var o = Xa(t, r, e, 0, null, !1, !1, "", Za);
      return e._reactRootContainer = o, e[dn] = o.current, tl(e.nodeType === 8 ? e.parentNode : e), bn(), o;
    }
    for (; l = e.lastChild; ) e.removeChild(l);
    if (typeof r == "function") {
      var c = r;
      r = function() {
        var w = ji(d);
        c.call(w);
      };
    }
    var d = ds(e, 0, !1, null, null, !1, !1, "", Za);
    return e._reactRootContainer = d, e[dn] = d.current, tl(e.nodeType === 8 ? e.parentNode : e), bn(function() {
      Ci(t, d, n, r);
    }), d;
  }
  function Li(e, t, n, r, l) {
    var i = n._reactRootContainer;
    if (i) {
      var o = i;
      if (typeof l == "function") {
        var c = l;
        l = function() {
          var d = ji(o);
          c.call(d);
        };
      }
      Ci(t, o, e, l);
    } else o = dd(n, t, e, l, r);
    return ji(o);
  }
  Ms = function(e) {
    switch (e.tag) {
      case 3:
        var t = e.stateNode;
        if (t.current.memoizedState.isDehydrated) {
          var n = Wr(t.pendingLanes);
          n !== 0 && (Di(t, n | 1), St(t, Qe()), (Ee & 6) === 0 && (Lr = Qe() + 500, Tn()));
        }
        break;
      case 13:
        bn(function() {
          var r = vn(e, 1);
          if (r !== null) {
            var l = dt();
            Yt(r, e, 1, l);
          }
        }), ps(e, 1);
    }
  }, $i = function(e) {
    if (e.tag === 13) {
      var t = vn(e, 134217728);
      if (t !== null) {
        var n = dt();
        Yt(t, e, 134217728, n);
      }
      ps(e, 134217728);
    }
  }, Ps = function(e) {
    if (e.tag === 13) {
      var t = $n(e), n = vn(e, t);
      if (n !== null) {
        var r = dt();
        Yt(n, e, t, r);
      }
      ps(e, t);
    }
  }, Ts = function() {
    return Me;
  }, Os = function(e, t) {
    var n = Me;
    try {
      return Me = e, t();
    } finally {
      Me = n;
    }
  }, Vn = function(e, t, n) {
    switch (t) {
      case "input":
        if (Fe(e, n), t = n.name, n.type === "radio" && t != null) {
          for (n = e; n.parentNode; ) n = n.parentNode;
          for (n = n.querySelectorAll("input[name=" + JSON.stringify("" + t) + '][type="radio"]'), t = 0; t < n.length; t++) {
            var r = n[t];
            if (r !== e && r.form === e.form) {
              var l = Kl(r);
              if (!l) throw Error(f(90));
              ge(r), Fe(r, l);
            }
          }
        }
        break;
      case "textarea":
        Dt(e, n);
        break;
      case "select":
        t = n.value, t != null && pt(e, !!n.multiple, t, !1);
    }
  }, El = os, I = bn;
  var pd = { usingClientEntryPoint: !1, Events: [ll, vr, Kl, Ir, _l, os] }, gl = { findFiberByHostInstance: Qn, bundleType: 0, version: "18.3.1", rendererPackageName: "react-dom" }, hd = { bundleType: gl.bundleType, version: gl.version, rendererPackageName: gl.rendererPackageName, rendererConfig: gl.rendererConfig, overrideHookState: null, overrideHookStateDeletePath: null, overrideHookStateRenamePath: null, overrideProps: null, overridePropsDeletePath: null, overridePropsRenamePath: null, setErrorHandler: null, setSuspenseHandler: null, scheduleUpdate: null, currentDispatcherRef: xe.ReactCurrentDispatcher, findHostInstanceByFiber: function(e) {
    return e = Ar(e), e === null ? null : e.stateNode;
  }, findFiberByHostInstance: gl.findFiberByHostInstance || fd, findHostInstancesForRefresh: null, scheduleRefresh: null, scheduleRoot: null, setRefreshHandler: null, getCurrentFiber: null, reconcilerVersion: "18.3.1-next-f1338f8080-20240426" };
  if (typeof __REACT_DEVTOOLS_GLOBAL_HOOK__ < "u") {
    var zi = __REACT_DEVTOOLS_GLOBAL_HOOK__;
    if (!zi.isDisabled && zi.supportsFiber) try {
      Nl = zi.inject(hd), bt = zi;
    } catch {
    }
  }
  return _t.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED = pd, _t.createPortal = function(e, t) {
    var n = 2 < arguments.length && arguments[2] !== void 0 ? arguments[2] : null;
    if (!ms(t)) throw Error(f(200));
    return cd(e, t, null, n);
  }, _t.createRoot = function(e, t) {
    if (!ms(e)) throw Error(f(299));
    var n = !1, r = "", l = qa;
    return t != null && (t.unstable_strictMode === !0 && (n = !0), t.identifierPrefix !== void 0 && (r = t.identifierPrefix), t.onRecoverableError !== void 0 && (l = t.onRecoverableError)), t = ds(e, 1, !1, null, null, n, !1, r, l), e[dn] = t.current, tl(e.nodeType === 8 ? e.parentNode : e), new hs(t);
  }, _t.findDOMNode = function(e) {
    if (e == null) return null;
    if (e.nodeType === 1) return e;
    var t = e._reactInternals;
    if (t === void 0)
      throw typeof e.render == "function" ? Error(f(188)) : (e = Object.keys(e).join(","), Error(f(268, e)));
    return e = Ar(t), e = e === null ? null : e.stateNode, e;
  }, _t.flushSync = function(e) {
    return bn(e);
  }, _t.hydrate = function(e, t, n) {
    if (!Ri(t)) throw Error(f(200));
    return Li(null, e, t, !0, n);
  }, _t.hydrateRoot = function(e, t, n) {
    if (!ms(e)) throw Error(f(405));
    var r = n != null && n.hydratedSources || null, l = !1, i = "", o = qa;
    if (n != null && (n.unstable_strictMode === !0 && (l = !0), n.identifierPrefix !== void 0 && (i = n.identifierPrefix), n.onRecoverableError !== void 0 && (o = n.onRecoverableError)), t = Xa(t, null, e, 1, n ?? null, l, !1, i, o), e[dn] = t.current, tl(e), r) for (e = 0; e < r.length; e++) n = r[e], l = n._getVersion, l = l(n._source), t.mutableSourceEagerHydrationData == null ? t.mutableSourceEagerHydrationData = [n, l] : t.mutableSourceEagerHydrationData.push(
      n,
      l
    );
    return new Ni(t);
  }, _t.render = function(e, t, n) {
    if (!Ri(t)) throw Error(f(200));
    return Li(null, e, t, !1, n);
  }, _t.unmountComponentAtNode = function(e) {
    if (!Ri(e)) throw Error(f(40));
    return e._reactRootContainer ? (bn(function() {
      Li(null, null, e, !1, function() {
        e._reactRootContainer = null, e[dn] = null;
      });
    }), !0) : !1;
  }, _t.unstable_batchedUpdates = os, _t.unstable_renderSubtreeIntoContainer = function(e, t, n, r) {
    if (!Ri(n)) throw Error(f(200));
    if (e == null || e._reactInternals === void 0) throw Error(f(38));
    return Li(e, t, n, !1, r);
  }, _t.version = "18.3.1-next-f1338f8080-20240426", _t;
}
var ic;
function gc() {
  if (ic) return gs.exports;
  ic = 1;
  function u() {
    if (!(typeof __REACT_DEVTOOLS_GLOBAL_HOOK__ > "u" || typeof __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE != "function"))
      try {
        __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE(u);
      } catch (y) {
        console.error(y);
      }
  }
  return u(), gs.exports = kd(), gs.exports;
}
var oc;
function Sd() {
  if (oc) return Mi;
  oc = 1;
  var u = gc();
  return Mi.createRoot = u.createRoot, Mi.hydrateRoot = u.hydrateRoot, Mi;
}
var _d = Sd(), M = Es();
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Ed = (u) => u.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase(), wc = (...u) => u.filter((y, f, x) => !!y && y.trim() !== "" && x.indexOf(y) === f).join(" ").trim();
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
var Cd = {
  xmlns: "http://www.w3.org/2000/svg",
  width: 24,
  height: 24,
  viewBox: "0 0 24 24",
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 2,
  strokeLinecap: "round",
  strokeLinejoin: "round"
};
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const jd = M.forwardRef(
  ({
    color: u = "currentColor",
    size: y = 24,
    strokeWidth: f = 2,
    absoluteStrokeWidth: x,
    className: _ = "",
    children: S,
    iconNode: F,
    ...V
  }, P) => M.createElement(
    "svg",
    {
      ref: P,
      ...Cd,
      width: y,
      height: y,
      stroke: u,
      strokeWidth: x ? Number(f) * 24 / Number(y) : f,
      className: wc("lucide", _),
      ...V
    },
    [
      ...F.map(([ee, T]) => M.createElement(ee, T)),
      ...Array.isArray(S) ? S : [S]
    ]
  )
);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Xt = (u, y) => {
  const f = M.forwardRef(
    ({ className: x, ..._ }, S) => M.createElement(jd, {
      ref: S,
      iconNode: y,
      className: wc(`lucide-${Ed(u)}`, x),
      ..._
    })
  );
  return f.displayName = `${u}`, f;
};
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Nd = Xt("CalendarDays", [
  ["path", { d: "M8 2v4", key: "1cmpym" }],
  ["path", { d: "M16 2v4", key: "4m81vk" }],
  ["rect", { width: "18", height: "18", x: "3", y: "4", rx: "2", key: "1hopcy" }],
  ["path", { d: "M3 10h18", key: "8toen8" }],
  ["path", { d: "M8 14h.01", key: "6423bh" }],
  ["path", { d: "M12 14h.01", key: "1etili" }],
  ["path", { d: "M16 14h.01", key: "1gbofw" }],
  ["path", { d: "M8 18h.01", key: "lrp35t" }],
  ["path", { d: "M12 18h.01", key: "mhygvu" }],
  ["path", { d: "M16 18h.01", key: "kzsmim" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Rd = Xt("ChevronLeft", [
  ["path", { d: "m15 18-6-6 6-6", key: "1wnfg3" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Ld = Xt("ChevronRight", [
  ["path", { d: "m9 18 6-6-6-6", key: "mthhwq" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const zd = Xt("FileText", [
  ["path", { d: "M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z", key: "1rqfz7" }],
  ["path", { d: "M14 2v4a2 2 0 0 0 2 2h4", key: "tnqrlb" }],
  ["path", { d: "M10 9H8", key: "b1mrlr" }],
  ["path", { d: "M16 13H8", key: "t4e002" }],
  ["path", { d: "M16 17H8", key: "z1uh3a" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const xc = Xt("Inbox", [
  ["polyline", { points: "22 12 16 12 14 15 10 15 8 12 2 12", key: "o97t9d" }],
  [
    "path",
    {
      d: "M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z",
      key: "oot6mr"
    }
  ]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Md = Xt("Library", [
  ["path", { d: "m16 6 4 14", key: "ji33uf" }],
  ["path", { d: "M12 6v14", key: "1n7gus" }],
  ["path", { d: "M8 8v12", key: "1gg7y9" }],
  ["path", { d: "M4 4v16", key: "6qkkli" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Pd = Xt("NotebookText", [
  ["path", { d: "M2 6h4", key: "aawbzj" }],
  ["path", { d: "M2 10h4", key: "l0bgd4" }],
  ["path", { d: "M2 14h4", key: "1gsvsf" }],
  ["path", { d: "M2 18h4", key: "1bu2t1" }],
  ["rect", { width: "16", height: "20", x: "4", y: "2", rx: "2", key: "1nb95v" }],
  ["path", { d: "M9.5 8h5", key: "11mslq" }],
  ["path", { d: "M9.5 12H16", key: "ktog6x" }],
  ["path", { d: "M9.5 16H14", key: "p1seyn" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Td = Xt("Search", [
  ["circle", { cx: "11", cy: "11", r: "8", key: "4ej97u" }],
  ["path", { d: "m21 21-4.3-4.3", key: "1qie3q" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Od = Xt("Settings", [
  [
    "path",
    {
      d: "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z",
      key: "1qme2f"
    }
  ],
  ["circle", { cx: "12", cy: "12", r: "3", key: "1v7zrd" }]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Fd = Xt("Star", [
  [
    "path",
    {
      d: "M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z",
      key: "r04s7s"
    }
  ]
]);
/**
 * @license lucide-react v0.468.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */
const Id = Xt("Users", [
  ["path", { d: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2", key: "1yyitq" }],
  ["circle", { cx: "9", cy: "7", r: "4", key: "nufk8" }],
  ["path", { d: "M22 21v-2a4 4 0 0 0-3-3.87", key: "kshegd" }],
  ["path", { d: "M16 3.13a4 4 0 0 1 0 7.75", key: "1da9ce" }]
]);
var sc = gc();
const Ad = { cmd: "⌘", shift: "⇧", alt: "⌥", option: "⌥", ctrl: "⌃", enter: "↵", return: "↵", esc: "esc", tab: "⇥", up: "↑", down: "↓", left: "←", right: "→", backspace: "⌫" }, Dd = (u) => u.split("+").map((y) => Ad[y.trim().toLowerCase()] ?? y.trim().toUpperCase());
function $d({ rows: u, at: y }) {
  return /* @__PURE__ */ s.jsx(s.Fragment, { children: u.map(
    (f) => f && /* @__PURE__ */ s.jsx("div", { className: "ss-keys", "data-show": f.show, "data-at": y, "aria-hidden": !0, children: f.caps.map((x, _) => /* @__PURE__ */ s.jsx("kbd", { className: "ss-key", "data-down": f.down, children: x }, _)) }, f.id)
  ) });
}
const kc = { x: 0, y: 0, width: 0, height: 0 }, Sc = (u) => typeof u == "string" ? u : "at" in u ? u.at : null, Wd = (u, y) => (u == null ? void 0 : u.offsetWidth) && u.getBoundingClientRect().width / u.offsetWidth || y || 1;
function Cs(u, y) {
  const f = u.getBoundingClientRect();
  return { left: f.left, top: f.top, scale: u.offsetWidth && f.width / u.offsetWidth || y || 1, borderX: u.clientLeft, borderY: u.clientTop };
}
function Sl(u, y, f, x = Cs(u, f)) {
  const _ = y.getBoundingClientRect(), { scale: S } = x;
  return { x: (_.left - x.left) / S - x.borderX, y: (_.top - x.top) / S - x.borderY, width: _.width / S, height: _.height / S };
}
function Ud(u, y, f, x = Cs(u, f)) {
  const _ = Sl(u, y, f, x), S = getComputedStyle(y), F = S.transform, V = F && F !== "none" ? F.match(/^matrix\(([^)]+)\)$/) : null;
  if (!V) return _;
  const [P, ee, T, Y, X, J] = V[1].split(",").map(Number);
  if (ee || T || X || J || !P || !Y) return _;
  const A = _.width / P, Z = _.height / Y, [U, ve] = S.transformOrigin.split(" ").map(parseFloat);
  return { x: _.x - U * (1 - P), y: _.y - ve * (1 - Y), width: A, height: Z };
}
const Bd = (u) => {
  const y = getComputedStyle(u);
  return y.transform !== "none" || y.translate && y.translate !== "none" || y.scale && y.scale !== "none" || y.rotate && y.rotate !== "none";
};
function Hd(u, y) {
  let f = !0;
  for (let F = y; F && F !== u; F = F.parentElement) if (Bd(F)) {
    f = !1;
    break;
  }
  if (f) return Sl(u, y, 1);
  let x = 0, _ = 0, S = y;
  for (; S && S !== u; ) {
    x += S.offsetLeft, _ += S.offsetTop;
    const F = S.offsetParent;
    if (!F || !u.contains(F)) break;
    S = F, S !== u && (x += S.clientLeft - S.scrollLeft, _ += S.clientTop - S.scrollTop);
  }
  return { x, y: _, width: y.offsetWidth, height: y.offsetHeight };
}
function uc(u, y) {
  const f = Object.keys(u);
  return f.length !== Object.keys(y).length ? !1 : f.every((x) => {
    const _ = u[x], S = y[x];
    return S && Math.abs(_.x - S.x) < 0.5 && Math.abs(_.y - S.y) < 0.5 && Math.abs(_.width - S.width) < 0.5 && Math.abs(_.height - S.height) < 0.5;
  });
}
function _c(u) {
  const y = u.parentElement;
  if (!(y != null && y.classList.contains("ss-scroller"))) return;
  const f = u.clientHeight, x = u.scrollHeight, _ = x > f ? Math.max(24, f / x * f) : 0, S = x > f ? u.scrollTop / (x - f) * (f - _) : 0;
  y.style.setProperty("--ss-thumb-h", `${_}px`), y.style.setProperty("--ss-thumb-y", `${S}px`);
}
const Vd = {
  /** Moves inside a shot (push-in, pan, a long cursor trip): peak at about 40%, long soft tail. 1.4 to 2.7 s. */
  house: [0.65, 0, 0.1, 1],
  /** The outgoing half of a move that ends in a cut: accelerates into it. */
  through: [0.8, 0, 0.1, 1],
  /** The incoming half after a cut: arrives at speed, settles. 0.6 to 0.8 s (1.6 s for a big pull-out). */
  settle: [0.05, 0.85, 0.3, 1],
  /** A cursor arriving from off-frame, already moving. */
  enter: [0.1, 0.8, 0.3, 0.95],
  /** One long cursor trip across the frame. */
  trip: [0.78, 0, 0.17, 1],
  /** The kit's camera push-in (Camera). */
  camera: [0.45, 0, 0.1, 1]
};
function Qd(u) {
  const [y, f, x, _] = Vd[u], S = 3 * y, F = 3 * (x - y) - S, V = 1 - S - F, P = 3 * f, ee = 3 * (_ - f) - P, T = 1 - P - ee, Y = (J) => ((V * J + F) * J + S) * J, X = (J) => (3 * V * J + 2 * F) * J + S;
  return (J) => {
    if (J <= 0) return 0;
    if (J >= 1) return 1;
    let A = J;
    for (let Z = 0; Z < 8; Z++) {
      const U = X(A);
      if (Math.abs(U) < 1e-6) break;
      const ve = A - (Y(A) - J) / U;
      if (ve < 0 || ve > 1) break;
      A = ve;
    }
    if (Math.abs(Y(A) - J) > 1e-6) {
      let Z = 0, U = 1;
      for (let ve = 0; ve < 40; ve++)
        A = (Z + U) / 2, Y(A) < J ? Z = A : U = A;
    }
    return ((T * A + ee) * A + P) * A;
  };
}
function Ec() {
  try {
    return !1;
  } catch {
    return !0;
  }
}
function Or(u) {
  Ec() && console.warn(`[stageshow] ${u}`);
}
const Pr = (u, y, f) => Math.min(f, Math.max(y, u)), Pi = (u) => u < 0.5 ? 4 * u * u * u : 1 - Math.pow(-2 * u + 2, 3) / 2, Kd = (u) => {
  const y = Math.sin(u * 12.9898) * 43758.5453;
  return y - Math.floor(y);
}, ac = (u) => {
  u && window.setTimeout(() => u.removeAttribute("data-touching"), 240);
};
class Tr extends Error {
}
function Yd(u, y) {
  const { rootRef: f, cursorRef: x, pos: _, hovered: S, kindRef: F, keysRef: V, dragging: P, autoUsed: ee, autoRef: T, scaleRef: Y, speed: X, layout: J, cursor: A, resolve: Z, place: U, remeasure: ve, ripple: ae, setState: ke, setKind: xe, setKeys: te, setLastKeys: Ne } = y, B = Qd("enter"), C = () => {
    if (u.aborted) throw new Tr();
  }, de = (a, p) => new Promise((v, k) => {
    C();
    const E = () => {
      p(D), u.removeEventListener("abort", E), k(new Tr());
    }, D = a(() => {
      u.removeEventListener("abort", E), u.aborted ? k(new Tr()) : v();
    });
    u.addEventListener("abort", E, { once: !0 });
  }), re = () => de((a) => requestAnimationFrame(a), cancelAnimationFrame), he = (a) => de((p) => setTimeout(p, a / X), clearTimeout), Pe = (a) => {
    let p = !0;
    const v = () => {
      p && (p = !1, u.removeEventListener("abort", v), a());
    };
    return u.addEventListener("abort", v, { once: !0 }), v;
  }, we = async (a, p) => {
    const v = performance.now(), k = a / X;
    for (; ; ) {
      C();
      const E = Math.min(1, (performance.now() - v) / k);
      if (p(E), E === 1) return;
      await re();
    }
  }, ce = (a) => {
    const p = [];
    for (let v = a; v && v !== f.current; v = v.parentElement) v.hasAttribute("data-target") && p.push(v);
    return p;
  }, Re = (a) => {
    const p = f.current;
    if (!p) return;
    const v = p.querySelectorAll("[data-cursor]");
    if (!v.length && !ee.current) return;
    v.length && (ee.current = !0);
    const k = p.getBoundingClientRect(), E = k.width / p.offsetWidth || 1, D = p.dataset.cursorBase ?? "pointer";
    let q = D;
    p.setAttribute("data-hit", "");
    const le = document.elementsFromPoint(k.left + a.x * E, k.top + a.y * E);
    p.removeAttribute("data-hit");
    const b = le.find((ne) => {
      if (!p.contains(ne) || ne.closest(".ss-cursor, .ss-keys, .ss-ripple") || getComputedStyle(ne).pointerEvents === "none" && !ne.closest('[data-cursor], [data-target], button, a[href], [role="button"], [role="menuitem"], [role="option"], [role="tab"]')) return !1;
      let pe = 1;
      for (let ge = ne; ge && ge !== p.parentElement; ge = ge.parentElement) {
        const Te = getComputedStyle(ge);
        if (Te.visibility === "hidden") return !1;
        pe *= Number(Te.opacity);
      }
      return pe > 0.15;
    });
    if (b) {
      const ne = b.closest('[data-cursor], button, a[href], [role="button"], [role="menuitem"], [role="option"], [role="tab"]');
      q = ne && p.contains(ne) && ne.dataset.cursor ? ne.dataset.cursor : D, q !== F.current && xe(q);
      return;
    }
    v.forEach((ne) => {
      const pe = ne.getBoundingClientRect(), ge = (pe.left - k.left) / E, Te = (pe.top - k.top) / E;
      a.x >= ge && a.x <= ge + pe.width / E && a.y >= Te && a.y <= Te + pe.height / E && (q = ne.dataset.cursor);
    }), q !== F.current && xe(q);
  };
  T.current = Re, P.current || Re(_.current);
  const Ce = (a) => {
    if (S.current === a) return;
    const p = ce(a);
    ce(S.current).forEach((v) => p.includes(v) || v.removeAttribute("data-hover")), p.forEach((v) => v.setAttribute("data-hover", "")), S.current = a;
  };
  let se = V.current.id, z = 0;
  const K = (a) => {
    var v;
    const p = Sc(a);
    return p === null ? null : ((v = f.current) == null ? void 0 : v.querySelector(`[data-target="${p}"]`)) ?? null;
  }, O = {
    get signal() {
      return u;
    },
    put(a) {
      u.aborted || ke((p) => ({ ...p, ...typeof a == "function" ? a(p) : a }));
    },
    async set(a) {
      var p;
      C(), O.put(a), await re(), await re(), (p = T.current) == null || p.call(T, _.current), C();
    },
    wait: async (a) => {
      C(), await he(a);
    },
    rect: (a, p) => {
      const v = f.current, k = v == null ? void 0 : v.querySelector(`[data-target="${a}"]`);
      return !v || !k ? (Or(`no element with data-target="${a}"`), kc) : p != null && p.layout ? Hd(v, k) : Sl(v, k, Y.current);
    },
    center: (a) => Z(a),
    caret(a, p) {
      z++;
      const v = K(a), k = f.current;
      if (!v || !k) return 0;
      const E = k.getBoundingClientRect(), D = E.width / k.offsetWidth || 1, q = E.left + p.x * D, le = E.top + p.y * D, b = [], ne = document.createTreeWalker(v, NodeFilter.SHOW_TEXT), pe = document.createRange();
      let ge = 0;
      const Te = (Fe) => {
        for (let tt = Fe.parentElement; tt; tt = tt === v ? null : tt.parentElement) {
          const Ie = getComputedStyle(tt);
          if (Ie.opacity === "0" || Ie.visibility === "hidden" || Ie.display === "none") return !0;
        }
        return !1;
      };
      for (let Fe = ne.nextNode(); Fe; Fe = ne.nextNode()) {
        const tt = Fe.textContent ?? "";
        if (!Te(Fe)) {
          for (let Ie = 0; Ie < tt.length; Ie++) {
            pe.setStart(Fe, Ie), pe.setEnd(Fe, Ie + 1);
            const Se = pe.getBoundingClientRect();
            (Se.width || Se.height) && b.push({ left: Se.left, right: Se.right, mid: (Se.left + Se.right) / 2, top: Se.top, bottom: Se.bottom, at: ge + Ie });
          }
          ge += tt.length;
        }
      }
      if (!b.length || le < b[0].top) return 0;
      if (le > b[b.length - 1].bottom) return ge;
      let Xe = b[0];
      for (const Fe of b) Math.abs((Fe.top + Fe.bottom) / 2 - le) < Math.abs((Xe.top + Xe.bottom) / 2 - le) && (Xe = Fe);
      const Le = b.filter((Fe) => Math.abs(Fe.top - Xe.top) < (Xe.bottom - Xe.top) / 2), ln = Le.find((Fe) => Fe.mid > q);
      return ln ? ln.at : Le[Le.length - 1].at + 1;
    },
    async move(a, p) {
      C();
      const v = { ..._.current }, k = Z(a), E = Math.hypot(k.x - v.x, k.y - v.y);
      if (E < 0.5) return Ce(K(a));
      const D = ce(K(a));
      Ce(ce(S.current).find((ge) => D.includes(ge)) ?? null);
      const q = (p == null ? void 0 : p.duration) ?? Pr(260 + E * 0.9, 300, 650), le = Pi, b = Math.min(E * 0.08, 24), ne = -(k.y - v.y) / E, pe = (k.x - v.x) / E;
      await we(q, (ge) => {
        const Te = le(ge), Xe = Math.sin(Math.PI * Te) * b, Le = p != null && p.path ? p.path(Te, v, k) : { x: v.x + (k.x - v.x) * Te + ne * Xe, y: v.y + (k.y - v.y) * Te + pe * Xe };
        U(Le), Re(Le), p != null && p.onMove && sc.flushSync(() => p.onMove(Le, v, ge));
      }), C(), Ce(K(a));
    },
    async click(a, p) {
      C(), a !== void 0 && (await O.move(a), await he(120)), C();
      const v = a !== void 0 ? K(a) : S.current, k = x.current, E = (A == null ? void 0 : A.style) === "touch", D = Pe(() => {
        k == null || k.removeAttribute("data-pressed"), v == null || v.removeAttribute("data-pressed"), E && ac(k);
      });
      try {
        E && (k == null || k.setAttribute("data-touching", ""), await he(140), C());
        for (let q = 0; q < (p != null && p.double ? 2 : 1); q++)
          q && await he(70), C(), k == null || k.setAttribute("data-pressed", "true"), A != null && A.ripple && ae(_.current), v == null || v.setAttribute("data-pressed", p != null && p.right ? "right" : ""), await he(p != null && p.double ? 80 : 100), C(), k == null || k.removeAttribute("data-pressed"), v == null || v.removeAttribute("data-pressed");
      } finally {
        D();
      }
    },
    async scroll(a, p, v) {
      var b, ne;
      C();
      const k = K(a);
      if (!k) return;
      const E = k.scrollTop;
      let D = typeof p == "number" ? p : E;
      if (typeof p == "string") {
        const pe = K(p);
        pe && (D = E + (pe.getBoundingClientRect().top - k.getBoundingClientRect().top) / Wd(f.current, Y.current) - ((v == null ? void 0 : v.offset) ?? 0));
      }
      if (D = Pr(D, 0, k.scrollHeight - k.clientHeight), A) {
        const pe = Sl(f.current, k, Y.current || 1), ge = _.current;
        ge.x >= pe.x + 8 && ge.x <= pe.x + pe.width - 8 && ge.y >= pe.y + 8 && ge.y <= pe.y + pe.height - 8 || (await this.move({ x: pe.x + pe.width * 0.6, y: pe.y + pe.height * 0.55 }), await this.wait(120));
      }
      const q = (b = k.parentElement) != null && b.classList.contains("ss-scroller") ? k.parentElement : null;
      q == null || q.setAttribute("data-scrolling", "");
      const le = Pe(() => q == null ? void 0 : q.removeAttribute("data-scrolling"));
      try {
        await we((v == null ? void 0 : v.duration) ?? Pr(420 + Math.abs(D - E) * 1.2, 500, 1400), (pe) => {
          k.scrollTop = E + (D - E) * Pi(pe), k.toggleAttribute("data-scrolled", k.scrollTop > 0.5), _c(k);
        }), C();
      } finally {
        le();
      }
      ve(), (ne = T.current) == null || ne.call(T, _.current);
    },
    async snap(a, p) {
      var E;
      C();
      const v = p ? (E = f.current) == null ? void 0 : E.querySelector(`[data-target="${p}"]`) : f.current;
      v == null || v.setAttribute("data-instant", "");
      const k = Pe(() => v == null ? void 0 : v.removeAttribute("data-instant"));
      try {
        O.put(a), await re(), await re(), C();
      } finally {
        k();
      }
    },
    async key(a) {
      C();
      const p = Dd(a), v = ++se, k = V.current;
      Ne(k.caps.length ? { ...k, show: !1, down: !1 } : null), te({ id: v, caps: p, show: !1, down: !1 }), await re(), await re(), C(), te({ id: v, caps: p, show: !0, down: !1 }), await he(180), C(), te({ id: v, caps: p, show: !0, down: !0 }), await he(140), C(), te({ id: v, caps: p, show: !0, down: !1 }), he(600).then(() => {
        se === v && !u.aborted && te({ id: v, caps: p, show: !1, down: !1 });
      }, (E) => {
        E instanceof Tr || console.error("[stageshow] script error", E);
      });
    },
    async stagger(a, p, v = 60) {
      await Promise.all(
        a.map(async (k, E) => {
          E && await he(v * E), C(), await p(k, E);
        })
      );
    },
    mark(a) {
      var p;
      u.aborted || (p = f.current) == null || p.setAttribute("data-mark", a);
    },
    async cursor(a) {
      C(), xe(a), await re();
    },
    async type(a, p, v) {
      const k = (v == null ? void 0 : v.interval) ?? 35;
      for (let E = 0; E <= p.length; E++)
        C(), ke((D) => ({ ...D, [a]: p.slice(0, E) })), await he(k * (0.7 + 0.6 * Kd(E)));
    },
    place(a) {
      var v;
      if (u.aborted) return;
      const p = Z(a);
      U(p), (v = T.current) == null || v.call(T, p);
    },
    async enter(a, p) {
      C();
      const v = Z(a), k = f.current, E = { x: 0, y: 0, w: k.offsetWidth, h: k.offsetHeight }, D = 40, q = [v.x - E.x, E.x + E.w - v.x, v.y - E.y, E.y + E.h - v.y], le = q.indexOf(Math.min(...q)), b = le === 0 ? { x: E.x - D, y: v.y + E.h * 0.12 } : le === 1 ? { x: E.x + E.w + D * 0.4, y: v.y + E.h * 0.12 } : le === 2 ? { x: v.x - E.w * 0.06, y: E.y - D } : { x: v.x + E.w * 0.06, y: E.y + E.h + D * 0.4 };
      U(b), Ce(null), await we((p == null ? void 0 : p.duration) ?? 700, (ne) => {
        const pe = B(ne), ge = { x: b.x + (v.x - b.x) * pe, y: b.y + (v.y - b.y) * pe };
        U(ge), Re(ge);
      }), C(), Ce(K(a));
    },
    async drag(a, p, v) {
      var Fe, tt, Ie;
      C();
      const k = { ..._.current }, E = Z(a), D = Math.hypot(E.x - k.x, E.y - k.y);
      Ce(null);
      const q = F.current, le = q === "ibeam" || q === "crosshair", b = !le && (v == null ? void 0 : v.cursor) !== "preserve", ne = (A == null ? void 0 : A.style) === "touch", pe = (Se) => {
        const Et = 1.1428571428571428;
        return Se < 0.25 ? Se * Se / (2 * 0.25) * Et : (Se - 0.25 / 2) * Et;
      };
      ne && ((Fe = x.current) == null || Fe.setAttribute("data-touching", ""), await he(140), C());
      const ge = ne ? ((tt = x.current) == null ? void 0 : tt.querySelector(".ss-cursor__streak")) ?? null : null, Te = [], Xe = (Se) => {
        Te.unshift({ ...Se }), Te.length > 9 && Te.pop();
        const pt = Te[Te.length - 1], Et = Se.x - pt.x, At = Se.y - pt.y, Dt = Math.min(Math.hypot(Et, At), 100);
        ge && (ge.style.width = `${Dt}px`, ge.style.left = `${-Dt}px`, ge.style.transform = `rotate(${Math.atan2(At, Et)}rad)`);
      };
      P.current = !0;
      const Le = x.current, ln = Pe(() => {
        P.current = !1, Le == null || Le.removeAttribute("data-pressed"), Le == null || Le.removeAttribute("data-swiping"), ne && ac(Le);
      });
      try {
        Le == null || Le.setAttribute("data-pressed", "true"), await he(ne ? 170 : 60), ne && (ge && (ge.style.width = "0px"), Le == null || Le.setAttribute("data-swiping", "")), C(), b && !ne && xe("grab"), ne || await he(70), C(), Le == null || Le.removeAttribute("data-pressed");
        const Se = le ? 0 : Math.min(D * 0.06, 18), pt = D ? -(E.y - k.y) / D : 0, Et = D ? (E.x - k.x) / D : 0, At = le && Math.abs(E.y - k.y) > 6;
        At && E.y > k.y && E.x < k.x - 2 && Or("a text selection that ends left of where it starts overshoots and shrinks back; select text that starts a line, or fits on one");
        const Dt = z;
        await we(ne ? (v == null ? void 0 : v.duration) ?? Pr(180 + D * 0.5, 240, 300) : (v == null ? void 0 : v.duration) ?? Pr(360 + D * 1.1, 450, 900), (on) => {
          var qt;
          const ht = ne ? pe(on) : Pi(on), sn = Math.sin(Math.PI * ht) * Se, Gt = At ? 1 - (1 - ht) * (1 - ht) : ht, kn = At ? ht * ht : ht, nt = ((qt = v == null ? void 0 : v.path) == null ? void 0 : qt.call(v, ht, k, E)) ?? { x: k.x + (E.x - k.x) * kn + pt * sn, y: k.y + (E.y - k.y) * Gt + Et * sn };
          sc.flushSync(() => p == null ? void 0 : p(nt, k, on)), U(nt), ne && Xe(nt);
        }), le && p && z === Dt && Or("selection drift: a text selection drag never read a.caret(), so the highlight is not under the I-beam; set it from a.caret(name, at) in onMove"), C(), b && !ne && xe(q === "grab" ? "pointer" : q);
      } finally {
        ln();
      }
      (Ie = T.current) == null || Ie.call(T, E);
    },
    layout: J
  };
  for (const a of Object.keys(O)) {
    const p = O[a];
    typeof p == "function" && (O[a] = (...v) => {
      const k = p.apply(O, v);
      return k instanceof Promise && k.catch((E) => {
        E instanceof Tr || console.error("[stageshow] script error", E);
      }), k;
    });
  }
  return O;
}
function Xd(u, y, f, x) {
  const _ = Object.keys(y).filter(
    (S) => JSON.stringify(u[S]) !== JSON.stringify(y[S])
  );
  _.length && Or(`loop seam: state still differs from initial at the end of the script (${_.join(", ")})`), x && Math.hypot(f.x - x.x, f.y - x.y) > 1 && Or("loop seam: cursor does not end where it starts");
}
function Gd() {
  return /* @__PURE__ */ s.jsx("svg", { height: "24", width: "24", viewBox: "0 0 32 32", fill: "none", children: /* @__PURE__ */ s.jsxs("g", { transform: "translate(10 7)", children: [
    /* @__PURE__ */ s.jsx("path", { d: "m6.148 18.473 1.863-1.003 1.615-.839-2.568-4.816h4.332l-11.379-11.408v16.015l3.316-3.221z", fill: "#fff" }),
    /* @__PURE__ */ s.jsx("path", { d: "m6.431 17 1.765-.941-2.775-5.202h3.604l-8.025-8.043v11.188l2.53-2.442z", fill: "#000" })
  ] }) });
}
function qd() {
  return /* @__PURE__ */ s.jsxs("svg", { width: "10", height: "16", viewBox: "0 0 10 16", fill: "none", overflow: "visible", children: [
    /* @__PURE__ */ s.jsx("path", { d: "M3 1H7M3 15H7M5 1V15", style: { stroke: "var(--ss-cursor-edge, #fff)" }, strokeWidth: "2.6", strokeLinecap: "round" }),
    /* @__PURE__ */ s.jsx("path", { d: "M3 1H7M3 15H7M5 1V15", style: { stroke: "var(--ss-cursor-line, #000)" }, strokeWidth: "1", strokeLinecap: "round" })
  ] });
}
function Zd() {
  return /* @__PURE__ */ s.jsxs("svg", { width: "17", height: "17", viewBox: "0 0 17 17", fill: "none", overflow: "visible", children: [
    /* @__PURE__ */ s.jsx("path", { d: "M8.5 0V17M0 8.5H17", style: { stroke: "var(--ss-cursor-edge, #fff)" }, strokeWidth: "2.6" }),
    /* @__PURE__ */ s.jsx("path", { d: "M8.5 0V17M0 8.5H17", style: { stroke: "var(--ss-cursor-line, #000)" }, strokeWidth: "1" })
  ] });
}
function Jd() {
  return /* @__PURE__ */ s.jsxs("svg", { width: "26", height: "26", viewBox: "0 0 32 32", fill: "none", children: [
    /* @__PURE__ */ s.jsx(
      "path",
      {
        d: "M10.6 6a1.7 1.7 0 0 1 3.4 0v6.6a1.3 1.3 0 0 1 2.6 0v.7a1.3 1.3 0 0 1 2.6 0v.7a1.3 1.3 0 0 1 2.6 0V19c0 3.1-2 5.6-5 5.6h-2.6c-2 0-3.3-.9-4.4-2.4l-3.1-4.1c-.6-.9-.4-2 .5-2.5.8-.4 1.7-.2 2.3.5l1.1 1.4V6Z",
        fill: "#fff",
        stroke: "#000",
        strokeWidth: "1.1",
        strokeLinejoin: "round"
      }
    ),
    /* @__PURE__ */ s.jsx("path", { d: "M14 12.6v3.6M16.6 13.3v3M19.2 14v2.6", stroke: "#000", strokeWidth: "1", strokeLinecap: "round" })
  ] });
}
function bd() {
  return /* @__PURE__ */ s.jsx("svg", { width: "26", height: "26", viewBox: "0 0 32 32", fill: "none", children: /* @__PURE__ */ s.jsxs("g", { transform: "translate(7 6)", children: [
    /* @__PURE__ */ s.jsx("path", { d: "m4.5557 8.5742c-.098-.375-.196-.847-.406-1.552-.167-.557-.342-.859-.47-1.233-.155-.455-.303-.721-.496-1.181-.139-.329-.364-1.048-.457-1.44-.119-.509.033-.924.244-1.206.253-.339.962-.49 1.357-.351.371.13.744.512.916.788.288.46.357.632.717 1.542.393.992.564 1.918.611 2.231l.085.452c-.001-.04-.043-1.122-.044-1.162-.035-1.029-.06-1.823-.038-2.939.002-.126.064-.587.084-.715.078-.5.305-.8.673-.979.412-.201.926-.215 1.401-.017.423.173.626.55.687 1.022.014.109.094.987.093 1.107-.013 1.025.006 1.641.015 2.174.004.231.003 1.625.017 1.469.061-.656.094-3.189.344-3.942.144-.433.405-.746.794-.929.431-.203 1.113-.07 1.404.243.285.305.446.692.482 1.153.032.405-.019.897-.02 1.245 0 .867-.021 1.324-.037 2.121-.001.038-.015.298.023.182.094-.28.188-.542.266-.745.049-.125.241-.614.359-.859.114-.234.211-.369.415-.688.2-.313.415-.448.668-.561.54-.235 1.109.112 1.301.591.086.215.009.713-.028 1.105-.061.647-.254 1.306-.352 1.648-.128.447-.274 1.235-.34 1.601-.072.394-.234 1.382-.359 1.82-.086.301-.371.978-.652 1.384 0 0-1.074 1.25-1.192 1.812-.117.563-.078.567-.101.965-.024.399.121.923.121.923s-.802.104-1.234.034c-.391-.062-.875-.841-1-1.078-.172-.328-.539-.265-.682-.023-.225.383-.709 1.07-1.051 1.113-.668.084-2.054.03-3.139.02 0 0 .185-1.011-.227-1.358-.305-.26-.83-.784-1.144-1.06l-.832-.921c-.284-.36-.629-1.093-1.243-1.985-.348-.504-1.027-1.085-1.284-1.579-.223-.425-.331-.954-.19-1.325.225-.594.675-.897 1.362-.832.519.05.848.206 1.238.537.225.19.573.534.75.748.163.195.203.276.377.509.23.307.302.459.214.121", fill: "#fff" }),
    /* @__PURE__ */ s.jsxs("g", { stroke: "#000", strokeLinecap: "round", strokeWidth: ".75", children: [
      /* @__PURE__ */ s.jsx("path", { d: "m4.5557 8.5742c-.098-.375-.196-.847-.406-1.552-.167-.557-.342-.859-.47-1.233-.155-.455-.303-.721-.496-1.181-.139-.329-.364-1.048-.457-1.44-.119-.509.033-.924.244-1.206.253-.339.962-.49 1.357-.351.371.13.744.512.916.788.288.46.357.632.717 1.542.393.992.564 1.918.611 2.231l.085.452c-.001-.04-.043-1.122-.044-1.162-.035-1.029-.06-1.823-.038-2.939.002-.126.064-.587.084-.715.078-.5.305-.8.673-.979.412-.201.926-.215 1.401-.017.423.173.626.55.687 1.022.014.109.094.987.093 1.107-.013 1.025.006 1.641.015 2.174.004.231.003 1.625.017 1.469.061-.656.094-3.189.344-3.942.144-.433.405-.746.794-.929.431-.203 1.113-.07 1.404.243.285.305.446.692.482 1.153.032.405-.019.897-.02 1.245 0 .867-.021 1.324-.037 2.121-.001.038-.015.298.023.182.094-.28.188-.542.266-.745.049-.125.241-.614.359-.859.114-.234.211-.369.415-.688.2-.313.415-.448.668-.561.54-.235 1.109.112 1.301.591.086.215.009.713-.028 1.105-.061.647-.254 1.306-.352 1.648-.128.447-.274 1.235-.34 1.601-.072.394-.234 1.382-.359 1.82-.086.301-.371.978-.652 1.384 0 0-1.074 1.25-1.192 1.812-.117.563-.078.567-.101.965-.024.399.121.923.121.923s-.802.104-1.234.034c-.391-.062-.875-.841-1-1.078-.172-.328-.539-.265-.682-.023-.225.383-.709 1.07-1.051 1.113-.668.084-2.054.03-3.139.02 0 0 .185-1.011-.227-1.358-.305-.26-.83-.784-1.144-1.06l-.832-.921c-.284-.36-.629-1.093-1.243-1.985-.348-.504-1.027-1.085-1.284-1.579-.223-.425-.331-.954-.19-1.325.225-.594.675-.897 1.362-.832.519.05.848.206 1.238.537.225.19.573.534.75.748.163.195.203.276.377.509.23.307.302.459.214.121", strokeLinejoin: "round" }),
      /* @__PURE__ */ s.jsx("path", { d: "m11.566 12.734v-3.459" }),
      /* @__PURE__ */ s.jsx("path", { d: "m9.551 12.746-.016-3.473" }),
      /* @__PURE__ */ s.jsx("path", { d: "m7.555 9.305.021 3.426" })
    ] })
  ] }) });
}
function e0() {
  return /* @__PURE__ */ s.jsx("svg", { width: "30", height: "30", viewBox: "0 0 32 32", fill: "none", children: /* @__PURE__ */ s.jsxs("g", { transform: "translate(8 9)", children: [
    /* @__PURE__ */ s.jsx("path", { d: "m3.44281398 1.68449726c-.74326136.27630142-1.05584685.8131257-1.07636853 1.38003696-.01344897.37336893.06665513.72649286.23114214 1.18694303-.02596219-.07267623.09676488.29282004.12116236.37362273.05052942.16918921-.4865367-.05865774-.81377307.00741883-.36363321.07113868-.84783757.38332307-1.10006887.79754775-.29643467.48542737-.3109609 1.04368567-.08235979 2.04824266.12491868.54736183.36572145 1.00836814.71076689 1.44594879.15329951.1944118.5713628.64726015.60307236.6875974l.84854343.94062339c.15080214.1358526.25794954.2361946.57590427.5380259.3147558.2987762.4647038.4380078.60308951.555976.05846214.0492474.10784267.1797116.12740685.3736249.01609788.1595565.01049553.3375341-.0090192.5090254-.00674888.0593077-.01325791.1020883-.01698742.1224696-.04189161.228932.13269563.4403386.36541902.4424835.21585671.0019894.38528595.0046546.82216479.0123538.09483476.0016698.09483476.0016698.18993053.0033129 1.16876447.0200186 1.75308289.0147904 2.17807912-.0385723.45429894-.0572869.92650915-.6110188 1.32698393-1.2957591.34289141.6108338.81859723 1.2057867 1.2995685 1.2820532.1510118.0244148.3353555.0322555.548787.0275887.1606725-.0035131.3307029-.0140241.5021961-.0293376.1276907-.0114022.2293359-.0228648.29003-.0307451.2258836-.0293282.373669-.251611.3133108-.4712481-.0130351-.0474332-.0339838-.1345011-.0551094-.2441635-.0245945-.1276687-.0423383-.2523857-.0503381-.365988-.0050217-.0713101-.0059948-.1359317-.0027687-.1918983.0059157-.0980798.0077938-.1530073.0108033-.281125.0010795-.0448938.0010795-.0448938.0024606-.0845172.0054208-.1364475.0233824-.2649146.0815132-.544638.0250088-.1201275.1473169-.352189.3398902-.639435.0571394-.0852302.1195783-.1742239.1864664-.26609712.1272143-.17473362.2641361-.35131772.4011075-.52030772.082051-.10123129.145482-.17695689.1808122-.21807676.2967593-.42378347.612817-1.11823437.7291396-1.52536348.1117407-.39153936.202351-1.12501196.254373-1.81690429.029923-.39968605.0410555-.72381216.0410555-1.23011613.0000742-.09758414.0000742-.09758414.0002975-.17670236.0003569-.11115478.0003569-.11115478.000115-.20711835-.0008934-.15683883-.0055282-.31323355-.0207085-.69507578-.0313109-.81293139-.4771727-1.33911388-1.1344906-1.44058831-.559108-.08631314-1.0586051.08188477-1.2779293.31625977-.0755526.08073733.0036753-.2781823-.2159489-.62316278-.1644465-.25841586-.593184-.58905957-.9209287-.65355552-.335487-.06535532-.73539548-.05811715-1.1017193.00667481-.32093157.05742909-.68608434.33741751-.87176225.64688068-.12411885.20686477.03884667-.00592296-.09368743-.23401341-.18231052-.31422641-.60754287-.59486422-1.01411454-.67799709-.34643562-.07139428-.74182572-.04452925-1.09945614.0633873-.43336319.1291117-1.01795827.61460976-.94899189 1.15552627-.34375-.54091651-1.25026717-.691379-1.97906097-.42111797z", fill: "#000" }),
    /* @__PURE__ */ s.jsx("path", { d: "m7.31951013 1.62138197c.20710357.04234751.44724204.20083012.51632974.31990811.08404358.1446387.15562749.36413806.21048667.6366124.02933373.14569467.12179446 1.2125285.29383112 1.32370243.41279229.04533731.41279229.04533731.52658055-.12364345.03545705-.07383858.03545705-.07383858.04226523-.1029106.01416796-.06009544.02463332-.12677987.0351322-.21754028l.00854738-.07915386.00047673-.00942804.00327525-.03167185c.01085148-.11424313.04184125-.4312127.05388392-.53034902.03788792-.31189663.08766449-.52757784.13944093-.6138719.0713024-.11883734.31942298-.28274442.43149612-.30279961.2804398-.04960082.58940103-.05519288.82623993-.00905543.1084394.02134018.3709471.22378689.432331.32024744.1291079.20279957.2524316.84889766.3225486 1.4970065-.0102194.04624251-.0102194.04624251.1640069.28984194.5843296-.06677889.5843296-.06677889.5703629-.17490247.0159511-.03856429.0284824-.08294031.045969-.15118961.0423876-.16089067.0697594-.25204451.111066-.35549917.0288558-.07227096.0592914-.13391873.0904889-.18278042.1209187-.19031132.4335712-.319392.7077174-.27707028.2943447.04543991.4816904.26653537.4994912.72869815.0148821.37434892.0193146.5239164.0201469.6700184l-.0004247.37954865c0 .48831141-.0104951.79388164-.0389535 1.17400348-.0480918.63962116-.1348512 1.34192123-.227649 1.66708484-.0946325.33121345-.3766371.95084197-.6003915 1.27298482-.0161892.01580846-.0841508.09694273-.1710333.20413492-.1445842.17838247-.2892181.36491271-.4247891.5511244-.0723398.09936149-.1402862.19620479-.2030964.2898938-.2440054.36396314-.400553.66098894-.4512157.90434304-.0659304.3172546-.0893838.4850003-.0966379.6675968-.0017072.0490782-.0017072.0490782-.002845.096677-.0028064.119476-.004437.1671639-.0097087.2545848-.0052654.091322-.0038193.187354.00332.2887353.0103318.1467182.1058713.3478531.1058713.3478531s-.2321503-.0119819-.3742084-.0088758c-.1718098.0037567-.3147843-.0023244-.4138162-.0183342-.1440353-.0228411-.53014068-.5057331-.7278511-.8821737-.30227042-.5764228-1.03604858-.5484427-1.33684295-.0394061-.26854779.4591613-.65918083.9172326-.7740684.9317199-.37404082.0469647-.94643778.0520862-2.07160079.0328144-.09480875-.0016381-.46003446-.0128683-.64600494-.0157445-.18597048-.0028763.05008807-.1790283.02786486-.399297-.03726222-.36933-.15125405-.6704984-.38877094-.8705429-.12241569-.1043631-.26774964-.2393104-.56509654-.5215613-.33323493-.3163366-.44236499-.4185353-.57290215-.533275l-.80130455-.89071892c-.03955779-.05174211-.45812831-.5051399-.5872217-.6688539-.28069963-.35597842-.47062947-.71959073-.56844755-1.14820437-.18921973-.83150113-.1793328-1.21146622-.00855589-1.49112273.13743587-.2257023.43815377-.4195862.60596039-.45241793.17165981-.03465512.55153059-.01648617.62179422.02229321.09902279.05401056.13357243.07300285.16379074.09097645.03572494.02124891.05965747.03799198.08182912.05708809.03426437.02951139.07235014.07170412.12420211.14044502.03611591.04821025.07806642.1053997.1423779.19304882.06054643.0816627.09183576.12069421.13369221.1590035.28038907.25662728.68391532.03238058.65052057-.32606956-.00567036-.06086415-.02203766-.12694598-.05458621-.23708502-.04356824-.15021272.00433013-.05284275-.26002629-.56642281-.08720664-.16942124-.13955864-.28835362-.17428227-.4046158l-.03412852-.10219113c-.03838756-.11059767-.09558223-.26854489-.12612861-.35199347l-.02009957-.05467087.002.008-.05974804-.17751191c-.09232236-.28807194-.13413567-.51358087-.12645475-.72681781.01040781-.28751553.16037753-.54506871.58790983-.70400047.40142488-.1488616 1.07786076.00117106 1.20581167.27856864.04319814.09369738.08927466.21199471.13900415.35457792l.03930997.11680217c.05539717.16759437.13470873.41493582.13860471.42816881.02724222.08344874.0471839.13860719.06943813.18441246.00217869.06301886.00217869.06301886.35429398.23177937.41699479-.29154152.41699479-.29154152.38019201-.37525838.00571063-.08773482.00758408-.17356287.00965287-.37317647.00242546-.23402898.00423842-.33154773.00994479-.45966208.01316411-.29554918.0437926-.51142116.09291227-.63864415.09160418-.23801371.25279279-.40993649.4432431-.46667832.24458613-.07380253.51465245-.09215236.73323569-.04710649zm1.21356228 4.27672201c-.20710459.00095412-.37422255.16961903-.37326843.37672361l.016 3.473c.00095412.20710459.16961903.37422251.37672361.37326841.20710459-.0009541.37422255-.16961901.37326843-.37672359l-.016-3.473c-.00095412-.20710459-.16961903-.37422255-.37672361-.37326843zm2.03332759.00229602c-.2071068 0-.375.16789322-.375.375v3.459c0 .20710678.1678932.375.375.375s.375-.16789322.375-.375v-3.459c0-.20710678-.1678932-.375-.375-.375zm-4.01399856.02930704c-.20710289.00126946-.37396385.17018863-.3726944.37729152l.021 3.426c.00126946.20710289.17018863.37396384.37729152.37269444.20710289-.0012695.37396385-.17018867.3726944-.37729156l-.021-3.426c-.00126946-.20710289-.17018863-.37396385-.37729152-.3726944z", fill: "#fff" })
  ] }) });
}
function t0() {
  return /* @__PURE__ */ s.jsxs("svg", { width: "16", height: "16", viewBox: "0 0 20 20", fill: "none", xmlns: "http://www.w3.org/2000/svg", children: [
    /* @__PURE__ */ s.jsx("circle", { cx: "10", cy: "10", r: "8", stroke: "rgba(0,0,0,0.15)", strokeWidth: "2" }),
    /* @__PURE__ */ s.jsx("path", { d: "M10 2A8 8 0 0 1 18 10", stroke: "black", strokeWidth: "2", strokeLinecap: "round" })
  ] });
}
const cc = "M0-8.4 2.55-3.65H-2.55ZM0 8.4 2.55 3.65H-2.55Z";
function Ti({ turn: u }) {
  return /* @__PURE__ */ s.jsx("svg", { width: "21", height: "21", viewBox: "-14 -14 28 28", overflow: "visible", children: /* @__PURE__ */ s.jsxs("g", { transform: `rotate(${u})`, strokeLinejoin: "round", children: [
    /* @__PURE__ */ s.jsx("path", { d: cc, style: { fill: "var(--ss-cursor-edge, #fff)", stroke: "var(--ss-cursor-edge, #fff)" }, strokeWidth: "3.2" }),
    /* @__PURE__ */ s.jsx("path", { d: cc, style: { fill: "var(--ss-cursor-line, #000)", stroke: "var(--ss-cursor-line, #000)" }, strokeWidth: "1.2" })
  ] }) });
}
const n0 = () => /* @__PURE__ */ s.jsx(Ti, { turn: 0 }), r0 = () => /* @__PURE__ */ s.jsx(Ti, { turn: 90 }), l0 = () => /* @__PURE__ */ s.jsx(Ti, { turn: -45 }), i0 = () => /* @__PURE__ */ s.jsx(Ti, { turn: 45 }), fc = {
  pointer: Gd,
  ibeam: qd,
  crosshair: Zd,
  hand: Jd,
  open: bd,
  grab: e0,
  wait: t0,
  "resize-ns": n0,
  "resize-ew": r0,
  "resize-nwse": l0,
  "resize-nesw": i0
}, o0 = {
  pointer: { x: 7.5, y: 5.25 },
  ibeam: { x: 5, y: 8 },
  crosshair: { x: 8.5, y: 8.5 },
  hand: { x: 9.75, y: 3.25 },
  open: { x: 11.7, y: 10.4 },
  grab: { x: 12, y: 12 },
  wait: { x: 8, y: 8 },
  "resize-ns": { x: 10.5, y: 10.5 },
  "resize-ew": { x: 10.5, y: 10.5 },
  "resize-nwse": { x: 10.5, y: 10.5 },
  "resize-nesw": { x: 10.5, y: 10.5 }
}, s0 = { x: 4, y: 3 };
function u0() {
  return /* @__PURE__ */ s.jsx("svg", { width: "22", height: "22", viewBox: "0 0 22 22", className: "ss-cursor__arrow", "aria-hidden": !0, children: /* @__PURE__ */ s.jsx("path", { d: "M4 3 18.5 9.6 11.8 11.8 9.6 18.5Z" }) });
}
function a0({ cursorRef: u, style: y = "real", kind: f }) {
  return /* @__PURE__ */ s.jsxs("div", { ref: u, className: "ss-cursor", "data-style": y, "data-kind": f, "aria-hidden": !0, children: [
    y === "touch" && /* @__PURE__ */ s.jsx("span", { className: "ss-cursor__streak" }),
    /* @__PURE__ */ s.jsxs("div", { className: "ss-cursor__press", children: [
      (y === "circle" || y === "touch") && /* @__PURE__ */ s.jsx("span", { className: "ss-cursor__dot" }),
      y !== "circle" && y !== "touch" && Object.keys(fc).map((x) => {
        const _ = y === "arrow";
        if (_ && x !== "pointer" && x !== "ibeam") return null;
        const S = _ && x === "pointer" ? u0 : fc[x], F = _ && x === "pointer" ? s0 : o0[x], V = _ && f !== "ibeam" ? "pointer" : f;
        return /* @__PURE__ */ s.jsx(
          "div",
          {
            className: "ss-cursor__glyph",
            "data-glyph": x,
            "data-active": x === V,
            style: { marginLeft: -F.x, marginTop: -F.y, transformOrigin: `${F.x}px ${F.y}px` },
            children: /* @__PURE__ */ s.jsx(S, {})
          },
          x
        );
      })
    ] })
  ] });
}
function c0(u, y) {
  const f = document.createElement("span");
  f.className = "ss-ripple", f.style.left = `${y.x}px`, f.style.top = `${y.y}px`, u.appendChild(f), f.addEventListener("animationend", () => f.remove());
}
const Cc = M.createContext({
  theme: "light",
  palette: "accent",
  fidelity: "standard",
  layout: "wide"
}), jc = () => M.useContext(Cc), Nc = M.createContext(!1);
function js() {
  const u = M.useContext(Nc), [y, f] = M.useState(!1);
  return M.useEffect(() => {
    const x = window.matchMedia("(prefers-reduced-motion: reduce)"), _ = () => f(x.matches);
    return _(), x.addEventListener("change", _), () => x.removeEventListener("change", _);
  }, []), u || y;
}
const rr = {
  now: () => performance.now(),
  raf: (u) => requestAnimationFrame(u),
  cancelRaf: (u) => cancelAnimationFrame(u),
  // Layout must finish even when a preview is paused. Keep these callbacks
  // separate: running arbitrary motion RAFs at a frozen timestamp can still
  // advance a spring that integrates once per callback.
  layoutRaf: (u) => {
    var y;
    return ((y = rr.recording) == null ? void 0 : y.requestLayoutFrame(u)) ?? requestAnimationFrame(u);
  },
  cancelLayoutRaf: (u) => {
    const y = rr.recording;
    y ? y.cancelLayoutFrame(u) : cancelAnimationFrame(u);
  },
  timeout: (u, y) => window.setTimeout(u, y),
  clearTimeout: (u) => window.clearTimeout(u),
  /** The recorder's control while one drives the page, else null. */
  get recording() {
    var u;
    return typeof window > "u" ? null : ((u = window.__stageshow) == null ? void 0 : u.clock) ?? null;
  }
}, f0 = {};
function d0({
  width: u,
  height: y,
  initial: f = f0,
  script: x,
  poster: _,
  cursor: S,
  hover: F,
  play: V = "loop",
  compact: P,
  keys: ee = "bottom",
  palette: T = "accent",
  greys: Y,
  fidelity: X = "standard",
  specimen: J,
  unframed: A,
  speed: Z = 1,
  accent: U,
  tokens: ve,
  ground: ae,
  fill: ke = !1,
  theme: xe = "light",
  className: te,
  children: Ne
}) {
  const B = V === "hover" && typeof window < "u" && window.matchMedia("(hover: none)").matches ? "once" : V, [C, de] = M.useState("wide"), re = M.useRef(C);
  re.current = C;
  const he = () => {
    const I = S.at;
    return typeof I == "object" && "wide" in I ? I[re.current] : I;
  }, [Pe, we] = M.useState(!1), ce = C === "compact" && P ? P.width : u, Re = C === "compact" && P ? P.height : y, Ce = M.useRef(null), se = M.useRef(null), z = M.useRef(null), K = js(), O = !x || K, [a, p] = M.useState(() => O && _ ? _ : f), v = M.useRef(a);
  v.current = a;
  const [k, E] = M.useState(1), D = M.useRef(1);
  D.current = k;
  const q = typeof window > "u" ? {} : window.__stageshow ?? {}, le = Z / (q.slow ?? 1), b = q.theme ?? xe, [ne, pe] = M.useState((S == null ? void 0 : S.kind) ?? "pointer"), ge = (I) => {
    const me = se.current;
    !me || K || c0(me, I);
  }, Te = M.useRef(ne);
  Te.current = ne;
  const [Xe, Le] = M.useState({ id: 0, caps: [], show: !1, down: !1 }), [ln, Fe] = M.useState(null), tt = M.useRef(Xe);
  tt.current = Xe;
  const Ie = M.useRef({ x: 0, y: 0 }), Se = M.useRef(null), [pt, Et] = M.useState(0), At = M.useRef(!1), Dt = M.useRef(!1), on = M.useRef(null);
  M.useLayoutEffect(() => {
    const I = Ce.current;
    if (!I) return;
    const me = () => {
      var Jt, Sn;
      const Oe = I.clientWidth, rt = !!((Jt = I.parentElement) != null && Jt.closest("[data-ss-wide]")), Ct = P && !rt && Oe < P.below ? "compact" : "wide";
      de(Ct);
      const ct = ke || !!((Sn = I.parentElement) != null && Sn.closest("[data-ss-fill]"));
      we(ct);
      const _e = Ct === "compact" ? P.width : u, Ze = Math.min(ct ? 2 : 1, Oe / _e);
      E(Ze), Et(Math.max(0, (Oe - _e * Ze) / 2));
    };
    me();
    const fe = new ResizeObserver(me);
    fe.observe(I);
    const We = new MutationObserver(me);
    for (let Oe = I.parentElement; Oe; Oe = Oe.parentElement)
      We.observe(Oe, { attributes: !0, attributeFilter: ["data-ss-wide", "data-ss-fill"] });
    return () => {
      fe.disconnect(), We.disconnect();
    };
  }, [u, P == null ? void 0 : P.below, P == null ? void 0 : P.width, ke]);
  const [ht, sn] = M.useState({}), Gt = M.useCallback(() => {
    const I = se.current;
    if (!I) return {};
    const me = {}, fe = I.querySelectorAll("[data-target]");
    if (!fe.length) return me;
    const We = Cs(I, D.current);
    return fe.forEach((Oe) => {
      me[Oe.dataset.target] = Ud(I, Oe, D.current, We);
    }), me;
  }, []), kn = M.useRef({ n: 0, frame: 0, owed: !1 }), nt = M.useCallback(() => {
    const I = kn.current;
    if (I.frame || (I.frame = rr.layoutRaf(() => {
      if (I.n = 0, I.frame = 0, !I.owed) return;
      I.owed = !1;
      const fe = Gt();
      sn((We) => uc(We, fe) ? We : fe);
    })), I.n >= 4) {
      I.owed = !0;
      return;
    }
    I.n++;
    const me = Gt();
    sn((fe) => uc(fe, me) ? fe : me);
  }, [Gt]);
  M.useLayoutEffect(nt), M.useLayoutEffect(() => () => {
    rr.cancelLayoutRaf(kn.current.frame), kn.current = { n: 0, frame: 0, owed: !1 };
  }, []), M.useEffect(() => {
    const I = se.current;
    if (I)
      return I.addEventListener("transitionend", nt), I.addEventListener("animationend", nt), () => {
        I.removeEventListener("transitionend", nt), I.removeEventListener("animationend", nt);
      };
  }, [nt]);
  const qt = M.useCallback((I) => ht[I] ?? kc, [ht]), [Oi, Fr] = M.useState(!0);
  M.useLayoutEffect(() => {
    Fr(!0);
    let I = !0, me = 0;
    const fe = () => {
      me = rr.layoutRaf(() => {
        me = rr.layoutRaf(() => I && Fr(!1));
      });
    };
    return !document.fonts || document.fonts.status === "loaded" ? fe() : document.fonts.ready.then(() => I && fe()), () => {
      I = !1, rr.cancelLayoutRaf(me);
    };
  }, [C]);
  const un = M.useRef(0), Hn = M.useRef(0), an = M.useRef(!1), cn = M.useRef(null), Zt = M.useCallback((I) => {
    Hn.current && !an.current && Math.hypot(I.x - Ie.current.x, I.y - Ie.current.y) > 0.5 && (an.current = !0, cn.current ?? (cn.current = performance.now() - Hn.current)), Ie.current = I, un.current = performance.now();
    const me = z.current;
    me && (me.style.transform = `translate(${I.x}px, ${I.y}px)`, me.removeAttribute("data-idle"));
  }, []), $t = M.useCallback((I) => {
    typeof I == "object" && I !== null && "wide" in I && (I = re.current === "compact" ? I.compact : I.wide);
    const me = Sc(I);
    if (me === null) return I;
    const fe = se.current, We = fe == null ? void 0 : fe.querySelector(`[data-target="${me}"]`);
    if (!fe || !We)
      return Or(`no element with data-target="${me}"`), Ie.current;
    const Oe = Sl(fe, We, D.current), rt = typeof I == "string" ? { x: 0.5, y: 0.5 } : { x: I.x ?? 0.5, y: I.y ?? 0.5 };
    return { x: Oe.x + Oe.width * rt.x, y: Oe.y + Oe.height * rt.y };
  }, []);
  M.useLayoutEffect(() => {
    if (!O || !F) return;
    const I = se.current;
    F.forEach((me) => {
      var fe;
      return (fe = I == null ? void 0 : I.querySelector(`[data-target="${me}"]`)) == null ? void 0 : fe.setAttribute("data-hover", "");
    });
  }), M.useLayoutEffect(() => {
    S && !Hn.current && Zt($t(he()));
  }, [k, C]);
  const Vn = M.useRef(0), mt = M.useRef(0), Wt = M.useCallback(() => {
    var I;
    ++Vn.current, cancelAnimationFrame(mt.current), mt.current = 0, (I = se.current) == null || I.removeAttribute("data-settling");
  }, []), ir = M.useCallback((I = !1) => {
    var We, Oe, rt, Ct, ct;
    Wt();
    const me = Vn.current;
    if (Dt.current = !1, p(f), pe((S == null ? void 0 : S.kind) ?? "pointer"), Le((_e) => ({ ..._e, show: !1, down: !1 })), Fe(null), (We = se.current) == null || We.querySelectorAll("[data-hover],[data-pressed]").forEach((_e) => {
      _e.removeAttribute("data-hover"), _e.removeAttribute("data-pressed");
    }), (Oe = se.current) == null || Oe.removeAttribute("data-mark"), (rt = se.current) == null || rt.querySelectorAll("[data-scrolled]").forEach((_e) => {
      _e.scrollTop = 0, _e.removeAttribute("data-scrolled"), _c(_e);
    }), (Ct = se.current) == null || Ct.querySelectorAll("[data-scrolling]").forEach((_e) => _e.removeAttribute("data-scrolling")), (ct = z.current) == null || ct.removeAttribute("data-pressed"), on.current = null, !S) return;
    if (!I) {
      mt.current = requestAnimationFrame(() => {
        var _e;
        mt.current = 0, Zt($t(he())), (_e = Se.current) == null || _e.call(Se, Ie.current);
      });
      return;
    }
    const fe = se.current;
    fe == null || fe.setAttribute("data-settling", ""), mt.current = requestAnimationFrame(() => {
      const _e = { ...Ie.current }, Ze = $t(he()), Jt = Pr(320 + Math.hypot(Ze.x - _e.x, Ze.y - _e.y) * 0.7, 380, 700), Sn = performance.now(), _n = () => {
        if (Vn.current !== me) return;
        const or = Math.min(1, (performance.now() - Sn) / Jt), vt = Pi(or);
        Zt({ x: _e.x + (Ze.x - _e.x) * vt, y: _e.y + (Ze.y - _e.y) * vt }), or < 1 ? mt.current = requestAnimationFrame(_n) : (mt.current = 0, fe == null || fe.removeAttribute("data-settling"));
      };
      _n();
    });
  }, [C]), Ir = M.useMemo(
    () => (I) => Yd(I, {
      rootRef: se,
      cursorRef: z,
      pos: Ie,
      hovered: on,
      kindRef: Te,
      keysRef: tt,
      dragging: Dt,
      autoUsed: At,
      autoRef: Se,
      scaleRef: D,
      speed: le,
      layout: C,
      cursor: S,
      resolve: $t,
      place: Zt,
      remeasure: nt,
      ripple: ge,
      setState: p,
      setKind: pe,
      setKeys: Le,
      setLastKeys: Fe
    }),
    [$t, Zt, le, C]
    // eslint-disable-line react-hooks/exhaustive-deps
  );
  M.useEffect(() => {
    const I = se.current;
    if (O || !x)
      return ir(), I.removeAttribute("data-offscreen"), p(_ ?? f), Wt;
    ir();
    const me = Ce.current;
    let fe = null, We = !1, Oe = !1, rt = !1;
    const Ct = (S == null ? void 0 : S.idle) ?? 4e3, ct = 1200;
    let _e = 0, Ze = 0;
    const Jt = () => {
      window.clearInterval(_e), !(!S || Ct === !1) && (un.current = performance.now(), _e = window.setInterval(() => {
        var fn;
        const ze = z.current;
        if (!ze) return;
        const yt = performance.now();
        if (!an.current) {
          cn.current === null && yt - un.current > ct && ze.setAttribute("data-idle", "");
          return;
        }
        ze.hasAttribute("data-pressed") || (fn = se.current) != null && fn.querySelector("[data-hover]") ? un.current = yt : yt - un.current > Ct && ze.setAttribute("data-idle", "");
      }, 150));
    }, Sn = () => {
      Hn.current = performance.now(), an.current = !1, window.clearTimeout(Ze);
      const ze = z.current, yt = cn.current;
      Ct === !1 || !ze || yt === null || yt <= ct || (ze.setAttribute("data-idle", ""), Ze = window.setTimeout(() => ze.removeAttribute("data-idle"), yt - 400));
    }, _n = () => {
      var ze;
      window.clearInterval(_e), window.clearTimeout(Ze), Hn.current = 0, (ze = z.current) == null || ze.removeAttribute("data-idle");
    }, or = () => {
      window.clearInterval(_e), window.clearTimeout(Ze);
      const ze = z.current, yt = () => (ze == null ? void 0 : ze.hasAttribute("data-pressed")) || I.querySelector("[data-hover]");
      if (!S || Ct === !1 || !ze || ze.hasAttribute("data-idle") || yt()) return;
      const fn = (an.current ? Ct : ct) - (performance.now() - un.current);
      Ze = window.setTimeout(() => {
        yt() || ze.setAttribute("data-idle", "");
      }, Math.max(0, fn));
    }, vt = () => {
      if (fe || rt || !We || document.hidden || B === "hover" && !Oe) return;
      Wt(), S && Zt($t(he())), fe = new AbortController();
      const ze = fe.signal;
      Jt();
      const yt = Ir(ze);
      (async () => {
        do {
          Sn();
          try {
            await x(yt);
          } catch (fn) {
            if (fn instanceof Tr) return;
            console.error("[stageshow] script error", fn), fe = null, _n();
            return;
          }
          B === "loop" && Ec() && Xd(v.current, f, Ie.current, S ? $t(he()) : null);
        } while (B === "loop" && !ze.aborted);
        B === "once" && !ze.aborted && (rt = !0, or());
      })();
    }, sr = (ze = !1) => {
      _n(), fe && (fe.abort(), fe = null, rt || ir(ze));
    }, ur = () => I.toggleAttribute("data-offscreen", !We || document.hidden);
    ur();
    const Cl = new IntersectionObserver(([ze]) => {
      We = ze.isIntersecting, ur(), We ? vt() : sr();
    });
    Cl.observe(me);
    const Ar = () => {
      ur(), document.hidden ? sr() : vt();
    };
    document.addEventListener("visibilitychange", Ar);
    const Dr = () => {
      Oe = !0, vt();
    }, $r = () => {
      Oe = !1, sr(!0);
    };
    return B === "hover" && (me.addEventListener("pointerenter", Dr), me.addEventListener("pointerleave", $r)), () => {
      Cl.disconnect(), document.removeEventListener("visibilitychange", Ar), me.removeEventListener("pointerenter", Dr), me.removeEventListener("pointerleave", $r), _n(), fe == null || fe.abort(), fe = null, Se.current = null, Wt();
    };
  }, [O, x, Ir, B, C]), M.useLayoutEffect(() => {
    var I;
    S && !O && !Dt.current && ((I = Se.current) == null || I.call(Se, Ie.current));
  }, [a]);
  const _l = M.useMemo(() => ({ theme: b, palette: T, fidelity: X, layout: C }), [b, T, X, C]), El = S && (!x || !O || S.still);
  return /* @__PURE__ */ s.jsx("div", { ref: Ce, className: `ss-fit${te ? ` ${te}` : ""}`, style: { maxWidth: Pe ? void 0 : u, height: Re * k }, children: /* @__PURE__ */ s.jsxs(
    "div",
    {
      ref: se,
      className: "ss-stage",
      "data-specimen": J || void 0,
      "data-unframed": A || void 0,
      "data-still": O || void 0,
      "data-placing": Oi || void 0,
      "data-theme": b,
      "data-palette": T,
      "data-greys": Y === "cool" ? "cool" : void 0,
      "data-fidelity": X,
      "data-layout": C,
      style: {
        width: ce,
        height: Re,
        marginLeft: pt || void 0,
        transform: `scale(${k})`,
        ...ve,
        ...U ? { "--ss-accent": U, "--ss-accent-2": U, "--ss-accent-soft": `color-mix(in srgb, ${U} 14%, transparent)` } : null
      },
      children: [
        ae && /* @__PURE__ */ s.jsx(
          "div",
          {
            className: "ss-ground",
            "aria-hidden": !0,
            style: Array.isArray(ae) ? { "--ss-orb-1": ae[0], "--ss-orb-2": ae[1], ...ae[2] ? { "--ss-orb-3": ae[2] } : null } : void 0
          }
        ),
        /* @__PURE__ */ s.jsx(Nc.Provider, { value: O, children: /* @__PURE__ */ s.jsx(Cc.Provider, { value: _l, children: Ne(a, qt, C) }) }),
        x && /* @__PURE__ */ s.jsx($d, { rows: [ln, Xe], at: typeof ee == "string" ? ee : ee[C] }),
        El && /* @__PURE__ */ s.jsx(a0, { cursorRef: z, style: S.style, kind: ne })
      ]
    }
  ) });
}
function xl() {
  return /* @__PURE__ */ s.jsxs("span", { className: "ss-window__lights", children: [
    /* @__PURE__ */ s.jsx("span", { className: "ss-window__dot" }),
    /* @__PURE__ */ s.jsx("span", { className: "ss-window__dot" }),
    /* @__PURE__ */ s.jsx("span", { className: "ss-window__dot" })
  ] });
}
function p0() {
  return /* @__PURE__ */ s.jsxs("svg", { className: "ss-window__lock", width: "7", height: "8", viewBox: "0 0 7 8", "aria-hidden": !0, children: [
    /* @__PURE__ */ s.jsx("path", { d: "M1.5 3.3V2.4a2 2 0 0 1 4 0v.9", fill: "none", stroke: "currentColor", strokeWidth: "1.1" }),
    /* @__PURE__ */ s.jsx("rect", { x: "0", y: "3.3", width: "7", height: "4.7", rx: "1.2", fill: "currentColor" })
  ] });
}
function dc({ back: u }) {
  return /* @__PURE__ */ s.jsx("svg", { className: "ss-window__chev", width: "10", height: "10", viewBox: "0 0 10 10", "aria-hidden": !0, children: /* @__PURE__ */ s.jsx("path", { d: u ? "M6.5 1.5 3 5l3.5 3.5" : "M3.5 1.5 7 5 3.5 8.5", fill: "none", stroke: "currentColor", strokeWidth: "1.4", strokeLinecap: "round", strokeLinejoin: "round" }) });
}
function h0({ url: u, urlShape: y, tabs: f, nav: x, title: _, sidebar: S, sidebarWidth: F = 180, sidebarStyle: V, toolbar: P, lead: ee, body: T, className: Y, receded: X, chrome: J, lights: A, lightsSize: Z, barSize: U, children: ve, ...ae }) {
  const ke = `ss-window ss-recede${Y ? ` ${Y}` : ""}`, xe = Z === "large" ? "large" : void 0, te = U === "tall" ? "tall" : void 0;
  if (J === "terminal")
    return /* @__PURE__ */ s.jsxs("div", { ...ae, className: ke, "data-chrome": "terminal", "data-lights": A === "grey" ? "grey" : void 0, "data-lights-size": xe, "data-receded": X || void 0, children: [
      /* @__PURE__ */ s.jsxs("div", { className: "ss-window__bar", children: [
        /* @__PURE__ */ s.jsx(xl, {}),
        _ !== void 0 && /* @__PURE__ */ s.jsx("span", { className: "ss-term__title", children: _ })
      ] }),
      /* @__PURE__ */ s.jsx("div", { ...T, className: `ss-window__body ss-term${T != null && T.className ? ` ${T.className}` : ""}`, children: ve })
    ] });
  if (J === "glass" || J === "card" || J === "hairline")
    return /* @__PURE__ */ s.jsxs("div", { ...ae, className: ke, "data-chrome": J, "data-lights": A === "color" || A === "white" ? A : J === "glass" ? "grey" : void 0, "data-receded": X || void 0, children: [
      /* @__PURE__ */ s.jsxs("div", { className: "ss-window__bar", children: [
        /* @__PURE__ */ s.jsx(xl, {}),
        u !== void 0 && /* @__PURE__ */ s.jsxs("span", { className: "ss-window__url", children: [
          J === "glass" && /* @__PURE__ */ s.jsx(p0, {}),
          /* @__PURE__ */ s.jsx("span", { className: "ss-window__url-text", children: u })
        ] }),
        /* @__PURE__ */ s.jsx("span", { className: "ss-window__end", children: P })
      ] }),
      /* @__PURE__ */ s.jsx("div", { ...T, className: `ss-window__body${T != null && T.className ? ` ${T.className}` : ""}`, children: ve })
    ] });
  const Ne = u !== void 0 && /* @__PURE__ */ s.jsxs(s.Fragment, { children: [
    x && /* @__PURE__ */ s.jsxs("span", { className: "ss-window__nav", children: [
      /* @__PURE__ */ s.jsx(dc, { back: !0 }),
      /* @__PURE__ */ s.jsx(dc, {})
    ] }),
    /* @__PURE__ */ s.jsx("span", { className: "ss-window__url", children: u })
  ] });
  return S !== void 0 ? /* @__PURE__ */ s.jsxs("div", { ...ae, className: ke, "data-kind": "sidebar", "data-side": V === "floating" ? "floating" : void 0, "data-lights": A === "grey" ? "grey" : void 0, "data-lights-size": xe, "data-bar": te, "data-receded": X || void 0, "data-url-shape": y, children: [
    /* @__PURE__ */ s.jsxs("aside", { className: "ss-window__side", style: { width: F }, children: [
      /* @__PURE__ */ s.jsx("div", { className: "ss-window__side-top", children: /* @__PURE__ */ s.jsx(xl, {}) }),
      S
    ] }),
    /* @__PURE__ */ s.jsxs("div", { className: "ss-window__main", children: [
      /* @__PURE__ */ s.jsxs("div", { className: "ss-window__bar", children: [
        _ !== void 0 && /* @__PURE__ */ s.jsx("span", { className: "ss-window__heading", children: _ }),
        ee,
        Ne,
        /* @__PURE__ */ s.jsx("span", { className: "ss-window__spacer" }),
        P
      ] }),
      /* @__PURE__ */ s.jsx("div", { ...T, className: `ss-window__body${T != null && T.className ? ` ${T.className}` : ""}`, children: ve })
    ] })
  ] }) : f != null && f.length ? /* @__PURE__ */ s.jsxs("div", { ...ae, className: ke, "data-kind": "tabs", "data-lights": A === "grey" ? "grey" : void 0, "data-lights-size": xe, "data-receded": X || void 0, "data-url-shape": y, children: [
    /* @__PURE__ */ s.jsxs("div", { className: "ss-window__tabs", children: [
      /* @__PURE__ */ s.jsx(xl, {}),
      f.map((B, C) => /* @__PURE__ */ s.jsxs("span", { className: "ss-window__tab", "data-active": C === 0 || void 0, children: [
        /* @__PURE__ */ s.jsx("span", { className: "ss-window__favicon" }),
        /* @__PURE__ */ s.jsx("span", { className: "ss-window__tab-label", children: B })
      ] }, C))
    ] }),
    /* @__PURE__ */ s.jsxs("div", { className: "ss-window__bar", children: [
      Ne,
      P
    ] }),
    /* @__PURE__ */ s.jsx("div", { ...T, className: `ss-window__body${T != null && T.className ? ` ${T.className}` : ""}`, children: ve })
  ] }) : /* @__PURE__ */ s.jsxs("div", { ...ae, className: ke, "data-receded": X || void 0, "data-url-shape": y, "data-lights": A === "grey" ? "grey" : void 0, "data-lights-size": xe, "data-bar": te, children: [
    /* @__PURE__ */ s.jsxs("div", { className: "ss-window__bar", children: [
      /* @__PURE__ */ s.jsx(xl, {}),
      Ne,
      _ !== void 0 && /* @__PURE__ */ s.jsx("span", { className: "ss-window__title", "data-toolbar": P ? !0 : void 0, children: _ }),
      ee,
      u === void 0 && _ === void 0 && /* @__PURE__ */ s.jsx("span", { className: "ss-window__spacer" }),
      P
    ] }),
    /* @__PURE__ */ s.jsx("div", { ...T, className: `ss-window__body${T != null && T.className ? ` ${T.className}` : ""}`, children: ve })
  ] });
}
const m0 = ["var(--ss-ink-1)", "var(--ss-ink-2)", "var(--ss-ink-3)", "var(--ss-ink-4)", "var(--ss-ink-5)"];
function zt({ w: u, h: y = 6, tone: f = 3, r: x = 2, shrink: _, className: S, style: F, ...V }) {
  const P = _ ?? (typeof u == "number" && u > y * 3);
  return /* @__PURE__ */ s.jsx("span", { ...V, className: `ss-bar${S ? ` ${S}` : ""}`, "data-shrink": P || void 0, style: { width: u, height: y, borderRadius: x, background: m0[f - 1], ...F } });
}
function xn({ children: u, w: y, h: f = 6, tone: x = 3, wrap: _, filler: S, className: F, style: V, ...P }) {
  const { fidelity: ee } = jc();
  if (ee === "minimal" || S && ee !== "realistic") {
    const T = typeof (V == null ? void 0 : V.fontSize) == "number" ? V.fontSize : 11;
    return /* @__PURE__ */ s.jsx(zt, { ...P, w: y ?? Math.round(u.length * T * 0.52), h: f, tone: x, className: F });
  }
  return /* @__PURE__ */ s.jsx("span", { ...P, className: `ss-text${F ? ` ${F}` : ""}`, "data-wrap": _ || void 0, style: V, children: u });
}
const v0 = { w: 402, h: 874, r: 64 }, pc = { a: 71, n: 2.31 }, y0 = { w: 393, h: 829, r: 42 }, g0 = { w: 412, h: 915, r: 38 }, w0 = {
  pro: { band: 3, glass: 10 },
  // Apple's photograph of the iPhone 18 Pro (its product bezel): the body runs
  // 16pt past the screen on every side; the image itself is drawn over it
  photo: { band: 0, glass: 16 },
  bezel: { band: 0, glass: 12 },
  soft: { band: 0, glass: 12.5 },
  bare: { band: 0, glass: 0 },
  silver: { band: 4, glass: 9 },
  clay: { band: 0, glass: 16 },
  outline: { band: 0, glass: 8 },
  android: { band: 2, glass: 9 }
}, x0 = {
  pro: [[13, "band"], [10, "var(--ss-phone-rim)"], [9.25, "var(--ss-phone-glass)"]],
  silver: [[13, "band"], [9, "var(--ss-phone-glass)"]],
  bezel: [[12, "var(--ss-phone-glass)"]],
  clay: [[16, "clay"], [1, "var(--ss-phone-seam)"]]
};
function k0(u, y, f, x) {
  const S = 2 / x, F = [];
  return [
    [u - f, f, 1, -1],
    [u - f, y - f, 1, 1],
    [f, y - f, -1, 1],
    [f, f, -1, -1]
  ].forEach(([P, ee, T, Y], X) => {
    for (let J = 0; J <= 32; J++) {
      const A = J / 32 * (Math.PI / 2), Z = X % 2 === 0 ? Math.sin(A) : Math.cos(A), U = X % 2 === 0 ? Math.cos(A) : Math.sin(A);
      F.push(`${(P + T * f * Math.pow(Z, S)).toFixed(2)} ${(ee + Y * f * Math.pow(U, S)).toFixed(2)}`);
    }
  }), `M${F.join("L")}Z`;
}
function hc({ width: u, frame: y = "pro", time: f = "9:41", island: x, status: _, dark: S, wallpaper: F, className: V, style: P, children: ee, ...T }) {
  const Y = M.useRef(null), [X, J] = M.useState(!0);
  M.useEffect(() => {
    var se;
    if (y !== "photo" || !Y.current) return;
    const ce = (se = getComputedStyle(Y.current).backgroundImage.match(/url\(["']?([^"')]+)["']?\)/)) == null ? void 0 : se[1];
    if (!ce) return void J(!1);
    let Re = !0;
    const Ce = new Image();
    return Ce.onerror = () => Re && J(!1), Ce.src = ce, () => {
      Re = !1;
    };
  }, [y, S]);
  const A = y === "photo" && !X ? "pro" : y, { band: Z, glass: U } = w0[A], { fidelity: ve } = jc(), ae = A === "android" ? g0 : A === "soft" ? y0 : v0, ke = Z + U, xe = u / (ae.w + ke * 2), te = (we) => we * xe, Ne = M.useId().replace(/:/g, ""), C = A !== "android" && A !== "soft" ? k0(te(ae.w), te(ae.h), te(pc.a), pc.n) : null, de = x0[A], re = A === "pro" || A === "photo" || A === "bezel" || A === "silver" || A === "android", he = x ?? (re && A !== "photo"), Pe = _ ?? re;
  return /* @__PURE__ */ s.jsxs(
    "div",
    {
      ...T,
      className: `ss-phone${V ? ` ${V}` : ""}`,
      "data-frame": A,
      "data-dark": S || void 0,
      style: {
        width: u,
        height: te(ae.h + ke * 2),
        padding: te(Z),
        borderRadius: te(ae.r + ke),
        "--ps": `${xe}px`,
        ...P
      },
      children: [
        (de || A === "outline") && C && /* @__PURE__ */ s.jsxs("svg", { className: "ss-phone__bands", width: "100%", height: "100%", "aria-hidden": !0, children: [
          /* @__PURE__ */ s.jsxs("defs", { children: [
            /* @__PURE__ */ s.jsx("linearGradient", { id: `${Ne}-band`, x1: "0.2", y1: "0", x2: "0.8", y2: "1", children: [0, 0.22, 0.48, 0.74, 1].map((we, ce) => /* @__PURE__ */ s.jsx("stop", { offset: we, style: { stopColor: `var(--ss-phone-band-${ce + 1})` } }, we)) }),
            /* @__PURE__ */ s.jsxs("linearGradient", { id: `${Ne}-clay`, x1: "0", y1: "0", x2: "0", y2: "1", children: [
              /* @__PURE__ */ s.jsx("stop", { offset: "0", style: { stopColor: "var(--ss-phone-clay-top)" } }),
              /* @__PURE__ */ s.jsx("stop", { offset: "1", style: { stopColor: "var(--ss-phone-clay-bottom)" } })
            ] }),
            A === "outline" && // Line art: a ring between 7 and 8pt out, cut from a mask so it is one hairline
            /* @__PURE__ */ s.jsxs("mask", { id: `${Ne}-ring`, maskUnits: "userSpaceOnUse", x: "-50%", y: "-50%", width: "200%", height: "200%", children: [
              /* @__PURE__ */ s.jsx("path", { d: C, fill: "none", stroke: "#fff", strokeWidth: te(16) }),
              /* @__PURE__ */ s.jsx("path", { d: C, fill: "none", stroke: "#000", strokeWidth: te(16) - 2 })
            ] })
          ] }),
          /* @__PURE__ */ s.jsx("g", { transform: `translate(${te(ke)} ${te(ke)})`, strokeLinejoin: "round", children: A === "outline" ? /* @__PURE__ */ s.jsxs(s.Fragment, { children: [
            /* @__PURE__ */ s.jsx("rect", { x: -te(9), y: -te(9), width: te(ae.w + 18), height: te(ae.h + 18), mask: `url(#${Ne}-ring)`, style: { fill: "var(--ss-phone-line)" } }),
            /* @__PURE__ */ s.jsx("path", { d: C, fill: "none", strokeWidth: "2", style: { stroke: "var(--ss-line, rgba(0, 0, 0, 0.06))" } })
          ] }) : de.map(([we, ce]) => /* @__PURE__ */ s.jsx(
            "path",
            {
              d: C,
              fill: "none",
              strokeWidth: te(we * 2),
              stroke: ce === "band" || ce === "clay" ? `url(#${Ne}-${ce})` : void 0,
              style: ce === "band" || ce === "clay" ? void 0 : { stroke: ce }
            },
            we
          )) })
        ] }),
        /* @__PURE__ */ s.jsx("div", { className: "ss-phone__glass", style: { padding: te(U), borderRadius: te(ae.r + U) }, children: /* @__PURE__ */ s.jsx(
          "div",
          {
            className: "ss-phone__window",
            style: {
              width: te(ae.w),
              height: te(ae.h),
              borderRadius: C ? void 0 : te(ae.r),
              clipPath: C ? `path('${C}')` : void 0
            },
            children: /* @__PURE__ */ s.jsxs(
              "div",
              {
                className: "ss-phone__screen",
                style: { width: ae.w, height: ae.h, transform: `scale(${xe})`, "--ss-screen-r": `${ae.r}px`, ...F ? { background: F } : null },
                children: [
                  Pe && /* @__PURE__ */ s.jsxs("div", { className: "ss-phone__status", children: [
                    /* @__PURE__ */ s.jsx("span", { className: "ss-phone__time", children: ve === "minimal" ? /* @__PURE__ */ s.jsx("span", { className: "ss-phone__time-bar" }) : f }),
                    /* @__PURE__ */ s.jsxs("span", { className: "ss-phone__glyphs", children: [
                      /* @__PURE__ */ s.jsx(S0, {}),
                      /* @__PURE__ */ s.jsx(_0, {}),
                      /* @__PURE__ */ s.jsx(E0, {})
                    ] })
                  ] }),
                  he && /* @__PURE__ */ s.jsx("span", { className: "ss-phone__island" }),
                  /* @__PURE__ */ s.jsx("div", { className: "ss-phone__content", "data-status": Pe || void 0, children: ee }),
                  re && /* @__PURE__ */ s.jsx("span", { className: "ss-phone__home" })
                ]
              }
            )
          }
        ) }),
        A === "photo" && // The bezel image is 450 × 920pt with the screen at (24, 23): laid over
        // the body so its cut-out frames the screen exactly
        /* @__PURE__ */ s.jsx("span", { ref: Y, className: "ss-phone__photo", style: { left: te(-8), top: te(-7), width: te(450), height: te(920) } })
      ]
    }
  );
}
function S0() {
  return /* @__PURE__ */ s.jsx("svg", { viewBox: "0 0 20.33 13.67", width: "20.33", height: "13.67", className: "ss-phone__glyph ss-phone__signal", children: [6.33, 8.67, 11, 13.67].map((u, y) => /* @__PURE__ */ s.jsx("rect", { x: y * 5.667, y: 13.67 - u, width: 3.333, height: u, rx: 1.667, fill: "currentColor" }, y)) });
}
function _0() {
  return /* @__PURE__ */ s.jsx("svg", { viewBox: "0 0 19.33 14.33", width: "19.33", height: "14.33", className: "ss-phone__glyph ss-phone__wifi", children: /* @__PURE__ */ s.jsx("path", { fillRule: "evenodd", fill: "currentColor", d: "M0.415933 5.54283C0.902185 6.04412 1.66017 5.95818 2.27513 5.41393C4.30595 3.58064 6.83731 2.63535 9.66901 2.63535C12.5007 2.63535 15.0464 3.60928 17.0629 5.41393C17.6636 5.97251 18.4215 6.0298 18.9221 5.54283C19.4226 5.02722 19.4942 4.2538 18.9793 3.70954C16.8341 1.51819 13.3302 0 9.66901 0C6.00783 0 2.48965 1.53251 0.358727 3.72387C-0.156127 4.2538 -0.0989213 5.02722 0.415933 5.55715L0.415933 5.54283ZM3.94841 9.13779C4.50617 9.68205 5.22124 9.62476 5.85051 9.10915C6.88022 8.29276 8.25316 7.73418 9.66901 7.7485C11.0706 7.7485 12.4435 8.29276 13.4875 9.12347C14.1168 9.63908 14.8605 9.66773 15.4039 9.12347C15.9331 8.57921 16.0189 7.7485 15.4611 7.23289C14.0739 5.98683 11.9859 5.11315 9.68332 5.11315C7.38077 5.11315 5.27845 5.98683 3.9055 7.23289C3.41925 7.69121 3.31914 8.47896 3.96271 9.13779L3.94841 9.13779ZM8.72511 13.8929C9.34008 14.4801 9.98365 14.4801 10.5986 13.8929L11.757 12.7757C12.372 12.1742 12.5007 11.4151 11.7999 10.8995C11.2136 10.4841 10.4699 10.212 9.66901 10.212C8.86813 10.212 8.11015 10.4841 7.53809 10.9138C6.83731 11.4151 6.98033 12.1885 7.59529 12.7757L8.73942 13.8929L8.72511 13.8929Z" }) });
}
function E0() {
  return /* @__PURE__ */ s.jsxs("svg", { viewBox: "0 0 29.33 13.67", width: "29.33", height: "13.67", className: "ss-phone__glyph ss-phone__battery", children: [
    /* @__PURE__ */ s.jsx("path", { fill: "currentColor", d: "M0 6.4C0 4.15979 0 3.03969 0.435974 2.18404C0.819467 1.43139 1.43139 0.819467 2.18404 0.435974C3.03969 0 4.15979 0 6.4 0L19.933 0C22.1732 0 23.2933 0 24.149 0.435974C24.9016 0.819467 25.5135 1.43139 25.897 2.18404C26.333 3.03969 26.333 4.15979 26.333 6.4L26.333 7.26666C26.333 9.50687 26.333 10.627 25.897 11.4826C25.5135 12.2353 24.9016 12.8472 24.149 13.2307C23.2933 13.6667 22.1732 13.6667 19.933 13.6667L6.4 13.6667C4.15979 13.6667 3.03969 13.6667 2.18404 13.2307C1.43139 12.8472 0.819467 12.2353 0.435974 11.4826C0 10.627 0 9.50687 0 7.26666L0 6.4Z" }),
    /* @__PURE__ */ s.jsx("path", { fillRule: "evenodd", fill: "currentColor", transform: "translate(27.33 4.33)", d: "M0 0L0 5C0.601505 4.8625 2 3.75 2 2.5C2 1.25 0.601505 0.1375 0 0Z" })
  ] });
}
function lr({ delay: u = 0, children: y, ...f }) {
  const x = js(), [_, S] = M.useState(y);
  return M.useEffect(() => {
    if (!u || x) return S(y);
    const F = setTimeout(() => S(y), u);
    return () => clearTimeout(F);
  }, [y, u, x]), /* @__PURE__ */ s.jsx(C0, { ...f, children: u && !x ? _ : y });
}
function C0({
  children: u,
  stagger: y = 45,
  variant: f = "roll",
  align: x,
  className: _,
  style: S
}) {
  const F = js(), [V, P] = M.useState({ text: u, head: 0, tail: 0, old: "", key: 0, numeric: !0 }), ee = M.useRef(null), T = M.useRef(null), Y = M.useRef(null), X = () => {
    if (!T.current || !ee.current) return 0;
    const B = parseFloat(getComputedStyle(ee.current).height), C = B > 0 ? ee.current.getBoundingClientRect().height / B : 1;
    return T.current.getBoundingClientRect().width / (C || 1);
  }, [J, A] = M.useState(x ?? "start");
  M.useLayoutEffect(() => {
    if (x) return A(x);
    const B = T.current;
    if (!(B != null && B.parentElement)) return;
    let C = B;
    for (; C.parentElement && C.parentElement.childElementCount === 1 && Math.abs(C.parentElement.getBoundingClientRect().width - C.getBoundingClientRect().width) < 1; ) C = C.parentElement;
    const de = C.parentElement;
    if (!de) return;
    const re = getComputedStyle(de), he = /flex/.test(re.display) && re.flexDirection.startsWith("row"), Pe = () => {
      const ce = C.previousElementSibling, Re = C.getBoundingClientRect(), Ce = de.getBoundingClientRect(), se = Math.abs(Ce.right - parseFloat(re.paddingRight) - parseFloat(re.borderRightWidth) - Re.right) < 1, z = ce ? Re.left - ce.getBoundingClientRect().right - (parseFloat(re.columnGap) || 0) : 0;
      return se && z > 1;
    }, we = /right|end/.test(getComputedStyle(B).textAlign) || he && C === de.lastElementChild && (/space-between|flex-end|^end/.test(re.justifyContent) || Pe());
    A(we ? "end" : "start");
  }, [x]), M.useEffect(() => {
    if (F) {
      P({ text: u, head: 0, tail: 0, old: "", key: 0, numeric: !0 });
      return;
    }
    if (V.text === u) return;
    const B = V.text, C = u;
    let de = 0;
    for (; de < B.length && de < C.length && B[de] === C[de]; ) de++;
    let re = 0;
    for (; re < B.length - de && re < C.length - de && B[B.length - 1 - re] === C[C.length - 1 - re]; ) re++;
    const he = /^[\d.,$€£%+\-−\s]*$/.test(B.slice(de, B.length - re) + C.slice(de, C.length - re));
    if (!he) {
      const ce = (Re) => Re === void 0 || /\s/.test(Re);
      for (; de > 0 && !ce(C[de - 1]) && !ce(C[de]); ) de--;
      for (; re > 0 && !ce(C[C.length - re - 1]) && !ce(C[C.length - re]); ) re--;
    }
    const Pe = V.key + 1;
    Y.current = X(), P({ text: C, head: de, tail: re, old: B.slice(de, B.length - re), key: Pe, numeric: he });
    const we = setTimeout(() => P((ce) => ce.key === Pe ? { ...ce, old: "" } : ce), 700);
    return () => clearTimeout(we);
  }, [u, F]), M.useLayoutEffect(() => {
    const B = ee.current, C = B == null ? void 0 : B.querySelector("[data-live]"), de = B == null ? void 0 : B.querySelector("[data-out]");
    if (!B || !C) return;
    const re = (se) => parseFloat(getComputedStyle(se).width) || 0, he = re(C);
    if (F || V.key === 0) {
      B.style.transition = "none", B.style.width = `${he}px`, Y.current = null;
      return;
    }
    const Pe = X() - re(B), we = Y.current;
    Y.current = null;
    const ce = we === null ? de ? re(de) : 0 : Math.max(0, we - Pe);
    if (B.style.transition = "none", B.style.width = `${ce}px`, B.offsetWidth, B.style.transition = "", f === "fade") {
      B.style.width = `${he}px`;
      return;
    }
    const Re = Math.max(he, ce, de ? re(de) : 0);
    if (B.style.width = `${Re}px`, Re === he) return;
    const Ce = setTimeout(() => B.style.width = `${he}px`, 360);
    return () => clearTimeout(Ce);
  }, [V.key, F, F ? u : void 0]);
  const { text: Z, head: U, tail: ve, old: ae, key: ke, numeric: xe } = F ? { text: u, head: 0, tail: 0, old: "", key: 0, numeric: !0 } : V, te = Z.slice(U, Z.length - ve), Ne = xe ? te.split("") : te.split(new RegExp("(?<=\\s)"));
  return /* @__PURE__ */ s.jsxs("span", { ref: T, className: `ss-roll${_ ? ` ${_}` : ""}`, "data-variant": f, "data-align": J, style: S, children: [
    Z.slice(0, U),
    /* @__PURE__ */ s.jsxs("span", { ref: ee, className: "ss-roll__mid", children: [
      ae && /* @__PURE__ */ s.jsx("span", { className: "ss-roll__item", "data-out": !0, children: ae }, `o${ke}`),
      /* @__PURE__ */ s.jsx("span", { className: "ss-roll__item", "data-live": !0, children: ke > 0 && f === "fade" ? /* @__PURE__ */ s.jsx("span", { className: "ss-roll__char", children: te }) : ke > 0 ? Ne.map((B, C) => /* @__PURE__ */ s.jsx("span", { className: "ss-roll__char", style: { animationDelay: `${C * y}ms` }, children: B }, C)) : te }, `n${ke}`)
    ] }),
    Z.slice(Z.length - ve)
  ] });
}
M.createContext({ current: !0 });
function mc({ open: u, reveal: y = "clip", from: f = "above", solid: x = !1, children: _, className: S, ...F }) {
  const [V, P] = M.useState(!1), [ee, T] = M.useState(!1), Y = M.useRef(null), X = M.useRef(!0), J = M.useRef(_), [A, Z] = M.useState(!0);
  return u && (J.current = _), M.useLayoutEffect(() => {
    var ae;
    const U = ((ae = Y.current) == null ? void 0 : ae.scrollHeight) ?? 0;
    if (U && T(U > 44), X.current) return void (X.current = !1);
    P(!0), u || Z(!1);
    const ve = setTimeout(() => {
      P(!1), Z(!0);
    }, 900);
    return () => clearTimeout(ve);
  }, [u]), /* @__PURE__ */ s.jsx(
    "div",
    {
      ...F,
      className: `ss-collapse${S ? ` ${S}` : ""}`,
      "data-open": u || void 0,
      "data-reveal": y,
      "data-solid": x || void 0,
      "data-from": y === "drop" ? f : void 0,
      "data-moving": V || void 0,
      "data-tall": ee || void 0,
      onTransitionEnd: (U) => {
        var ve;
        U.target === U.currentTarget && U.propertyName === "grid-template-rows" && (P(!1), Z(!0)), (ve = F.onTransitionEnd) == null || ve.call(F, U);
      },
      children: /* @__PURE__ */ s.jsx("div", { ref: Y, className: "ss-collapse__inner", "data-crop": y === "clip" || void 0, children: y === "drop" ? /* @__PURE__ */ s.jsx("div", { className: "ss-collapse__glide", children: u || A ? _ : J.current }) : u || A ? _ : J.current })
    }
  );
}
function j0({ on: u, pending: y, size: f = 16, className: x, ..._ }) {
  return /* @__PURE__ */ s.jsx("span", { ..._, className: `ss-check${x ? ` ${x}` : ""}`, "data-on": u || void 0, "data-pending": y && !u || void 0, style: { width: f, height: f, ..._.style }, children: /* @__PURE__ */ s.jsxs("svg", { viewBox: "0 0 16 16", width: f, height: f, "aria-hidden": !0, children: [
    /* @__PURE__ */ s.jsx("circle", { className: "ss-check__ring", cx: "8", cy: "8", r: "7.25" }),
    /* @__PURE__ */ s.jsx("circle", { className: "ss-check__arc", cx: "8", cy: "8", r: "7.25", pathLength: 1 }),
    /* @__PURE__ */ s.jsx("circle", { className: "ss-check__fill", cx: "8", cy: "8", r: "8" }),
    /* @__PURE__ */ s.jsx("path", { className: "ss-check__tick", d: "M4.5 8.2 7 10.6l4.6-5", pathLength: 1 })
  ] }) });
}
function _s({ lead: u, title: y, subtitle: f, meta: x, preview: _, unread: S, selected: F, pad: V = 12, className: P, style: ee, children: T, ...Y }) {
  return /* @__PURE__ */ s.jsxs(
    "div",
    {
      ...Y,
      className: `ss-row${P ? ` ${P}` : ""}`,
      "data-selected": F || void 0,
      "data-unread": S || void 0,
      "data-lead": u ? "" : void 0,
      style: { "--ss-row-pad": `${V}px`, ...ee },
      children: [
        S && /* @__PURE__ */ s.jsx("span", { className: "ss-row__dot", "aria-hidden": !0 }),
        u && /* @__PURE__ */ s.jsx("span", { className: "ss-row__lead", children: u }),
        /* @__PURE__ */ s.jsxs("span", { className: "ss-row__body", children: [
          /* @__PURE__ */ s.jsxs("span", { className: "ss-row__head", children: [
            /* @__PURE__ */ s.jsx("span", { className: "ss-row__title", children: y }),
            x && /* @__PURE__ */ s.jsx("span", { className: "ss-row__meta", children: x })
          ] }),
          f && /* @__PURE__ */ s.jsx("span", { className: "ss-row__subtitle", children: f })
        ] }),
        _ && (Array.isArray(_) && _.every((X) => typeof X == "number") ? /* @__PURE__ */ s.jsx("span", { className: "ss-row__preview", "aria-hidden": !0, children: _.map((X, J) => /* @__PURE__ */ s.jsx(zt, { w: X, h: 6, tone: 2 }, J)) }) : /* @__PURE__ */ s.jsx("span", { className: "ss-row__preview", "data-text": !0, children: _ })),
        T
      ]
    }
  );
}
function N0({ tone: u = "neutral", dot: y, icon: f, children: x, className: _, ...S }) {
  return /* @__PURE__ */ s.jsxs("span", { ...S, className: `ss-badge${_ ? ` ${_}` : ""}`, "data-tone": u, "data-lead": y || f ? "" : void 0, children: [
    y && /* @__PURE__ */ s.jsx("span", { className: "ss-badge__dot" }),
    f,
    /* @__PURE__ */ s.jsx("span", { className: "ss-badge__label", children: x })
  ] });
}
function R0({ variant: u = "secondary", size: y = "medium", icon: f, trailingIcon: x, children: _, className: S, ...F }) {
  const [V, P] = M.useState(f), [ee, T] = M.useState(!!f), Y = !!f;
  return M.useLayoutEffect(() => {
    if (!Y) return T(!1);
    if (P(f), ee) return;
    const X = requestAnimationFrame(() => T(!0));
    return () => cancelAnimationFrame(X);
  }, [Y]), /* @__PURE__ */ s.jsxs(
    "span",
    {
      role: "button",
      "data-cursor": "pointer",
      ...F,
      className: `ss-button${S ? ` ${S}` : ""}`,
      "data-variant": u,
      "data-size": y,
      "data-leading": ee ? "" : void 0,
      "data-trailing": x ? "" : void 0,
      children: [
        V != null && /* @__PURE__ */ s.jsx("span", { className: "ss-button__icon ss-button__lead", "data-open": ee || void 0, onTransitionEnd: (X) => {
          !Y && X.propertyName === "width" && P(null);
        }, children: f ?? V }),
        _ != null && _ !== !1 && /* @__PURE__ */ s.jsx("span", { className: "ss-button__label", children: typeof _ == "string" || typeof _ == "number" ? /* @__PURE__ */ s.jsx(lr, { variant: "fade", children: String(_) }) : _ }),
        x && /* @__PURE__ */ s.jsx("span", { className: "ss-button__icon", children: x })
      ]
    }
  );
}
const L0 = { done: !1, day: "today", synced: !1 }, z0 = { done: !0, day: "tomorrow", synced: !0 }, kl = { wide: { x: 600, y: 330 }, compact: { x: 290, y: 380 } };
async function M0(u) {
  await u.wait(900), u.mark("tick"), await u.move({ at: "check-review", x: 0.8, y: 0.85 }), await u.wait(200), await u.click(), await u.set({ done: !0 }), await u.wait(700), await u.set({ synced: !0 }), await u.wait(800), u.mark("tomorrow"), await u.move({ at: "next", x: 0.78, y: 0.78 }), await u.wait(200), await u.click(), await u.set({ day: "tomorrow" }), await u.move("rest"), await u.wait(2600), u.mark("back"), await u.move({ at: "today", x: 0.8, y: 0.6 }), await u.wait(200), await u.click(), await u.set({ day: "today" }), await u.wait(900), await u.move({ at: "check-review", x: 0.8, y: 0.85 }), await u.wait(200), await u.click(), await u.set({ done: !1 }), await u.wait(700), await u.set({ synced: !1 }), await u.wait(500), await u.move("rest"), await u.wait(900);
}
function ks({ days: u }) {
  return /* @__PURE__ */ s.jsx(N0, { tone: u >= 3 ? "warning" : "neutral", className: "dh-age", children: /* @__PURE__ */ s.jsx(lr, { children: `${u}d` }) });
}
function Mr({ title: u, meta: y, lead: f, done: x, target: _, pad: S = 8 }) {
  return /* @__PURE__ */ s.jsx(
    _s,
    {
      className: "dh-task",
      "data-done": x || void 0,
      lead: f ?? /* @__PURE__ */ s.jsx(j0, { on: !!x, size: 16, "data-target": _, "data-cursor": "pointer" }),
      title: u,
      subtitle: /* @__PURE__ */ s.jsx("span", { className: "dh-meta", children: y }),
      pad: S
    }
  );
}
function Ss({ s: u, phone: y, passive: f }) {
  const x = u.day === "tomorrow", _ = x ? 4 : 6, S = x ? 0 : u.done ? 2 : 1;
  return /* @__PURE__ */ s.jsxs("div", { className: "dh-page", children: [
    /* @__PURE__ */ s.jsxs("div", { className: "dh-head", children: [
      /* @__PURE__ */ s.jsxs("div", { className: "dh-dates", children: [
        /* @__PURE__ */ s.jsx("div", { className: "dh-kicker", children: /* @__PURE__ */ s.jsx(lr, { children: x ? "Tomorrow · Monday" : "Today · Sunday" }) }),
        /* @__PURE__ */ s.jsx("div", { className: "dh-date", children: /* @__PURE__ */ s.jsx(lr, { children: x ? "9 November" : "8 November" }) })
      ] }),
      /* @__PURE__ */ s.jsxs("div", { className: "dh-nav", children: [
        /* @__PURE__ */ s.jsx("span", { className: "dh-today", "data-show": x || void 0, children: /* @__PURE__ */ s.jsx(R0, { size: y ? "large" : "small", "data-target": f ? void 0 : "today", children: "Today" }) }),
        /* @__PURE__ */ s.jsx("span", { className: "dh-arrow", children: /* @__PURE__ */ s.jsx(Rd, { size: 18, strokeWidth: 2 }) }),
        /* @__PURE__ */ s.jsx("span", { className: "dh-arrow", "data-target": f ? void 0 : "next", "data-cursor": "pointer", children: /* @__PURE__ */ s.jsx(Ld, { size: 18, strokeWidth: 2 }) })
      ] })
    ] }),
    /* @__PURE__ */ s.jsxs("div", { className: "dh-progress", children: [
      /* @__PURE__ */ s.jsx("span", { className: "dh-track", children: /* @__PURE__ */ s.jsx("span", { className: "dh-fill", style: { width: `${S / _ * 100}%` } }) }),
      /* @__PURE__ */ s.jsx("span", { className: "dh-count", children: /* @__PURE__ */ s.jsx(lr, { align: "end", children: `${S} of ${_} done` }) })
    ] }),
    /* @__PURE__ */ s.jsxs("div", { className: "dh-list", "data-crop": !0, children: [
      /* @__PURE__ */ s.jsx(
        Mr,
        {
          title: /* @__PURE__ */ s.jsx(xn, { children: "Send Q4 hiring plan to leadership" }),
          meta: /* @__PURE__ */ s.jsxs(s.Fragment, { children: [
            /* @__PURE__ */ s.jsx(xn, { children: "9:10 AM" }),
            /* @__PURE__ */ s.jsx(Fd, { size: 11, className: "dh-star", fill: "currentColor", strokeWidth: 0 }),
            /* @__PURE__ */ s.jsx(xn, { children: "Meera" }),
            /* @__PURE__ */ s.jsx(ks, { days: x ? 6 : 5 })
          ] })
        }
      ),
      /* @__PURE__ */ s.jsx(mc, { open: !(x && u.done), children: /* @__PURE__ */ s.jsx(
        Mr,
        {
          title: /* @__PURE__ */ s.jsx(xn, { children: "Review Arjun's design doc" }),
          done: u.done,
          target: f ? void 0 : "check-review",
          meta: /* @__PURE__ */ s.jsxs(s.Fragment, { children: [
            /* @__PURE__ */ s.jsx(xn, { children: "2:30 PM" }),
            /* @__PURE__ */ s.jsx(ks, { days: x ? 3 : 2 })
          ] })
        }
      ) }),
      /* @__PURE__ */ s.jsx(mc, { open: !x, children: /* @__PURE__ */ s.jsx(
        Mr,
        {
          title: /* @__PURE__ */ s.jsx(xn, { children: "Weekly status report" }),
          done: !0,
          meta: /* @__PURE__ */ s.jsx(zt, { w: 58, h: 6, tone: 2 })
        }
      ) }),
      /* @__PURE__ */ s.jsx(
        Mr,
        {
          title: /* @__PURE__ */ s.jsx(xn, { children: "Book the team offsite" }),
          meta: /* @__PURE__ */ s.jsxs(s.Fragment, { children: [
            /* @__PURE__ */ s.jsx(xn, { children: "11:00 AM" }),
            /* @__PURE__ */ s.jsx(ks, { days: x ? 2 : 1 })
          ] })
        }
      ),
      /* @__PURE__ */ s.jsx(Mr, { title: /* @__PURE__ */ s.jsx(zt, { w: 150, h: 7, tone: 3 }), meta: /* @__PURE__ */ s.jsx(zt, { w: 48, h: 6, tone: 2 }) }),
      /* @__PURE__ */ s.jsx(Mr, { title: /* @__PURE__ */ s.jsx(zt, { w: 118, h: 7, tone: 3 }), meta: /* @__PURE__ */ s.jsx(zt, { w: 56, h: 6, tone: 2 }) })
    ] })
  ] });
}
function vc({ reviews: u, children: y }) {
  return /* @__PURE__ */ s.jsxs("div", { className: "dh-app", children: [
    /* @__PURE__ */ s.jsxs("div", { className: "dh-appbar", children: [
      /* @__PURE__ */ s.jsx("span", { className: "dh-circle", children: /* @__PURE__ */ s.jsx(Od, { size: 20, strokeWidth: 1.75 }) }),
      /* @__PURE__ */ s.jsxs("span", { className: "dh-review", children: [
        /* @__PURE__ */ s.jsx(xc, { size: 18, strokeWidth: 1.75 }),
        /* @__PURE__ */ s.jsx(lr, { children: u })
      ] })
    ] }),
    y
  ] });
}
function P0() {
  const u = [
    { icon: /* @__PURE__ */ s.jsx(Nd, { size: 16, strokeWidth: 1.75 }), label: /* @__PURE__ */ s.jsx(xn, { children: "Today" }), selected: !0 },
    { icon: /* @__PURE__ */ s.jsx(Pd, { size: 16, strokeWidth: 1.75 }), label: /* @__PURE__ */ s.jsx(zt, { w: 46, h: 7, tone: 3 }) },
    { icon: /* @__PURE__ */ s.jsx(Md, { size: 16, strokeWidth: 1.75 }), label: /* @__PURE__ */ s.jsx(zt, { w: 38, h: 7, tone: 3 }) },
    { icon: /* @__PURE__ */ s.jsx(Id, { size: 16, strokeWidth: 1.75 }), label: /* @__PURE__ */ s.jsx(zt, { w: 44, h: 7, tone: 3 }) },
    { icon: /* @__PURE__ */ s.jsx(Td, { size: 16, strokeWidth: 1.75 }), label: /* @__PURE__ */ s.jsx(zt, { w: 40, h: 7, tone: 3 }) }
  ], y = [52, 64, 44];
  return /* @__PURE__ */ s.jsxs("div", { className: "dh-side", children: [
    u.map((f, x) => /* @__PURE__ */ s.jsx(_s, { className: "dh-side-row", lead: /* @__PURE__ */ s.jsx("span", { className: "dh-side-icon", children: f.icon }), title: f.label, selected: f.selected, pad: 8 }, x)),
    /* @__PURE__ */ s.jsx("div", { className: "dh-side-head", children: /* @__PURE__ */ s.jsx(zt, { w: 34, h: 6, tone: 2 }) }),
    y.map((f, x) => /* @__PURE__ */ s.jsx(_s, { className: "dh-side-row", lead: /* @__PURE__ */ s.jsx("span", { className: "dh-side-icon dh-side-icon--faint", children: /* @__PURE__ */ s.jsx(zd, { size: 16, strokeWidth: 1.75 }) }), title: /* @__PURE__ */ s.jsx(zt, { w: f, h: 7, tone: 3 }), pad: 8 }, `p${x}`))
  ] });
}
function T0() {
  const u = M.useRef(null), [y, f] = M.useState(!1);
  return M.useLayoutEffect(() => {
    const x = u.current;
    if (!x) return;
    const _ = new ResizeObserver(([S]) => f(S.contentRect.width < 560));
    return _.observe(x), () => _.disconnect();
  }, []), /* @__PURE__ */ s.jsx("div", { ref: u, children: /* @__PURE__ */ s.jsx(
    d0,
    {
      width: 720,
      height: 400,
      compact: { below: 560, width: 358, height: 420 },
      initial: L0,
      poster: z0,
      script: M0,
      accent: "#3B4A8C",
      cursor: { at: kl, style: y ? "touch" : "real" },
      className: "dh",
      children: (x, _, S) => {
        const F = x.day === "tomorrow" || x.done ? "2" : "3";
        return S === "compact" ? /* @__PURE__ */ s.jsxs(s.Fragment, { children: [
          /* @__PURE__ */ s.jsx(hc, { width: 326, className: "dh-phone", children: /* @__PURE__ */ s.jsx(vc, { reviews: F, children: /* @__PURE__ */ s.jsx(Ss, { s: x, phone: !0 }) }) }),
          /* @__PURE__ */ s.jsx("span", { "data-target": "rest", style: { position: "absolute", left: kl.compact.x, top: kl.compact.y } })
        ] }) : /* @__PURE__ */ s.jsxs(s.Fragment, { children: [
          /* @__PURE__ */ s.jsx(
            h0,
            {
              className: "dh-window",
              title: "Dayfold",
              sidebar: /* @__PURE__ */ s.jsx(P0, {}),
              sidebarWidth: 168,
              toolbar: /* @__PURE__ */ s.jsxs("span", { className: "dh-review", children: [
                /* @__PURE__ */ s.jsx(xc, { size: 16, strokeWidth: 1.75 }),
                /* @__PURE__ */ s.jsx(lr, { children: F })
              ] }),
              children: /* @__PURE__ */ s.jsx(Ss, { s: x })
            }
          ),
          /* @__PURE__ */ s.jsx(hc, { width: 236, className: "dh-pair-phone", children: /* @__PURE__ */ s.jsx(vc, { reviews: x.synced ? "2" : "3", children: /* @__PURE__ */ s.jsx(Ss, { s: { done: x.synced, day: "today" }, phone: !0, passive: !0 }) }) }),
          /* @__PURE__ */ s.jsx("span", { "data-target": "rest", style: { position: "absolute", left: kl.wide.x, top: kl.wide.y } })
        ] });
      }
    }
  ) });
}
const yc = document.getElementById("dayfold-hero");
yc && _d.createRoot(yc).render(/* @__PURE__ */ s.jsx(T0, {}));
