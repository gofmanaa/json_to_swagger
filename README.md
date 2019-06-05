# json_to_swagger
Json to Swagger Yaml converter

## Description:
Helper script for translate json to swagger yaml

## Usage:

```
Usage: json_to_yml.rb [options]
    -h, --help                       Show this help message
    -r, --root ROOT                  The name of the json root
    -j, --json JSON                  Json body
```

``` $ curl https://indexing.googleapis.com/v3/urlNotifications/metadata | ruby json_to_swagger.rb ```
###Result: 
``` ---
 error:
     type: object
 properties:
     code:
     type: integer
 message:
     type: string
 status:
     type: string
```

### Or

``` $  ruby json_to_swagger.rb -r RootObj -j '{"m":"hello","arr_obj":[{"field":"msg"},{"c":2}],"ids":[1,2],"active":true,"obj":{"n":"Dart","some_id":null}}' ```

###Result: 
```
RootObj:
  type: object
  properties:
    m:
      type: string
    arr_obj:
      type: array
      items:
        type: object
        properties:
          field:
            type: string
    ids:
      type: array
      items:
        type: integer
    active:
      type: boolean
    obj:
      type: object
      properties:
        n:
          type: string
        some_id:
          type: integer
```
 
 Or you can use inline enter, run `$ ruby json_to_swagger.rb`, enter json and press `Ctrl+D`.
 