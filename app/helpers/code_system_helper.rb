module CodeSystemHelper
  # General helpers for working with codes and code systems
  # Based on abandoned code from quality-measure-engine (1.0.4)
  # http://github.com/pophealth/quality-measure-engine.git
  # revision: 6573859d0d8ca8d76e6dc2f0d4d15181c8457c61
  # branch: develop
  class CodeSysHelper
    CODE_SYSTEMS = {
        '2.16.840.1.113883.6.1' =>    'LOINC',
        '2.16.840.1.113883.6.96' =>   'SNOMED-CT',
        '2.16.840.1.113883.6.12' =>   'CPT',
        #'2.16.840.1.113883.3.88.12.80.32' => 'CPT',
        '2.16.840.1.113883.6.88' =>   'RxNorm',
        '2.16.840.1.113883.6.103' =>  'ICD-9-CM',
        '2.16.840.1.113883.6.104' =>  'ICD-9-CM',
        '2.16.840.1.113883.6.90' =>   'ICD-10-CM',
        '2.16.840.1.113883.6.14' =>   'HCPCS',
        '2.16.840.1.113883.6.59' =>   'CVX',
        '2.16.840.1.113883.6.238' =>   'CDC-RE',
        '2.16.840.1.113883.5.83' => 'HITSP C80 Observation Status',
        '2.16.840.1.113883.3.26.1.1' => 'NCI Thesaurus',
        '2.16.840.1.113883.3.88.12.80.20' => 'FDA',
        '2.16.840.1.113883.5.14' => 'HL7 ActStatus',
        '2.16.840.1.113883.6.259' => 'HL7 Healthcare Service Location',
        '2.16.840.1.113883.5.4' => 'HL7 Act Code',
        '2.16.840.1.113883.1.11.18877' => 'HL7 Relationship Code',
        '2.16.840.1.113883.6.238' => 'CDC Race',
        '2.16.840.1.113883.5.1105' => 'HC-DIN',
        '2.16.840.1.113883.6.63' => 'FDDC',
        '2.16.840.1.113883.6.73' => 'whoATC',
        '2.16.840.1.113883.6.42' => 'ICD9',
        '2.16.840.1.113883.3.1818.10.2.8.2' => 'PITO AllergyClinicalStatus',
        '2.16.840.1.113883.2.20.3.78' => 'ObservationInterpretation',
        '2.16.840.1.113883.2.20.5.1' => 'pCLOCD',
        '2.16.840.1.113883.3.3068.10.6.3' => 'ObservationType-CA-Pending'
    }

    # Returns the name of a code system given an oid
    # @param [String] oid of a code system
    # @return [String] the name of the code system as described in the measure definition JSON
    def self.code_system_for(oid)
      CODE_SYSTEMS[oid] || "Unknown"
    end

    # Returns the oid for a code system given a codesystem name
    # @param [String] the name of the code system
    # @return [String] the oid of the code system
    def self.oid_for_code_system(code_system)
      CODE_SYSTEMS.invert[code_system]
    end

    # Returns the whole map of OIDs to code systems
    # @terurn [Hash] oids as keys, code system names as values
    def self.code_systems
      CODE_SYSTEMS
    end
  end


end