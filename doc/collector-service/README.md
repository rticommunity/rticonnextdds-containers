*RTI® Observability Collector Service* is a component of the 
*RTI® Connext® Observability Framework™* that scalably collects telemetry data 
(metrics and logs) from Connext applications and stores this data in third-party 
observability backends.

In the *Connext* 7.2.0 release, *Collector Service* provides native integration  
with Prometheus, as the time-series database to store Connext metrics, and Grafana 
Loki, as the log aggregation system to store Connext logs. Integration with other 
backends is possible using 
[OpenTelemetry™](https://opentelemetry.io/) and the 
[OpenTelemetry Collector](https://opentelemetry.io/docs/collector/).

For additional information on *RTI® Connext® Observability Framework™*, see the 
[RTI documentation](https://community.rti.com/static/documentation/connext-dds/7.2.0/doc/manuals/addon_products/observability/index.html#). 

## Using the Collector Service container image
Running *Collector Service* on Docker is as simple as running the `docker run` command:

```
docker run -d \
        --network host \
        -v $PWD/rti_license.dat:/rti/rti_license.dat \
        --name=collector-service \
        rticom/collector-service:7.2.0
```

The above command starts *Collector Service* with a default configuration 
that stores the metrics and logs emitted by *Connext* applications using 
[Connext Monitoring Library 2.0](https://community.rti.com/static/documentation/connext-dds/7.2.0/doc/manuals/addon_products/observability/library.html) 
on domain ID 2 into Prometheus (for metrics) and Grafana Loki (for logs) 
databases .

With the default configuration, *Collector Service* runs a Prometheus client that 
spawns an HTTP server on port 19090 and a Grafana Loki HTTP client that connects 
to a Grafana Loki server running on port 3100.

An RTI license file is always required to run *Collector Service* in a Docker 
container. Bind-mount your license from the host by using the following 
command-line parameter:

```
-v /path/to/your_license.dat:/rti/rti_license.dat
```

The following table indicates the RTI licenses required based on your answers 
to the questions in the first two columns.

|Do you need to secure telemetry data exchanged between applications and *Collector Service* using *RTI Security Plugins*?|Do you need to send telemetry data to *Collector Service* over the WAN using *RTI Real-Time WAN Transport*?|Required License|
|-------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|----------------|
|NO|NO|Connext Professional|
|YES|NO|Connext Secure|
|YES|YES|Connext Anywhere|
|NO|YES|Connext Anywhere|

## Built-in configuration

The built-in configuration file used by *Collector Service* can be retrieved using the following command:

```
docker cp collector_service:/rti/rti_connext_dds/resource/xml/RTI_COLLECTOR_SERVICE.xml .
```
The built-in configuration supports the execution modes:

|Configuration Name|Network|Data Storage|Security|
|------------------|-------|------------|--------|
|NonSecureLAN|LAN|Prometheus and Grafana Loki|No|
|NonSecureWAN|WAN|Prometheus and Grafana Loki|No|
|SecureLAN|LAN|Prometheus and Grafana Loki|Yes|
|SecureWAN|WAN|Prometheus and Grafana Loki|Yes|
|NonSecureOTelLAN|LAN|Multiple through OpenTelemetry Collector|No|
|NonSecureOTelWAN|WAN|Multiple through OpenTelemetry Collector|No|
|SecureOTelLAN|LAN|Multiple through OpenTelemetry Collector|Yes|
|SecureOTelWAN|WAN|Multiple through OpenTelemetry Collector|Yes|

In LAN modes, *Collector Service* uses *UDPv4* and *SHMEM* Transports to 
receive telemetry data from *Connext* applications and runs on the same LAN 
where the applications run.

In WAN modes, *Collector Service* uses the *RTI Real-Time WAN Transport* to 
receive telemetry data from *Connext* applications and runs on a WAN. For 
example, *Collector Service* may run in an AWS instance while the 
*Connext* applications may run on-premises.

The default execution mode is *NonSecureLAN*. To select a different execution 
mode, set the environment variable CFG_NAME to the name of the configuration 
file you want to use. For example, to run *Collector Service* in *SecureLAN*
mode, set the environment variable CFG_NAME to *SecureLAN*.

```
docker run -d \
        --network host \
        -v $PWD/rti_license.dat:/rti/rti_license.dat \
        -e CFG_NAME="SecureLAN" \
        --name=collector-service \
        rticom/collector-service:7.2.0
```

In all modes, the built-in configuration assumes that the following components
are running on the same host where *Collector Service* runs: 
* Prometheus server
* Grafana Loki server
* OpenTelemetry Collector

In addition to the configuration name, there are other parameters you can 
set using environment variables when running the Docker container:

**General Parameters**

```
-e OBSERVABILITY_DOMAIN=<domain ID in which Collector Service receives the telemetry data from Connext applications, default: 2>
-e OBSERVABILITY_HOSTNAME=<hostname of the host where Collector Service runs, default: localhost>
-e OBSERVABILITY_CONTROL_PORT=<TCP port where Collector Service receives external commands, default: 19098>
```

**Security Paramaters**

```
-e OBSERVABILITY_BASIC_AUTH_USERNAME=<username to authenticate the HTTP connections (client) created by Collector Service, default: user>
-e OBSERVABILITY_BASIC_AUTH_PASSWORD=<password to authenticate the HTTP connections (client) created by Collector Service, default: userpassword>
```

The above parameters are used by the HTTP clients created by 
*Collector Service* to send telemetry data to third-party backends (for example,
Prometheus, Grafana Loki, OpenTelemetry Collector).

**WAN Parameters**

```
-e OBSERVABILITY_RTW_PORT=<The public UDP port of Collector Service in which it will receive telemetry data from Connext applications, default: 30000>
```

**OpenTelemetry Parameters**

```
-e OBSERVABILITY_OTEL_METRIC_EXPORTER_PORT=<The port of the OpenTelemetry Collector in which it will receive metrics from Collector Service using OTLP protocol, default: 4318>
-e OBSERVABILITY_OTEL_LOG_EXPORTER_PORT=<The port of the OpenTelemetry Collector in which it will receive logs from Collector Service using OTLP protocol, default: 4319>
```

**Prometheus Parameters**

```
-e OBSERVABILITY_PROMETHEUS_EXPORTER_PORT=<The port of the HTTP server instantiated by the Collector Service to provide metrics to a Prometheus server, default: 19090>
```

**Grafana Loki Parameters**

```
-e OBSERVABILITY_LOKI_EXPORTER_PORT=<The TCP port of the Grafana Loki server in which it will receive logs from Collector Service, default: 3100>
```

For example, to run a *Collector Service* instance with public address 
10.10.1.34:16000 that collects all telemetry data published by *Connext* 
applications over the WAN on domain 33, you can run a Docker container as 
follows:

```
docker run -d \
        --network host \
        -v $PWD/rti_license.dat:/rti/rti_license.dat \
        -e CFG_NAME="NonSecureLAN" \
        -e OBSERVABILITY_DOMAIN=33 \
        -e OBSERVABILITY_HOSTNAME=10.10.1.34 \
        -e OBSERVABILITY_RTW_PORT=16000 \
        --name=collector-service \
        rticom/collector-service:7.2.0
```

### Security Artifacts

When running one of the secure configurations, the following security artifacts
must be mounted into the container:

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
*identity_certificate.pem*
* *identity_certificate.pem* must contain the certificate of the *Collector
Service*
* *private_key.pem* must contain the private key of the *Collector Service*.
* *permissions_ca.pem* must contain the certificate of the CA that signed the
*permissions.p7s* and *governance.p7s*
* *governance.p7s* must contain the governance file of the *Collector Service*.
* *permissions.p7s* must contain the permissions file of the *Collector Service*

For additional information on how to generate these security artifacts, see
[Generating the Observability Framework Security Artifacts](https://community.rti.com/static/documentation/connext-dds/7.2.0/doc/manuals/addon_products/observability/security.html#generating-the-observability-framework-security-artifacts).

**To configure HTTPS + Basic Authentication:**

*Collector Service* uses HTTPS + Basic Authentication to encrypt and
authenticate the HTTP connections created by *Collector Service* to send
telemetry data and to receive commands from external clients.

To configure HTTPS + Basic Authentication, you need to provide:

```
-v /path/to/rootCA.crt:/rti/security/https/rootCA.crt
-v /path/to/server.pem:/rti/security/https/server.pem
-v /path/to/htdigest:/rti/security/https/htdigest
```

* *rootCA.crt* must contain the root certificate of the CA that signed the
server.pem* certificate
* *server.pem* must contain both a valid server certificate and the 
corresponding private key
* *htdigest* htdigest is a password file that contains the username and password 
for BASIC-Auth. The htdigest file is a password file that contains the Apache 
htdigest. This file is used by the HTTP server started by *Collector Service*
to authenticate the HTTP connections created by external clients (for example, a
Prometheus scraping client).

For additional information on how to generate these security artifacts, see
[Generating the Observability Framework Security Artifacts](https://community.rti.com/static/documentation/connext-dds/7.2.0/doc/manuals/addon_products/observability/security.html#generating-the-observability-framework-security-artifacts).


## Custom configuration

**Note:** Custom XML configurations are not officially supported in this release.
The format of the configuration file is not described in the documentation,
and it is subject to change in future releases. If you need to provide your own 
configuration, please contact RTI Support (support@rti.com).

To provide your own configuration, follow these steps when running the container:

* bind-mount your configuration file (e.g. MyCollectorService.xml) from the host 
into the following location in the docker container: 
/rti/rti_workspace/user_config/collector_service/USER_COLLECTOR_SERVICE.xml.
* Select the *Collector Service* configuration in the configuration file by 
setting CFG_NAME environment variable.

For example:

```
docker run -d \
        --network host \
        -v $PWD/rti_license.dat:/rti/rti_license.dat \
        -v $PWD/MyCollectorService.xml:/rti/rti_workspace/user_config/collector_service/USER_COLLECTOR_SERVICE.xml \
        -e CFG_NAME="MyCollectorService" \
        --name=collector_service \
        rticom/collector_service:<tag>
```

## Command line parameters

You can provide your command-line parameters to *Collector Service* by adding 
them to the end of the **docker run** command. For example:

```
docker run -d \
        --network host \
        -v $PWD/rti_license.dat:/rti/rti_license.dat \
        -v $PWD/MyCollectorService.xml:/rti/rti_workspace/user_config/collector_service/USER_COLLECTOR_SERVICE.xml \
        -e CFG_NAME="MyCollectorService" \
        --name=collector_service \
        rticom/collector_service:<tag> \
        -verbosity WARN
```

The previous command runs *Collector Service* with the verbosity level set to WARN.

The only command-line parameter supported in this release is **-verbosity**.

## Release Notes

Release notes for RTI *Connext* products are available on the RTI Community Portal at https://community.rti.com/documentation. For patch release notes, contact our support team at support@rti.com to request the relevant Release Notes Supplement. For Docker image release notes, check RTI’s Github containers repository at https://github.com/rticommunity/rticonnextdds-containers.

## License

RTI® Collector Service is licensed under the following supplemental license terms and the Software License Agreement accompanying RTI Connext® Professional (https://www.rti.com/free-trial/terms).

This image uses Ubuntu as the base image, and your usage must comply with the applicable license terms found [here](https://hub.docker.com/_/ubuntu).

You can find the Software Bill of Materials (SBOM) third-party information in SPDX format in the ``/user/local/share/sbom/`` directory.

Additional third party information can be found at https://community.rti.com/documentation#doc_third_party.

Use the following command to retrieve the *RTI_License_Agreement.pdf* built-in file:

```
docker cp collector_service:/opt/rti.com/rti_connext_dds-7.3.0/RTI_License_Agreement.pdf .
```

## How to get a license file

An RTI license file is always required to run *Collector Service* in a Docker container.

### Existing customers
If you are an RTI customer, and you need an RTI Connext 7.2.0 license file, contact RTI support.

### Evaluators
If you are not an RTI customer, contact evaluations@rti.com for an RTI Connext 7.2.0 free trial. With the free trial you will receive a limited time license file that contains an activation key for RTI Connext Professional, RTI Security Plugins, RTI Real-Time WAN Transport, and RTI Cloud Discovery Service.

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
