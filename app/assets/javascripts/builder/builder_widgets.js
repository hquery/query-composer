var bind = function(func, thisValue, extraArguments, addOriginalThis) {
    var args = extraArguments || [];
    var add_this = addOriginalThis;
    return function() {
        var _args = (add_this) ? [this] : [];

        for (var i = 0; i < arguments.length; i++) {
            _args.push(arguments[i]);
        }

        for (var j = 0; j < args.length; j++) {
            _args.push(args[j]);
        }

        return func.apply(thisValue, _args);
    }
}


function _getDataModel(elem) {
    var data = $(elm).data();
    return data.AndContainerUI || data.OrContainerUI || data.ItemUI;
}

function resetPosition(draggable) {
    draggable.css({
        top: '0',
        left: '0'
    });
}




$.widget("ui.popup",{
  
  options: {
    position:{
             my:"left top",
             at:"right top"    
    }
    ,
    arrow: "none"
  },
  
  _create: function(){
    this.content = this.options.content;
    this.widg = this.options.widg;
    this.div = this._createPopupShell();
    $(document.body).append(this.div);
    this.position = this.options.position;
    this.position["of"] = this.element;
   
  },
  
  _init: function(){
   this.div.position(this.position);
   
  },
  
  open: function(){
    this.div.show();
    this._positionArrow(this.div);
    this.div.position(this.position);
  },
  
  close: function(){
    this.div.hide();
  },
  
  cancel: function(){
    this.close();
  },
  
  save: function(){
    // save some stuff then close
    this.close();
    updateQuery();
  },
  
  _createPopupShell: function(){
    var div = $("<div >", {"class":"popup-frame", 'style':"position:absolute"});
    div.hide();
    this.contentDiv = $("<div class='popup-content'>");
    this.contentDiv.append(this.content);
    div.append(this.contentDiv);
    var buttonRow = $("<div></div>");
    var saveButton = $("<input class='save' type='button' value='Done'>");
    saveButton.click(bind(this.save, this));
   // var closeButton = $("<input class='close' type='button' value='cancel'>");
   // closeButton.click(bind(this.close,this));
    
    buttonRow.append(saveButton);
   // buttonRow.append(closeButton);
    div.append(buttonRow);
    
    div.append($("<div class='popup-arrow-border'></div><div class='popup-arrow'></div>"));
    return div;
  },

  _positionArrow: function(div){
     // drop in in the body so we can use it 
      if(this.options.arrow && this.options.arrow!= "none"){
        var arrowDiv = $("div.popup-arrow", div);
        var arrowBorder = $("div.popup-arrow-border", div);
        var arrowParts = this.options.arrow.split(" ");
        
        var direction = arrowParts[0] || "left";    
        var location = arrowParts[1] || ".50";
          // figure out arrow position 
        var directions = ["left","right","bottom","top"]; 
        if(!arrowDiv.hasClass("popup-arrow-"+direction)){
          $.each(directions,function(i,v){
            arrowDiv.removeClass("popup-arrow-"+v);
            arrowBorder.removeClass("popup-arrow-border-"+v);
          });
          arrowDiv.css({top:"", left:"", bottom:"", right:""});
          arrowBorder.css({top:"", left:"", bottom:"", right:""});
          arrowDiv.addClass("popup-arrow-"+direction);
          arrowBorder.addClass("popup-arrow-border-"+direction);
        }
        
        var width = div.width();
        var height = div.height();
        
        var arrowWidth = arrowDiv.width();
        var arrowHeight = arrowDiv.height();
        location = (location == "center") ? ".5" : location;
        var fLoc = parseFloat(location);
        if(!isNaN(fLoc)){
           
           if(direction == "left" || direction == "right"){
              var where = (height * fLoc) + (arrowHeight/2);
              arrowDiv.css({"top":where+"px"});
              arrowBorder.css({"top":where+"px"});
           }else{
             var where = (width * fLoc) + (arrowWidth/2);
             arrowDiv.css({"left":where+"px"});
             arrowBorder.css({"left":where+"px"});
           }
        }else{
        arrowDiv.addClass(direction+"-"+location);
        arrowBorder.addClass(direction+"-"+location);
        }
       }
  }
   
  
  
});



