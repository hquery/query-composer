$.widget("ui.RawJavascriptEditor",{
  options: {},
  _create:function(){
    this.container = this.options.container;
    
    this.div = $("<div>");
    this.text = $("<textarea>",{"rows":10, "cols":40});
    this.div.append(this.text);
    this.rule = this.get("RawJavascriptRule");
    this.text.val((this.rule) ? this.rule.data.js : "");
    var self = this;
    this.text.blur(function(){
      var r = $(this).val();
      try{
      eval("var js = "+r); // just a safty check to make sure its js
      this.rule = new queryStructure.RawJavascriptRule({js:r})
      self.set(this.rule);
    }
    catch(e){
      
    }
    });
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