map: (patient) ->
  if (find(patient))
    if (filter(patient))
      emit('target_pop', 1);
    else
      emit('filtered_pop', 1);
      emit_patient(patient);
  else
    emit('unfound_pop', 1);
  emit('total_pop', 1);

find: (patient) ->
  return true;

filter: (patient) ->
  return filter.test(patient);    

