$.widget("ui.SimpleRangeWidget",{
  options:{
    min:0,
    max:5000,
    onchange:function(){}
  },
  
  _create: function(){
    this.parent = this.options.parent;
    this.div = $("<div>");
    this.min = $("<input>");
    this.max = $("<input>");
    this.div.append(min);
    this.div.append(max);
    this.onchange = this.options.onChange();
  },
  
  getRangeValue:function(){
    return {min:this.min.value(), max:this.max.value()}
  },
  
  
  
}
);