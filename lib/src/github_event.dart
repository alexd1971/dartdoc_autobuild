/// Github-событие
class GithubEvent {
  /// Тип события
  final GithubEventType type;

  /// Полезная информация о событии, полученная в запросе с github
  final Map<String, dynamic> payload;

  /// Создает собыдие на основании данных
  ///
  /// `type` - тип события (в настоящее время поддержиается только `push`)
  /// `payload` - информация о событии
  GithubEvent(GithubEventType type, Map<String, dynamic> payload)
      : type = type,
        payload = Map.unmodifiable(payload);
}

/// Тип события
class GithubEventType {
  /// Событие `push`
  static const GithubEventType push = GithubEventType('push');

  final String _type;

  /// Создает новый тип события
  const GithubEventType(String type) : _type = type;

  @override
  String toString() => _type;
}
