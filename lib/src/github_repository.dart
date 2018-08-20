/// Репозиторий github
class GithubRepository {
  /// Название репозитория
  final String name;

  /// Описание репозитория
  final String description;

  /// URL репозитория
  final Uri url;

  /// Признак закрытого репозитория
  final bool private;

  /// URL для клонирования репозитория
  final Uri cloneUrl;

  /// Язык программирования для репозитория
  final String language;

  /// Создает репозиторий на основании данных JSON
  GithubRepository.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'] ?? '',
        url = Uri.parse(json['url']),
        cloneUrl = Uri.parse(json['clone_url']),
        private = json['private'],
        language = json['language'];
}
