// Generated by CoffeeScript 1.10.0
(function() {
  var GridPanel, GridView, Matrix, basicTable, callback, div, emptyTable, isArray, isString, parseHTML,
    slice = [].slice;

  window.onload = function() {
    var k, len, ref, results, x;
    ref = document.querySelectorAll(".table");
    results = [];
    for (k = 0, len = ref.length; k < len; k++) {
      x = ref[k];
      results.push(new GridView(x, basicTable));
    }
    return results;
  };

  isString = function(x) {
    return x.constructor === String;
  };

  isArray = function(x) {
    return x.constructor === Array;
  };

  Array.prototype.last = function() {
    return this[this.length - 1];
  };

  callback = function(t, f) {
    return setTimeout(f, t);
  };

  parseHTML = function(x) {
    var div;
    if (isString(x)) {
      div = document.createElement('div');
      div.innerHTML = x;
      return div;
    } else {
      return x;
    }
  };

  div = function() {
    var d, k, len, x, xs;
    xs = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    d = document.createElement('div');
    for (k = 0, len = xs.length; k < len; k++) {
      x = xs[k];
      d.appendChild(parseHTML(x));
    }
    return d;
  };

  Matrix = (function() {
    Matrix.prototype.data = [];

    function Matrix(data) {
      this.data = data;
    }

    Matrix.prototype.height = function() {
      return this.data.length;
    };

    Matrix.prototype.width = function() {
      var ref;
      return ((ref = this.data[0]) != null ? ref.length : void 0) || 0;
    };

    Matrix.prototype.length = function() {
      return this.width() * this.height();
    };

    Matrix.prototype.get = function(i, j) {
      return this.data[i][j];
    };

    Matrix.prototype.row = function(i) {
      return this.data[i];
    };

    Matrix.prototype.col = function(j) {
      var i, k, ref, results;
      results = [];
      for (i = k = 0, ref = this.height(); 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        results.push(this.data[i][j]);
      }
      return results;
    };

    Matrix.prototype.firstRow = function() {
      return this.row(0);
    };

    Matrix.prototype.firstCol = function() {
      return this.col(0);
    };

    Matrix.prototype.lastRow = function() {
      return this.row(this.height() - 1);
    };

    Matrix.prototype.lastCol = function() {
      return this.col(this.width() - 1);
    };

    Matrix.prototype.topLeft = function() {
      return this.data[0][0];
    };

    Matrix.prototype.bottomRight = function() {
      return this.data.last().last();
    };

    Matrix.prototype.pushRow = function(row) {
      return this.data.push(row);
    };

    Matrix.prototype.pushCol = function(col) {
      var i, k, ref, results;
      results = [];
      for (i = k = 0, ref = this.height(); 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        results.push(this.row(i).push(col[i]));
      }
      return results;
    };

    Matrix.prototype.unshiftRow = function(row) {
      return this.data.unshift(row);
    };

    Matrix.prototype.unshiftCol = function(col) {
      var i, k, ref, results;
      results = [];
      for (i = k = 0, ref = this.height(); 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        results.push(this.row(i).unshift(col[i]));
      }
      return results;
    };

    Matrix.prototype.popRow = function() {
      return this.data.pop();
    };

    Matrix.prototype.popCol = function() {
      var k, len, ref, results, row;
      ref = this.data;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        row = ref[k];
        results.push(row.pop());
      }
      return results;
    };

    Matrix.prototype.shiftRow = function() {
      return this.data.shift();
    };

    Matrix.prototype.shiftCol = function() {
      var k, len, ref, results, row;
      ref = this.data;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        row = ref[k];
        results.push(row.shift());
      }
      return results;
    };

    Matrix.prototype.forEach = function(f) {
      var k, len, ref, results, row, val;
      ref = this.data;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        row = ref[k];
        results.push((function() {
          var l, len1, results1;
          results1 = [];
          for (l = 0, len1 = row.length; l < len1; l++) {
            val = row[l];
            results1.push(f(val));
          }
          return results1;
        })());
      }
      return results;
    };

    return Matrix;

  })();

  GridPanel = (function() {
    function GridPanel(table, data, range1) {
      this.table = table;
      this.data = data;
      this.range = range1;
      this.createView(this.range);
      this.refresh(this.range);
    }

    GridPanel.prototype.createView = function(arg) {
      var bottom, cell, cells, cellv, k, left, len, ref, results, right, row, rowv, top;
      top = arg.top, bottom = arg.bottom, left = arg.left, right = arg.right;
      this.cellViews = (function() {
        var k, ref, ref1, results;
        results = [];
        for (row = k = ref = left, ref1 = right; ref <= ref1 ? k <= ref1 : k >= ref1; row = ref <= ref1 ? ++k : --k) {
          results.push((function() {
            var l, ref2, ref3, results1;
            results1 = [];
            for (cell = l = ref2 = top, ref3 = bottom; ref2 <= ref3 ? l <= ref3 : l >= ref3; cell = ref2 <= ref3 ? ++l : --l) {
              results1.push(div());
            }
            return results1;
          })());
        }
        return results;
      })();
      this.view = div.apply(null, (function() {
        var k, len, ref, results;
        ref = this.cellViews;
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          cells = ref[k];
          results.push(div.apply(null, cells));
        }
        return results;
      }).call(this));
      this.view.classList.add('table-panel');
      ref = this.view.children;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        rowv = ref[k];
        rowv.classList.add('row');
        results.push((function() {
          var l, len1, ref1, results1;
          ref1 = rowv.children;
          results1 = [];
          for (l = 0, len1 = ref1.length; l < len1; l++) {
            cellv = ref1[l];
            results1.push(cellv.classList.add('cell'));
          }
          return results1;
        })());
      }
      return results;
    };

    GridPanel.prototype.refresh = function(range) {
      var col, k, l, ref, ref1, row;
      if (range != null) {
        this.range = range;
      }
      for (row = k = 0, ref = this.cellViews.length; 0 <= ref ? k < ref : k > ref; row = 0 <= ref ? ++k : --k) {
        for (col = l = 0, ref1 = this.cellViews[0].length; 0 <= ref1 ? l < ref1 : l > ref1; col = 0 <= ref1 ? ++l : --l) {
          this.cellViews[row][col].innerText = this.data.getCell(range.top + row, range.left + col);
        }
      }
      return this;
    };

    GridPanel.prototype.position = {
      x: 0,
      y: 0
    };

    GridPanel.prototype.setPosition = function(arg) {
      var x, y;
      x = arg.x, y = arg.y;
      this.position = {
        x: x,
        y: y
      };
      return this.refreshPosition();
    };

    GridPanel.prototype.refreshPosition = function() {
      return this.view.style.transform = "translate3d(" + (this.position.x - this.table.offset.x) + "px, " + (this.position.y - this.table.offset.y) + "px,0)";
    };

    return GridPanel;

  })();

  GridView = (function() {
    GridView.prototype.chunkSize = {
      x: 8,
      y: 8
    };

    function GridView(view, data, isBackground) {
      this.view = view;
      this.data = data;
      if (!isBackground) {
        this.background = document.createElement('div');
        this.background.classList.add('table-background');
        this.view.appendChild(this.background);
        new GridView(this.background, emptyTable, true);
      }
      this.container = document.createElement('div');
      this.container.classList.add('table-container');
      this.view.appendChild(this.container);
      this.size = {
        x: this.view.clientWidth,
        y: this.view.clientHeight
      };
      this.initPanels();
      if (!isBackground) {
        this.view.addEventListener("mousewheel", (function(_this) {
          return function(e) {
            return _this.scroll(e);
          };
        })(this));
        this.panelCycle();
      }
    }

    GridView.prototype.oldPanels = [];

    GridView.prototype.rmPanel = function(p) {
      p.view.style.visibility = 'hidden';
      return this.oldPanels.push(p);
    };

    GridView.prototype.getPanel = function(range) {
      var p;
      if (this.oldPanels.length === 0) {
        p = new GridPanel(this, this.data, range);
        this.container.appendChild(p.view);
        p.size = {
          x: p.view.clientWidth,
          y: p.view.clientHeight
        };
        return p;
      } else {
        p = this.oldPanels.shift();
        p.view.style.visibility = null;
        return p.refresh(range);
      }
    };

    GridView.prototype.initPanels = function() {
      var p, results;
      p = this.getPanel({
        top: 1,
        left: 1,
        bottom: this.chunkSize.y,
        right: this.chunkSize.x
      });
      this.panels = new Matrix([[p]]);
      while (this.extendRight()) {
        true;
      }
      results = [];
      while (this.extendLower()) {
        results.push(true);
      }
      return results;
    };

    GridView.prototype.reposition = function() {
      return this.panels.forEach(function(p) {
        return p.refreshPosition();
      });
    };

    GridView.prototype.panelCycle = function() {
      this.extendLower() || this.extendUpper();
      return callback(0.1, (function(_this) {
        return function() {
          _this.extendLeft() || _this.extendRight();
          return callback(0.1, function() {
            return _this.panelCycle();
          });
        };
      })(this));
    };

    GridView.prototype.extendUpper = function() {
      var last, p, panelBound, row, screenBound;
      panelBound = this.panels.topLeft().position.y;
      screenBound = this.offset.y;
      if (panelBound > screenBound) {
        this.trimLower();
        row = (function() {
          var k, len, ref, results;
          ref = this.panels.firstRow();
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            last = ref[k];
            p = this.getPanel({
              top: last.range.top - this.chunkSize.y,
              bottom: last.range.top - 1,
              left: last.range.left,
              right: last.range.right
            });
            p.setPosition({
              x: last.position.x,
              y: last.position.y - p.size.y
            });
            results.push(p);
          }
          return results;
        }).call(this);
        this.panels.unshiftRow(row);
      }
      return panelBound < screenBound;
    };

    GridView.prototype.extendLeft = function() {
      var col, last, p, panelBound, screenBound;
      panelBound = this.panels.topLeft().position.x;
      screenBound = this.offset.x;
      if (panelBound > screenBound) {
        this.trimRight();
        col = (function() {
          var k, len, ref, results;
          ref = this.panels.firstCol();
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            last = ref[k];
            p = this.getPanel({
              top: last.range.top,
              bottom: last.range.bottom,
              left: last.range.left - this.chunkSize.x,
              right: last.range.left - 1
            });
            p.setPosition({
              x: last.position.x - p.size.x,
              y: last.position.y
            });
            results.push(p);
          }
          return results;
        }).call(this);
        this.panels.unshiftCol(col);
      }
      return panelBound > screenBound;
    };

    GridView.prototype.extendLower = function() {
      var last, n, p, panelBound, panelHeight, row, screenBound;
      panelHeight = this.panels.bottomRight().size.y;
      panelBound = this.panels.bottomRight().position.y + panelHeight;
      screenBound = this.offset.y + this.size.y / this.zoom;
      n = Math.ceil((screenBound - panelBound) / panelHeight);
      if (n > 0) {
        this.trimUpper();
        row = (function() {
          var k, len, ref, results;
          ref = this.panels.lastRow();
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            last = ref[k];
            p = this.getPanel({
              top: last.range.bottom + 1,
              bottom: last.range.bottom + this.chunkSize.y,
              left: last.range.left,
              right: last.range.right
            });
            p.setPosition({
              x: last.position.x,
              y: last.position.y + last.size.y
            });
            results.push(p);
          }
          return results;
        }).call(this);
        this.panels.pushRow(row);
      }
      return n > 0;
    };

    GridView.prototype.extendRight = function() {
      var col, last, n, p, panelBound, panelWidth, screenBound;
      panelWidth = this.panels.bottomRight().size.x;
      panelBound = this.panels.bottomRight().position.x + panelWidth;
      screenBound = this.offset.x + this.size.x / this.zoom;
      n = Math.ceil((screenBound - panelBound) / panelWidth);
      if (n > 0) {
        this.trimLeft();
        col = (function() {
          var k, len, ref, results;
          ref = this.panels.lastCol();
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            last = ref[k];
            p = this.getPanel({
              top: last.range.top,
              bottom: last.range.bottom,
              left: last.range.right + 1,
              right: last.range.right + this.chunkSize.x
            });
            p.setPosition({
              x: last.position.x + last.size.x,
              y: last.position.y
            });
            results.push(p);
          }
          return results;
        }).call(this);
        this.panels.pushCol(col);
      }
      return n > 0;
    };

    GridView.prototype.trimUpper = function() {
      var k, len, p, ps;
      if (this.offset.y > this.panels.topLeft().position.y + this.panels.topLeft().size.y) {
        ps = this.panels.shiftRow();
        for (k = 0, len = ps.length; k < len; k++) {
          p = ps[k];
          this.rmPanel(p);
        }
      }
    };

    GridView.prototype.trimLeft = function() {
      var k, len, p, ps;
      if (this.offset.x > this.panels.topLeft().position.x + this.panels.topLeft().size.x) {
        ps = this.panels.shiftCol();
        for (k = 0, len = ps.length; k < len; k++) {
          p = ps[k];
          this.rmPanel(p);
        }
      }
    };

    GridView.prototype.trimLower = function() {
      var k, len, p, ps;
      if (this.offset.y + this.size.y / this.zoom < this.panels.bottomRight().position.y) {
        ps = this.panels.popRow();
        for (k = 0, len = ps.length; k < len; k++) {
          p = ps[k];
          this.rmPanel(p);
        }
      }
    };

    GridView.prototype.trimRight = function() {
      var k, len, p, ps;
      if (this.offset.x + this.size.x / this.zoom < this.panels.bottomRight().position.x) {
        ps = this.panels.popCol();
        for (k = 0, len = ps.length; k < len; k++) {
          p = ps[k];
          this.rmPanel(p);
        }
      }
    };

    GridView.prototype.refreshZoom = function() {
      var zoom;
      zoom = Math.exp(this.zoomFactor / 1000);
      this.container.style.transform = "scale(" + zoom + ")";
      return this.zoom = zoom;
    };

    GridView.prototype.zoomFactor = 0;

    GridView.prototype.zoom = 1;

    GridView.prototype.offset = {
      x: 0,
      y: 0
    };

    GridView.prototype.scroll = function(e) {
      e.preventDefault();
      if (e.ctrlKey) {
        this.zoomFactor -= e.deltaY;
        return requestAnimationFrame((function(_this) {
          return function() {
            return _this.refreshZoom();
          };
        })(this));
      } else {
        this.offset.x += e.deltaX / this.zoom;
        this.offset.y += e.deltaY / this.zoom;
        return requestAnimationFrame((function(_this) {
          return function() {
            return _this.reposition();
          };
        })(this));
      }
    };

    return GridView;

  })();

  basicTable = {
    getCell: function(row, col) {
      return row + ":" + col;
    }
  };

  emptyTable = {
    getCell: function() {
      return "";
    }
  };

}).call(this);
