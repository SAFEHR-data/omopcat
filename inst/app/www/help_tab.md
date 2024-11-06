# `omopcat` help

`omopcat` is for viewing OMOP concept data available.

It allows you to

* View a summary of OMOP data available (minimum time period 1 month, no Confidential Patient Information)
* Search available OMOP data
* Get an indication of the frequency of records and patients for each concept
* Export a list of selected concepts that can be used in the omop_es extraction system

## Using `omopcat`

There are four tabs at the top: **Concepts, Bundles, Export & help**.

### Side bar

The side bar (visible in each tab) exposes the following elements:

1. The **Date range** slider allows to filter available concepts with records for the given date range.
1. The **Select bundle** drop-down menu to select a group of related concepts (more info [below](#bundles-tab))
1. The **"Add current selection to export"** button adds the currently selected concepts to the export (more info [below](#export-tab))
1. The **Concepts selected for export** keeps track of the number of concepts selected for export

### Concepts tab

The **Concepts Overview** table gives an overview of all available concepts. Users can click on rows
in this table to visualise the summary statistics for the selected concept(s) in the plots below:

* The Monthly Records plots shows the number of records in each month for the selected concepts over
the specified date range
* The Summary Statistics plot shows a box plot or bar chart if the selected concepts have numeric
 or categorical data, respectively

Note that the Summary Statistics plots may be empty in case the selected concept(s) do not contain
any numeric data.

The **Concepts overview** table also reports the number of records (`Records`) and Patients (`Patients`)
for each concept. These values are updated for the chosen date range.

**Note**: to ensure patients are not identifiable, low counts are converted to a dummy decimal number.

To add concepts to the export, select them in the overview table and then click the
"Add current selection to export" button in the side bar. Note that unselecting a row, does _not_
remove it from the export. So you can interactively explore different sets of concepts without
them being removed from the export.

### Bundles tab

The **Bundles overview** table shows an overview of the available Bundles (groups of related concepts) 
and the number of concepts included.
Clicking a row in this table will select the bundle in the drop-down menu in the side bar and also
select all included concepts in the Concepts tab for visualisation.

To add a bundle of concepts to the export:

1. Select the desired bundle
1. Click the "Add current selection to export" button

Note that the drop-down box also allows typing, so you can search for a bundle by typing its name
in the box.

### Export tab

The export tab gives a summary of the concepts selected for exports and gives a preview of the
table that will be exported to CSV.

Clicking the **Export CSV** button will download a CSV file of this table to the user's Downloads
directory. This table can subsequently be used in the `omop_es` extraction system.

## How `omopcat` works

`omopcat` has a pre-processing step that summarises an OMOP extraction by calculating monthly counts
for all concepts. These monthly counts are used by the `omopcat` app to enable users to query data
availability by concept.

## Contact

https://github.com/SAFEHR-data/omopcat

If you encounter any issues with the app, feel free to
[open an issue on GitHub](https://github.com/SAFEHR-data/omopcat/issues/new).

`omopcat` is made by the SAFEHR-data development team at UCLH and UCL supported by the
[UCLH Biomedical Research Centre](https://www.uclhospitals.brc.nihr.ac.uk/).


## Licence

Copyright 2024 UCLH SAFEHR-data

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
