FROM google/dart

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

RUN mkdir docs
RUN mkdir repos
VOLUME [ "/app/docs", "/app/repos" ]

EXPOSE 7777

CMD []
ENTRYPOINT ["/usr/bin/dart", "bin/start.dart"]