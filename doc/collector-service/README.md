_RTI® Observability Collector Service_ is a component of the
_RTI Connext® Observability Framework_, a solution that scalably collects telemetry data
from _RTI Connext_ applications and distributes this data to third-party observability backends
or _RTI Admin Console_.

For metrics, logs, and security events _Collector Service_ provides native integration
with Prometheus®, as the time-series database to store _Connext_ metrics, and Grafana® Loki™,
as the log aggregation system to store _Connext_ logs. Integration with other backends is
possible using [OpenTelemetry™](https://opentelemetry.io/) and the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/).
For additional information on _RTI Connext Observability Framework_, see the [RTI documentation](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/observability/index.html).

_Collector Service_ also collects non-metric data (configuration and discovery data) that is
currently consumed by _Admin Console_ to support the remote debugging feature. For additional information on remote debugging with _Admin Console_ see [Remote Debugging](https://community.rti.com/static/documentation/connext-dds/7.6.0/doc/manuals/connext_dds_professional/tools/admin_console/p2_administration/features_reference/ref_remote_debugging.html#remote-debugging-experimental).

## Using the Collector Service container image

> Note: Due to limitations of the size of the README file that can be hosted on Docker Hub,
> the complete instructions on how to use this docker image are not contained in this README
> file.

For detailed information on how to use this docker image with the `latest` tag, see the full [README](https://github.com/rticommunity/rticonnextdds-containers/blob/release/7.6.0/doc/collector-service/README_FULL.md) in the https://github.com/rticommunity/rticonnextdds-containers repository. You can also access documentation for previous releases by navigating to the `doc/collector-service` folder in the repository and selecting the appropriate release branch (e.g., `release/7.3.0`).

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

      - macOS - Add the Connext target directory to the DYLD_LIBRARY_PATH variable. An example \<architecture> would be _x64Darwin20clang12.0_.

              DYLD_LIBRARY_PATH=${NDDSHOME}/lib/<architecture>:${DYLD_LIBRARY_PATH}

      - Linux - Add the Connext target directory to the LD_LIBRARY_PATH variable. An example \<architecture> would be _x64Linux4gcc8.5.0_.

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
