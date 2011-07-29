function map(patient) {
	
	/************************************************************************************************
	*                                                                                               *
	*                                  BEGIN AUTOMATED SECTION HERE                                 *
	*                                                                                               *
	************************************************************************************************/
	
	var bilateralMastectomyCodes = {
		"ICD-9-CM": [
			"85.42", "85.44", "85.46", "85.48"
		],
		"SNOMED-CT": [
			"14693006", "14714006", "17086001", "172046003", "172049005", "22418005", "237370008", "27865001", "287654001",
			"359734005", "359740003", "367502008", "384723003", "395165008", "52314009", "59860000", "60633004", "66398006",
			"76468001"
		]
	};
	
	var breastCancerScreeningCodes = {
		"ICD-10-CM": [
			"Z12.31"
		],
		"SNOMED-CT": [
			"12389009", "241055006", "241056007", "241057003", "241058008", "241189009", "241539009", "24623002", "258172002",
			"35482003", "418074003", "418378007", "43204002", "439324009", "71651007"
		],
		"CPT": [
			"76090", "76091", "76092", "77055", "77056", "77057"
		],
		"HCPCS": [
			"G0202", "G0204", "G0206"
		],
		"ICD-9-CM": [
			"87.36", "87.37", "V76.11", "V76.12"
		]
	};
	
	var encounterOutpatientCodes = {
		"ICD-9-CM": [
			"V70.0", "V70.3", "V70.5", "V70.6", "V70.8", "V70.9"
		],
		"CPT": [
			"99201", "99202", "99203", "99204", "99205", "99211", "99212", "99213", "99214",
			"99215", "99217", "99218", "99219", "99220", "99241", "99242", "99243", "99244",
			"99245", "99341", "99342", "99343", "99344", "99345", "99347", "99348", "99349",
			"99350", "99384", "99385", "99386", "99387", "99394", "99395", "99396", "99397",
			"99401", "99402", "99403", "99404", "99411", "99412", "99420", "99429", "99455",
			"99456"
		]
	};
	
	var unilateralMastectomyCodes = {
		"CPT": [
			"19180", "19200", "19220", "19240", "19303", "19304", "19305", "19306", "19307"
		],
		"ICD-9-CM": [
			"85.41", "85.43", "85.45", "85.47"
		],
		"SNOMED-CT": [
			"172043006", "172044000", "237367009", "237368004", "274957008", "287653007", "318190001", "359728003", "359731002",
			"395702000", "406505007", "41104003", "428564008", "428571003", "429400009", "70183006"
		]
	};
	
	var bilateralMastectomyModifierCodes = {
		"CPT-Mod": [
			"09950", ".50"
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
		return (patient.age(start) >= 41 && patient.age(start) <= 68);
	}
	
	function denominator(patient) {
		return (
			patient.encounters().match(encounterOutpatientCodes, addDate(end, -2), end) &&
			(
				!patient.procedures().match(bilateralMastectomyCodes, null, end) ||
				(
					patient.procedures().match(unilateralMastectomyCodes, null, end) <= 1 &&
					!patient.procedures().match(bilateralMastectomyModifierCodes, null, end)
				)
			)
		);
	}
	
	function numerator(patient) {
		return patient.procedures().match(breastCancerScreeningCodes, addDate(end, -2), end);
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