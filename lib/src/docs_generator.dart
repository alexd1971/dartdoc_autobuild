import 'dart:async';
import 'dart:io';

import 'github_repository.dart';
import 'package:html/dom.dart';

/// Генератор документации
///
/// Генерация производится с помощью `dartdoc` после обновления данных из github-репозитория
class DocsGenerator {
  final GithubRepository _repository;

  /// Создает генератор документации для репозитория
  ///
  /// `repository` - репозиторий [GithubRepository] на основании которого генерируется документация
  DocsGenerator(GithubRepository repository) : _repository = repository;

  /// Генерирует документацию на основании репозитория
  Future generate() async {
    final repoDir = Directory('repos/${_repository.name}');
    if (await repoDir.exists()) {
      await _runShellCommand('git', ['pull'], workingDirectory: repoDir.path);
    } else {
      await _runShellCommand(
          'git', ['clone', '${_repository.cloneUrl}', repoDir.path]);
    }
    final docDir = Directory('docs/${_repository.name}');
    await _runShellCommand('dartdoc', ['--output', docDir.absolute.path],
        workingDirectory: repoDir.path);
  }

  /// Перестраивает индекс по документации, обслуживаемой сервисом
  Future rebuidIndex() async {
    final docsLink = Element.tag('h2');
    docsLink.innerHtml = '<a href="${_repository.name}/index.html">'
        '${_repository.name}'
        '</a> '
        '<small>'
        '${_repository.description}'
        '</small>';

    final includeFile = File('docs/include/${_repository.name}.html');
    if (!await includeFile.exists()) {
      await includeFile.create(recursive: true);
    }
    await includeFile.writeAsString(docsLink.outerHtml);

    final htmlDoc = Document.html('<!DOCTYPE html>'
        '<html>'
        '<head>'
        '<title></title>'
        '<meta  charset="utf-8">'
        ' <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">'
        '</head>'
        '<body>'
        '<div class="container">'
        '<h1>Документация по пакетам проекта AFS</h1>'
        '<dl class="dl-horizontal">'
        '</dl>'
        '</div>'
        '</body>'
        '</html>');
    htmlDoc.head.querySelector('title').text = 'AFS docs';
    htmlDoc.body.querySelector('h1').text =
        'Документация по пакетам проекта AFS';
    final includeDir = Directory('docs/include');
    await for (FileSystemEntity file in includeDir.list()) {
      htmlDoc.body.querySelector('dl').append(Comment(
          '#include file="${file.uri.pathSegments.sublist(1).join('/')}"'));
    }
    final indexFile = File('docs/index.html');
    if (!await indexFile.exists()) {
      await indexFile.create();
    }
    await indexFile.writeAsString(htmlDoc.outerHtml);
  }

  Future _runShellCommand(String command, List<String> arguments,
      {String workingDirectory}) async {
    final result = await Process.run(command, arguments,
        workingDirectory: workingDirectory);
    if (result.exitCode != 0) {
      throw (result.stderr);
    }
  }
}
