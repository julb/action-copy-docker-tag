![Build](https://github.com/julb/action-copy-docker-tag/workflows/Build/badge.svg)

# GitHub Action to copy a Docker tag and push to Docker Hub

The GitHub Action to create Docker tags from an existing one and push to Docker Hub.

It expects the following secrets:

- `DOCKERHUB_USERNAME` : the DockerHub username.
- `DOCKERHUB_PASSWORD` : the DockerHub password.

## Usage

### Example Workflow file

- Copy and Push Docker tags:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Copy and Push Docker tags
        uses: julb/action-copy-docker-tag@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
          from: julb/some-image:version
          tags: |
            julb/some-image:new-version-1
            julb/some-image:new-version-2
```

### Inputs

| Name       | Type     | Default   | Description                                                      |
| ---------- | -------- | --------- | ---------------------------------------------------------------- |
| `username` | string   | `Not set` | The DockerHub username. **Required**                             |
| `password` | string   | `Not Set` | The DockerHub password. **Required**                             |
| `from`     | string   | `Not set` | The Docker tag to copy. **Required**                             |
| `tags`     | string[] | `Not Set` | The Docker tags to create from `from` tag and push. **Required** |

**Important note**: DockerHub credentials contains sensitive values and should be provided using Github Action Secrets.
Don't paste your DockerHub credentials in clear in your Github action.

### Outputs

| Name | Type | Description |
| ---- | ---- | ----------- |

## Contributing

This project is totally open source and contributors are welcome.

When you submit a PR, please ensure that the python code is well formatted and linted.

```
$ make install.dependencies
$ make format
$ make lint
```
