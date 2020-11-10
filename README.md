# [Read the docs](https://nycparks-data.github.io/Structures/)
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

At a later stage of this project the **[ParksGIS].[DPR].[StructureLandmarks]** will be updated through an ETL that matches data from the NYC Landmark Preservation Commission (LPC) to a Parks structure based on the BIN.

The following tables are related to the [ParksGIS].[DPR].[Structure] through the SYSTEMID column. They will contain information that is managed by divisions or individuals at NYC Parks.

**[ParksGIS].[DPR].[StructureForm]** - The shape or configuration of a structure. Some examples include: air-supported, building and stadia. 

**[ParksGIS].[DPR].[StructureFunction]** - The intended use of a structure. Some examples include: comfort station, recreation center and food service.

**[ParksGIS].[DPR].[StructurePIP]** - Information specific to the Parks Inspection Program (PIP) that is not required to be stored in the main Structure table.

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
### NYC Parks
Structures
 - This is a feature class within our internal, enterprise geographic information system (ParksGIS). In addition to the attributes updated through this ETL, there are additional attributes that are managed by individuals or divisions within NYC Parks.
 
### NYC DoITT
[Building Footprints](https://data.cityofnewyork.us/Housing-Development/Building-Footprints/nqwf-w8eh#About)
 - [Data Documentation](https://github.com/CityOfNewYork/nyc-geo-metadata/blob/master/Metadata/Metadata_BuildingFootprints.md)
 - [Capture Rules Documentation](https://github.com/CityOfNewYork/nyc-planimetrics/blob/master/Capture_Rules.md)
 
### NYC Planning
[Geosupport](https://geoservice.planning.nyc.gov/)
- Presumably this only available to New York City Agencies Only
- [Function BIN Documentation](https://geoservice.planning.nyc.gov/FunctionBIN)
- [Function 1B Documentation](https://geoservice.planning.nyc.gov/Function1B)
- [Related GOAT Documentation](http://a030-goat.nyc.gov/goat)

## Attribute Table
| Attribute              | Description       | Generative Process   | Derived from Another Source | Source Data Owner / Modifier |
|------------------------|-------------------|----------------------|-----------------------------|------------------------------|
| **SYSTEM**           | Unique Parks ID of the Structure  |          | No     |               | IT/GIS
| **BIN**              | Building Identification Number. A number assigned by City Planning and used by Dept. of Buildings to reference information pertaining to an individual building. The first digit is a borough code (1 = Manhattan, 2 = The Bronx, 3 = Brooklyn, 4 = Queens, 5 = Staten Island). The remaining 6 digits are unique for buildings within that borough. In some cases where these 6 digits are all zeros (e.g. 1000000, 2000000, etc.) the BIN is unassigned or unknown.|          | Yes    |DoITT               |
| **BBL**              |Borough, block, and lot number for the tax lot that the footprint is physically located within.|          | Yes |DoITT            |
| **DOITT_ID**         |Unique identifier assigned by DOITT.|          | Yes    |               |
| **Ground_Elevation** |Lowest Elevation at the building ground level. Calculated from LiDAR or photogrammetrically.|          | Yes    |DoITT               |
| **Height_Roof**      |Building Height is calculated as the difference from the building elevation from the Elevation point feature class and the elevation in the interpolated TIN model. This is the height of the roof above the ground elevation, NOT its height above sea level. Records where this is zero or NULL mean that this information was not available.|          | Yes    |DoITT               |
| **Alteration_Year**  |                                   |          | Yes    |DoITT               |
| **Construction_Year**|The year construction of the building was completed.Originally this column was populated using the Department of Finance Real Property Assessment Database (RPAD). Beginning in 2017 this will be the first year the completed structure is visible in available orthoimagery. Records where this is zero or NULL mean that this information was not available.|          | Yes    |DoITT               |
| **Demolition_Year**  |                                   |          | Yes    |DoITT               |

