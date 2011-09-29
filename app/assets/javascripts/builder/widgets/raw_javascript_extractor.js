$.widget("ui.RawJavascriptExtractor",{
  options: {},
  _create:function(){
    this.container = this.options.container;
    
    this.div = $("<div>");
    
    this.element.append(this.div);
    
  },
  
  get:function(type){
    var entry = null;
     $.each(this.container.children,function(i, node){
        if(node.type == type){
          entry = node;
        }
     });
     return entry;
  },
  
  set:function(object){
     var self = this;
     $.each(this.container.children,function(i, node){
        if(node.type == object.type){
          self.container.removeChild(node)
        }
     });
     this.container.add(object);
  }
  
  
});