/* Base container UI widget */
$.widget("ui.ContainerUI", {
    options: {

        },
    _create: function() {
        this.container = this.options.container;
        this.parent = this.options.parent;
        this.element.append(this._createContainer());
        this.element.addClass("collection");
        var self = this;
        if (this.parent){
          this.element.draggable({
              helper: 'clone',
              cursor: 'crosshair',
              snap: false,
              revert: 'invalid',
              zIndex: 1000,
              refreshPositions: true,
         //     stack: ".ui-layout-center, .content, .section, .header, #test,.ui-droppable",
              handle: '.expando',
              start: function() {
                  $(this).data("widget", self);
                  //self.element.hide();
              },
              stop: function() {
                  //self.element.show();
              }
          });
        }
    },

    _createContainer: function() {

        var $dc = $("<div>", {
            'class': 'dependency_collection'
        });
        $dc.addClass((this.container instanceof queryStructure.And) ? "and": "or")
        var $expando = $("<div>", {
            'class': 'expando'
        }).hover(bind(function() {
            this.element.addClass('hover');
        },
        this)
        , bind(function() {
            this.element.removeClass('hover');
        },
        this));


        var $expandIndicator = $('<span>', {
            'class': 'expansion_indicator'
        });
        var $expander = $('<div>', {
            'class': 'dep_type',
            text: this.collectionType(),
            click: bind(function() {
                this.toggleExpand();
            },
            this)
        });
        
        $expander.prepend($expandIndicator);
        $expando.prepend($expander);
        $dc.append($expando);

        // Set the drop target
        $expando.droppable({
            drop: bind(this.drop, this),
            greedy: true,
            tolerance: 'intersect',
            over: bind(this.over, this),
            out: bind(this.out, this)
        });

        var $ul = $("<ul>");
        $dc.append($ul);
        var self = this;
        var f = function(i, item) {
            $ul.append(self._createItemUI(i, item));
        };

        $.each(this.container.children, f);
        this.div = $dc
        this.ul = $ul
        return this.div;
    },

    over: function(event, ui) {
        this.setActive(true);
    },

    out: function(event, ui) {
        this.setActive(false);
    },

    drop: function(element, ui) {
        this.setActive(false);

        var droppedWidget = ui.draggable.data('widget');
        var _new = false;
        if (!droppedWidget) {
            var data = ui.draggable.data("item");

            var el = $('<li>', {
                "class": "dependency resource_dep"
            });
            el.ItemUI({
                container: data
            });
            droppedWidget = el.data().ItemUI;
            _new = true;
        }

        // if parent is this container do nothing
        if (droppedWidget.parent == this) {
            resetPosition(droppedWidget.element);
        } else {
            var oldParent = droppedWidget.parent;
            droppedWidget.setParent(this);
            resetPosition(droppedWidget.element);
            resetPosition(ui.draggable);
            this.ul.append(droppedWidget.element);

            if (oldParent) {
                oldParent.destroyIfEmpty()
            }

             if(oldParent && oldParent != this.parent &&
                (oldParent.container instanceof queryStructure.And)){
                oldParent._collapsIfSingleChild();

              }
        }
        
        if(_new){
          droppedWidget.openPopup();
        }

       updateQuery();
    },


    _createItemUI: function(i, item) {

        var cell = $('<li>', {
            'class': "dependency"
        });
        if (item && item.name != null) {
            $(cell).ItemUI({
                parent: this,
                container: item
            });
            cell.addClass("resource_dep")
        } else {
            if (item instanceof queryStructure.And) {
                $(cell).AndContainerUI({
                    parent: this,
                    container: item
                });
            } else {
                $(cell).OrContainerUI({
                    parent: this,
                    container: item
                });
            }
        }
        return cell;
    },
    setActive: function() {
        this.div.toggleClass('active');
    },

    setParent: function(widget) {
        if (widget == this.parent) return;
        this.container.remove();
        widget.container.add(this.container);
        this.parent = widget;

    },

    toggleExpand: function() {
        this.ul.toggle();
        this.div.toggleClass('collapsed');
    },

    childDropped: function(widget, other) {

        if (this.reordering && widget.parent == this && other.parent == this) {
            if (this.container.moveBefore(widget.container, other.container)) {
                widget.element.before(other.element);
                return;
            }
        }
        
        var sameParent = widget.parent == other.parent;
        var otherParent = other.parent;
        other.element.remove();
        var collection = (this.container instanceof queryStructure.And) ? new queryStructure.Or() : new queryStructure.And();


        this.container.replaceChild(widget.container, collection);
        collection.addAll([widget.container, other.container]);
        var ui = this._createItemUI( - 1, collection)
        widget.element.replaceWith(ui);
        // if other was the last thing in it's parent
        // remove the parent
        if (other.parent) {
            other.parent.destroyIfEmpty()
        }
        other.destroy();
        widget.destroy();
        
        if(!sameParent && otherParent && (otherParent.container instanceof queryStructure.And)){
          otherParent._collapsIfSingleChild();
        }
        updateQuery();
    },
    
    _collapsIfSingleChild: function(){
      if(this.container && this.container.children.length == 1 && this.parent && this.container.parent){
        var child = this.container.children[0];
        var childui = this.parent._createItemUI( - 1, child);
        this.container.parent.add(child,this.container);
        this.element.replaceWith(childui);
        this.container.remove();
        this.element.remove();
        this.destroy();
        
      }
    },
    
    destroyIfEmpty: function() {
        var p = this.parent;

        if (p && this.container && this.container.children.length == 0) {
            this.container.remove();
            this.element.remove();
            this.destroy();
            p.destroyIfEmpty();
            
        }

    },

    _remove:function(){
      var el = this.element;
      function callback() {
         el.remove();
        }
      this.element.hide( "explode", {}, 1000, callback );
     
      this.container.remove();
      updateQuery();
    }

}

);


