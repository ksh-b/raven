

import 'package:raven/repository/git/github.dart';

abstract class Repo {
  Repo(this.url);

  String repo="";
  String url;
  String get id;
  String get latestZip;
  String get zipFolder;
  String get defaultBranch;
  String name = "";
  String description = "";

  Future<int> lastCommit();

  static Repo? getRepo(String url) {
    if (url.contains("github.com")) {
      return Github(url: url);
    }
    return null;
  }
}
