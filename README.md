# hostname-server

A simple web server returning a JSON response including hostname and current time

This is useful for testing container networking.

## Installing the Chart

To install the chart with the release name `my-release`:

```shell
$ helm repo add hostname-server-charts https://mojochao.github.io/hostname-server
$ helm install my-release hostname-server-charts/hostname-server --namespace hostname-server --create-namespace
```
