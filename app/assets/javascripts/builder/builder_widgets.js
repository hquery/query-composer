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



function openPopup(widget){
  alert("this is where the open popup code will go");
  $(":ui-popup").popup("close");
  $("<div>").popup({"widget":widget});
}


$.widget("ui.popup",{
  
  options: {},
  
  _create: function(){
    this.element.addClass("ui-popup");
    this.widget = this.options.widget;
  },
  
  _init: function(){
  this.content = $("<div>"); // call template creation
  $(this.element).position({of:this.widget.element, my:"bottom", at:"top"});
  $(this.element).show();
  },
  
  
  save: function(){
    
  },
  
  
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
              stacks: ".ui-layout-center, .content, .section, .header, #test,.ui-droppable",
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
            tolerance: 'pointer',
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

        if (!droppedWidget) {
            var data = ui.draggable.data("item");

            var el = $('<li>', {
                "class": "dependency resource_dep"
            });
            el.ItemUI({
                container: data
            });
            droppedWidget = el.data().ItemUI;
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

             if(oldParent && 
                oldParent.container.children.length == 1 && 
                (oldParent.container instanceof queryStructure.And)){
                var child = oldParent.container.children[0];
                var childui = this._createItemUI( - 1, child);
                this.container.add(child);
                droppedWidget.element.after(childui);

                oldParent.container.remove();
                oldParent.element.remove();
                oldParent.destroy();

              }
        }


    },


    _createItemUI: function(i, item) {

        var cell = $('<li>', {
            class: "dependency"
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
        
        if(!sameParent && 
          otherParent.container.children.length == 1 && 
          (otherParent.container instanceof queryStructure.And)){
          var child = other.parent.container.children[0];
          var childui = this._createItemUI( - 1, child);
          this.container.add(child, collection);
          ui.after(childui);
          
          otherParent.container.remove();
          otherParent.element.remove();
          otherParent.destroy();
          
        }
    }

    ,
    destroyIfEmpty: function() {
        var p = this.parent;

        if (p && this.container && this.container.children.length == 0) {
            this.container.remove();
            this.element.remove();
            this.destroy();
            p.destroyIfEmpty();

        }

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
                class: "dependency resource_dep"
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
      alert("this is where the opening of the popup code will go");
    }

});








