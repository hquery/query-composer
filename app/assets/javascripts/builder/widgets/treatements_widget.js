

$.widget("ui.EncountersEditor",{
  options: {},
  _create:function(){
    var self = this;
    var parent = this.options.parent;
    $(this.element).CodeList({title:"Encounters",type:"encounter", onChange:function(code,event){parent.set(new queryStructure.CodeSetRule({type:"encounters",code:code}))}});
    
  }
});



$.widget("ui.TreatmentsEditor",{
  options: {},
  _create:function(){
    this.container = this.options.container;
    
    this.div = $("<div>");
    this.encountersDiv = $("<div>").EncountersEditor({parent:this});
   
    this.div.append(this.encountersDiv);
    
    this.element.append(this.div);
  },
  
  get:function(type){
    var entry = null;
     $.each(this.container.and,function(i, node){
        if(node.code_set_type == type){
          entry = node;
        }
     });
     
  },
  
  set:function(object){
     var self = this;
     $.each(this.container.children,function(i, node){
        if(node.data.type == object.data.type){
          self.container.removeChild(node)
        }
     });
     this.container.add(object);
  }
  
  
});