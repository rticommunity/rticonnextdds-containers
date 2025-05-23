*RTI® Observability Collector Service* is a component of the
*RTI Connext® Observability Framework*, a solution that scalably collects telemetry data
from *RTI Connext* applications and distributes this data to third-party observability backends
or *RTI Admin Console*. 

For metrics, logs, and security events *Collector Service* provides native integration
with Prometheus®, as the time-series database to store *Connext* metrics, and Grafana® Loki™,
as the log aggregation system to store *Connext* logs. Integration with other backends is
possible using [OpenTelemetry™](https://opentelemetry.io/) and the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/).
For additional information on *RTI Connext Observability Framework*, see the [RTI documentation](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/addon_products/observability/index.html#).

*Collector Service* also collects non-metric data (configuration and discovery data) that is
currently consumed by *Admin Console* to support the remote debugging feature. For additional information on remote debugging with *Admin Console* see [Remote Debugging](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/connext_dds_professional/tools/admin_console/p2_administration/features_reference/ref_remote_debugging.html#remote-debugging-experimental).

## Releases

The documentation on this page applies to the *Collector Service* Docker image with the `latest` tag, which refers to the most recent image released by RTI. To confirm the *Connext* release that corresponds to the `latest` tag, or to review the other *Connext* releases that support the *Collector Service* image, go to https://hub.docker.com/r/rticom/collector-service/tags.

For documentation on previous releases of the *Collector Service* image, refer to the https://github.com/rticommunity/rticonnextdds-containers repository.

## Using the Collector Service container image

Running *Collector Service* on Docker is as simple as running the ``docker run`` command:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
        --name=collector_service \
        rticom/collector-service:latest
```

The above command starts *Collector Service* with a default configuration 
that stores the metrics and logs emitted by *Connext* applications using 
[Connext Monitoring Library 2.0](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/addon_products/observability/library.html)
on domain ID 2 into Prometheus (for metrics) and Grafana Loki (for logs) 
databases. The *Collector Service* also collects and distributes the non-metric
data required for the *Admin Console* remote debugging feature.

With the default configuration, *Collector Service* runs a Prometheus client that 
spawns an HTTP server on port 19090 and a Grafana Loki HTTP client that connects 
to a Grafana Loki server running on port 3100. It also creates a server on port
19098 that provides HTTP control of metrics and logs as well as the distribution
of non-metric data for *Admin Console* remote debugging.

An RTI license file is always required to run *Collector Service* in a Docker 
container. Bind-mount your license from the host by using the following 
command-line parameter:

```
-v /path/to/your_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat
```

The *Collector Service* container image uses the following user and group:

* User: rtiuser (1000)
* Group: rtigroup (1000)

The *Collector Service* container image uses the following working directory:

* ```/home/rtiuser/rti_workspace/7.5.0/user_config/collector_service```

The following table indicates the RTI licenses required based on your answers 
to the questions in the first two columns.

|Do you need to secure telemetry data exchanged between applications and *Collector Service* using *RTI Security Plugins*?|Do you need to send telemetry data to *Collector Service* over the WAN using *RTI Real-Time WAN Transport*?|Required License|
|-------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|----------------|
|NO|NO|Connext Professional|
|YES|NO|Connext Professional and Security Plugins|
|YES|YES|Connext Professional, Security Plugins, Cloud Discovery Service, and Real-Time WAN Transport|
|NO|YES|Connext Professional, Cloud Discovery Service, and Real-Time WAN Transport|

## Built-in configuration

The built-in configuration file used by *Collector Service* can be retrieved using the following command:

```
docker cp collector_service:/opt/rti.com/rti_connext_dds-7.5.0/resource/xml/RTI_COLLECTOR_SERVICE.xml .
```
The built-in configuration supports the following execution modes:

|Configuration Name|Network|Metric and Log Storage|Remote Debugging|Security|
|------------------|-------|------------|----------------|--------|
|NonSecureLAN|LAN|Prometheus and Grafana Loki|Yes|No|
|NonSecureWAN|WAN|Prometheus and Grafana Loki|Yes|No|
|SecureLAN|LAN|Prometheus and Grafana Loki|Yes|Yes|
|SecureWAN|WAN|Prometheus and Grafana Loki|Yes|Yes|
|NonSecureOTelLAN|LAN|Multiple through OpenTelemetry Collector|Yes|No|
|NonSecureOTelWAN|WAN|Multiple through OpenTelemetry Collector|Yes|No|
|SecureOTelLAN|LAN|Multiple through OpenTelemetry Collector|Yes|Yes|
|SecureOTelWAN|WAN|Multiple through OpenTelemetry Collector|Yes|Yes|
|SecureRemoteDebugging|WAN|None|Yes|Yes|
|NonSecureRemoteDebugging|LAN|None|Yes|No|

**Note:** The SecureRemoteDebugging built-in configuration has an error in it. See the
Known Issues section below on how to correct this.

In LAN modes, *Collector Service* uses *UDPv4* and *SHMEM* Transports to 
receive telemetry data from *Connext* applications and runs on the same LAN 
where the applications run.

In WAN modes, *Collector Service* uses *RTI Real-Time WAN Transport* to 
receive telemetry data from *Connext* applications and runs on a WAN. For 
example, *Collector Service* may run in an AWS instance while the 
*Connext* applications may run on-premise.

The default execution mode is *NonSecureLAN*. To select a different execution 
mode, set the environment variable ``CFG_NAME`` to the name of the configuration 
file you want to use. For example, to run *Collector Service* in *SecureLAN*
mode, set the environment variable ``CFG_NAME`` to *SecureLAN*.

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
        -e CFG_NAME="SecureLAN" \
        --name=collector_service \
        rticom/collector-service:latest
```

When using built-in configurations that provide metric and log storage, the
configuration assumes that the following components are running on the same host where
*Collector Service* runs: 
* Prometheus server
* Grafana Loki server
* OpenTelemetry Collector

In addition to the configuration name, there are other parameters you can 
set using environment variables when running the Docker container:

**General Parameters**

```
-e OBSERVABILITY_DOMAIN=<The domain ID in which Collector Service receives the telemetry data from Connext applications. default: 2>
-e OBSERVABILITY_CONTROL_PORT=<The private TCP port to access the Collector Service control server for external commands and to distribute non-metric data for Admin Console remote debugging. This is the port the service listens to. default: 19098>
-e OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME=<The public hostname to access the Collector Service control server from a public network. default: localhost>
-e OBSERVABILITY_CONTROL_PUBLIC_PORT=<The public TCP port to access the Collector Service control server from a public network. default: 19098>
```

**Security Parameters**

```
-e OBSERVABILITY_BASIC_AUTH_USERNAME=<The username to authenticate the HTTP connections (client) created by Collector Service. default: user>
-e OBSERVABILITY_BASIC_AUTH_PASSWORD=<The password to authenticate the HTTP connections (client) created by Collector Service. default: userpassword>
```

The above parameters are used by the HTTP clients created by 
*Collector Service* to send telemetry data to third-party backends (for example,
Prometheus, Grafana Loki, and OpenTelemetry Collector).

**WAN Parameters**

```
-e OBSERVABILITY_RWT_PORT=<Both the private and public UDP port of Collector Service in which it will receive telemetry data from Connext applications using Real-Time WAN Transport. default: 30000>
-e OBSERVABILITY_RWT_PUBLIC_ADDRESS=<The public address of Collector Service in which it will receive telemetry data from Connext applications using Real-Time WAN Transport. default: localhost>
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

For example, to run a *Collector Service* instance with public address 
10.10.1.34:16000 that collects all telemetry data published by *Connext* 
applications over the WAN on domain 33, you can run a Docker container as 
follows:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
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
> ```
> -e OBSERVABILITY_CONTROL_PORT=19098
> -e OBSERVABILITY_CONTROL_PUBLIC_PORT=19098
> ```
>
> Secure port example:
> ```
> -e OBSERVABILITY_CONTROL_PORT=19098s
> -e OBSERVABILITY_CONTROL_PUBLIC_PORT=19098s
> ```

When running one of the secure configurations, the following security artifacts
must be mounted into the container. 

**To configure the *RTI Security Plugins*:**

```
-v /path/to/identity_ca.pem:/rti/security/dds/identity_ca.pem
-v /path/to/permissions_ca.pem:/rti/security/dds/permissions_ca.pem
-v /path/to/identity_certificate.pem:/rti/security/dds/identity_certificate.pem
-v /path/to/private_key.pem:/rti/security/dds/private_key.pem
-v /path/to/governance.p7s:/rti/security/dds/governance.p7s
-v /path/to/permissions.p7s:/rti/security/dds/permissions.p7s
```

* *identity_ca.pem* must contain the certificate of the CA that signed the
*identity_certificate.pem*.
* *identity_certificate.pem* must contain the certificate of the *Collector
Service*.
* *private_key.pem* must contain the private key of the *Collector Service*.
* *permissions_ca.pem* must contain the certificate of the CA that signed the
*permissions.p7s* and *governance.p7s*.
* *governance.p7s* must contain the governance file of the *Collector Service*.
* *permissions.p7s* must contain the permissions file of the *Collector Service*.

For additional information on how to generate these security artifacts, see
[Generating the Observability Framework Security Artifacts](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/addon_products/observability/security.html#generating-the-observability-framework-security-artifacts).

**To configure HTTPS + Basic Authentication:**

*Collector Service* uses HTTPS + Basic Authentication to encrypt and
authenticate the HTTP connections created by *Collector Service* to send
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

* *rootCALoki.crt* must contain the root certificate of the CA that signed the
*server.pem* certificate used to communicate with the Grafana Loki server.
* *rootCAOtel.crt* must contain the root certificate of the CA that signed the
*server.pem* certificate used to communicate with the OpenTelemetry Collector.
* *serverPrometheusEndpoint.pem* must contain both a valid server certificate 
and the corresponding private key for the Prometheus endpoint created
by *Collector Service*. The Prometheus endpoint is an HTTPS server that
provides metrics to a Prometheus server.
* *serverControl.pem* must contain both a valid server certificate and the
corresponding private key for the control server created by 
*Collector Service*. The control server is an HTTPS server that receives
commands from external clients such as the Grafana dashboards running in your
browser.
* *htdigest_control* is a password file that contains the username and password 
for BASIC-Auth. This file is used by the Controllability HTTP server started by *Collector Service*
to authenticate the HTTP connections created by external clients (for example, to change the verbosity
of an application). The htdigest file can be created using the 
[Apache htdigest tool](https://httpd.apache.org/docs/2.4/programs/htdigest.html).
* *htdigest_prometheus* is a password file that contains the username and password 
for BASIC-Auth. This file is used by the Prometheus HTTP server started by *Collector Service*
to authenticate the HTTP connections created by external clients (for example, a Prometheus scraping request). The htdigest file can be created using the 
[Apache htdigest tool](https://httpd.apache.org/docs/2.4/programs/htdigest.html).

Depending on your security configuration, you may not need to provide all the
files listed above. For example, if you are not running OpenTelemetry Collector,
you do not need to provide *rootCAOtel.crt*.

For additional information on how to generate these security artifacts, see
[Generating the Observability Framework Security Artifacts](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/addon_products/observability/security.html#generating-the-observability-framework-security-artifacts).

## Remote debugging configuration for Admin Console

If you are not running the full *RTI Connext Observability Framework*, only the
*Collector Service* component is required to support remote debugging in
*Admin Console*. The built-in configurations SecureRemoteDebugging and
NonSecureRemoteDebugging support just the remote debugging feature. 

The following example runs the *Collector Service* to support remote debugging in secure mode:

```
docker run -dt --rm \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
        -v /path/to/serverControl.pem:/rti/security/https/serverControl.pem \
        -v /path/to/htdigest_control:/rti/security/https/htdigest_control \
        -e OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME="public-hostname" \
        -e OBSERVABILITY_HOSTNAME="hostname" \
        -e OBSERVABILITY_CONTROL_PORT="19098s" \
        -e OBSERVABILITY_CONTROL_PUBLIC_PORT="19098s" \
        -e CFG_NAME="SecureRemoteDebugging" \
        --name=collector_service \
        rticom/collector-service:latest
```

The following example runs the *Collector Service* to support remote debugging non-secure mode:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
        -e CFG_NAME="NonSecureRemoteDebugging" \
        --name=collector_service \
        rticom/collector-service:latest
```

## Custom configuration

**Note:** Custom XML configurations are not officially supported in this release.
The format of the configuration file is not described in the documentation,
and it is subject to change in future releases. If you need to provide your own 
configuration, please contact RTI Support (support@rti.com).

To provide your own configuration, follow these steps when running the container:

* bind-mount your configuration file (for example, MyCollectorService.xml) from the host 
into the following location in the Docker container: 
```/home/rtiuser/rti_workspace/7.5.0/user_config/collector_service/USER_COLLECTOR_SERVICE.xml```
* select the *Collector Service* configuration in the configuration file by 
setting the ``CFG_NAME`` environment variable

For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
        -v $PWD/MyCollectorService.xml:/home/rtiuser/rti_workspace/7.5.0/user_config/collector_service/USER_COLLECTOR_SERVICE.xml \
        -e CFG_NAME="MyCollectorService" \
        --name=collector_service \
        rticom/collector-service:latest
```

## Command-line parameters

You can provide your command-line parameters to *Collector Service* by adding 
them to the end of the ``docker run`` command. For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
        -v $PWD/MyCollectorService.xml:/home/rtiuser/rti_workspace/7.5.0/user_config/collector_service/USER_COLLECTOR_SERVICE.xml \
        -e CFG_NAME="MyCollectorService" \
        --name=collector_service \
        rticom/collector-service:latest \
        -verbosity WARN
```

The previous command runs *Collector Service* with the verbosity level set to WARN.

The only command-line parameter supported in this release is **-verbosity**.

To see the list of allowed parameters, use the ``-h`` parameter:

```
docker run --rm -t rticom/collector-service:latest -h
```

## Network configuration

The previous examples use the ``--network host`` parameter to run the containers in the host network. The host network is the most straightforward way to run the containers, because it allows the containers to communicate with each other and with the host machine. However, the host network is not available on all platforms and has different levels of support depending on the operating system.

If you want to run the containers in a custom network isolated from the host network, you can create a custom network using `docker network create` and run the containers in that network. See the [Docker networking overview documentation](https://docs.docker.com/network/) for more information on Docker networks.

If you  want to make the containers accessible from outside the Docker environment without using the host network, the recommendation is to use RTI Real-Time WAN Transport and expose the necessary UDP ports using the `-p` option. For more information on RTI Real-Time WAN Transport, refer to the [RTI Real-Time WAN Transport documentation](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/connext_dds_professional/users_manual/users_manual/PartRealtimeWAN.htm). For more information on the `-p` option, refer to the [Docker running containers documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports).

The following built-in configuration modes use the RTI Real-Time WAN Transport:
* SecureWAN
* NonSecureWAN
* SecureOTelWAN
* NonSecureOTelWAN

## Known issues

### SecureRemoteDebugging XML configuration not working

The SecureRemoteDebugging XML built-in configuration includes an error that prevents it from working as intended. As a workaround, perform the following steps to correct the error.

Note: The CONTAINER ID used below is an example only.

1. Run the *Collector Service* Docker image using the ``docker run`` command. Use the correct path for your license file. 

        $ docker run -dt \
                --network host \
                -v /path/to/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
                -e CFG_NAME="NonSecureLAN" \
                --name=collector_service \
                rticom/collector-service:7.5.0

2. Run ``docker ps`` to confirm the image is running. Take note of your CONTAINER ID. 

        $ docker ps -a
        CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
        06c96c0daa35   rticom/collector-service:7.5.0   "rtientrypoint rtico…"   30 seconds ago   Up 30 seconds             collector_service
    
3. Using your CONTAINER ID, run ``docker cp <container id>:<path inside container> <local path>`` to copy the RTI_COLLECTOR_SERVICE.xml
   configuration file from the container to a local directory. For example:

        $ docker cp 06c96c0daa35:/opt/rti.com/rti_connext_dds-7.5.0/resource/xml/RTI_COLLECTOR_SERVICE.xml RTI_COLLECTOR_SERVICE.xml

4. Use the ``cat <local path>`` command to display the contents of the local copy of RTI_COLLECTOR_SERVICE.xml. Look for the
   SecureRemoteDebugging configuration section shown below.

        $ cat RTI_COLLECTOR_SERVICE.xml
             ...
            </collector_service>

            <collector_service name="SecureRemoteDebugging">
                <!-- Input connection: DDS -->
                <receivers>
                    <dds_receiver>
                        <domain_id>$(OBSERVABILITY_DOMAIN)</domain_id>
                        <domain_participant_qos base_name="CollectorQosLibrary::NonSecureDDSLAN"/>
                    </dds_receiver>
                </receivers>
                <!-- Output connection: exporting via WebSocket -->
                <exporters>
                    <websocket_exporter>
                        <telemetry_mask>OBSERVABLE</telemetry_mask>
                    </websocket_exporter>
                </exporters>
                <control>
                    <http_server>
                        <hostname>$(OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME)</hostname>
                        <listening_port>$(OBSERVABILITY_CONTROL_PORT)</listening_port>
                        <public_listening_port>$(OBSERVABILITY_CONTROL_PUBLIC_PORT)</public_listening_port>
                        <ssl_certificate>
                            /rti/security/https/serverControl.pem
                        </ssl_certificate>
                        <authentication_domain>
                            $(OBSERVABILITY_HOSTNAME)
                        </authentication_domain>
                        <global_auth_file>
                            $(OBSERVABILITY_CONTROL_BASIC_AUTH_FILE)
                        </global_auth_file>
                    </http_server>
                </control>
            </collector_service>
        </dds>

5. Open the local copy of RTI_COLLECTOR_SERVICE.xml in a text editor. In the SecureRemoteDebugging section, change the
   <domain_participant_qos base_name> from "CollectorQosLibrary::NonSecureDDSLAN"
   to "CollectorQosLibrary::SecureDDSWAN," as shown below.

        <collector_service name="SecureRemoteDebugging">
            <!-- Input connection: DDS -->
            <receivers>
                <dds_receiver>
                    <domain_id>$(OBSERVABILITY_DOMAIN)</domain_id>
                    <domain_participant_qos base_name="CollectorQosLibrary::SecureDDSWAN"/>
                </dds_receiver>
            </receivers>
            <!-- Output connection: exporting via WebSocket -->
            <exporters>
                <websocket_exporter>
                    <telemetry_mask>OBSERVABLE</telemetry_mask>
                </websocket_exporter>
            </exporters>
            <control>
                <http_server>
                    <hostname>$(OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME)</hostname>
                    <listening_port>$(OBSERVABILITY_CONTROL_PORT)</listening_port>
                    <public_listening_port>$(OBSERVABILITY_CONTROL_PUBLIC_PORT)</public_listening_port>
                    <ssl_certificate>
                        /rti/security/https/serverControl.pem
                    </ssl_certificate>
                    <authentication_domain>
                        $(OBSERVABILITY_HOSTNAME)
                    </authentication_domain>
                    <global_auth_file>
                        $(OBSERVABILITY_CONTROL_BASIC_AUTH_FILE)
                    </global_auth_file>
                </http_server>
            </control>
        </collector_service>

6. Run ``docker cp <container id>: <local path> <path inside container>`` to copy the locally edited RTI_COLLECTOR_SERVICE.xml file back into 
   the *Collector Service* container. For example:

        $ docker cp RTI_COLLECTOR_SERVICE.xml 06c96c0daa35:/opt/rti.com/rti_connext_dds-7.5.0/resource/xml/RTI_COLLECTOR_SERVICE.xml

7. Use the ``cat`` command within the container (``docker exec <container ID> cat <path inside container>``) to display the contents of 
   the RTI_COLLECTOR_SERVICE.xml file. Confirm <domain_participant_qos base_name> in the SecureRemoteDebugging configuration is "CollectorQosLibrary::SecureDDSWAN".

        $ docker exec 06c96c0daa35 cat /opt/rti.com/rti_connext_dds-7.5.0/resource/xml/RTI_COLLECTOR_SERVICE.xml
             ...
            <collector_service name="SecureRemoteDebugging">
                <!-- Input connection: DDS -->
                <receivers>
                    <dds_receiver>
                        <domain_id>$(OBSERVABILITY_DOMAIN)</domain_id>
                        <domain_participant_qos base_name="CollectorQosLibrary::SecureDDSWAN"/>
                    </dds_receiver>
                </receivers>
                <!-- Output connection: exporting via WebSocket -->
                <exporters>
                    <websocket_exporter>
                        <telemetry_mask>OBSERVABLE</telemetry_mask>
                    </websocket_exporter>
                </exporters>
                <control>
                    <http_server>
                        <hostname>$(OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME)</hostname>
                        <listening_port>$(OBSERVABILITY_CONTROL_PORT)</listening_port>
                        <public_listening_port>$(OBSERVABILITY_CONTROL_PUBLIC_PORT)</public_listening_port>
                        <ssl_certificate>
                            /rti/security/https/serverControl.pem
                        </ssl_certificate>
                        <authentication_domain>
                            $(OBSERVABILITY_HOSTNAME)
                        </authentication_domain>
                        <global_auth_file>
                            $(OBSERVABILITY_CONTROL_BASIC_AUTH_FILE)
                        </global_auth_file>
                    </http_server>
                </control>
            </collector_service>
        </dds>   

8. To persist the change, commit the file update to a new docker image. Use the CONTAINER ID of the container you modified and
   a new tag of your choosing to identify the updated image. In the following example, ``_updated`` is appended to the existing image’s tag
   to create a new one:

        $ docker commit 06c96c0daa35 rticom/collector-service:7.5.0_updated

9. To verify the changes, stop and remove the existing container, start the new container, then list running containers. Use the ``cat`` 
   command, with the new container’s ID, to display and verify the RTI_COLLECTOR_SERVICE.xml file contents.

        $ docker stop collector_service
        collector_service
        $ docker rm collector_service
        collector_service
        $ docker ps -a
        CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
        $ docker run -dt \
                --network host \
                -v /path/to/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
                -e CFG_NAME="NonSecureLAN" \
                --name=collector_service \
                rticom/collector-service:7.5.0
        04da8002391d9cdef642309094246420e77da21fc74ef27edd112828ec6171f4
        $ docker ps -a
        CONTAINER ID   IMAGE                                   COMMAND                  CREATED         STATUS         PORTS     NAMES
        04da8002391d   rticom/collector-service:7.5.0_update   "rtientrypoint rtico…"   5 seconds ago   Up 5 seconds             collector_service
        $ docker exec 04da8002391d cat /opt/rti.com/rti_connext_dds-7.5.0/resource/xml/RTI_COLLECTOR_SERVICE.xml
             ...
            <collector_service name="SecureRemoteDebugging">
                <!-- Input connection: DDS -->
                <receivers>
                    <dds_receiver>
                        <domain_id>$(OBSERVABILITY_DOMAIN)</domain_id>
                        <domain_participant_qos base_name="CollectorQosLibrary::SecureDDSWAN"/>
                    </dds_receiver>
                </receivers>
                <!-- Output connection: exporting via WebSocket -->
                <exporters>
                    <websocket_exporter>
                        <telemetry_mask>OBSERVABLE</telemetry_mask>
                    </websocket_exporter>
                </exporters>
                <control>
                    <http_server>
                        <hostname>$(OBSERVABILITY_CONTROL_PUBLIC_HOSTNAME)</hostname>
                        <listening_port>$(OBSERVABILITY_CONTROL_PORT)</listening_port>
                        <public_listening_port>$(OBSERVABILITY_CONTROL_PUBLIC_PORT)</public_listening_port>
                        <ssl_certificate>
                            /rti/security/https/serverControl.pem
                        </ssl_certificate>
                        <authentication_domain>
                            $(OBSERVABILITY_HOSTNAME)
                        </authentication_domain>
                        <global_auth_file>
                            $(OBSERVABILITY_CONTROL_BASIC_AUTH_FILE)
                        </global_auth_file>
                    </http_server>
                </control>
            </collector_service>
        </dds>  

10. To use the new image tag, modify the Observability docker-compose.yml file, or include the new image tag in the ``docker run`` command.

        $ docker run -dt \
                --network host \
                -v /path/to/rti_license.dat:/opt/rti.com/rti_connext_dds-7.5.0/rti_license.dat \
                -e CFG_NAME="NonSecureLAN" \
                --name=collector_service \
                rticom/collector-service:7.5.0_updated

### RTI Infrastructure Services cannot emit telemetry data

For RTI Infrastructure Services to emit telemetry data, *RTI Monitoring Library 2.0* must be enabled for and available to the services.
The *Connext* host installation packages erroneously do not contain the *Monitoring Library 2.0* distribution. Therefore, for Infrastructure Services to emit telemetry data, you need to:

- enable *Monitoring Library 2.0* by configuring the XML configuration file, and
- make *Monitoring Library 2.0* available by installing the appropriate target package (if you only installed the host package).

Follow the steps below to enable *Monitoring Library 2.0*, then install and configure the appropriate *Connext* target package to make it available to the RTI Infrastructure Services.

1. To enable *Monitoring Library 2.0* in an RTI Infrastructure Service, add the XML code snippet shown below to 
   any of the following XML QoS profiles.

    * NDDS_QOS_PROFILES.xml, located in the *Web Integration Service* working directory

    * USER_QOS_PROFILES.xml, located in the *Web Integration Service* working directory

    * Any XML file included in the NDDS_QOS_PROFILES environment variable

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

    The profile containing the snippet must have *is_default_participant_factory_profile* set to true.
    For more information on configuring *Monitoring Library 2.0* see [MONTORING QosPolicy](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/connext_dds_professional/users_manual/users_manual/MONITORING_QosPolicy.htm). 
    
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

2. Install the appropriate *Connext* target package for your architecture, as described in the 
[RTI Connext Installation Guide](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/connext_dds_professional/installation_guide/installing.html).

1. After the target package is installed, configure your system so that the RTI services can load the library.
   This can be done in one of two ways, as shown below. Only one of the following methods is required.

    * Set the library search path to include the *Connext* target library install directory.

        * macOS - Add the Connext target directory to the DYLD_LIBRARY_PATH variable. An example \<architecture> would be *x64Darwin20clang12.0*.

                DYLD_LIBRARY_PATH=${NDDSHOME}/lib/<architecture>:${DYLD_LIBRARY_PATH}

        * Linux - Add the Connext target directory to the LD_LIBRARY_PATH variable. An example \<architecture> would be *x64Linux4gcc7.3.0*.

                LD_LIBRARY_PATH=${NDDSHOME}/lib/<architecture>:${LD_LIBRARY_PATH}

        * Windows - Add the Connext target directory to the Path variable. An example \<architecture> would be *x64Win64VS2017*.

                Path=%NDDSHOME%\lib\<architecture>; %Path%

    * Alternatively, copy the required *Monitoring Library 2.0* files from the target library directory to the host resource directory.

        * macOS - Copy the *Monitoring Library 2.0* files from the target library directory to the host resource directory. An example of \<architecture>
          would be *x64Darwin20clang12.0*.

                % cp ${NDDSHOME}/lib/<architecture>/librtimonitoring2*.* ${NDDSHOME}/resource/app/lib/<architecture>

        * Linux - Copy the *Monitoring Library 2.0* files from the target library directory to the host resource directory. An example of \<architecture>
          would be *x64Linux4gcc7.3.0*.

                $ cp ${NDDSHOME}/lib/<architecture>/librtimonitoring2*.* ${NDDSHOME}/resource/app/lib/<architecture>

        * Windows - Copy the *Monitoring Library 2.0* files from the target library directory to the host resource directory. An example 
          \<architecture> would be *x64Win64VS2017*.

                C:\>copy ${NDDSHOME}/lib/<architecture>/rtimonitoring2*.* ${NDDSHOME}/resource/app/lib/<architecture>


## Release Notes

Release notes for RTI *Connext* products are available on the RTI Community Portal at https://community.rti.com/documentation. For patch release notes, contact our support team at support@rti.com to request the relevant Release Notes Supplement. For Docker image release notes, check RTI’s Github containers repository at https://github.com/rticommunity/rticonnextdds-containers.

## License

RTI® Collector Service is licensed under the following supplemental license terms and the Software License Agreement accompanying RTI Connext® Professional (https://www.rti.com/free-trial/terms).

This image uses Ubuntu as the base image, and your usage must comply with the applicable license terms found [here](https://hub.docker.com/_/ubuntu).

You can find the Software Bill of Materials (SBOM) third-party information in SPDX format in the ``/user/local/share/sbom/`` directory.

Additional third party information can be found at https://community.rti.com/documentation#doc_third_party.

Use the following command to retrieve the *RTI_License_Agreement.pdf* built-in file:

```
docker cp collector_service:/opt/rti.com/rti_connext_dds-7.5.0/RTI_License_Agreement.pdf .
```

## How to get a license file

An RTI license file is always required to run Collector Service in a Docker container.

### Existing customers

If you are an RTI customer, and you need an RTI Connext license file, contact [RTI support](https://www.rti.com/support). 

### Evaluators

If you are not an RTI customer, visit https://www.rti.com/free-trial/connext to get an RTI Connext free trial for release 7.5.0 or higher. With the free trial you will receive a limited time license file that contains an activation key for RTI Connext Professional, RTI Security Plugins, RTI Real-Time WAN Transport, and RTI Cloud Discovery Service.

To get a free trial license for earlier releases, contact evaluations@rti.com.

### RTI Supplemental License

This RTI Supplemental License ("Supplemental License") is for the accompanying RTI container image ("Container Image"). Real-Time Innovations, Inc. ("RTI") licenses the Container Image to you only if you agree to comply with all of the terms and conditions of this Supplemental License.

The Container Image may only be used with a validly licensed copy of RTI Connext software (the "Host Software") licensed from RTI (the agreement pursuant to which you licensed the Host Software is the "Host License Agreement").

You may not use the Container Image if you do not have a current Host License Agreement. Certain restrictions and additional terms may apply, which are described herein. If any terms or conditions in this Supplemental License conflict with the Host License Agreement, then this Supplemental License shall govern solely with respect to the Container Image. BY ACCEPTING THIS SUPPLEMENTAL LICENSE OR USING THE CONTAINER IMAGE, YOU AGREE TO ALL OF THE TERMS AND CONDITIONS IN THIS SUPPLEMENTAL LICENSE ON BEHALF OF YOURSELF AND THE ENTITY THAT LICENSED THE HOST SOFTWARE UNDER THE HOST LICENSE AGREEMENT. IF YOU DO NOT AGREE WITH THE TERMS AND CONDITIONS OF THIS SUPPLEMENTAL LICENSE, OR YOU DO NOT HAVE THE AUTHORITY TO BIND THE ENTITY THAT LICENSED THE HOST SOFTWARE UNDER THE HOST LICENSE AGREEMENT TO THIS SUPPLEMENTAL LICENSE, YOU MAY NOT USE THE CONTAINER IMAGE.

**Host License Agreement.** The Host License Agreement applies to your use of the Container Image and any application you create using, or in which you incorporate, the Container Image.

**Use Rights.** The Container Image may be used only in connection with configuring, testing, and using the Host Software. Notwithstanding RTI’s provision, and your use, of the Container Image, you are solely responsible for, and bear the entire risk of: (a) configuring the Host Software for your application, and (b) the performance or non-performance of your application.  Updates to the Host Software may not update the Container Image. RTI is not obligated to provide any updates or support for the Container Image.

**Restrictions.** You may not remove this Supplemental License document file from the Container Image. You may not reverse engineer, decompile, or disassemble the Container Image, or attempt to do so, except and only to the extent required by third party licensing terms governing the use of certain open-source components that may be included with the software. Additional restrictions in the Host License Agreement may apply.

**Disclaimer of Warranties.** The Container Image is provided to you on an "AS IS" basis, and RTI disclaims, to the maximum extent permitted by applicable law, all express and implied representations, warranties and guarantees, including without limitation, the implied warranties of merchantability, fitness for a particular purpose, satisfactory quality, and non-infringement of third party rights.

**Feedback.** Any suggestions or ideas you provide to RTI regarding the Container Image (collectively, "Feedback"), may be used and exploited in any and every way by RTI (including without limitation, by granting sublicenses), on a non-exclusive, perpetual, irrevocable, transferable, and worldwide basis, without any compensation, without any obligation to report on such use, and without any other restriction or obligation to you.

**Limitation of Liability.**  TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT WILL RTI BE LIABLE TO YOU FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR PUNITIVE OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR FOR LOST PROFITS, LOST DATA, LOST REPUTATION, OR COST OF COVER, REGARDLESS OF THE FORM OF ACTION WHETHER IN CONTRACT, TORT (INCLUDING WITHOUT LIMITATION, NEGLIGENCE), STRICT PRODUCT LIABILITY OR OTHERWISE, WHETHER ARISING OUT OF OR RELATING TO THE USE OR INABILITY TO USE THE CONTAINER IMAGE, EVEN IF RTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

**OSS.** Certain items of independent, third-party code may be included within the software in the Container Image that are subject to the GNU General Public License ("GPL") or other open source licenses (such third-party code collectively, "Open Source Software" or "OSS"). Such Open Source Software is licensed under the terms and conditions of the license that accompanies such Open Source Software (the "OSS Terms"). Nothing herein or in the Host License Agreement limits your rights under, or grants you rights that supersede, the OSS Terms applicable to the corresponding Open Source Software. In particular, nothing herein restricts your right to copy, modify, and distribute such Open Source Software that is subject to the terms of the GPL. The OSS Terms and OSS required notices are provided in the [License](#license) section of this document. By accepting the Supplemental License, you are also accepting the OSS Terms for the corresponding Open Source Software. If you do not agree to any provision of the OSS Terms for the corresponding Open Source Software, you should not download or use this Container Image.

**General.**  This Supplemental License constitutes the entire agreement between the parties pertaining to the subject matter hereof, and supersedes any and all written or oral agreements previously existing between the parties with respect to the subject matter hereof.  Any additional or different terms in any purchase order from You are deemed material and expressly rejected by RTI. You agree that this Agreement will not be construed against RTI by virtue of having drafted them.