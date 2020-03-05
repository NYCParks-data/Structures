# Structures
This project updates attributes in the NYC Parks **[ParksGIS].[DPR].[Structure]** dataset and its related tables by pulling values from 
authoritative sources outside of the agency. Currently, the following fields are updated in the ParksGIS Structure layer weekly 
via an automated process:

**BIN**

**BBL**

**DOITT_ID**

**Ground_Elevation**

**Height_Roof**

**Alteration_Year**

**Construction_Year**

**Demolition_Year**


Additionally, the following related table(s) are currently being populated/updated via a weekly ETL:

**[ParksGIS].[DPR].[StructureGeosupport]**

Finally, the following related table(s) will soon be populated/updated via a similar process:

**[ParksGIS].[DPR].[StructureForm]**

**[ParksGIS].[DPR].[StructureFunction]**

**[ParksGIS].[DPR].[StructureLandmarks]**

**[ParksGIS].[DPR].[StructurePIP]**

## Data Product Overview: Structures
Currently, this dataset includes structures on NYC Parks properties that are broadly defined as *an assembly of materials 
forming construction for occupancy or use*. 

The current schema includes attributes that are both no longer maintained as well as attributes that are 
maintained by parties outside of NYC Parks. In the coming months, we hope to eliminate the former (fields 
that are no longer maintained by anyone) while attributes for which we have identified authoritative sources 
will be updated via a weekly ETL script (details can soon be found in the wiki).


## Purpose of this document
The purpose of this data product overview is to identify and describe the
attributes within Structures that are derived from other data sources and are updated internally via an automated
ETL script. This document also identifies the source systems, tables, fields, as well as the owners of 
those source fields. 

## Data Sources
This ETL pulls data from several sources that are considered to be the authority for particular attributes.

### DoITT
[Building Footprints](https://data.cityofnewyork.us/Housing-Development/Building-Footprints/nqwf-w8eh#About)
 - [Documentation](https://github.com/CityOfNewYork/nyc-geo-metadata/blob/master/Metadata/Metadata_BuildingFootprints.md)
 
### DCP
[DCP]()
-

## Attribute Table
| Attribute              | Description       | Generative Process   | Derived from Another Source | Source Data Owner / Modifier |
|------------------------|-------------------|----------------------|-----------------------------|------------------------------|
| **SYSTEM**           | Unique Parks ID of the Structure  |          | No     |               | IT/GIS
| **BIN**              |                                   |          | Yes    |               |
| **BBL**              |                                   |          | Yes    |               |
| **DOITT_ID**         |                                   |          | Yes    |               |
| **Ground_Elevation** |                                   |          | Yes    |               |
| **Height_Roof**      |                                   |          | Yes    |               |
| **Alteration_Year**  |                                   |          | Yes    |               |
| **Construction_Year**|                                   |          | Yes    |               |
| **Demolition_Year**  |                                   |          | Yes    |               |

