var Nonsense = {
  makeNegative: function(number) {
    return number * -1;
  }
}


var bind = function(func, thisValue) {
  return function() {
    return func.apply(thisValue, arguments);
  }
}

$.widget("ui.ContainerUI",{
  options: {

  },
  _init:function(){
    debugger;
    this.container = this.options.container;
    this.items = [];
    this.parent = this.options.parent;
    this.element.append(this._createContainer());
    this.element.append(this.div);
    
  },
  
  conjunction:function(){
    return container.conjunction();
  },
   
  _createContainer:function(){
     return $("<div>")
  }   ,

  childDrop :function(){
       alert("child Dropped");
     }
  
}
  
);

$.widget("ui.AndContainerUI",$.ui.ContainerUI, {
  options: {

  },
  
  
  _createContainer:function(){
      var div = $("<div>", {"class":"container and"}); // this is a table 
      var self = this;  
      var f = function(i,item){
             div.append(self._createItemUI(i,item));
           };
      $.each(this.container.children,f);
     return div;
  },
  
  _createItemUI:function(i, item){
      var row = $("<div>", {"class":"container_row"});  // row in the table 
      var contentCell = $("<div>", {"class":"container_cell"})// second cell in the row ,  content cell

      row.append(contentCell);
      if(item && item.type != null){
         $(contentCell).ItemUI({parent: this, item:item  });
      }else{
         if(item instanceof hQuery.AndContainer){
           $(contentCell).AndContainerUI({parent:this, container:item});
         }else{
           $(contentCell).OrContainerUI({parent:this, container:item});
         }
      }  
      return row;
   },
   childDrop :function(element){
       alert("child Dropped");
     },  
   
    childOver: function(widget, direction){
      if(direction == "bottom"){
        widget.element.parents(".container_row:first").after(this.newItemDrop());
        this.newItemDrop().show(.1);
      }else{
        
      }
    },

    childOut :function(widget, direction){
      this.newItemDrop().hide(.1);
    },

    newItemDrop:function(){
      if(this.newDrop == null){
        var row = $("<div>", {"class":"container_row"});  // row in the table 
        var contentCell = $("<div>", {"class":"container_cell"})// second cell in the row ,  content cell
        row.append(contentCell);

        contentCell.append("DROP HERE");
        this.newDrop = row;
     }
     return this.newDrop;
    }
}
);



$.widget("ui.OrContainerUI",$.ui.ContainerUI, {
  options: {

  },
 
  
  _createContainer:function(){
       var div = $("<div>", {"class":"container or"});
       var row = $("<div>", {"class":"container_row"}); 
       div.append(row);
       var self = this;    
       var f = function(i,item){
                row.append(self._createItemUI(i,item));
       };
       $.each(this.container.children,f);
       return div;
   },


   _createItemUI:function(i, item){
       var cell = $("<div>", {"class":"container_cell"}); // table cell for or row
       var table = $("<div>", {"class":"container"}); // style row for the cell item
       cell.append(table);
       var styleRow = $("<div>", {"class":"container_row"})
       var contentCell = $("<div>", {"class":"container_row"}); // content row for the item -- do I need to add a cell to the row to wrap things in?

       table.append(styleRow);
       table.append(contentCell);
       
       if(item && item.type != null){
          $(contentCell).ItemUI({parent: this, item:item  });
       }else{
          if(item instanceof hQuery.AndContainer){
            $(contentCell).AndContainerUI({parent:this, container:item});
          }else{
            $(contentCell).OrContainerUI({parent:this, container:item});
          }
       }  
       return cell;
   },

   acceptDrop: function(){

   },
   
   childDropped: function(widget,direction, data){
     
   },
   
   childOver: function(widget,direction){
     if(direction == "right"){
       widget.element.parents(".container_cell:first").after(this.newItemDrop());
       this.newItemDrop().show(.1);
     }else{
       
     }
   },
   
   childOut :function(widget,direction){
     if(direction == "bottom"){
       this.currentNewDrop.replaceWith(widget.element);
     }
     this.currentDropDirection = null;
     this.currentNewDrop.hide(.1);
     this.currentNewDrop = null;
   },
   
   newItemDrop:function(direction){
     var newDrop = null;
     if(direction = "right"){
       if(this.newDropRight == null){
        var cell = $("<div>", {"class":"container_cell"}); // table cell for or row
        var table = $("<div>", {"class":"container"}); // style row for the cell item
        cell.append(table);
        var styleRow = $("<div>", {"class":"container_row"})
        var contentCell = $("<div>", {"class":"container_row"});
        table.append(styleRow);
        table.append(contentCell);
        contentCell.append("DROP HERE");
        newDrop = cell;
      }
    }
    else{
      
    }
    this.currentNewDrop = newDrop;
    return this.currentNewDrop;
   }
 }
  
);



