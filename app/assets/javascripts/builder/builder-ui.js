builder = builder || {};

builder.generateJson = function() {
  var demographics = []
  $('.demographics_toggle:checked').each(function(index) {
    var demographic = {}
    demographic.id = $(this).attr('id');
    demographic.comparison = $('#'+demographic.id+'_comparison').val();
    demographic.value = $('#'+demographic.id+'_value').val();
    
    demographics.push(demographic);
  });

  query = new queryBuilder.Query();
  and = query.filter.add(new queryBuilder.And());

  for (index in demographics) {
    var demographic = demographics[index];
    and.add(new queryBuilder.Comparison('demographics', demographic.id, demographic.id, demographic.value, demographic.comparison));
  }
  
  return JSON.stringify(query.toJson());
};