$.widget("ui.DemographicsEditor",{
  options:{},
  
  _create: function(){
    // the encompassing container for the demographic objects
    var self = this;
    this.container = this.options.container;
    this.demo = this.get("DemographicRule");
    
    this.ageRange = (this.demo) ? this.demo.data.ageRange : {low:0, high:130};
    this.gender = (this.demo) ? this.demo.data.gender : null;
    this.raceCode =(this.demo) ? this.demo.data.raceCode : null;
    this.maritalStatusCode = (this.demo) ? this.demo.data.maritalStatusCode : null;
    
    this.div = $("<div>");
    this.element.append(this.div);
    
    this.ageDiv = $("<div>").append("<span>age</span><input class='age_range' type='text' id='amount' style='border:0; color:#f6931f; font-weight:bold;' value='"+ this.ageRange.low + " - "+ this.ageRange.high+"' /> ");
    this.age_slider = $("<div>").slider({
      min:0, 
      max:130, 
      range:true,values: [ 0, 130 ],
      values:[self.ageRange.low, self.ageRange.high],
      slide: function( event, ui ) {
         $( ".age_range",self.ageDiv ).val("" + ui.values[ 0 ] + " - " + ui.values[ 1 ]  );
         self.ageRange = {low:ui.values[ 0 ], high:ui.values[ 1 ]};
         },
      stop:function(){self._update()}   
          });
    this.ageDiv.append(this.age_slider);
  
    this.genderDiv = $("<div>").append("<span>gender</span>");
    this.genderDiv.append(this._createGenderSelect(this.gender));
    this.raceDiv = $("<div>").CodeList({title:"Race",type:"race",selected:"", onChange:function(code,event){self.raceCode = code; self._update()}});
    this.msDiv = $("<div>").CodeList({title:"Marital Staus",type:"marital_status",selected:"", onChange:function(code,event){self.maritalStatusCode = code; self._update()}});
    
    
    this.div.append(this.ageDiv);
    this.div.append(this.genderDiv);
    this.div.append(this.raceDiv);
    this.div.append(this.msDiv);
    
  },
  
  _createGenderSelect:function(selected){
    
    var sel =  $("<select>");
    sel.append("<option>Select</option>");
    $.each(["M","F","UN"],function(i,g){
        var op = $("<option>",{"value":g}).append(g);
        if(selected == g){
          op.attr("selected","true");
        }
        sel.append(op);
    });
    var self = this;
    sel.change(function(event){
      
      $("option:selected",this).each(function () {
            var genderCode = $(this).attr("value");
            self.gender = genderCode;
            self._update()
        });
      
    });
    return sel;
  },
  
  
  _update:function(){
    this.set(new queryStructure.DemographicRule({ageRange:this.ageRange, gender:this.gender, raceCode:this.raceCode, maritalStatusCode:this.maritalStatusCode}));
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