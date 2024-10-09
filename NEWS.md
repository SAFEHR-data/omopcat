# omopcat (development version)

# omopcat 0.2.0

This version adds support for OMOP bundles. The app name also changed from `calypso` to `omopcat`.

## Major changes

* Changed app name from `calypso` to `omopcat` (@milanmlft, #64)
* Various updates to the export tab (@tim-band & @milanmlft, #62, #67) 
* Added dropdown menu to select bundles (@BaptisteBR, #72)
* Updated dev and test data with concepts for which we have bundle information (@milanmlft, #74)
* The concepts table overview now always shows all available concepts (@milanmlft, #80)
* The concepts table now also shows the number of patients and records for each concept(@andysouth, #67)
* Added a new tab to display bundles (@milanmlft, #78)
* Added support for visualising multiple concepts simultaneously (@milanmlft, #81)
* Add a new tab with user manual (@andysouth & @milanmlft, #71)

## Minor changes and bug fixes

* Set up code coverage checking (@milanmlft, #66)
* Set up pre-commit (@milanmlft, #68)
* Refactored the plots module (@milanmlft, #77)
* Set default ggplot2 theme with larger font size (@milanmlft, #82)

**Full Changelog**: https://github.com/SAFEHR-data/omop-data-catalogue/compare/v0.1.0...v0.2.0

# omopcat 0.1.0

The minimal data catalogue.

* Implemented prototype (#3)
* Added preprocessing script to calculate summary statistics (#22)
* Made dashboard reactive to concept selection and date range filtering (#31, #37)
* Added handling of categorical concepts (#32)
* Added setup and use of realistic test data (#24)
* Set up deployment environment (#44, #45)
* Added masking of low-frequency statistics (#51)
