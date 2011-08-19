var bind = function(func, thisValue) {
    return function() {
        return func.apply(thisValue, arguments);
    }
}

var dropTargetImage  = $("<img>",{"src":"/assets/drop_target.png", "padding":"0"});



function createItemContainer(image, description){
    var div = $("<div>", {
        "class": "container item"
    });
    var contentRow = $("<div>", {
        "class": "container_row"
    });   
    div.append(contentRow);
    var imageCell = $("<div>", {
        "class": "container_cell builder_image " +image
    });
    var textCell = $("<div>", {
        "class": "container_cell description "
    });
    imageCell.append("&nbsp;");  
    // add the text
    textCell.append(description);
    contentRow.append(this.imageCell);
    contentRow.append(this.textCell);
    return div;
}

var dropTargetItem = createItemContainer("drop_target", "");

/* Base container UI widget */
$.widget("ui.ContainerUI", {
    options: {

        },
    _create: function() {
        this.container = this.options.container;
        this.items = [];
        this.parent = this.options.parent;
        this.element.append(this._createContainer());
        this.element.append(this.div);

    },

    conjunction: function() {
        return container.conjunction();
    },

    _createContainer: function() {
        return $("<div>")
    },


    childDrop: function() {
        alert("child Dropped");
    }

}

);


/* And container UI widget   


*/
$.widget("ui.AndContainerUI", $.ui.ContainerUI, {
    options: {

        },


    _createContainer: function() {
        var div = $("<div>", {
            "class": "container and"
        });
        this.div = div;
        // this is a table
        var self = this;
        var f = function(i, item) {
            div.append(self._createItemUI(i, item));
        };
        $.each(this.container.children, f);
        div.droppable({
            drop: bind(this.drop, this),
            over: bind(this.over, this),
            out: bind(this.out, this),
            greedy: true
        });
        return div;
    },

    _createItemUI: function(i, item) {
        var row = $("<div>", {
            "class": "container_row and_item"
        });
        // row in the table
        var contentCell = $("<div>", {
            "class": "container_cell"
        })
        // second cell in the row ,  content cell
        row.append(contentCell);
        if (item && item.type != null) {
            $(contentCell).ItemUI({
                parent: this,
                item: item
            });
        } else {
            if (item instanceof queryBuilder.And) {
                $(contentCell).AndContainerUI({
                    parent: this,
                    container: item
                });
            } else {
                $(contentCell).OrContainerUI({
                    parent: this,
                    container: item
                });
            }
        }
        return row;
    },
    drop: function(event,ui) {
      var type = ui.draggable.data("type");
             if(this.container.children.length == 0){
               var or = new queryBuilder.Or();
               
               or.add({
                    "type": type,
                    "description": "dropped"
                });
               this.container.add(or);

              var item =  this._createItemUI(-1,or );
               this.div.append(item);
             }else{
               if(this.parent){
                 this.parent.childDropped(this,"right",{
                       "type": type,
                       "description": "dropped"
                   });
               }
             }
             if(this.dropTarget){
                this.dropTarget.remove();
              }
            this.element.css("background-color", "");
    },
    over: function(event,ui) {
        if (this.parent) {
            if (this.dropTarget == null) {
                var cell = $("<div>", {
                    "class": "container_cell"
                });
                // table cell for or row
                var table = $("<div>", {"class": "container"});
                // style row for the cell item
                cell.append(table);
                var styleRow = $("<div>", {"class": "container_row"});
                var contentCell = $("<div>", {"class": "container_row" });
                // content row for the item -- do I need to add a cell to the row to wrap things in?
                table.append(styleRow);
                table.append(contentCell);
                contentCell.append("Drop Zone")
                this.dropTarget = cell;
            }
            this.element.parents(".container_cell:first").after(this.dropTarget);
            this.element.css("background-color", "red");
        }
    },
    out: function(event,ui) {
        if (this.dropTarget) {
            this.dropTarget.remove();
            this.element.css("background-color", "");
        }
    },

    childDropped: function(widget, direction, data) {
        if (direction == "bottom") {
            var item = this._createItemUI( - 1, data);
            this.container.add(data,widget.container);
            widget.element.parents(".container_row:first").after(item);
        } else {
            var or = new queryBuilder.Or();
            or.add(widget.item);
            or.add(data);
            //this.container.replace(widget.item, or);
            var ui = this._createItemUI( - 1, or);
            widget.element.parents(".container_row:first").replaceWith(ui);
        }
    }

}
);



