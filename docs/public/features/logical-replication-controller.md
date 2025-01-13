This section describes features of the Logical Replication Controller.
* [Overview](#overview)
* [Replication Service API](#replication-service-api)
  * [Create publication](#create-publication)
  * [Alter Add publication](#alter-add-publication)
  * [Alter Set publication](#alter-set-publication)
  * [Get publication](#get-publication)
  * [Drop publication](#drop-publication)
  * [Grant User](#grant-user)

# Overview

This service allows to set up and manage publications on postgres. Also this service provides an ability to grant user for replication.

# Replication Service API

## Create publication
```
POST /publications/create
```


### Description
Create publication. If schemas and tables are empty publication will be created for all tables.


### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**publication**  <br>*required*|Data for publication create|[publication](#publication)|

#### Publication

|Name|Description|Schema|
|---|---|---|
|**publicationName**  <br>*required*| Name of publication|string|
|**database**  <br>*required*|Logical database name|string|
|**tables**  <br>*optional*|Tables included in publication.|string|
|**schemas**  <br>*optional*|Schemas included in publication.|string|


### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|string|
|**400**|Bad request|string|


### Consumes

* `application/json`


### Produces

* `*/*`


## Alter Add publication
```
POST /publications/alter/add
```


### Description
Alter publication. Add some tables and schemas to publication. Empty both tables and schemas are not allowed.


### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**publication**  <br>*required*|Data for publication create|[publication](#publication)|

#### Publication

|Name|Description|Schema|
|---|---|---|
|**publicationName**  <br>*required*| Name of publication|string|
|**database**  <br>*required*|Logical database name|string|
|**tables**  <br>*optional*|Tables included in publication.|string|
|**schemas**  <br>*optional*|Schemas included in publication.|string|


### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|string|
|**400**|Bad request|string|


### Consumes

* `application/json`


### Produces

* `*/*`


## Alter Set publication
```
POST /publications/alter/add
```


### Description
Alter publication. Change some tables and schemas in publication. Empty both tables and schemas are not allowed.


### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**publication**  <br>*required*|Data for publication create|[publication](#publication)|

#### Publication

|Name|Description|Schema|
|---|---|---|
|**publicationName**  <br>*required*| Name of publication|string|
|**database**  <br>*required*|Logical database name|string|
|**tables**  <br>*optional*|Tables included in publication.|string|
|**schemas**  <br>*optional*|Schemas included in publication.|string|


### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|string|
|**400**|Bad request|string|


### Consumes

* `application/json`


### Produces

* `*/*`

## Get publication
```
GET /{database}/{publication}
```


### Description
Get publication Info.


### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Path**|**publicationName**  <br>*required*| Name of publication|string|
|**Path**|**database**  <br>*required*|Logical database name|string|
|**Query**|**withTables**  <br>*optional*|If table info must present in response|bool|

### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|[Publication Info](#publication-info)|
|**400**|Bad request|string|

#### Publication Info

|Name|Description|Schema|
|---|---|---|
|**name**  |Name of publication|string|
|**database**  |Logical database name|string|
|**owner**  |Publication owner|string|
|**tables**  |Tables included in publication|Array of [Table](#table)|

#### Table
|Name|Description|Schema|
|---|---|---|
|**name**   |Table name|string|
|**attrNames** |Attributes included in publication|Array of string|
|**rowfilter**  |RowFilter for table, if present|string|

### Consumes

* `*/*`


### Produces

* `*/*`

## Drop publication
```
DELETE /publications/drop
```

### Description
Drop publication for logical database.


### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**publication**  <br>*required*|Data for publication create|[publication](#publication)|

#### Publication

|Name|Description|Schema|
|---|---|---|
|**publicationName**  <br>*required*| Name of publication|string|
|**database**  <br>*required*|Logical database name|string|
|**tables**  <br>*optional*|Tables included in publication.|string|
|**schemas**  <br>*optional*|Schemas included in publication.|string|

### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|string|
|**400**|Bad request|string|


### Consumes

* `application/json`


### Produces

* `*/*`

## Grant user
```
Post /users/grant
```

### Description
Grant user with REPLICATION.


### Parameters

|Type|Name|Description|Schema|
|---|---|---|---|
|**Body**|**user**  <br>*required*|User data|[user](#user)|

#### User

|Name|Description|Schema|
|---|---|---|
|**username**  <br>*required*| Name of the user|string|


### Responses

|HTTP Code|Description|Schema|
|---|---|---|
|**200**|OK|string|
|**400**|Bad request|string|


### Consumes

* `application/json`


### Produces

* `*/*`
