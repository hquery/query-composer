(function() {
  /**
  @class Representation of a patient
  */  this.Patient = (function() {
    /**
    @constructs
    */    function Patient(json) {
      this.json = json;
    }
    /**
    @returns {String} containing M or F representing the gender of the patient
    */
    Patient.prototype.gender = function() {
      return this.json['gender'];
    };
    /**
    @returns {String} containing the patient's given name
    */
    Patient.prototype.given = function() {
      return this.json['first'];
    };
    Patient.prototype.family = function() {
      return this.json['last'];
    };
    /**
    @returns {Date} containing the patient's birthdate
    */
    Patient.prototype.birthtime = function() {
      return dateFromUtcSeconds(this.json['birthdate']);
    };
    /**
    @returns {Array} A list of {@link Encounter} objects
    */
    Patient.prototype.encounters = function() {
      var encounter, _i, _len, _ref, _results;
      _ref = this.json['encounters'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        encounter = _ref[_i];
        _results.push(new Encounter(encounter));
      }
      return _results;
    };
    /**
    @returns {Array} A list of {@link Medication} objects
    */
    Patient.prototype.medications = function() {
      var medication, _i, _len, _ref, _results;
      _ref = this.json['medications'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        medication = _ref[_i];
        _results.push(new Medication(medication));
      }
      return _results;
    };
    /**
    @returns {Array} A list of {@link Condition} objects
    */
    Patient.prototype.conditions = function() {
      var condition, _i, _len, _ref, _results;
      _ref = this.json['conditions'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        condition = _ref[_i];
        _results.push(new Condition(condition));
      }
      return _results;
    };
    /**
    @returns {Array} A list of {@link Procedure} objects
    */
    Patient.prototype.procedures = function() {
      var procedure, _i, _len, _ref, _results;
      _ref = this.json['procedures'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        procedure = _ref[_i];
        _results.push(new Procedure(procedure));
      }
      return _results;
    };
    /**
    @returns {Array} A list of {@link Result} objects
    */
    Patient.prototype.results = function() {
      var result, _i, _len, _ref, _results;
      _ref = this.json['results'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        _results.push(new Result(result));
      }
      return _results;
    };
    /**
    @returns {Array} A list of {@link Result} objects
    */
    Patient.prototype.vitalSigns = function() {
      var vital, _i, _len, _ref, _results;
      _ref = this.json['vital_signs'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        vital = _ref[_i];
        _results.push(new Result(vital));
      }
      return _results;
    };
    return Patient;
  })();
}).call(this);