$.widget("ui.OrContainerUI", $.ui.ContainerUI, {
    options: {

        },

    _createContainer: function() {
        var div = $("<div>", {"class": "container or"});
        var row = $("<div>", {"class": "container_row"  });
        div.append(row);
        var self = this;
        var f = function(i, item) {
            row.append(self._createItemUI(i, item));
        };
        $.each(this.container.children, f);

        row.droppable({
            drop: bind(this.drop, this),
            over: bind(this.over, this),
            out: bind(this.out, this),
            greedy: true
        });
        this.div = div;
        this.contentRow = row;
        return div;
    },


    _createItemUI: function(i, item) {
        var cell = $("<div>", {
            "class": "container_cell or_item"
        });
        // table cell for or row
       // var table = $("<div>", {"class": "container" });
        // style row for the cell item
      //  cell.append(table);

       // var contentCell = $("<div>", {"class": "container_row" });
        // content row for the item -- do I need to add a cell to the row to wrap things in?
      
      //  table.append(contentCell);


        var style = $("<div>", {"class": "container style_header" });
        var styleRow = $("<div>", {"class": "container_row style_row" });
        var curveCell = $("<div>", {"class": "container_cell curve_style"  });
        var lineCell = $("<div>", {"class": "container_cell line_style" });
        curveCell.append("&nbsp;");
        lineCell.append("&nbsp;");
        style.append(styleRow);
        styleRow.append(curveCell);
        styleRow.append(lineCell);
        cell.append(style);
        if (item && item.type != null) {
            $(cell).ItemUI({parent: this,item: item});
        } else {
            if (item instanceof queryBuilder.And) {
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

    drop: function(event, ui) {
       var type = ui.draggable.data("type");
       var data = {
           "type": type,
           "description": "dropped"
       };
        if(this.container.children.length == 0){
         
          this.container.add(data);
          
         var item =  this._createItemUI(-1,data);
          this.row.append(item);
        }else{
          this.parent.childDropped(this,"bottom",data);
        }
        if(this.dropTarget){this.dropTarget.remove();}
        this.element.css("background-color", "");
    },
    
    over: function() {
        if (this.parent) {
            if (this.dropTarget == null) {
                var row = $("<div>", {
                    "class": "container_row"
                });
                var cell = $("<div>DROPPPPPPP MEEEEE</div>");
                row.append(cell);
                this.dropTarget = row;
            }
            this.contentRow.after(this.dropTarget);
            this.element.css("background-color", "red");
        }
    },
    out: function() {
        if (this.dropTarget) {
            this.dropTarget.remove();
            this.element.css("background-color", "");
        }
    },

    childDropped: function(widget, direction, data) {
        if (direction == "right") {
            var item = this._createItemUI( - 1, data);
         //   this.container.add(data,widget.container);
            widget.element.after(item);
        } else {
            var and = new queryBuilder.And();
            and.add(widget.item);
            and.add(data);
        //    this.container.replace(widget.contaier,and);
            var ui = this._createItemUI( - 1, and);
            widget.element.replaceWith(ui);
            
        }
    },
    
    styleChildren :function(){
     
    }
}

);



$.widget("ui.ItemUI", {
    options: {},

    _init: function() {
        this.item = this.options.item;
        this.parent = this.parent = this.options.parent;
        this.element.append(this._createContainer());
    },


    _createContainer: function() {

        this.div = $("<div>", {
            "class": "container item"
        });

        this.contentRow = $("<div>", {
            "class": "container_row"
        });
  

        this.div.append(this.contentRow);


        this.imageCell = $("<div>", {
            "class": "container_cell builder_image " +this.item.type 
        });
        this.textCell = $("<div>", {
            "class": "container_cell description "
        });

        // add the appropriate image/component
     //  this.imageCell.append($("<img>", {
      //     "src": "/assets/icon_"+ (this.item.type || 'conditions') +".png"
      // }));
      
        this.imageCell.append("&nbsp;");
        
        
        this.imageCell.droppable({
            drop: this._dropBottom,
            out: this._outBottom,
            accept: this._accept,
            over: this._overBottom,
            greedy: true
        });

        this.imageCell.data("widget", this);
        
        // add the text
        this.textCell.append(this.item.description);

        this.contentRow.append(this.imageCell);
        this.contentRow.append(this.textCell);

         this.textCell.data("widget", this);
         this.textCell.droppable({
              drop: this._dropRight,
              out: this._outRight,
              accept: this._accept,
              over: this._overRight,
              greedy: true
          });
        


        return this.div;
    },
    _accept: function(event, ui) {
        return true;
    },
    _outRight: function(event, ui) {
        var widget = $(this).data("widget");
        widget.textCell.next().remove();
        $(this).css("background-color", "")
    },
    _outBottom: function(event, ui) {
        var widget = $(this).data("widget");
        widget.contentRow.next().hide("fast");
        widget.contentRow.next().remove();
        $(this).css("background-color", "")
    },
    _dropRight: function(event, ui) {
        var widget = $(this).data("widget");
         widget.textCell.next().hide("fast");
         widget.textCell.next().remove();
        $(this).css("background-color", "");
        
        var type = ui.draggable.data("type");
        widget.parent.childDropped(widget, "right", {
            "type": type,
            "description": "dropped"
        });
    },
    _dropBottom: function(event, ui) {
        var widget = $(this).data("widget");
        widget.contentRow.next().remove();
        $(this).css("background-color", "")
         var type = ui.draggable.data("type");
          widget.parent.childDropped(widget, "bottom", {
              "type": type,
              "description": "dropped"
          });
    },
    _overRight: function(event, ui) {
        var widget = $(this).data("widget");
        //widget.parent.childOver(widget, "right");
        var cell = $("<div>", {
            "class": "container_cell drop_target"
        });
        // table cell for or row
        cell.append(dropTargetImage);
        cell.hide();
        widget.textCell.after(cell);
        cell.show("fast");
        //$(this).css("background-color", "red");
    },
    _overBottom: function(event, ui) {
        var widget = $(this).data("widget");
        var row = $("<div>", {
            "class": "container_row"
        });
        // row in the table
        var contentCell = $("<div>", {
            "class": "container_cell"
        })
        // second cell in the row ,  content cell
        row.append(contentCell);
        contentCell.append(dropTargetImage);
        row.hide();
        widget.div.append(row);
        row.show("fast");
        // widget.parent.childOver(widget, "bottom");

    }
});








