/// Библиотека содержит компоненты для сервиса автоматической генерации документации
///
/// Реализуется github webhook, который обрабатывает события `push` и `pull_request`(action: merge):
/// * клонирует/обновляет локальный репозиторий
/// * генерирует на основе обновленного репозитория документацию по пакету
/// * обновляет индекс
library dartdoc_autobuild;

export 'src/docs_generator.dart';
export 'src/github_event.dart';
export 'src/github_repository.dart';
export 'src/github_webhook.dart';
