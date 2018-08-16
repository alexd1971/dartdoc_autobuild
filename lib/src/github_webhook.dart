import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'github_event.dart';
import 'github_repository.dart';
import 'docs_generator.dart';

/// Webhook, обслуживающий события с github
class GithubWebhook {
  /// Запускает webhook
  Future start() async {
    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_processRequest);

    var server = await io.serve(handler, InternetAddress.anyIPv4, 7777);
    print('Serving at http://${server.address.host}:${server.port}');
  }

  Future<shelf.Response> _processRequest(shelf.Request request) async {
    final event = request.headers['x-github-event'];
    final payload = json.decode(await request.readAsString());

    GithubEvent githubEvent;
    switch (event) {
      case 'ping':
        return shelf.Response(HttpStatus.ok, body: 'pong');
      case 'push':
        githubEvent = GithubEvent(GithubEventType.push, payload);
        break;
      case 'pull_request':
        githubEvent = GithubEvent(GithubEventType.pullRequest, payload);
        if (githubEvent.payload['action'] != 'merge') {
          return shelf.Response(HttpStatus.accepted,
              body:
                  'The service does not handle pull request action ${githubEvent.payload['action']}');
        }
        break;
      default:
        return shelf.Response(HttpStatus.badRequest,
            body: 'Unsupported github event');
    }
    final githubRepository =
        GithubRepository.fromJson(githubEvent.payload['repository']);
    if (githubRepository.language != 'Dart') {
      return shelf.Response(HttpStatus.unsupportedMediaType,
          body:
              'The service does not support language ${githubRepository.language}');
    }
    DocsGenerator(githubRepository)
      ..generate()
      ..rebuidIndex();
    return shelf.Response.ok('Accepted');
  }
}
