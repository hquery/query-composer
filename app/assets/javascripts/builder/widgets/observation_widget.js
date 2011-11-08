

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
    _detailsFields : {'allergies' : {
          descriptor : {
                    valueText : "reaction is"
                    },
      variability : {options: [ 
                    {label : "mild", value:"1"},
                    {label : "mild to moderate", value:"2"},
                    {label : "moderate", value:"3"},
                    {label : "moderate to severe",value:"4"},
                    {label : "severe",value:"5"},
                    {label : "fatal",value:"6"}
                    ]},
                    
      dateDescriptor : "recorded from",
      dateVariability : {options: [
        {label:"active",value:"active"},
        {label:"notactive",value:"notactive"}
        ]
        },
      startDate: "05/11/2011",
      endDate : "09/18/2011"
      },
      'vitals' :  {
      descriptor : {options: [ 
                    {label : "highest", value:"hi"},
                    {label : "lowest", value:"lo"},{label : "most recent",value:"mr"}
                    ],
                    valueText : "value is"
                    },
      variability : {options:[
                      {label:"between",value:"bt"},
                      {label:"exactly",value:"ex"},
                      {label:"greater than", value:"gt"},
                      {label:"less than",value:"lt"}
                      ],
                      minValue:100,
                      maxValue:250},
      dateDescriptor : "recorded from",
      startDate: "05/11/2011",
      endDate : "09/18/2011"
      }
    },
  _create:function(){
    this.container = this.options.container;
    var self = this;
    this.div = $("<div>");
    $("<h2>").text("Observations").appendTo(this.div);

    this.vitalSignRule = this.findRuleByName("VitalSignRule");
    this.allergyRule = this.findRuleByName("allergies");

    var code = (this.allergyRule) ? this.allergyRule.data.code : null;
   // this.functionalStatusRule = this.findRuleByName("functionalStatus");
    this.vitalsDiv = $("<p>").VitalsEditor({parent:this, rule:this.vitalSignRule});
    $(this.vitalsDiv).data("type","vitals");
    this._appendOptions(this.vitalsDiv);
    this.allergiesDiv = $("<p>").CodeList({title:"Allergies",type:"allergy",selected:code, onChange:function(code,event){self.allergyRule = new queryStructure.CodeSetRule({type:"allergies",code:code}); self._update();}});
    $(this.allergiesDiv).data("type","allergies");
    this._appendOptions(this.allergiesDiv);
    //this.funcionalStatusDiv = $("<div>").CodeList({title:"Race",type:"functional_status",selected:this.functionalStatusCode, onChange:function(code,event){self.functionalStatusCode = code; self.set(new queryStructure.CodeSetRule({type:"functional_status",code:code}))}});
    
    this.div.append(this.funcionalStatusDiv);
    this.div.append(this.allergiesDiv);
    this.div.append(this.vitalsDiv);
    
    this.element.append(this.div);
  },
  _appendOptions:function(e) {
    var dataType = $(e).data("type");
    var _self = this;
        var dpOptions = {showOn: "button",
			buttonImage: "/assets/cal20.png",
			buttonText: "Select date",
			buttonImageOnly: true};
			
    var showDetails = function(e) {
      var toggleVariabilityFields = function(d) {
      $(d).find("#variabilityLabel").change(function() {
        if ($(this).val() != "bt") {
          $("#variabilityMin").show().siblings("span.sep").hide();
          $("#variabilityMax").hide();
        } else {
          $("#variabilityMin,#variabilityMax,span.sep").show();
        }
      });
      
      $("#variabilityLabel").trigger("change");
      
    } // end toggleVariabilityFields
    $(".optLink a").removeClass("sel");
    $(this).addClass("sel");
    
      var dlg = $("#detailsDialogTemplate").tmpl(_self._detailsFields[$(this).data("type")]);
      $(dlg).find("input.datePicker").datepicker(dpOptions).end();
      $("#detailDialog").html(dlg);
      toggleVariabilityFields(dlg);
      
      $("#detailDialog").position({of:$(this),my:"left bottom",at:"right bottom",offset:"5 10"});
    }
    var a = $("<a>").text("options").attr("href","#").css("display","inline").data("type",dataType).click(showDetails);
    var optLink = $("<div>").addClass("optLink").append(a);
    
    $(e).append(optLink);
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