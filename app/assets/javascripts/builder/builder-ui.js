
var builderUI = builderUI || {};


builderUI.query;

builderUI.generateJson = function() {
  builderUI.query.find = builderUI.buildWhere('find');
  builderUI.query.filter = builderUI.buildWhere('filter');
  builderUI.query.extract = builderUI.buildExtract();
  return JSON.stringify(builderUI.query.toJson());
};

builderUI.repopulateUi = function(json) {
  builderUI.query.rebuildFromJson(json);
  builderUI.repopulateUiZone(builderUI.query.find, 'find');
  builderUI.repopulateUiZone(builderUI.query.filter, 'filter');
  builderUI.repopulateUiZone(builderUI.query.extract, 'extract');
}

builderUI.repopulateUiZone = function(container, category) {
  if (category === 'extract') {
    $('.aggregate_selection').attr('disabled', 'disabled');
    for (var index in container.selections) {
      selection = container.selections[index]
      $('#extract_'+selection['title']).prop('checked', true);
      $('#aggregate_'+selection['title']).val(selection.aggregation);
      $('#aggregate_'+selection['title']).removeAttr('disabled');
    }
    for (var index in container.groups) {
      group = container.groups[index]
      $('#group_'+index).val(group['title']);
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

builderUI.buildExtract = function() {
  selects = builderUI.buildSelections();
  groups = builderUI.buildGroupBy();
  return new queryStructure.Extraction(selects, groups);
};

builderUI.buildSelections = function() {
  selects = [];
  $('#extract input:checked').each(function(index) {
    key = $(this).attr('key');
    aggregation = [$('#aggregate_'+key).val()];
    if (aggregation[0] != '--select--') {
      select = new queryStructure.Selection(key, key, aggregation);
      selects.push(select);
    } else {
      alert('Extraction for ' + key + ' will be skipped because it was not aggregated')
    }
  });
  return selects
};

builderUI.buildGroupBy = function() {
  groups = []
  $('#group select').each(function(index) {
    key = $(this).val();
    if (key != '--select--') {
      group = new queryStructure.Group(key, key);
      groups.push(group);
    }
  });
  return groups;
};
