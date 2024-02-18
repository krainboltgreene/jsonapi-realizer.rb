# Changelog

## 6.3.0

  - [feature] Trying to include relationships that aren't defined now give you extra context on the fact that it was included
  - [feature] Now parameters can be allowed to be blank

## 6.2.4

  - [bugfix] Catching a nasty case where if you `include` an empty string it would fail to parse.

## 6.2.3

  - [bugfix] The solution for bad values in `data.*` turned out to be not as explicit as a production application needs, so I've made it significantly more strict and also expanded it to `page.*` as well.

## 6.2.2

  - [bugfix] A continuation of the previous bug fix where null values for data.attributes and data.relationships caused issues

## 6.2.1

  - [bugfix] If you handle a request where there is a data.attributes property, but it is `null` then the program will fail trying to `transfrom_keys()` on `null`

## 1.0.0

  - Initial release
