$.widget("ui.FunctionalStatusEditor",{
  options: {},
  _create:function(){
    this.div = $("<div>");
    this.div.append("<span>Functional Status</span><span><select></select></span>");
    this.element.append(this.div);
  }
});




$.widget("ui.AllergiesEditor",{
  options: {},
  _create:function(){
    
    this.div = $("<div>");
    this.div.append("<span>Allergies</span><span><select></select></span>");
    this.element.append(this.div);

  }
});



$.widget("ui.VitalsEditor",{
  options: {},
  _create:function(){
    var self = this;
    var parent = this.options.parent;
    var selected = (this.options.rule && this.options.rule.data.code) ? this.options.rule.data.code._id : "";
    
    $(this.element).CodeList({title:"Vital Signs",type:"vital_sign",selected:selected, onChange:function(code,event){parent.set(new queryStructure.VitalSignRule({code:code}))}});
    
  }
});



$.widget("ui.ObservationsEditor",{
  options: {},
  _create:function(){
    this.container = this.options.container;
    
    this.div = $("<div>");
    this.vitalsDiv = $("<div>").VitalsEditor({parent:this, rule:this.get("VitalSignRule")});
    this.allergiesDiv = $("<div>").AllergiesEditor();
    this.funcionalStatusDiv = $("<div>").FunctionalStatusEditor();
    
    this.div.append(this.funcionalStatusDiv);
    this.div.append(this.allergiesDiv);
    this.div.append(this.vitalsDiv);
    
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