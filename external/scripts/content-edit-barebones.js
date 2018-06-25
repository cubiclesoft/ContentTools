// Barebones CMS extensions to ContentEdit.
// Adds generic embedding of HTML.

(function() {
  // Swiped intro logic from content-edit.js.
  var _mergers,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  // Generic embed type.
  ContentEdit.Embed = (function(_super) {
    __extends(Embed, _super);

    function Embed(tagName, attributes, content) {
      Embed.__super__.constructor.call(this, tagName, attributes);
      this._content = content;
      this.navigate = true;
    }

    Embed.prototype.cssTypeName = function() {
      return 'embed';
    };

    Embed.prototype.type = function() {
      return 'Embed';
    };

    Embed.prototype.typeName = function() {
      return 'Embed';
    };

    Embed.prototype.getCaption = function() {
      return (this.attr('aria-label') ? this.attr('aria-label') : '');
    }

    Embed.prototype.setCaption = function(caption) {
      this.attr('aria-label', caption);
      if (this._domElement)  this._domElement.setAttribute('data-ce-title', this._title());
    }

    Embed.prototype.getContent = function() {
      return this._content;
    }

    Embed.prototype.setContent = function(content) {
      var tempdiv = document.createElement('div');
      tempdiv.innerHTML = content;
      this._content = tempdiv.innerHTML;
    }

    Embed.prototype._title = function() {
      var caption;
      caption = '';
      if (this.attr('aria-label')) {
        caption = this.attr('aria-label');
      }
      if (!caption) {
        caption = 'No caption/label found';
      }
      if (caption.length > 80) {
        caption = caption.substr(0, 80) + '...';
      }
      return caption;
    };

    Embed.prototype.createDraggingDOMElement = function() {
      var helper;
      if (!this.isMounted()) {
        return;
      }
      helper = Embed.__super__.createDraggingDOMElement.call(this);
      helper.innerHTML = this._title();
      return helper;
    };

    Embed.prototype._onMouseDown = function(ev) {
      Embed.__super__._onMouseDown.call(this, ev);
      clearTimeout(this._dragTimeout);
      return this._dragTimeout = setTimeout((function(_this) {
        return function() {
          return _this.drag(ev.pageX, ev.pageY);
        };
      })(this), 150);
    };

    Embed.prototype._onMouseUp = function(ev) {
      Embed.__super__._onMouseUp.call(this);
      if (this._dragTimeout) {
        return clearTimeout(this._dragTimeout);
      }
    };

    Embed.prototype.html = function(indent) {
      if (indent == null) {
        indent = '';
      }
      if (HTMLString.Tag.SELF_CLOSING[this._tagName]) {
        return "" + indent + "<" + this._tagName + (this._attributesToString()) + ">";
      }
      return ("" + indent + "<" + this._tagName + (this._attributesToString()) + ">") + ("" + this._content) + ("" + indent + "</" + this._tagName + ">");
    };

    Embed.prototype.mount = function() {
      var style;
      this._domElement = document.createElement('div');
      if (this.a && this.a['class']) {
        this._domElement.setAttribute('class', this.a['class']);
      } else if (this._attributes['class']) {
        this._domElement.setAttribute('class', this._attributes['class']);
      }
      style = this._attributes['style'] ? this._attributes['style'] : '';
      this._domElement.setAttribute('style', style);
      this._domElement.setAttribute('data-ce-title', this._title());
      return Embed.__super__.mount.call(this);
    };

    Embed.droppers = {
      'Image': ContentEdit.Element._dropBoth,
      'PreText': ContentEdit.Element._dropBoth,
      'Static': ContentEdit.Element._dropBoth,
      'Text': ContentEdit.Element._dropBoth,
      'Video': ContentEdit.Element._dropBoth,
      'Embed': ContentEdit.Element._dropBoth
    };

    Embed.placements = ['above', 'below', 'left', 'right', 'center'];

    Embed.fromDOMElement = function(domElement) {
      return new this(domElement.tagName, this.getDOMElementAttributes(domElement), domElement.innerHTML);
    };

    return Embed;

  })(ContentEdit.Element);

  ContentEdit.TagNames.get().register(ContentEdit.Embed, 'div-embed');

  // Patch other types to include drag-and-drop support for the Embed type.
  ContentEdit.List.droppers['Embed'] = ContentEdit.Element._dropBoth;
  ContentEdit.Table.droppers['Embed'] = ContentEdit.Element._dropBoth;

}).call(this);