/* And container UI widget   
*/
$.widget("ui.AndContainerUI", $.ui.ContainerUI, {
    options: {

        },

    collectionType: function() {
        return "AND";
    }

}
);

$.widget("ui.OrContainerUI", $.ui.ContainerUI, {
    options: {

        },
    collectionType: function() {
        return "OR";
    },

}

);



$.widget("ui.ItemUI", {
    options: {},

    _init: function() {
        this.container = this.options.container;
        this.parent = this.parent = this.options.parent;
        var self = this;
        var div = $("<div>", {
            "class": "resource_dependency"
        });
        this.div = div;
        var img = $("<div>", {"class":"item_image "+this.container.name});
        img.append("&nbsp;");
        div.append(img);
        div.append($('<div>', {
            'class': 'name',
            text: this.container.name
        }));
        $(div).dblclick(function() {
            self.openPopup()
        })
        this.element.append(div);

        this.element.draggable({
            helper: 'clone',
            cursor: 'crosshair',
            snap: false,
            revert: 'invalid',
            zIndex: 1000,
            refreshPositions: true,
            stacks: ".ui-layout-center, .content, .section, .header, #test,.ui-droppable",
            start: function() {
                $(this).data("widget", self);
                //self.element.hide();
            },
            stop: function() {
                //self.element.show();
            }
        });

        this.element.droppable({
            drop: bind(this.drop, this),
            greedy: true,
            tolerance: 'pointer',
            hoverClass: 'active'
        });

    },

    accept: function(event, ui) {
        return true;
    },
    out: function(event, ui) {
        this.element.removeclass("over")
    },
    drop: function(event, ui) {
        var other = ui.draggable.data('widget');
        if (other == null) {
            var el = $('<li>', {
                'class': "dependency resource_dep"
            }).ItemUI({
                container: ui.draggable.data('item')
            });
            other = el.data().ItemUI;
        }
        this.parent.childDropped(this, other);
    },
    over: function(event, ui) {
        this.element.addClass("over")
    },
    setParent: function(widget) {
        if (widget == this.parent) return;
        this.container.remove();
        widget.container.add(this.container);
        this.parent = widget;

    },
    
    openPopup: function(){
      var image = $(".item_image", this.div);
      var edName = this.container.name.replace(/^\w/, function($0) { return $0.toUpperCase(); });
      
      this.editor = (this.editor || eval("$('<div>')."+edName+"Editor({container:this.container})"));
      image.popup({'widg':this, arrow:"left .08", offset:"5px", content:this.editor});
      image.popup("open");
    },
    _remove:function(){
        var el = this.element;
        function callback() {
           el.remove();
          }
        this.element.hide( "explode", {}, 1000, callback );

        this.container.remove();
        updateQuery();
    }

});