$.widget("ui.ItemUI",{
  options: {},
  
  _init:function(){
    this.item = this.options.item;
    this.parent = this.parent = this.options.parent;
    this.element.append(this._createContainer());
  },
  
  
  _createContainer:function(){
    this.div = $("<div>", {"class": "container item"});
    
    this.contentRow = $("<div>",{"class": "container_row"});
    this.contentRow.data("widget",this);
    this.contentRow.droppable({drop:this._dropRight,
                               activate:this._activateRight,
                               deactivate:this._deactivateRight,
                               out:this._outRight,
                               accept:this._acceptRight,
                               hover:this._hoverRight,
                               over:this._overRight});
                               
     this.bottomRow = $("<div>",{"class": "container_row bottom_hotzone"});
    
     this.bottomRow.droppable({drop:this._dropBottom,
                                 activate:this._activateBottom,
                                 deactivate:this._deactivateBottom,
                                 out:this._outBottom,
                                 accept:this._acceptBottom,
                                 hover:this._hoverBottom,
                                 over:this._overBottom});
    
    this.bottomRow.data("widget",this);                             
    this.div.append(this.contentRow);
    this.div.append(this.bottomRow);
    
    this.imageCell = $("<div>",{"class":"container_cell"});
    this.textCell = $("<div>",{"class":"container_cell"});
    
    // add the appropriate image/component
    this.imageCell.append($("<img>", {"src":"/assets/icon_observations.png"}));
    // add the text
    
    this.textCell.append(this.item.description);
    
    this.contentRow.append(this.imageCell);
    this.contentRow.append(this.textCell);
    
    this.bottomHotZone = $("<div>");
    
    // set up the drop zone 
    
    
    this.bottomRow.append(this.bottomHotZone);
    this.bottomRow.append($("<div>"))
    
    return this.div;
  },
  
  _hoverRight: function(event, ui){
    window.console.log("hover right");
  },
  
  _hoverBottom: function(event, ui){
      window.console.log("hover bottom");
  },
  _accept: function(event, ui){
   // window.console.log("accept right");
    var widget = $(this).data("widget");
    return true;
  }
  _outRight: function(event, ui){
       var widget = $(this).data("widget");
       widget.parent.childOut(widget, "right");
     $(this).css("background-color","")
  },
  _outBottom: function(event, ui){
     var widget = $(this).data("widget");
     widget.parent.childOut(widget, "bottom");
     $(this).css("background-color","")
  },
  _activateRight: function(event, ui){
      window.console.log("activate right");
  },
  _activateBottom: function(event, ui){
   window.console.log("activate bottom");
  },
  _deactivateRight: function(event, ui){
     window.console.log("deactivate right");
   },
  _deactivateBottom: function(event, ui){
    window.console.log("deactivate bottom");
  },
  _dropRight: function(event, ui){
      window.console.log("drop right");
  },
  _dropBottom: function(event, ui){
    window.console.log("drop bottom");
  },
  _overRight: function(event, ui){
    var widget = $(this).data("widget");
    widget.parent.childOver(widget, "right");
      $(this).css("background-color","red");
  },
  _overBottom: function(event, ui){
    var widget = $(this).data("widget");
    widget.parent.childOver(widget, "bottom");
    $(this).css("background-color","red");
  }  
});








