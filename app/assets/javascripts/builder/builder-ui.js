var builderUI = builderUI || {};

builderUI.generateJson = function() {
  query = new queryStructure.Query();
  query.find = builderUI.buildWhere('find');
  query.filter = builderUI.buildWhere('filter');
  query.select = builderUI.buildSelect();
  query.group = builderUI.buildGroupBy();
  query.aggregate = builderUI.buildAggregate();

  return JSON.stringify(query.toJson());
};


builderUI.buildWhere = function(category) {
  var demographics = []
  $('#'+category+' input:checked').each(function(index) {
    var demographic = {}
    demographic.id = $(this).attr('key');
    demographic.comparison = $('#'+category+'_'+demographic.id+'_comparison').val();
    demographic.value = $('#'+category+'_'+demographic.id+'_value').val();
    
    demographics.push(demographic);
  });
  
  var root = new queryStructure.And();
  bottom = root.add(new queryStructure.Or());
  bottom = bottom.add(new queryStructure.And())

  for (index in demographics) {
    var demographic = demographics[index];
    bottom.add(new queryStructure.Comparison('demographics', demographic.id, demographic.id, demographic.value, demographic.comparison));
  }
  
  return root;
};

builderUI.buildSelect = function() {
  fields = [];
  $('#extract input:checked').each(function(index) {
    key = $(this).attr('key');
    field = new queryStructure.Field(key, key);
    
    fields.push(field);
  });
  return fields;
};

builderUI.buildGroupBy = function() {
  fields = []
  $('#extract select').each(function(index) {
    key = $(this).val();
    if (key != '--select--') {
      field = new queryStructure.Field(key, key);
      fields.push(field);
    }
  });
  return fields;
};

builderUI.buildAggregate = function() {
  fields = [];
  $('#aggregate input:checked').each(function(index) {
    key = $(this).attr('key');
    field = new queryStructure.Field(key, key);
    fields.push(field);
  });
  return fields;
};
