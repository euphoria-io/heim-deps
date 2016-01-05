'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = Item;

var _react = require('react');

var _react2 = _interopRequireDefault(_react);

var _PropTypes = require('../PropTypes');

var _PropTypes2 = _interopRequireDefault(_PropTypes);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function Item(props) {
  return _react2.default.createElement(
    'tr',
    null,
    _react2.default.createElement(
      'td',
      { align: props.align, valign: props.valign, bgcolor: props.bgcolor, style: props.style },
      props.children
    )
  );
}

Item.propTypes = {
  bgcolor: _react.PropTypes.string,
  align: _react.PropTypes.oneOf(['left', 'center', 'right']),
  valign: _react.PropTypes.oneOf(['top', 'middle', 'bottom']),
  style: _PropTypes2.default.style,
  children: _react.PropTypes.node
};