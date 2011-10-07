function map(patient) {

  var outpatientEncounterCodes = {
    "CPT": [
      "99201", "99202", "99203", "99204", "99205", "99211", "99212", "99213", "99214", 
      "99215", "99217", "99218", "99219", "99220", "99241", "99242", "99243", "99244", 
      "99245", "99341", "99342", "99343", "99344", "99345", "99347", "99348", "99349", 
      "99350", "99384", "99385", "99386", "99387", "99394", "99395", "99396", "99397", 
      "99401", "99402", "99403", "99404", "99411", "99412", "99420", "99429", "99455", 
      "99456"
    ],
    "ICD-9-CM": [
      "V70.0", "V70.3", "V70.5", "V70.6", "V70.8", "V70.9"
    ]
  };
  
  var pneumococcalMedicationCodes = {
    "RxNorm": [
      "854931", "854933", "854935", "854937", "854939", "854941", "854943", "854945",
      "854947", "854949", "854951", "854953", "854955", "854957", "854959", "854961",
      "854963", "854965", "854967", "854969", "854971", "854973", "854975", "854977",
      "854981"
    ]
  };
  
  var pneumococcalProcedureCodes = {
    "CVX": [
      "33", "100", "133"
    ],
    "CPT": [
      "90669", "90670", "90732"
    ]
  };
  
  var start = new Date(2010,1,1);
  var end = new Date(2010,12,31);

  function population(patient) {
    return (patient.age(start)>=64);
  }
  
  function denominator(patient) {
    var encounters = patient.encounters().match(
      outpatientEncounterCodes, start, end).length;
    return (encounters>0);
  }
  
  function numerator(patient) {
    var medication = patient.medications().match(
      pneumococcalMedicationCodes, null, end).length;
    var procedure = patient.procedures().match(
      pneumococcalProcedureCodes, null, end).length;
    return medication || procedure;
  }
  
  function exclusion(patient) {
    return false;
  }
  
  if (population(patient)) {
    emit("p", 1);
    if (denominator(patient)) {
      if (numerator(patient)) {
        emit("d", 1);
        emit("n", 1);
      } else if (exclusion(patient)) {
        emit("e", 1);
      } else {
        emit("d", 1);
      }
    }
  }
}

function reduce(criteria, counts) {
  var sum = 0;
  for(var i in counts)
    sum += counts[i];
  return sum;
};