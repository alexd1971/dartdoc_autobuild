import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'github_event.dart';
import 'github_repository.dart';
import 'docs_generator.dart';

/// Сервер, обслуживающий PushEvents с github
class Server {
  /// Запускает сервер
  Future start() async {
    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_processRequest);

    var server = await io.serve(handler, 'localhost', 7777);
    print('Serving at http://${server.address.host}:${server.port}');
  }

  Future<shelf.Response> _processRequest(shelf.Request request) async {
    if (request.headers['x-github-event'] != 'push') {
      return shelf.Response(HttpStatus.badRequest,
          body: 'Unsupported github event');
    }
    final body = json.decode(await request.readAsString());
    final githubEvent = GithubEvent(GithubEventType.push, body);
    final githubRepository =
        GithubRepository.fromJson(githubEvent.payload['repository']);
    DocsGenerator(githubRepository)
      ..generate()
      ..rebuidIndex();
    return shelf.Response.ok('Accepted');
  }
}
