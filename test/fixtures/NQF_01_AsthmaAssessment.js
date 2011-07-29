function map(patient) {
	
	/************************************************************************************************
	*                                                                                               *
	*                                  BEGIN AUTOMATED SECTION HERE                                 *
	*                                                                                               *
	************************************************************************************************/
	
	var asthmaCodes = {
		"ICD-10-CM": [
			"J45", "J45.22", "J45.32", "J45.42", "J45.52", "J45.90", "J45.901", "J45.902", "J45.990",
			"J45.991"
		],
		"ICD-9-CM": [
			"493.00", "493.01", "493.02", "493.10", "493.11", "493.12", "493.20", "493.21", "493.22",
			"493.81", "493.82", "493.90", "493.91", "493.92"
		],
		"SNOMED-CT": [
			"11641008", "12428000", "13151001", "195949008", "195967001", "195977004", "195979001", "196013003", "225057002",
			"233672007", "233678006", "233679003", "233681001", "233683003", "233685005", "233688007", "266361008", "266364000",
			"281239006", "30352005", "304527002", "31387002", "370218001", "370219009", "370220003", "370221004", "389145006",
			"405944004", "407674008", "409663006", "423889005", "424199006", "424643009", "425969006", "426656000", "426979002",
			"427295004", "427354000", "427603009", "427679007", "442025000", "55570000", "56968009", "57546000", "59327009",
			"59786004", "63088003", "67415000", "85761009", "91340006", "92807009", "93432008"
		]
	};
	
	var asthmaDaytimeSymptomsCodes = {
		"SNOMED-CT": [
			"370204008", "373899003"
		]
	};
	
	var asthmaDaytimeSymptomsQuantifiedCodes = {
		"SNOMED-CT": [
			"370202007", "370203002", "370208006"
		]
	};
	
	var asthmaNighttimeSymptomsCodes = {
		"SNOMED-CT": [
			"170631002", "170632009", "170633004", "170634005", "395022009"
		]
	};
	
	var asthmaNighttimeSymptomsQuantifiedCodes = {
		"SNOMED-CT": [
			"170635006", "170636007", "370205009"
		]
	};
	
	var asthmaSymptomAssessmentToolCodes = {
		"SNOMED-CT": [
			"401011001"
		]
	};
	
	var encounterOfficeOutpatientConsultCodes = {
		"CPT": [
			"99201", "99202", "99203", "99204", "99205", "99212", "99213", "99214", "99215",
			"99241", "99242", "99243", "99244", "99245"
		]
	};
	
	/************************************************************************************************
	*                                                                                               *
	*                                   END AUTOMATED SECTION HERE                                  *
	*                                                                                               *
	************************************************************************************************/

	function addDate (date, y, m, d){
		var n = new Date (date);
		n.setFullYear(date.getFullYear() + (y || 0));
		n.setMonth(date.getMonth() + (m || 0));
		n.setDate(date.getDate() + (d || 0));
		return n;
	}
	
	var start = new Date(2010,1,1);
	var end = new Date(2010,12,31);

	function population(patient) {
		return (
			patient.age(start) >= 5 && patient.age(start) <= 40 &&
			patient.conditions().match(asthmaCodes, null, end) &&
			patient.encounters().match(encounterOfficeOutpatientConsultCodes, null, end) >= 2
		);
	}
	
	function denominator(patient) {
		return true;
	}
	
	function numerator(patient) {
		return (
			(
				patient.conditions().match(asthmaDaytimeSymptomsQuantifiedCodes, null, end) &&
				patient.conditions().match(asthmaNighttimeSymptomsQuantifiedCodes, null, end)
			) ||
			(
				patient.conditions().match(asthmaDaytimeSymptomsCodes, null, end) &&
				patient.conditions().match(asthmaNighttimeSymptomsCodes, null, end)
			) ||
			(
				patient.procedures().match(asthmaSymptomAssessmentToolCodes, null, end)
			)
		);
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
	for(var i in counts) sum += counts[i];
	return sum;
};