$.widget("ui.ExtractUI", {
  _create: function() {
    this.div = $(".extract_editor", this.element);
    this.element.droppable({
      drop: bind(this.drop, this),
      greedy: true,
      tolerance: 'pointer',
      hoverClass: 'active'
    });
    this.ul = $("<ul>");  
    this.div.append(this.ul);
    
    if (query.extract.selections.length > 0 || query.extract.selections.length > 0) {
      var cell = $('<li>', {
        "class": "dependency resource_dep"
      });
      cell.ExtractItemUI({type:"demographics"});
      this.ul.append(cell);
      droppedWidget = cell.data().ExtractItemUI;
    }
  },
  
  drop: function(element, ui) {
    this.element.removeClass("over");

    var droppedWidget = ui.draggable.data('widget');
    if (!droppedWidget) {
      if ($(".extract_editor").children("ul").children("li").length == 0) {
        var data = ui.draggable.data("item");
        var cell = $('<li>', {
          "class": "dependency resource_dep"
        });
        cell.ExtractItemUI({type:"demographics"});
        this.ul.append(cell);
        droppedWidget = cell.data().ExtractItemUI;
        droppedWidget.openPopup();
      }
    } else {
      droppedWidget.closePopup();
      droppedWidget._remove();
    }
  },
  
  over: function(event, ui) {
    this.element.addClass("over");
  },
  
  out: function(event, ui) {
    this.element.removeClass("over");
  }
});


$.widget("ui.ExtractItemUI", {
  _create: function() {
    var div = $("<div>", {
        "class": "resource_dependency"
    });
    
    this.div = div;
    var img = $("<div>", { "class" : "item_image " + this.options.type });
    img.append("&nbsp;");
    div.append(img);
    
    div.append($('<div>', {
      'class': 'name',
      text: this.options.type
    }));
    this.element.append(div);
    
    var self = this;
    $(div).dblclick(function() {
      self.openPopup();
    });
    
    this.element.draggable({
      helper: 'clone',
      cursor: 'crosshair',
      snap: false,
      revert: 'invalid',
      zIndex: 1000,
      refreshPositions: true,
      stacks: ".ui-layout-center, .content, .section, .header, #test, .ui-droppable",
      start: function() {
        $(this).data("widget", self);
      }
    });

    this.element.droppable({
      drop: bind(this.drop, this),
      greedy: true,
      tolerance: 'pointer',
      hoverClass: 'active'
    });
  },
  
  closePopup: function() {
    $(".item_image", this.div).popup('close');
  },
  
  openPopup: function() {
    var image = $(".item_image", this.div);
    this.editor = (this.editor || eval("$('<div>').DemographicsExtractor()"));
    image.popup({'widg':this, arrow:"left .08", offset:"5px", content:this.editor});
    image.popup("open");
  },
  
  _remove: function() {
    query.extract = new queryStructure.Extraction([], []);
    updateQuery();
    
    var cell = this.element;
    this.element.hide('explode', {}, 1000, function() {
      cell.remove();
    });
  },
});