$.widget("ui.HistoryEditor",{
  options:{},
  
  _create: function(){
    
    this.div = $("<div>");
    this.element.append(this.div);
    
    this.div.append("History ... coming soon")
    
  }
  
});