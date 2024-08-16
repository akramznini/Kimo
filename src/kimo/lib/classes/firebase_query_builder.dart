import 'package:cloud_firestore/cloud_firestore.dart';

class QueryBuilder {
  late Query _query;

  QueryBuilder(Query collection) {
    _query = collection;
  }

  QueryBuilder whereEqualTo(String field, dynamic value) {
    if (value != null) {
      _query = _query.where(field, isEqualTo: value);
    }
    return this;
  }

  QueryBuilder whereGreaterThan(String field, dynamic value) {
    if (value != null) {
      _query = _query.where(field, isGreaterThan: value);
    }
    return this;
  }

  QueryBuilder whereLessThan(String field, dynamic value) {
    if (value != null) {
      _query = _query.where(field, isLessThan: value);
    }
    return this;
  }
  QueryBuilder whereGreaterThanOrEqualTo(String field, dynamic value) {
    if (value != null) {
      _query = _query.where(field, isGreaterThan: value);
    }
    return this;
  }

  QueryBuilder whereLessThanOrEqualTo(String field, dynamic value) {
    if (value != null) {
      _query = _query.where(field, isLessThan: value);
    }
    return this;
  }

  QueryBuilder applyQueryFilters(List<QueryFilter> filters) {
    print("inside query builder");
    for (QueryFilter filter in filters) {
      print(filter.type);
      switch (filter.type) {
        case QueryFilterType.isEqualTo:
          _query = _query.where(filter.attribute, isEqualTo: filter.value);
          break;
        case QueryFilterType.isGreaterThanOrEqualTo:
          _query = _query.where(filter.attribute, isGreaterThanOrEqualTo: filter.value);
          break;
        case QueryFilterType.isGreaterThan:
          _query = _query.where(filter.attribute, isGreaterThan: filter.value);
          break;
        case QueryFilterType.isLessThanOrEqualTo:
          _query = _query.where(filter.attribute, isLessThanOrEqualTo: filter.value);
          break;
        case QueryFilterType.isLessThan:
          _query = _query.where(filter.attribute, isLessThan: filter.value);
          break;
      }
    }
    print("finished applying filters");
    
    return this;
  }

  Query build() {
    return _query;
  }
}












enum QueryFilterType {
      isEqualTo,
      isLessThanOrEqualTo,
      isGreaterThanOrEqualTo,
      isGreaterThan,
      isLessThan
}


class QueryFilter {
  String attribute;
  QueryFilterType type;
  dynamic value;

  QueryFilter({
    required this.attribute,
    required this.type,
    required this.value
  });
}

