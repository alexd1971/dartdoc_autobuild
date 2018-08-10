/// Репозиторий github
class GithubRepository {
  /// Название репозитория
  final String name;

  /// Описание репозитория
  final String description;

  /// URL репозитория
  final Uri url;

  /// URL для кллнирования репозитория
  final Uri cloneUrl;

  /// Создает репозиторий на основании данных JSON
  GithubRepository.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'] ?? '',
        url = Uri.parse(json['url']),
        cloneUrl = Uri.parse(json['clone_url']);
}
