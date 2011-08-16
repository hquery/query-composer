builder = builder || {};

builder.generateJson = function() {
  
  query = new queryBuilder.Query();
  query.find = builder.buildWhere('find');
  query.filter = builder.buildWhere('filter');
  query.select = builder.buildSelect();
  query.group = builder.buildGroupBy();
  query.aggregate = builder.buildAggregate();
  
  return JSON.stringify(query.toJson());
};


builder.buildWhere = function(category) {
  var demographics = []
  $('#'+category+' input:checked').each(function(index) {
    var demographic = {}
    demographic.id = $(this).attr('key');
    demographic.comparison = $('#'+category+'_'+demographic.id+'_comparison').val();
    demographic.value = $('#'+category+'_'+demographic.id+'_value').val();
    
    demographics.push(demographic);
  });

  or = new queryBuilder.Or();
  and = or.add(new queryBuilder.And());

  for (index in demographics) {
    var demographic = demographics[index];
    and.add(new queryBuilder.Comparison('demographics', demographic.id, demographic.id, demographic.value, demographic.comparison));
  }
  
  return or;
};

builder.buildSelect = function() {
  fields = []
  $('#extract input:checked').each(function(index) {
    key = $(this).attr('key');
    field = new queryBuilder.Field(key, key)
    
    fields.push(field);
  });
  return fields;
};

builder.buildGroupBy = function() {
  fields = []
  $('#extract select').each(function(index) {
    key = $(this).val();
    if (key != '--select--') {
      field = new queryBuilder.Field(key, key)
      fields.push(field);
    }
  });
  return fields;
};

builder.buildAggregate = function() {
  fields = []
  $('#aggregate input:checked').each(function(index) {
    key = $(this).attr('key');
    field = new queryBuilder.Field(key, key)
    fields.push(field);
  });
  return fields;
};
