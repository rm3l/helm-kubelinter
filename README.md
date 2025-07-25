# helm-kubelinter

[![Build Status](https://github.com/rm3l/helm-kubelinter/workflows/release/badge.svg)](https://github.com/rm3l/helm-kubelinter/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Helm plugin that validates your Helm charts using [KubeLinter](https://github.com/stackrox/kube-linter), a static analysis tool that checks Kubernetes YAML files and Helm charts to ensure they follow best practices.

## Features

- 🔍 **Static Analysis**: Lint your Helm charts against Kubernetes best practices
- 🚀 **Auto-Installation**: Automatically downloads and installs KubeLinter
- 🔄 **Auto-Updates**: Update KubeLinter to the latest version
- 🌐 **Cross-Platform**: Supports Linux and macOS (x86_64 and ARM64)
- ⚡ **Flexible Arguments**: Pass arguments to both Helm and KubeLinter separately

## Installation

### Via Helm Plugin Manager

```bash
helm plugin install https://github.com/rm3l/helm-kubelinter
```

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/rm3l/helm-kubelinter.git && cd helm-kubelinter
```

2. Install the plugin:
```bash
helm plugin install .
```

### Verify Installation

```bash
helm kubelinter --help
```

## Usage

### Basic Usage

```bash
helm kubelinter <chart> [helm_args] -- [kubelinter_args]
```

The plugin uses `--` as a separator:
- Arguments **before** `--` are passed to `helm template`
- Arguments **after** `--` are passed to `kube-linter`

### Examples

#### Basic Chart Validation

```bash
# Validate a local chart
helm kubelinter ./my-chart

# Validate a chart with specific values
helm kubelinter ./my-chart --values production-values.yaml

# Validate a chart from a repository
helm kubelinter my-chart --repo=https://my-helm-chart-repo.example.com
```

#### Advanced Usage with KubeLinter Options

```bash
# Use specific KubeLinter configuration
helm kubelinter ./my-chart -- --config /path/to/kubelinter-config.yaml

# Run with verbose output
helm kubelinter ./my-chart -- --verbose

# Check only specific checks
helm kubelinter ./my-chart -- --include run-as-non-root,no-read-only-root-fs

# Exclude specific checks
helm kubelinter ./my-chart -- --exclude latest-tag
```

#### Combined Example

```bash
# Comprehensive validation with custom values and KubeLinter config
helm kubelinter ./my-chart \
  --values values.yaml \
  --values production-values.yaml \
  --namespace production \
  --name-template my-app \
  -- \
  --config .kubelinter.yaml \
  --verbose \
  --exclude latest-tag
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `HELM_KUBELINTER_UPDATE` | Force update KubeLinter on next run | `false` |

### KubeLinter Configuration

You can use a [KubeLinter configuration file](https://github.com/stackrox/kube-linter/blob/main/docs/configuring-kubelinter.md) to customize the checks:

```yaml
# .kubelinter.yaml
checks:
  # Exclude checks that don't apply to your environment
  exclude:
    - "latest-tag"
    - "unset-cpu-requirements"
  
  # Include only specific checks
  include:
    - "run-as-non-root"
    - "no-read-only-root-fs"
    - "privilege-escalation"

# Custom check configurations
customChecks:
  - name: "required-annotation-key"
    template: "required-annotation"
    params:
      key: "example.com/key"
    remediation: Please set the annotation 'example.com/key'. This will be parsed by xy to generate some docs.
```

Then use it with:
```bash
helm kubelinter ./my-chart -- --config .kubelinter.yaml
```

## Troubleshooting

### Common Issues

#### KubeLinter Not Found
```bash
# Force reinstall KubeLinter
HELM_KUBELINTER_UPDATE=true helm kubelinter ./my-chart
```

#### Permission Denied
```bash
# Ensure the plugin directory has correct permissions
chmod +x ~/.local/share/helm/plugins/helm-kubelinter/scripts/*.sh
```

#### Template Rendering Issues
```bash
# Debug Helm template rendering
helm kubelinter ./my-chart --debug
```

#### Network Issues During Installation
```bash
# Manual KubeLinter installation
mkdir -p ~/.local/share/helm/plugins/helm-kubelinter/bin
curl -L https://github.com/stackrox/kube-linter/releases/download/v0.7.4/kube-linter-linux.tar.gz | \
  tar -xz -C ~/.local/share/helm/plugins/helm-kubelinter/bin
```

### Debug Mode

For verbose output, use:
```bash
helm kubelinter ./my-chart --debug -- --verbose
```

### Check Plugin Status

```bash
# List installed plugins
helm plugin list

# Check KubeLinter version
~/.local/share/helm/plugins/helm-kubelinter/bin/kube-linter version
```

## Update

### Update the Plugin

```bash
helm plugin update kubelinter
```

### Update KubeLinter Binary

```bash
# Force update to latest KubeLinter version
HELM_KUBELINTER_UPDATE=true helm kubelinter --help
```

## Contributing

We welcome contributions!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
