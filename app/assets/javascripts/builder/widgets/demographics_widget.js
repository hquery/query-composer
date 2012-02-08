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
    $("<h2>").text("Demographics").appendTo(this.div);
    this.element.append(this.div);
    
    this.ageDiv = $("<p>").append("<label>Age</label><input class='age_range' type='text' size='7' id='amount' value='"+ this.ageRange.low + " - "+ this.ageRange.high+"' />");
    this.age_slider = $("<div style='margin:10px 0'>").slider({
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
  
    this.genderDiv = $("<p>").append("<div><label>Gender</label></div>");
    this.genderDiv.find("div").append(this._createGenderSelect(this.gender));
    this.raceDiv = $("<p>").CodeList({title:"Ethnicity",type:"Enticity",selected:"", onChange:function(code,event){self.raceCode = code; self._update()}});
    this.msDiv = $("<p>").CodeList({title:"Marital Status",type:"Marital Status",selected:"", onChange:function(code,event){self.maritalStatusCode = code; self._update()}});
    
    
    this.div.append(this.ageDiv);
    this.div.append(this.genderDiv);
    this.div.append(this.raceDiv);
    this.div.append(this.msDiv);
    
  },
  
  _createGenderSelect:function(selected){
    
    var sel =  $("<select>");
    sel.append("<option value=''>Select</option>");
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
      var a = $(this).closest("p").find("div.optLink a");
      if (self.gender != "") {
      a.css("visibility","visible");
      }
      else
      {
      a.css("visibility","hidden");
      }
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


$.widget("ui.DemographicsExtractor", {
  _create: function() {
    this.div = $("<div>");
    this.element.append(this.div);
    
    this.selectGender = false;
    this.aggregateGender = ['sum'];
    this.groupGender = false;
    this.selectAge = false;
    this.aggregateAge = ['sum'];
    this.groupAge = false;
    
    var selections = query.extract.selections;
    for (var s in selections) {
      var field = selections[s]['title'].charAt(0).toUpperCase() + selections[s]['title'].slice(1);
      this['select' + field] = true;
      this['aggregate' + field] = selections[s]['aggregation'];
    }
    var groups = query.extract.groups;
    for (var g in groups) {
      var field = groups[g]['title'].charAt(0).toUpperCase() + groups[g]['title'].slice(1);
      this['group' + field] = true;
    }
    
    this.div.append("select");
    this.selectGenderDiv = $("<div>");
    this.selectGenderDiv.append(this._createCheckBox('selectGender', 'gender')).append('gender');
    this.selectGenderDiv.append(this._createAggregationSelect('aggregateGender', 'gender'));
    this.selectAgeDiv = $("<div>");
    this.selectAgeDiv.append(this._createCheckBox('selectAge', 'age')).append('age');
    this.selectAgeDiv.append(this._createAggregationSelect('aggregateAge', 'age'));
    
    this.div.append(this.selectGenderDiv);
    this.div.append(this.selectAgeDiv);
    this.div.append("<br />"); // With a full apology to mnosal until we refactor all of this into proper CSS
    
    this.div.append("group");
    this.groupGenderDiv = $("<div>");
    this.groupGenderDiv.append(this._createCheckBox('groupGender', 'gender')).append('gender');
    this.groupAgeDiv = $("<div>");
    this.groupAgeDiv.append(this._createCheckBox('groupAge', 'age')).append('age');
    
    this.div.append(this.groupGenderDiv);
    this.div.append(this.groupAgeDiv);
  },
  
  _createAggregationSelect: function(field, name) {
    var select = $("<select style='float: right; margin-left: 5px'>");
    
    var aggregationOptions = ["sum","frequency","mean","median","mode"];
    $.each(aggregationOptions, function(index, value) {
      var option = $("<option>", { "value" : value }).append(value);
      select.append(option);
    });
    
    select.val(this[field][0]).selected = true;
    
    var self = this;
    select.change(function(event) {
      self[field] = [this.value];
      self._update();
    });
    return select;
  },
  
  _createCheckBox: function(field, name) {
    var checked = '';
    if (this[field]) {
      checked = "checked='true'";
    }

    var check = $("<input type='checkbox' name='" + name + "' value='" + name + "' " + checked + " />");
    
    var self = this;
    check.change(function(event) {
      self[field] = this.checked;
      self._update();
    });
    
    return check;
  },
  
  _update: function() {
    var selections = [];
    var groups = [];
    
    if (this.selectGender)
      selections.push(new queryStructure.Selection('gender', 'gender', this.aggregateGender))
    if (this.selectAge)
      selections.push(new queryStructure.Selection('age', 'age', this.aggregateAge));
    
    if (this.groupGender)
      groups.push(new queryStructure.Group('gender', 'gender'));
    if (this.groupAge)
      groups.push(new queryStructure.Group('age', 'age'));
    
    query.extract = new queryStructure.Extraction(selections, groups);
  }
});