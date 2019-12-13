## Kibana Plugin Tester [![GitHub Actions](https://github.com/daniccan/kibana-plugin-tester/workflows/Deploy%20to%20DockerHub/badge.svg)](https://github.com/daniccan/kibana-plugin-tester) [![Docker Pulls](https://img.shields.io/docker/pulls/daniccan/kibana-plugin-tester.svg)](https://hub.docker.com/r/daniccan/kibana-plugin-tester)

A Docker image to deploy and test plugins for any given version of [Kibana](https://github.com/elastic/kibana).

### Requirements

- Docker
- A [Kibana Plugin](https://github.com/elastic/kibana/tree/master/packages/kbn-plugin-generator)

### Usage

```bash
docker run -it -p 9200:9200 -p 5601:5601 -e KIBANA_VERSION=$KIBANA_VERSION -e PLUGIN_FILE_NAME=$PLUGIN_FILE_NAME -v $KIBANA_PLUGIN_PATH:/kibana-plugin --rm daniccan/kibana-plugin-tester
```

### Example

```bash
docker run -it -p 9200:9200 -p 5601:5601 -e KIBANA_VERSION=7.5.0 -e PLUGIN_FILE_NAME=my_plugin.zip -v /home/username/my_plugin:/kibana-plugin --rm daniccan/kibana-plugin-tester
```

### URLs

- **Elasticsearch:** http://localhost:9200
- **Kibana:** http://localhost:5601

### Issues

Find any bugs or need additional features? Please don't hesitate to [create an issue](https://github.com/daniccan/kibana-plugin-tester/issues/new).

### License

MIT Copyright (c) 2019 [daniccan](https://github.com/daniccan)
