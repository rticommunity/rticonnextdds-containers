_RTI® Observability Collector Service_ is a component of the
_RTI Connext® Observability Framework_, a solution that scalably collects telemetry data
from _RTI Connext_ applications and distributes this data to third-party observability backends
or _RTI Admin Console_ for remote debugging.

For metrics, logs, and security events _Collector Service_ provides native integration
with Prometheus®, as the time-series database to store _Connext_ metrics, and Grafana® Loki™,
as the log aggregation system to store _Connext_ logs. Integration with other backends is
possible using [OpenTelemetry™](https://opentelemetry.io/) and the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/).
For additional information on _RTI Connext Observability Framework_, see the [RTI documentation](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/observability/index.html).

_Collector Service_ also collects non-metric data (configuration and discovery data) that is
currently consumed by _Admin Console_ to support the remote debugging feature. For additional information on remote debugging with _Admin Console_ see [Remote Debugging](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/tools/admin_console/p2_administration/features_reference/ref_remote_debugging.html#remote-debugging-experimental).

To improve scalability, a _Collector Service_ instance can be configured to forward telemetry data to another _Collector Service_. This approach is especially useful in large systems where applications run across multiple networks. In such environments, it is recommended to run one _Collector Service_ per network and configure each to forward telemetry data to a central _Collector Service_. The central instance can then store the data in third-party backends or forward it to _Admin Console_ for remote debugging.

## Releases

The documentation on this page applies to the _Collector Service_ Docker image with the `latest` tag, which refers to the most recent image released by RTI. To confirm the _Connext_ release that corresponds to the `latest` tag, or to review the other _Connext_ releases that support the _Collector Service_ image, go to https://hub.docker.com/r/rticom/collector-service/tags.

For documentation on previous releases of the _Collector Service_ image, refer to the https://github.com/rticommunity/rticonnextdds-containers repository.

## Collector Service receivers and exporters

_Collector Service_ receives data by instantiating receiver endpoints, and it 
forwards data by instantiating exporter endpoints.

### Collector Service receivers

Currently, the only supported receiver endpoint is a DDS receiver endpoint, which receives telemetry data from _Monitoring Library 2.0_ in a _Connext_ application or from another _Collector Service_ instance
when _Collector Service_ acts as a Forwarder.

### Collector Service exporters

The following exporter endpoints are supported:

- `prometheus_exporter`, which exports metrics to a Prometheus server.
- `loki_exporter`, which exports logs to a Grafana Loki server.
- `otlp_exporter`, which exports metrics and logs to an OpenTelemetry Collector using the OpenTelemetry protocol (OTLP).
- `websocket_exporter`, which provides telemetry data to RTI Admin Console for remote debugging using a WebSocket API.
- `dds_exporter`, which forwards telemetry data to another Collector Service instance.

## Using the _Collector Service_ container image

Running _Collector Service_ on Docker is as simple as running the `docker run` command:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        --name=collector_service \
        rticom/collector-service:latest
```

The above command starts _Collector Service_ with a default configuration
that stores the metrics and logs emitted by _Connext_ applications using
[Connext Monitoring Library 2.0](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/observability/library.html)
on domain ID 2 into Prometheus (for metrics) and Grafana Loki (for logs)
databases. _Collector Service_ also collects and distributes the telemetry
data required for the _Admin Console_ remote debugging feature.

With the default configuration, _Collector Service_ runs a Prometheus client that
spawns an HTTP server on port 19090 and a Grafana Loki HTTP client that connects
to a Grafana Loki server running on port 3100. It also creates a server on port
19098 that provides HTTP control of metrics and logs as well as the distribution
of non-metric data for _Admin Console_ remote debugging.

An RTI license file is always required to run _Collector Service_ in a Docker
container. Bind-mount your license from the host by using the following
command-line parameter:

```
-v /path/to/your_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat
```

The _Collector Service_ container image uses the following user and group:

- User: rtiuser (1010)
- Group: rtigroup (1010)

The _Collector Service_ container image uses the following working directory:

- `/home/rtiuser/rti_workspace/7.6.0/user_config/collector_service`

The following table indicates the RTI licenses required based on your answers
to the questions in the first two columns.

| Do you need to secure telemetry data exchanged between applications and _Collector Service_ using _RTI Security Plugins_? | Do you need to send telemetry data to _Collector Service_ over the WAN using _RTI Real-Time WAN Transport_? | Required License                                                                             |
| ------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| NO                                                                                                                        | NO                                                                                                          | Connext Professional                                                                         |
| YES                                                                                                                       | NO                                                                                                          | Connext Professional and Security Plugins                                                    |
| YES                                                                                                                       | YES                                                                                                         | Connext Professional, Security Plugins, Cloud Discovery Service, and Real-Time WAN Transport |
| NO                                                                                                                        | YES                                                                                                         | Connext Professional, Cloud Discovery Service, and Real-Time WAN Transport                   |

## Built-in configuration

Use the following command to retrieve the _Collector Service_ built-in 
configuration file:

```
docker cp collector_service:/opt/rti.com/rti_connext_dds-7.6.0/resource/xml/RTI_COLLECTOR_SERVICE.xml .
```
The built-in configuration file supports the following profiles:

|Configuration Name          |Supported Exporter(s) |Network    |Security |
|--------------------------- |--------------------- |-----------|-------- |
|NonSecureForwarderLANtoLAN  |dds_exporter          |LAN to LAN |No       |
|NonSecureForwarderLANtoWAN  |dds_exporter          |LAN to WAN |No       |
|NonSecureForwarderWANtoWAN  |dds_exporter          |WAN to WAN |No       |
|SecureForwarderLANtoLAN     |dds_exporter          |LAN to LAN |Yes      |
|SecureForwarderLANtoWAN     |dds_exporter          |LAN to WAN |Yes      |
|SecureForwarderWANtoWAN     |dds_exporter          |WAN to WAN |Yes      |
|NonSecureLAN                |prometheus_exporter, loki_exporter, websocket_exporter |LAN        |No       |
|NonSecureWAN                |prometheus_exporter, loki_exporter, websocket_exporter |WAN        |No       |
|SecureLAN                   |prometheus_exporter, loki_exporter, websocket_exporter |LAN        |Yes      |
|SecureWAN                   |prometheus_exporter, loki_exporter, websocket_exporter |WAN        |Yes      |
|NonSecureOTelLAN            |otlp_exporter, websocket_exporter                      |LAN        | No      |
|NonSecureOTelWAN            |otlp_exporter, websocket_exporter                      |WAN        | No      |
|SecureOTelLAN               |otlp_exporter, websocket_exporter                      |LAN        |Yes      |
|SecureOTelWAN               |otlp_exporter, websocket_exporter                      |WAN        |Yes      |
|NonSecureRemoteDebuggingLAN |websocket_exporter                                     |LAN        |No       |
|NonSecureRemoteDebuggingWAN |websocket_exporter                                     |WAN        |No       |
|SecureRemoteDebuggingLAN    |websocket_exporter                                     |LAN        |Yes      |
|SecureRemoteDebuggingWAN    |websocket_exporter                                     |WAN        |Yes      |

In LAN profiles, _Collector Service_ uses _UDPv4_ and _SHMEM_ transports to 
receive telemetry data from _Connext_ applications and runs on the same LAN 
where the applications run.

NOTE: Multicast is not supported in the _Collector Service_ Docker container at this time.

In WAN profiles, _Collector Service_ uses _RTI Real-Time WAN Transport_ to 
receive telemetry data from _Connext_ applications and runs on a WAN. For 
example, _Collector Service_ may run in an AWS instance while the 
_Connext_ applications may run on-premise.

The default profile is NonSecureLAN. To select a different profile, set the
environment variable ``CFG_NAME`` to the name of the profile you want to
use. For example, to run the _Collector Service_ SecureLAN profile, set the
environment variable ``CFG_NAME`` to "SecureLAN".

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -e CFG_NAME="SecureLAN" \
        --name=collector_service \
        rticom/collector-service:latest
```

When using built-in configurations that provide metric and log storage, the
configuration assumes that the following components are running on the same host where
_Collector Service_ runs:

- Prometheus server
- Grafana Loki server
- OpenTelemetry Collector

You can override the default hostnames and ports of these components by setting
the appropriate environment variables. See below for more information.

In addition to the configuration name, there are other parameters you can
set using environment variables when running the Docker container:

**General Parameters**

```
-e OBSERVABILITY_DOMAIN=<The domain ID in which Collector Service receives the telemetry data from _Connext_ applications or from another Collector Service instance. default: 2>
-e OBSERVABILITY_CONTROL_PORT=<The private TCP port to access the Collector Service control server for external commands and to distribute non-metric data for Admin Console remote debugging. This is the port the service listens to. default: 19098>
-e OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME=<The public hostname to access the Collector Service control server from a public network. default: localhost>
-e OBSERVABILITY_CONTROL_PUBLIC_PORT=<The public TCP port to access the Collector Service control server from a public network. default: 19098>
-e OBSERVABILITY_OUTPUT_DOMAIN=<The domain ID in which Collector Service forwards the telemetry data to another Collector Service instance. default: 101>
-e OBSERVABILITY_OUTPUT_COLLECTOR_PEER=<The initial peer the Collector Service uses for discovery to send telemetry data to another Collector Service instance. default: builtin.udpv4://127.0.0.1>
```

**Security Parameters**

```
-e OBSERVABILITY_BASIC_AUTH_USERNAME=<The username to authenticate the HTTP connections (client) created by Collector Service. default: user>
-e OBSERVABILITY_BASIC_AUTH_PASSWORD=<The password to authenticate the HTTP connections (client) created by Collector Service. default: userpassword>
```

The above parameters are used by the HTTP clients created by
_Collector Service_ to send telemetry data to third-party backends (for example,
Prometheus, Grafana Loki, and OpenTelemetry Collector).

**WAN Parameters**

```
-e OBSERVABILITY_RWT_PORT=<Both the host and public UDP port of Collector Service in which it will receive telemetry data from _Connext_ applications or another Collector Service instance using the Real-Time WAN Transport. default: 30000>
-e OBSERVABILITY_RWT_PUBLIC_ADDRESS=<The public address of Collector Service in which it will receive telemetry data from _Connext_ applications or another Collector Service instance using the Real-Time WAN Transport. default: localhost>
```

**OpenTelemetry Parameters**

```
-e OBSERVABILITY_OTEL_HOSTNAME=<The hostname where the OpenTelemetry Collector runs. default: localhost>
-e OBSERVABILITY_OTEL_METRIC_EXPORTER_PORT=<The TCP port of the OpenTelemetry Collector in which it will receive metrics from Collector Service using OTLP protocol. This is the port that the OpenTelemetry Collector listens to. default: 4318>
-e OBSERVABILITY_OTEL_LOG_EXPORTER_PORT=<The TCP port of the OpenTelemetry Collector in which it will receive logs from Collector Service using OTLP protocol. This is the port that the OpenTelemetry Collector listens to. default: 4319>
```

**Prometheus Parameters**

```
-e OBSERVABILITY_PROMETHEUS_EXPORTER_PORT=<The TCP port of the Prometheus endpoint for exporting telemetry data to Prometheus. This is the port that the Prometheus endpoint service listens to and uses to provide telemetry data via scrapes from the Prometheus server. default: 19090>
```

**Grafana Loki Parameters**

```
-e OBSERVABILITY_LOKI_HOSTNAME=<The hostname where the Loki server runs, default: localhost>
-e OBSERVABILITY_LOKI_EXPORTER_PORT=<The TCP port of the Grafana Loki server in which it will receive logs from Collector Service. default: 3100>
```

For example, to run a _Collector Service_ instance with public address
10.10.1.34:16000 that collects all telemetry data published by _Connext_
applications over the WAN on domain 33, you can run a Docker container as
follows:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -e CFG_NAME="NonSecureWAN" \
        -e OBSERVABILITY_DOMAIN=33 \
        -e OBSERVABILITY_RWT_PUBLIC_ADDRESS=10.10.1.34 \
        -e OBSERVABILITY_RWT_PORT=16000 \
        --name=collector_service \
        rticom/collector-service:latest
```

### Security Artifacts

> Note: When running a secure configuration, all port specifications defined in
> previous sections must be appended with an ’s’ to indicate a secure connection is
> to be used.
>
> Non-Secure port example:
>
> ```
> -e OBSERVABILITY_CONTROL_PORT=19098
> -e OBSERVABILITY_CONTROL_PUBLIC_PORT=19098
> ```
>
> Secure port example:
>
> ```
> -e OBSERVABILITY_CONTROL_PORT=19098s
> -e OBSERVABILITY_CONTROL_PUBLIC_PORT=19098s
> ```

When running one of the secure configurations, the following security artifacts
must be mounted into the container.

**To configure _RTI Security Plugins_ to receive telemetry data from _Connext_ applications or another _Collector Service_ instance running in Forwarder mode:**

_RTI Security Plugins_ must be configured on _Collector Service_ `receivers`
for all secure configurations. The following security artifacts must be made
available to _Collector Service_.

```
-v /path/to/identity_ca.pem:/rti/security/dds/identity_ca.pem
-v /path/to/permissions_ca.pem:/rti/security/dds/permissions_ca.pem
-v /path/to/identity_certificate.pem:/rti/security/dds/identity_certificate.pem
-v /path/to/private_key.pem:/rti/security/dds/private_key.pem
-v /path/to/governance.p7s:/rti/security/dds/governance.p7s
-v /path/to/permissions.p7s:/rti/security/dds/permissions.p7s
```

- _identity_ca.pem_ must contain the certificate of the CA that signed the
_identity_certificate.pem_.
- _identity_certificate.pem_ must contain the certificate of the _Collector
Service_ `receivers`.
- _private_key.pem_ must contain the private key of the _Collector Service_
`receivers`.
- _permissions_ca.pem_ must contain the certificate of the CA that signed the
_permissions.p7s_ and _governance.p7s_.
- _governance.p7s_ must contain the governance file of the _Collector Service_
`receivers`.
- _permissions.p7s_ must contain the permissions file of the _Collector Service_
`receivers`.

**To configure _RTI Security Plugins_ to send telemetry data to another _Collector Service_ instance while running in Forwarder mode:**

_RTI Security Plugins_ must be configured on _Collector Service_ `exporters`
for all secure Forwarder configurations. The following security artifacts must
be made available to _Collector Service_.

```
-v /path/to/identity_ca_output.pem:/rti/security/dds/identity_ca_output.pem
-v /path/to/permissions_ca_output.pem:/rti/security/dds/permissions_ca_output.pem
-v /path/to/identity_certificate_output.pem:/rti/security/dds/identity_certificate_output.pem
-v /path/to/private_key_output.pem:/rti/security/dds/private_key_output.pem
-v /path/to/governance_output.p7s:/rti/security/dds/governance_output.p7s
-v /path/to/permissions_output.p7s:/rti/security/dds/permissions_output.p7s
```

- _identity_ca_output.pem_ must contain the certificate of the CA that signed the
_identity_certificate_output.pem_.
- _identity_certificate_output.pem_ must contain the certificate of the _Collector
Service_ `exporters`.
- _private_key_output.pem_ must contain the private key of the _Collector Service_
`exporters`.
- _permissions_ca_output.pem_ must contain the certificate of the CA that signed the
_permissions_output.p7s_ and _governance_output.p7s_.
- _governance_output.p7s_ must contain the governance file of the _Collector Service_
`exporters`.
- _permissions_output.p7s_ must contain the permissions file of the _Collector Service_
`exporters`.

For additional information on how to generate these security artifacts, see
[Generating the Observability Framework Security Artifacts](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/observability/security.html#generating-the-observability-framework-security-artifacts).

**To configure HTTPS + Basic Authentication:**

_Collector Service_ uses HTTPS + Basic Authentication to encrypt and
authenticate the HTTP connections created by _Collector Service_ to send
telemetry data and to receive commands from external clients.

To configure HTTPS + Basic Authentication, you need to provide:

```
-v /path/to/rootCA.crt:/rti/security/https/rootCALoki.crt
-v /path/to/rootCA.crt:/rti/security/https/rootCAOtel.crt
-v /path/to/serverPrometheusEndpoint.pem:/rti/security/https/serverPrometheusEndpoint.pem
-v /path/to/serverControl.pem:/rti/security/https/serverControl.pem
-v /path/to/htdigest_control:/rti/security/https/htdigest_control
-v /path/to/htdigest_prometheus:/rti/security/https/htdigest_prometheus
```

- _rootCALoki.crt_ must contain the root certificate of the CA that signed the
  _server.pem_ certificate used to communicate with the Grafana Loki server.
- _rootCAOtel.crt_ must contain the root certificate of the CA that signed the
  _server.pem_ certificate used to communicate with the OpenTelemetry Collector.
- _serverPrometheusEndpoint.pem_ must contain both a valid server certificate
  and the corresponding private key for the Prometheus endpoint created
  by _Collector Service_. The Prometheus endpoint is an HTTPS server that
  provides metrics to a Prometheus server.
- _serverControl.pem_ must contain both a valid server certificate and the
  corresponding private key for the control server created by
  _Collector Service_. The control server is an HTTPS server that receives
  commands from external clients such as the Grafana dashboards running in your
  browser.
- _htdigest_control_ is a password file that contains the username and password
  for BASIC-Auth. This file is used by the Controllability HTTP server started by _Collector Service_
  to authenticate the HTTP connections created by external clients (for example, to change the verbosity
  of an application). The htdigest file can be created using the
  [Apache htdigest tool](https://httpd.apache.org/docs/2.4/programs/htdigest.html).
- _htdigest_prometheus_ is a password file that contains the username and password
  for BASIC-Auth. This file is used by the Prometheus HTTP server started by _Collector Service_
  to authenticate the HTTP connections created by external clients (for example, a Prometheus scraping request). The htdigest file can be created using the
  [Apache htdigest tool](https://httpd.apache.org/docs/2.4/programs/htdigest.html).

Depending on your security configuration, you may not need to provide all the
files listed above. For example, if you are not running OpenTelemetry Collector,
you do not need to provide _rootCAOtel.crt_.

For additional information on how to generate these security artifacts, see
[Generating the Observability Framework Security Artifacts](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/observability/security.html#generating-the-observability-framework-security-artifacts).

## Remote debugging configuration for Admin Console

If you are not running the full _RTI Connext Observability Framework_, only the
_Collector Service_ component is required to support remote debugging in
_Admin Console_. The following built-in configurations support just the remote
debugging feature.

- NonSecureRemoteDebuggingLAN
- NonSecureRemoteDebuggingWAN
- SecureRemoteDebuggingLAN
- SecureRemoteDebuggingWAN

The following example runs _Collector Service_ to support remote debugging
securely over WAN:

```
docker run -dt --rm \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -v /path/to/serverControl.pem:/rti/security/https/serverControl.pem \
        -v /path/to/htdigest_control:/rti/security/https/htdigest_control \
        -e OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME="public-hostname" \
        -e OBSERVABILITY_HOSTNAME="hostname" \
        -e OBSERVABILITY_CONTROL_PORT="19098s" \
        -e OBSERVABILITY_CONTROL_PUBLIC_PORT="19098s" \
        -e CFG_NAME="SecureRemoteDebuggingWAN" \
        --name=collector_service \
        rticom/collector-service:latest
```

The following example runs _Collector Service_ to support remote debugging
non-securely over LAN:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -e OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME="public-hostname" \
        -e OBSERVABILITY_HOSTNAME="hostname" \
        -e OBSERVABILITY_CONTROL_PORT="19098" \
        -e OBSERVABILITY_CONTROL_PUBLIC_PORT="19098" \
        -e CFG_NAME="NonSecureRemoteDebuggingLAN" \
        --name=collector_service \
        rticom/collector-service:latest
```

## Forwarder configuration

The following built-in configurations can be used to configure a
_Collector Service_ instance to forward telemetry data to another
_Collector Service_ instance.

- NonSecureForwarderLANtoLAN
- NonSecureForwarderLANtoWAN
- NonSecureForwarderWANtoWAN
- SecureForwarderLANtoLAN
- SecureForwarderLANtoWAN
- SecureForwarderWANtoWAN

The following example runs _Collector Service_:
- in Forwarder mode
- securely
- forwarding from LAN to WAN
- from domain 100 to 101

```
docker run -dt --rm \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -v /path/to/identity_ca.pem:/rti/security/dds/identity_ca.pem \
        -v /path/to/permissions_ca.pem:/rti/security/dds/permissions_ca.pem \
        -v /path/to/identity_certificate.pem:/rti/security/dds/identity_certificate.pem \
        -v /path/to/private_key.pem:/rti/security/dds/private_key.pem \
        -v /path/to/governance.p7s:/rti/security/dds/governance.p7s \
        -v /path/to/permissions.p7s:/rti/security/dds/permissions.p7s \
        -v /path/to/identity_ca_output.pem:/rti/security/dds/identity_ca_output.pem \
        -v /path/to/permissions_ca_output.pem:/rti/security/dds/permissions_ca_output.pem \
        -v /path/to/identity_certificate_output.pem:/rti/security/dds/identity_certificate_output.pem \
        -v /path/to/private_key_output.pem:/rti/security/dds/private_key_output.pem \
        -v /path/to/governance_output.p7s:/rti/security/dds/governance_output.p7s \
        -v /path/to/permissions_output.p7s:/rti/security/dds/permissions_output.p7s \
        -e OBSERVABILITY_DOMAIN=100 \
        -e OBSERVABILITY_OUTPUT_DOMAIN=101 \
        -e OBSERVABILITY_OUTPUT_COLLECTOR_PEER="udpv4_wan://50.10.23.45:16000" \
        -e CFG_NAME="SecureForwarderLANtoWAN" \
        --name=collector_service \
        rticom/collector-service:latest
```

The following example runs _Collector Service_:
- in Forwarder mode
- non-securely
- forwarding from LAN to LAN
- from domain 100 to 101

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -e OBSERVABILITY_DOMAIN=100 \
        -e OBSERVABILITY_OUTPUT_DOMAIN=101 \
        -e OBSERVABILITY_OUTPUT_COLLECTOR_PEER="builtin.udpv4://50.10.23.45" \
        -e CFG_NAME="NonSecureForwarderLANtoLAN" \
        --name=collector_service \
        rticom/collector-service:latest
```

## Custom configuration

**Note:** Custom XML configurations are not officially supported in this release.
The format of the configuration file is not described in the documentation,
and it is subject to change in future releases. If you need to provide your own
configuration, please contact RTI Support (support@rti.com).

To provide your own configuration, follow these steps when running the container:

- bind-mount your configuration file (for example, MyCollectorService.xml) from the host
  into the following location in the Docker container:
  `/home/rtiuser/rti_workspace/7.6.0/user_config/collector_service/USER_COLLECTOR_SERVICE.xml`
- select the _Collector Service_ configuration in the configuration file by
  setting the `CFG_NAME` environment variable

For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -v $PWD/MyCollectorService.xml:/home/rtiuser/rti_workspace/7.6.0/user_config/collector_service/USER_COLLECTOR_SERVICE.xml \
        -e CFG_NAME="MyCollectorService" \
        --name=collector_service \
        rticom/collector-service:latest
```

## Command-line parameters

You can provide your command-line parameters to _Collector Service_ by adding
them to the end of the `docker run` command. For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -v $PWD/MyCollectorService.xml:/home/rtiuser/rti_workspace/7.6.0/user_config/collector_service/USER_COLLECTOR_SERVICE.xml \
        -e CFG_NAME="MyCollectorService" \
        --name=collector_service \
        rticom/collector-service:latest \
        -verbosity WARN
```

The previous command runs _Collector Service_ with the verbosity level set to WARN.

The only command-line parameter supported in this release is **-verbosity**.

To see the list of allowed parameters, use the `-h` parameter:

```
docker run --rm -t rticom/collector-service:latest -h
```

## Network configuration

The previous examples use the `--network host` parameter to run the containers in the host network. The host network is the most straightforward way to run the containers, because it allows the containers to communicate with each other and with the host machine. However, the host network is not available on all platforms and has different levels of support depending on the operating system.

If you want to run the containers in a custom network isolated from the host network, you can create a custom network using `docker network create` and run the containers in that network. See the [Docker networking overview documentation](https://docs.docker.com/network/) for more information on Docker networks.

If you want to make the containers accessible from outside the Docker environment without using the host network, the recommendation is to use _RTI Real-Time WAN Transport_ and expose the necessary UDP ports using the `-p` option. For more information on _RTI Real-Time WAN Transport_, refer to the [RTI Real-Time WAN Transport documentation](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/users_manual/users_manual/PartRealtimeWAN.htm). For more information on the `-p` option, refer to the [Docker running containers documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports).

The following built-in configuration profiles use _RTI Real-Time WAN Transport_:
- NonSecureForwarderLANtoWAN
- NonSecureForwarderWANtoWAN
- SecureForwarderLANtoWAN
- SecureForwarderWANtoWAN
- SecureWAN
- NonSecureWAN
- SecureOTelWAN
- NonSecureOTelWAN
- NonSecureRemoteDebuggingWAN
- SecureRemoteDebuggingWAN

For example, to run _Collector Service_ in non-host network mode and make it accessible from outside the Docker environment using _RTI Real-Time WAN Transport_, you can run a Docker container as follows:

```
docker run -dt --rm \
        -p 30000:30000/udp \
        -p 19098:19098 \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -e CFG_NAME="NonSecureWAN" \
        -e OBSERVABILITY_DOMAIN=33 \
        -e OBSERVABILITY_RWT_PUBLIC_ADDRESS="<public-hostname-or-ip>" \
        -e OBSERVABILITY_RWT_PORT=30000 \
        -e OBSERVABILITY_CONTROL_PORT=19098 \
        -e OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME="<public-hostname-or-ip>" \
        -e OBSERVABILITY_CONTROL_PUBLIC_PORT=19098 \
        --name=collector_service \
        rticom/collector-service:latest
```

In the previous example, it is really important to use the -p option
to map the UDP port 30000 and the TCP port 19098 from the host to the container.

For the sake of simplicity, the previous example does not use security.

## Running Collector Service behind Firewall/NAT

When running _Collector Service_ behind a firewall or NAT, the recommendation is to use _RTI Real-Time WAN Transport_ to communicate with _Connext_ applications or other _Collector Service_ instances. This is because _RTI Real-Time WAN Transport_ can be configured to use a single UDP port for communication, which can be easily opened in the firewall or NAT.

See the previous section for an example of how to run _Collector Service_ using _RTI Real-Time WAN Transport_.

## Running Collector Service in ARM-based systems

There is no official RTI Collector Service Docker image for ARM-based 
systems. However, you can run the x86_64 _Collector Service_ Docker image on 
ARM-based systems using emulation with QEMU. This is possible because Docker 
Desktop for Mac and Windows includes support for running x86_64 images on 
ARM-based systems using QEMU.

To run the x86_64 _Collector Service_ Docker image on an ARM-based system, you
can use the same `docker run` command as you would on an x86_64 system along
with the `--platform linux/amd64` parameter. For example:

```
docker run -dt \
        --platform linux/amd64 \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        --name=collector_service \
        rticom/collector-service:latest
```

## Running Collector Service in WSL2

There are several ways to run Collector Service in WSL2, depending on your network configuration and requirements.

The simplest and most reliable approach for enabling communication between WSL2 and external _Connext_ applications is to use mirrored networking mode. This mode eliminates the complexities of the default NAT-based architecture by placing your WSL2 instance on the same network as your Windows host.

Additionally, Windows Firewall may block some of the traffic between WSL2, the host, or other machines. To address this, you can run _Collector Service_ using the _RTI Real-Time WAN Transport_ inside WSL2. This option gives you control over the UDP port used by _Collector Service_ so you can explicitly open it in Windows Firewall.

Here is an example of how to run _Collector Service_ in WSL2 using mirrored networking mode and _RTI Real-Time WAN Transport_:

```
docker run -dt --rm \
        -p 30000:30000/udp \
        -p 19098:19098 \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.6.0/rti_license.dat \
        -e CFG_NAME="NonSecureWAN" \
        -e OBSERVABILITY_DOMAIN=33 \
        -e OBSERVABILITY_RWT_PUBLIC_ADDRESS="<public-hostname-or-ip>" \
        -e OBSERVABILITY_RWT_PORT=30000 \
        -e OBSERVABILITY_CONTROL_PORT=19098 \
        -e OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME="<public-hostname-or-ip>" \
        -e OBSERVABILITY_CONTROL_PUBLIC_PORT=19098 \
        --name=collector_service \
        rticom/collector-service:latest
```

For the sake of simplicity, the previous example does not use security.

To configure mirrored networking mode in WSL2, follow these steps:

1. Create or edit your .wslconfig file under `C:\Users\<YourUsername>\.wslconfig` and add the following lines:

    ```
    [wsl2]
    networkingMode=mirrored
    ```

    __Note__: You can also set the networking mode by using the _Windows Subsystem for Linux Settings_ application.

2. Restart WSL to apply changes:

    ```sh
    wsl --shutdown
    ```

3. From inside WSL2, run:

    ```sh
    ip -4 addr show eth0
    ```

    This command will display the IP address assigned to your WSL2 instance. You 
    can use this IP address to configure your _Connext_ applications to communicate 
    with _Collector Service_ running in WSL2.

    This IP address should be the same as the IP address of your Windows host.

    If your Windows host has multiple network interfaces, WSL2 may be assigned several of those IP addresses. In that case, use the externally reachable IP address when configuring your _Connext_ applications.

Here is an example of how to open a port in Windows Firewall using command line:

```sh
netsh advfirewall firewall add rule name="Open UDP Port 30000" dir=in action=allow protocol=UDP localport=30000
netsh advfirewall firewall add rule name="Open TCP Port 19098" dir=in action=allow protocol=TCP localport=19098
``` 

Alternatively, you can open the port using the Windows Defender Firewall with 
Advanced Security GUI.

## Known issues

### RTI Infrastructure Services cannot emit telemetry data

For RTI Infrastructure Services to emit telemetry data, _RTI Monitoring Library 2.0_ must be enabled for and available to the services.
The _Connext_ host installation packages erroneously do not contain the _Monitoring Library 2.0_ distribution. Therefore, for Infrastructure Services to emit telemetry data, you need to:

- enable _Monitoring Library 2.0_ by configuring the XML configuration file, and
- make _Monitoring Library 2.0_ available by installing the appropriate target package (if you only installed the host package).

Follow the steps below to enable _Monitoring Library 2.0_, then install and configure the appropriate _Connext_ target package to make it available to the RTI Infrastructure Services.

1.  To enable _Monitoring Library 2.0_ in an RTI Infrastructure Service, add the XML code snippet shown below to
    any of the following XML QoS profiles.

    - NDDS_QOS_PROFILES.xml, located in the _Web Integration Service_ working directory

    - USER_QOS_PROFILES.xml, located in the _Web Integration Service_ working directory

    - Any XML file included in the NDDS_QOS_PROFILES environment variable

            <participant_factory_qos>
                <monitoring>
                    <enable>true</enable>
                    <application_name>Monitored Service</application_name>
                    <telemetry_data>
                        <metrics>
                            <element>
                                <resource_selection>//*</resource_selection>
                                <enabled_metrics_selection>
                                    <element>*</element>
                                </enabled_metrics_selection>
                            </element>
                        </metrics>
                    </telemetry_data>
                </monitoring>
            </participant_factory_qos>

    The profile containing the snippet must have _is_default_participant_factory_profile_ set to true.
    For more information on configuring _Monitoring Library 2.0_ see [MONTORING QosPolicy](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/users_manual/users_manual/MONITORING_QosPolicy.htm).

    The following example is a complete profile:

             <?xml version="1.0"?>
                 <dds>
                     <qos_library name="MonitoringEnabledLibrary">
                         <qos_profile name="MonitoringEnabledProfile" is_default_participant_factory_profile="true">
                             <participant_factory_qos>
                                 <monitoring>
                                     <enable>true</enable>
                                     <application_name>Monitored Service</application_name>
                                     <telemetry_data>
                                         <metrics>
                                             <element>
                                                 <resource_selection>//*</resource_selection>
                                                 <enabled_metrics_selection>
                                                     <element>*</element>
                                                 </enabled_metrics_selection>
                                             </element>
                                         </metrics>
                                     </telemetry_data>
                                 </monitoring>
                             </participant_factory_qos>
                     </qos_library>
                 </dds>

2.  Install the appropriate _Connext_ target package for your architecture, as described in the
    [RTI Connext Installation Guide](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/installation_guide/installing.html).

3.  After the target package is installed, configure your system so that the RTI services can load the library.
    This can be done in one of two ways, as shown below. Only one of the following methods is required.

    - Set the library search path to include the _Connext_ target library install directory.

      - macOS - Add the Connext target directory to the DYLD_LIBRARY_PATH variable. An example <architecture> would be _x64Darwin20clang12.0_.

              DYLD_LIBRARY_PATH=${NDDSHOME}/lib/<architecture>:${DYLD_LIBRARY_PATH}

      - Linux - Add the Connext target directory to the LD_LIBRARY_PATH variable. An example <architecture> would be _x64Linux4gcc8.5.0_.

              LD_LIBRARY_PATH=${NDDSHOME}/lib/<architecture>:${LD_LIBRARY_PATH}

      - Windows - Add the Connext target directory to the Path variable. An example \<architecture> would be _x64Win64VS2017_.

              Path=%NDDSHOME%\lib\<architecture>; %Path%

    - Alternatively, copy the required _Monitoring Library 2.0_ files from the target library directory to the host resource directory.

      - macOS - Copy the _Monitoring Library 2.0_ files from the target library directory to the host resource directory. An example of \<architecture>
        would be _x64Darwin20clang12.0_.

              % cp ${NDDSHOME}/lib/<architecture>/librtimonitoring2*.* ${NDDSHOME}/resource/app/lib/<architecture>

      - Linux - Copy the _Monitoring Library 2.0_ files from the target library directory to the host resource directory. An example of \<architecture>
        would be _x64Linux4gcc8.5.0_.

              $ cp ${NDDSHOME}/lib/<architecture>/librtimonitoring2*.* ${NDDSHOME}/resource/app/lib/<architecture>

      - Windows - Copy the _Monitoring Library 2.0_ files from the target library directory to the host resource directory. An example
        \<architecture> would be _x64Win64VS2017_.

              C:\>copy ${NDDSHOME}/lib/<architecture>/rtimonitoring2*.* ${NDDSHOME}/resource/app/lib/<architecture>

## Release Notes

Release notes for RTI _Connext_ products are available on the RTI Community Portal at https://community.rti.com/documentation. For patch release notes, contact our support team at support@rti.com to request the relevant Release Notes Supplement. For Docker image release notes, check RTI’s Github containers repository at https://github.com/rticommunity/rticonnextdds-containers.

## License

RTI® Collector Service is licensed under the following supplemental license terms and the Software License Agreement accompanying RTI Connext® Professional (https://www.rti.com/free-trial/terms).

This image uses Ubuntu as the base image, and your usage must comply with the applicable license terms found [here](https://hub.docker.com/_/ubuntu).

You can find the Software Bill of Materials (SBOM) third-party information in SPDX format in the `/user/local/share/sbom/` directory.

Additional third party information can be found at https://community.rti.com/documentation#doc_third_party.

Use the following command to retrieve the _RTI_License_Agreement.pdf_ built-in file:

```
docker cp collector_service:/opt/rti.com/rti_connext_dds-7.6.0/RTI_License_Agreement.pdf .
```

## How to get a license file

An RTI license file is always required to run Collector Service in a Docker container.

### Existing customers

If you are an RTI customer, and you need an RTI Connext license file, contact [RTI support](https://www.rti.com/support).

### Evaluators

If you are not an RTI customer, visit https://www.rti.com/free-trial/connext to get an RTI Connext free trial for release 7.6.0 or higher. With the free trial you will receive a limited time license file that contains an activation key for RTI Connext Professional, RTI Security Plugins, RTI Real-Time WAN Transport, and RTI Cloud Discovery Service.

To get a free trial license for earlier releases, contact evaluations@rti.com.

### RTI Supplemental License

This RTI Supplemental License ("Supplemental License") is for the accompanying RTI container image ("Container Image"). Real-Time Innovations, Inc. ("RTI") licenses the Container Image to you only if you agree to comply with all of the terms and conditions of this Supplemental License.

The Container Image may only be used with a validly licensed copy of RTI Connext software (the "Host Software") licensed from RTI (the agreement pursuant to which you licensed the Host Software is the "Host License Agreement").

You may not use the Container Image if you do not have a current Host License Agreement. Certain restrictions and additional terms may apply, which are described herein. If any terms or conditions in this Supplemental License conflict with the Host License Agreement, then this Supplemental License shall govern solely with respect to the Container Image. BY ACCEPTING THIS SUPPLEMENTAL LICENSE OR USING THE CONTAINER IMAGE, YOU AGREE TO ALL OF THE TERMS AND CONDITIONS IN THIS SUPPLEMENTAL LICENSE ON BEHALF OF YOURSELF AND THE ENTITY THAT LICENSED THE HOST SOFTWARE UNDER THE HOST LICENSE AGREEMENT. IF YOU DO NOT AGREE WITH THE TERMS AND CONDITIONS OF THIS SUPPLEMENTAL LICENSE, OR YOU DO NOT HAVE THE AUTHORITY TO BIND THE ENTITY THAT LICENSED THE HOST SOFTWARE UNDER THE HOST LICENSE AGREEMENT TO THIS SUPPLEMENTAL LICENSE, YOU MAY NOT USE THE CONTAINER IMAGE.

**Host License Agreement.** The Host License Agreement applies to your use of the Container Image and any application you create using, or in which you incorporate, the Container Image.

**Use Rights.** The Container Image may be used only in connection with configuring, testing, and using the Host Software. Notwithstanding RTI’s provision, and your use, of the Container Image, you are solely responsible for, and bear the entire risk of: (a) configuring the Host Software for your application, and (b) the performance or non-performance of your application. Updates to the Host Software may not update the Container Image. RTI is not obligated to provide any updates or support for the Container Image.

**Restrictions.** You may not remove this Supplemental License document file from the Container Image. You may not reverse engineer, decompile, or disassemble the Container Image, or attempt to do so, except and only to the extent required by third party licensing terms governing the use of certain open-source components that may be included with the software. Additional restrictions in the Host License Agreement may apply.

**Disclaimer of Warranties.** The Container Image is provided to you on an "AS IS" basis, and RTI disclaims, to the maximum extent permitted by applicable law, all express and implied representations, warranties and guarantees, including without limitation, the implied warranties of merchantability, fitness for a particular purpose, satisfactory quality, and non-infringement of third party rights.

**Feedback.** Any suggestions or ideas you provide to RTI regarding the Container Image (collectively, "Feedback"), may be used and exploited in any and every way by RTI (including without limitation, by granting sublicenses), on a non-exclusive, perpetual, irrevocable, transferable, and worldwide basis, without any compensation, without any obligation to report on such use, and without any other restriction or obligation to you.

**Limitation of Liability.** TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT WILL RTI BE LIABLE TO YOU FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR PUNITIVE OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR FOR LOST PROFITS, LOST DATA, LOST REPUTATION, OR COST OF COVER, REGARDLESS OF THE FORM OF ACTION WHETHER IN CONTRACT, TORT (INCLUDING WITHOUT LIMITATION, NEGLIGENCE), STRICT PRODUCT LIABILITY OR OTHERWISE, WHETHER ARISING OUT OF OR RELATING TO THE USE OR INABILITY TO USE THE CONTAINER IMAGE, EVEN IF RTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

**OSS.** Certain items of independent, third-party code may be included within the software in the Container Image that are subject to the GNU General Public License ("GPL") or other open source licenses (such third-party code collectively, "Open Source Software" or "OSS"). Such Open Source Software is licensed under the terms and conditions of the license that accompanies such Open Source Software (the "OSS Terms"). Nothing herein or in the Host License Agreement limits your rights under, or grants you rights that supersede, the OSS Terms applicable to the corresponding Open Source Software. In particular, nothing herein restricts your right to copy, modify, and distribute such Open Source Software that is subject to the terms of the GPL. The OSS Terms and OSS required notices are provided in the [License](#license) section of this document. By accepting the Supplemental License, you are also accepting the OSS Terms for the corresponding Open Source Software. If you do not agree to any provision of the OSS Terms for the corresponding Open Source Software, you should not download or use this Container Image.

**General.** This Supplemental License constitutes the entire agreement between the parties pertaining to the subject matter hereof, and supersedes any and all written or oral agreements previously existing between the parties with respect to the subject matter hereof. Any additional or different terms in any purchase order from You are deemed material and expressly rejected by RTI. You agree that this Agreement will not be construed against RTI by virtue of having drafted them.
