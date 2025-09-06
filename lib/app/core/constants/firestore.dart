enum FirestorePath {
  users("users"),
  topics("topics"),
  words("words");

  final String value;
  const FirestorePath(this.value);
}
