### omopcat is for viewing OMOP concept data available.

<br> <br>

#### omopcat allows you to :

* view a summary of OMOP data available (minimum time period 1 month, no Confidential Patient Information)
* search available OMOP data
* get an indication of the frequency of records and patients for each concept
* export a list of selected concepts that can be used in the omop_es extraction system

#### using omopcat   

There are four tabs at the top : **Concepts, Bundles, Export & help**

##### Concepts tab

1. On the left **Select bundle** to select a group of related concepts to appear in the **Select concepts** box. 
1. In the **Select concepts** box delete and re-add concepts to set which appear in the **Export** tab.
1. Set a **Date range** to calculate record and patient counts in the **Concepts overview** table. 
1. Select row(s) in the **Concepts overview** table. Attributes of the top selected concept will be plotted below.


##### Bundles tab

A table shows all Bundles (groups of related concepts) and how many concepts there are in each. Select a concept (row) to populate the **Select bundle** box on the left.

##### Export tab

View concepts that have been selected in the **Select concepts** box and press **Export CSV** to create a text file of selected concepts that can be used in the omop_es extraction system.


#### How omopcat works

omopcat has a pre-processing step that summarises an OMOP extraction by calculating monthly counts for all concepts. These monthly counts are used by the omopcat app to enable users to query data availability by concept.

#### Contact

https://github.com/SAFEHR-data/omop-data-catalogue

omopcat is made by the SAFEHR-data development team at UCLH and UCL supported by the [UCLH
Biomedical Research Centre](https://www.uclhospitals.brc.nihr.ac.uk/).


#### Licence

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
