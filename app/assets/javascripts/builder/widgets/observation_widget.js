

$.widget("ui.VitalsEditor",{
  options: {},
  _create:function(){
    var self = this;
    var parent = this.options.parent;
    var selected = (this.options.rule && this.options.rule.data.code) ? this.options.rule.data.code._id : "";
    $(this.element).CodeList({title:"Vital Signs",type:"vital_sign",selected:selected, onChange:function(code,event){parent.vitalSignRule = new queryStructure.VitalSignRule({code:code}); parent._update();}});
    
  }
});



$.widget("ui.ObservationsEditor",{
  options: {},
  _create:function(){
    this.container = this.options.container;
    var self = this;
    this.div = $("<div>");
    this.vitalSignRule = this.findRuleByName("VitalSignRule");
    this.allergyRule = this.findRuleByName("allergy");

    var code = (this.allergyRule) ? this.allergyRule.data.code : null;
   // this.functionalStatusRule = this.findRuleByName("functionalStatus");
    this.vitalsDiv = $("<p>").VitalsEditor({parent:this, rule:this.vitalSignRule});
    this.allergiesDiv = $("<p>").CodeList({title:"Allergies",type:"allergy",selected:code, onChange:function(code,event){self.allergyRule = new queryStructure.CodeSetRule({type:"allergy",code:code}); self._update();}});
    //this.funcionalStatusDiv = $("<div>").CodeList({title:"Race",type:"functional_status",selected:this.functionalStatusCode, onChange:function(code,event){self.functionalStatusCode = code; self.set(new queryStructure.CodeSetRule({type:"functional_status",code:code}))}});
    
    this.div.append(this.funcionalStatusDiv);
    this.div.append(this.allergiesDiv);
    this.div.append(this.vitalsDiv);
    
    this.element.append(this.div);
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
     if(this.vitalSignRule){this.container.add(this.vitalSignRule)};
     if(this.allergyRule){this.container.add(this.allergyRule);}

  },

  
});