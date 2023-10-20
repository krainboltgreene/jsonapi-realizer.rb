# Changelog

## 6.2.3

  - [bugfix] The solution for bad values in `data.*` turned out to be not as explicit as a production application needs, so I've made it significantly more strict and also expanded it to `page.*` as well.

## 6.2.2

  - [bugfix] A continuation of the previous bug fix where null values for data.attributes and data.relationships caused issues

## 6.2.1

  - [bugfix] If you handle a request where there is a data.attributes property, but it is `null` then the program will fail trying to `transfrom_keys()` on `null`

## 1.0.0

  - Initial release
