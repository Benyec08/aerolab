abstract interface class ComponentRepository<T> {
  List<T> getAll();

  T? findById(String id);

  List<T> searchByModel(String query);

  List<T> filterByManufacturer(String manufacturer);

  bool containsId(String id);

  int get count;

  bool get isEmpty;

  bool get isNotEmpty;
}
