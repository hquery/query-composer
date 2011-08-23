
var builderUI = builderUI || {};


builderUI.query;

builderUI.generateJson = function() {
  builderUI.query.find = builderUI.buildWhere('find');
  builderUI.query.filter = builderUI.buildWhere('filter');
  builderUI.query.select = builderUI.buildSelect();
  builderUI.query.group = builderUI.buildGroupBy();
  builderUI.query.aggregate = builderUI.buildAggregate();

  return JSON.stringify(builderUI.query.toJson());
};

builderUI.repopulateUi = function(json) {
  builderUI.query.rebuildFromJson(json);
  builderUI.repopulateUiZone(builderUI.query.find, 'find');
  builderUI.repopulateUiZone(builderUI.query.filter, 'filter');
  builderUI.repopulateUiZone(builderUI.query.select, 'extract');
  builderUI.repopulateUiZone(builderUI.query.aggregate, 'aggregate');
  builderUI.repopulateUiZone(builderUI.query.group, 'group');
}

builderUI.repopulateUiZone = function(container, category) {
  if (category === 'group') {
    for (var index in container) {
      selection = container[index]
      $('#'+category+'_'+index).val(selection['title']);
    }
  } else if (category === 'extract' || category === 'aggregate') {
    for (var index in container) {
      checkbox = container[index]
      $('#'+category+'_'+checkbox['title']).prop('checked', true);
    }
  } else {
    if (container.name != undefined) {
      for (var c in container.children) {
        var comparison = container.children[c];
        $('#' + category + '_' + comparison.title).prop('checked', true);
        $('#' + category + '_' + comparison.title + '_comparison').val(comparison.comparator);
        $('#' + category + '_' + comparison.title + '_value').val(comparison.value);
      }
    } else {
      for (var c in container.children) {
        builderUI.repopulateUiZone(container.children[c], category);
      }
    }
  }
}

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
  bottom = bottom.add(new queryStructure.And(bottom, null, 'demographics'));

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
