find = {}
filter = {}

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
  return find.test(patient);

filter: (patient) ->
  return filter.test(patient);

emit_patient: (patient) ->
  emit(generate_key(patient), generate_values(patient));