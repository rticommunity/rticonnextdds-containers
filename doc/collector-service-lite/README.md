_RTI® Observability Collector Service Lite_ is a component of the
_RTI Connext® Observability Framework_, a solution that scalably collects and
distributes telemetry data from _RTI Connext_ applications. For metrics, logs, 
and security events, _Collector Service Lite_ can forward telemetry data from 
_RTI Connext_ applications to other _Collector Service_ or _Collector Service Lite_ instances. 
For additional information on how  this service works in the _RTI Connext Observability Framework_, see the [RTI documentation](https://community.rti.com/static/documentation/connext-dds/7.7.0/doc/manuals/connext_dds_professional/observability/index.html).

_Collector Service Lite_ also collects non-metric data (configuration and discovery data) that is
currently consumed by _Admin Console_ to support the remote debugging feature. For additional information on remote debugging with _Admin Console_ see [Remote Debugging](https://community.rti.com/static/documentation/connext-dds/7.7.0/doc/manuals/connext_dds_professional/tools/admin_console/p2_administration/features_reference/ref_remote_debugging.html#remote-debugging-experimental).

For complete documentation about _Collector Service Lite_, see [Collector Service](https://community.rti.com/static/documentation/connext-dds/7.7.0/doc/manuals/connext_dds_professional/observability/rest_api.html) in the _RTI Observability Framework User's Manual_.

## Releases

The documentation on this page applies to the _Collector Service Lite_ Docker image with the `latest` tag, which refers to the most recent image released by RTI. To confirm the _Connext_ release that corresponds to the `latest` tag, or to review the other _Connext_ releases that support the _Collector Service Lite_ image, go to https://hub.docker.com/r/rticom/collector-service-lite/tags.

For _Collector Service Lite_ release notes, see the [Observability Framework User's Manual](https://community.rti.com/static/documentation/connext-dds/7.7.0/doc/manuals/connext_dds_professional/observability/release_notes.html)

## Collector Service Lite receivers and exporters

_Collector Service Lite_ receives data by instantiating receiver endpoints, and it 
forwards data by instantiating exporter endpoints.

### Collector Service Lite receivers

Currently, the only supported receiver endpoint is a DDS receiver endpoint, which receives telemetry data from _Monitoring Library 2.0_ in a _Connext_ application or from another _Collector Service_ or _Collector Service Lite_ instance
when _Collector Service Lite_ acts as a Forwarder.

### Collector Service Lite exporters

The following exporter endpoints are supported:

- `websocket_exporter`, which provides telemetry data to _RTI Admin Console_ for remote debugging using a WebSocket API.
- `dds_exporter`, which forwards telemetry data to another _Collector Service_ or _Collector Service Lite_ instance.

## Using the Collector Service Lite container image

Running _Collector Service Lite_ on Docker is as simple as running the `docker run` command:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.7.0/rti_license.dat \
        -e CFG_NAME="NonSecureForwarderLANtoLAN" \
        --name=collector_service_lite \
        rticom/collector-service-lite:latest
```

The above command starts _Collector Service Lite_ with the NonSecureForwarderLANtoLAN
configuration. which forwards the metrics and logs emitted by _Connext_ applications using
[Connext Monitoring Library 2.0](https://community.rti.com/static/documentation/connext-dds/7.7.0/doc/manuals/connext_dds_professional/observability/library.html) on domain ID 101 to another _Collector Service_ or _Collector Service Lite_ instance.
 
An RTI license file is always required to run _Collector Service Lite_ in a Docker
container. Bind-mount your license from the host by using the following
command-line parameter:

```
-v /path/to/your_license.dat:/opt/rti.com/rti_connext_dds-7.7.0/rti_license.dat
```

The _Collector Service Lite_ container image uses the following user and group:

- User: rtiuser (1010)
- Group: rtigroup (1010)

The _Collector Service Lite_ container image uses the following working directory:

- `/home/rtiuser/rti_workspace/7.7.0/user_config/collector_service`

The following table indicates the RTI licenses required based on your answers
to the questions in the first two columns.

| Do you need to secure telemetry data exchanged between applications and _Collector Service Lite_ using _RTI Security Plugins_? | Do you need to send telemetry data to _Collector Service Lite_ over the WAN using _RTI Real-Time WAN Transport_? | Required License                                                                             |
| ------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| NO                                                                                                                        | NO                                                                                                          | Connext Professional                                                                         |
| YES                                                                                                                       | NO                                                                                                          | Connext Professional and Security Plugins                                                    |
| YES                                                                                                                       | YES                                                                                                         | Connext Professional, Security Plugins, Cloud Discovery Service, and Real-Time WAN Transport |
| NO                                                                                                                        | YES                                                                                                         | Connext Professional, Cloud Discovery Service, and Real-Time WAN Transport                   |

## Builtin configuration

Use the following command to retrieve the _Collector Service Lite_ builtin 
configuration file:

```
docker cp collector_service:/opt/rti.com/rti_connext_dds-7.7.0/resource/xml/RTI_COLLECTOR_SERVICE.xml .
```
_Collector Service Lite_ is compatible with the following builtin configuration profiles:

|Configuration Name          |Supported Exporter(s) |Network    |Security |
|--------------------------- |--------------------- |-----------|-------- |
|NonSecureForwarderLANtoLAN  |dds_exporter          |LAN to LAN |No       |
|NonSecureForwarderLANtoWAN  |dds_exporter          |LAN to WAN |No       |
|NonSecureForwarderWANtoWAN  |dds_exporter          |WAN to WAN |No       |
|LWSecureForwarderLANtoLAN   |dds_exporter          |LAN to LAN |Yes      |
|LWSecureForwarderLANtoWAN   |dds_exporter          |LAN to WAN |Yes      |
|LWSecureForwarderWANtoWAN   |dds_exporter          |WAN to WAN |Yes      |
|SecureForwarderLANtoLAN     |dds_exporter          |LAN to LAN |Yes      |
|SecureForwarderLANtoWAN     |dds_exporter          |LAN to WAN |Yes      |
|SecureForwarderWANtoWAN     |dds_exporter          |WAN to WAN |Yes      |
|NonSecureRemoteDebuggingLAN |websocket_exporter                                     |LAN        |No       |
|NonSecureRemoteDebuggingWAN |websocket_exporter                                     |WAN        |No       |
|LWSecureRemoteDebuggingLAN    |websocket_exporter                                     |LAN        |Yes      |
|LWSecureRemoteDebuggingWAN    |websocket_exporter                                     |WAN        |Yes      |
|SecureRemoteDebuggingLAN    |websocket_exporter                                     |LAN        |Yes      |
|SecureRemoteDebuggingWAN    |websocket_exporter                                     |WAN        |Yes      |

In LWSecure profiles, _Collector Service Lite_ uses _RTI® Lightweight Builtin Security Plugins_.

In Secure profiles, _Collector Service Lite_ uses _RTI® Security Plugins_.

In LAN profiles, _Collector Service Lite_ uses _UDPv4_ and _SHMEM_ transports to 
receive telemetry data from _Connext_ applications and runs on the same LAN 
where the applications run.

NOTE: The _Collector Service Lite_ Docker container supports multicast.
_Monitoring Library 2.0_ only supports connecting to a single _Collector Service Lite_
instance. Because the default initial peers include a multicast address,
more than one _Collector Service Lite_ instance on the network may be discovered.
If that happens, _Monitoring Library 2.0_ will print a warning:
_Multiple active Collector Services detected._ To avoid this situation,
set ``collector_initial_peers`` to the unicast address of the specific _Collector
Service_ or _Collector Service Lite_ instance you want to connect to.

In WAN profiles, _Collector Service Lite_ uses _RTI Real-Time WAN Transport_ to 
receive telemetry data from _Connext_ applications and runs on a WAN. For 
example, _Collector Service Lite_ may run in an AWS instance while the 
_Connext_ applications may run on-premise.

The default profile is NonSecureRemoteDebuggingLAN. To select a different profile, set the
environment variable ``CFG_NAME`` to the name of the profile you want to
use. For example, to run the _Collector Service Lite_ SecureRemoteDebuggingLAN profile, set the
environment variable ``CFG_NAME`` to "SecureRemoteDebuggingLAN".

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.7.0/rti_license.dat \
        -e CFG_NAME="SecureRemoteDebuggingLAN" \
        --name=collector_service_lite \
        rticom/collector-service-lite:latest
```

## Release Notes

Release notes for RTI _Connext_ products are available on the RTI Community Portal at https://community.rti.com/documentation. For patch release notes, contact our support team at support@rti.com to request the relevant Release Notes Supplement. For Docker image release notes, check RTI’s Github containers repository at https://github.com/rticommunity/rticonnextdds-containers.

## License

RTI® Collector Service Lite is licensed under the following supplemental license terms and the Software License Agreement accompanying RTI Connext® Professional (https://www.rti.com/free-trial/terms).

This image uses Ubuntu as the base image, and your usage must comply with the applicable license terms found [here](https://hub.docker.com/_/ubuntu).

You can find the Software Bill of Materials (SBOM) third-party information in SPDX format in the `/user/local/share/sbom/` directory.

Additional third party information can be found at https://community.rti.com/documentation#doc_third_party.

Use the following command to retrieve the _RTI_License_Agreement_LM.pdf_ builtin file:

```
docker cp collector_service:/opt/rti.com/rti_connext_dds-7.7.0/RTI_License_Agreement_LM.pdf .
```

## How to get a license file

An RTI license file is always required to run Collector Service Lite in a Docker container.

### Existing customers

If you are an RTI customer, and you need an RTI Connext license file, contact [RTI support](https://www.rti.com/support).

### Evaluators

If you are not an RTI customer, visit https://evaluation.rti.com to get an RTI Connext free trial for release 7.7.0 or higher. With the free trial you will receive a limited time license file that contains an activation key for RTI Connext Professional, RTI Security Plugins, RTI Real-Time WAN Transport, and RTI Cloud Discovery Service.

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
