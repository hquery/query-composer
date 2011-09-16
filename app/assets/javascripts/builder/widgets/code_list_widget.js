$.widget("ui.CodeList",{
  options:{},
  
  _create: function(){
    var self = this;
    this.type = this.options.type;
    this.auto_complete = this.options.auto_complete;
    this.selected = this.options.selected;
    this.div = $("<div>");
    this.div.append($("<span>").append(this.options.title));
    this.selectBox = $("<select>");
    this.selectBox.change(function(event){
      
      $("option:selected",this.selectBox).each(function () {
            var selectedID = $(this).attr("value")
            var code = self._getSelectedCode(selectedID);
            self.selectedCode = code;
            if(self.onChange){
              self.onChange(code, event);
            }
        });
      
    });
    
    this.div.append($("<span>").append(this.selectBox));
    this.element.append(this.div);
    this._loadCodeList();
    this.onChange = this.options.onChange || function(){};
    
  },
  
  _loadCodeList:function(){
    var self = this;
    $.get("/code_sets/by_type/"+this.type+".json",function(data){self._loadData(data)});  
  },
  
  _loadData:function(data){
    var self = this;
    var select = this.select;
    this.code_list = data;
    $.each(data, function(i, node){
       var selected = (node._id == self.selected);
       var option = $("<option "+( (selected)? "selected='true'" : "" )+ ">", {"value":node._id});
       if(selected){
         self.selectedCode = node;
       }
       option.append(node.name);
       self.selectBox.append(option);
    });
  },
  _getSelectedCode:function(codeID){
    var code= null;
    $.each(this.code_list,function(i, node){
        if(node._id == codeID){
           code = node;;
        }
    });
    
    return code
  },
  
  
});