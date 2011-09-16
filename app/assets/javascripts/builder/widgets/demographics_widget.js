$.widget("ui.DemographicsEditor",{
  options:{},
  
  _create: function(){
    // the encompassing container for the demographic objects
    this.container = this.options.container;
    
    this.div = $("<div>");
    this.element.append(this.div);
    
    this.age = $("<div>").append("<span>age</span>");
    this.age_slider = $("<div>").slider({min:0, max:130, range:true,values: [ 0, 130 ],
         
          });
    this.age.append(this.age_slider);
  
    this.gender = $("<div>").append("<span>gender</span>");
    this.gender.append(this._createGenderSelect());
    this.race = $("<div>").append("race");
    this.ms = $("<div>").append("marital status");
    
    this.div.append(this.age);
    this.div.append(this.gender);
    this.div.append(this.race);
    this.div.append(this.ms);
    
  },
  
  _createGenderSelect:function(){
    
    var sel =  $("<select>");
    $.each(["M","F","UN"],function(i,g){
        var op = $("<option>",{"value":g}).append(g);
        sel.append(op);
    });
    return sel;
  }
  
  
  
});