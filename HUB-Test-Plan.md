##SCOOPHEALTH Infrastructure Testing Methodology

#Infrastructure Overview

There are 4 major components in the SCOOPHEALTH infrastructure.  These consist of the:

  - Importer Library (health-data-standards)
  - Endpoint (query-gateway)
  - Patient API (patientapi)
  - Hub (query-composer)
  
## Importer Library
The health-data-standards ([HDS]) library  used by SCOOPHEALTH is a fork of [Project Cypress] which is still undergoing rapid development.  The SCOOPHEALTH fork was made on Nov 15, 2012.  Since then the major changes to the SCOOPHEALTH fork have been migration from Ruby 1.9.2 to 1.9.3 and the addition of E2E importer code.

The health-data-standards library uses the Ruby Gem "minitest" to support test-driven development (TDD) and a mock-object framework.  The E2E importer has extensive unit testing of all the sections of the E2E document.  These tests are ran against test patient data, verifying that known information is imported correctly.  This makes refactoring of the HDS E2E importer code much easier and ensures that code changes required for consistency with changing E2E document specifications are made.

## Endpoint
Ongoing [endpoint] code development is taking place in the Scoophealth fork of [query-gateway]. Visitors to the hquery site are now advised to use the Scoophealth fork for updated code.  Major changes include migration from Ruby 1.9.2 to 1.9.3 and mongoid 2.0 to mongoid 3.0.6 (for consistentancy with health-data-standards). The query-gateway code also uses the "minitest" framework which makes refactoring and tracking of the evolving E2E standard easier.  Testing consists of 1) functional testing to verify that E2E test patient documents can be loaded into the MongoDB records collection and that information from the patient records can be retrieved successfully, and 2) integration testing of the E2E importer verifying that data loaded into the database can be retrieved using Javascript methods provided by the patientapi library.  Each section of the E2E document imported by the HDS E2E importer is tested.  All code relevant to E2E has 100% code coverage.  Test scripts based on PDC and scoophealth queries are ran to ensure that output remains consistent with past results.

## Patient API
The SCOOPHEALTH [patientapi] library code is a fork of the [pophealth-patientapi] branch which was forked from the [hquery-patientapi] code base.  The hquery codebase is no longer updated and the pophealth code base is updated infrequently.  The scoophealth fork tracks any changes relevant to E2E.  The primary difference from the pophealth codebase is support for regular expressions in coded values and the addition of tests specific to E2E documents.  All "minitest"-based tests performed on imported CDA documents are also executed against E2E documents and the results are compared with expected E2E test patient information.

## Hub
The [hub]  code is a fork of [query-composer]. The hquery site now redirects visitors to the scoophealth fork for updated code.  Major changes to the code relate to migration from Ruby 1.9.2 to 1.9.3, mongoid from 2.3.4 to 3.1.4, and rails from 3.1.3 to  3.2.7.  The query-composer code has extensive "minitest" code coverage based on functional testing of the Rails controllers, unit tests of hub functionality, and integration tests of query aggregation and user access control.  None of these tests are specific to E2E because once the data is stored in the endpoint database in a format queryable by the patientapi, the details of which importer was used to obtain the data is hidden.

[HDS]:https://github.com/scoophealth/health-data-standards "health-data-standards"

[Project Cypress]: http://projectcypress.org/

[Endpoint]: https://github.com/hquery/query-gateway "scoop query-gateway"

[query-gateway]: https://github.com/hquery/query-gateway "hquery gateway"

[patientapi]: https://github.com/scoophealth/patientapi "Patient API"

[pophealth-patientapi]: https://github.com/pophealth/patientapi "Pophealth patientapi"

[hquery-patientapi]: https://github.com/pophealth/patientapi "hquery patientapi"

[hub]: https://github.com/scoophealth/query-composer "scoop query-composer"

[query-composer]: https://github.com/hquery/query-composer "hquery query-composer"
