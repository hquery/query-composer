filter = {};

map: (patient) ->
  if (find(patient))
    if (filter(patient))
      emit('target_pop', 1);
    else
      emit('filtered_pop', 1);
  else
    emit('unfound_pop', 1);
  emit('total_pop', 1);

passes_find: (patient) ->
  return true;

passes_filter: (patient) ->
  return filter.test(patient);    

map: (patient) ->
  if (passes_find(patient))
    if (passes_filter(patient))
      emit('target_pop', 1);
    else
      emit('filtered_pop', 1);
  else
    emit('unfound_pop', 1);
  emit('total_pop', 1);
