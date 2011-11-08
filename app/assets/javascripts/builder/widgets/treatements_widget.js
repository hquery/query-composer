

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
    var self = this; 
    this.encounterRule = this.findRuleByName("encounters");
    var code = (this.encounterRule )? this.encounterRule.data.code : null;
    this.div = $("<div>");
    $("<h2>").text("Treatments").appendTo(this.div);

    this.encountersDiv = $("<div>").CodeList({title:"Encounters",type:"encounter", selected:code, onChange:function(code,event){self.encounterRule = new queryStructure.CodeSetRule({type:"encounters",code:code}); self._update();}});
    
    
   
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
  },
  
  findRuleByName:function(name){
     var entry = null;
     $.each(this.container.children,function(i, node){
        if(node && node.name == name ){
          entry = node;
        }
     });
       return entry;
  },
  
  findRuleByType:function(type){
    var entry = null;
      $.each(this.container.children,function(i, node){
          if(node && node.type == type ){
            entry = node;
          }
       });
       return entry;
  },
  
  _update:function(){
    this.container.clear();
    if(this.encounterRule){this.container.add(this.encounterRule);}
  }
  
});