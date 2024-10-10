Welcome to *RTI® Perftest*, an *RTI Connext®* out-of-the-box solution designed to measure and analyze the performance of *RTI Connext* applications. This tool provides comprehensive metrics for latency, throughput, and other critical performance aspects.

For additional information on *RTI Perftest*, refer to the [RTI documentation](https://community.rti.com/static/documentation/perftest/4.1.1/introduction.html).

The documentation shown on this page applies to the *Perftest* Docker image with the `latest` tag. The latest tag refers to the most recent Long Term Support (LTS) version released from RTI. For specific tag documentation, refer to the https://github.com/rticommunity/rticonnextdds-containers repository.

# Using the Perftest container image

Running *Perftest* on Docker is as simple as running the ``docker run`` command:

**Publisher:**

The following command runs *Perftest* as a publisher with a data length of 1024 bytes for 60 seconds. 

```
docker run -t \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=perftest_pub \
        rticom/perftest:latest \
        -pub -dataLen 1024 -executionTime 60
```

You should see output similar to the following:

```
Waiting to discover 1 subscribers ...
Waiting for subscribers announcement ...
Sending 400 initialization pings ...
Sending data ...
```

**Subscriber:**

The following command runs *Perftest* as a subscriber with a data length of 1024 bytes.

```
docker run -t \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=perftest_sub \
        rticom/perftest:latest \
        -sub -dataLen 1024
```

You should see output similar to the following:

```
Waiting to discover 1 publishers ...
Interval Throughput for 1024 Bytes:
Length (Bytes), Total Samples,  Samples/s, Avg Samples/s,     Mbps,  Avg Mbps, Lost Samples, Lost Samples (%)
Waiting for data ...
```

The above ``docker run`` command-line options run the containers in the foreground. To run the containers in the background, add the ``-d`` parameter to the ``docker run`` command.

With the ``-d`` parameter, you can view the container logs using the following additional commands:

```
docker logs perftest_pub
docker logs perftest_sub
```

To run *Perftest*, you will need an RTI license file. Bind-mount your license from the host by using the following command-line parameter:

```
-v $PWD/your/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat
```

The *Perftest* container image uses the following user and group:

* User: rtiuser (1000)
* Group: rtigroup (1000)

The *Perftest* container image uses the following working directory:

* ```/home/rtiuser/rti_workspace/7.4.0/user_config/perftest```

## Built-in Configuration

Use the following command to retrieve the *Perftest* built-in configuration file:

```
docker cp perftest:/opt/rti.com/rti_connext_dds-7.4.0/resource/xml/RTI_PERFTEST.xml .
```

## Custom Configuration

To provide your own configuration, follow these steps when running the container:

* bind-mount your configuration file from the host
into the following location in the Docker container: 
```/home/rtiuser/rti_workspace/7.4.0/user_config/perftest/USER_PERFTEST_CONFIG.xml```
* select the *Perftest* configuration in the configuration file by adding the ```-cfgName``` parameter with the name of your selected configuration 

For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        -v $PWD/MyPerftestConfig.xml:/home/rtiuser/rti_workspace/7.4.0/user_config/perftest/USER_PERFTEST_CONFIG.xml \
        --name=perftest \
        rticom/perftest:latest \
        -cfgName MyPerftestConfig
```

## Command-Line Parameters

To provide additional command-line parameters to *Perftest*, add
them to the end of the ``docker run`` command. For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=perftest \
        rticom/perftest:latest \
        -pub -dataLen 1024 -executionTime 60 -verbosity WARN
```

The above example runs *Perftest* with the verbosity level set to WARN.

To see the list of allowed parameters, use the ``-h`` parameter:

```
docker run --rm -t rticom/perftest:latest -h
```

## Use Cases

Following are two *Perftest* container image use case examples.

### Running a Basic Throughput Test

The following examples run a basic throughput test.

**Publisher:**

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=perftest_pub \
        rticom/perftest:latest \
        -pub -dataLen 1024 -executionTime 60
```
**Subscriber:**

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=perftest_sub \
        rticom/perftest:latest \
        -sub -dataLen 1024
```



### Running a Latency Test

The following examples run a latency test.

**Publisher:**

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=perftest_pub \
        rticom/perftest:latest \
        -pub -latencyTest -dataLen 1024 -executionTime 60
```

**Subscriber:**

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=perftest_sub \
        rticom/perftest:latest \
        -sub -dataLen 1024
```

## Network configuration

The previous examples use the ``--network host`` parameter to run the containers in the host network. The host network is the most straightforward way to run the containers because it allows the containers to communicate with each other and with the host machine. However, the host network is not available on all platforms and has different levels of support depending on the operating system.

If you want to run the containers in a custom network isolated from the host network, you can create a custom network using `docker network create` and run the containers in that network. See the [Docker networking overview documentation](https://docs.docker.com/network/) for more information on Docker networks.

If you  want to make the containers accessible from outside the Docker environment without using the host network, the recommendation is to use *RTI Real-Time WAN Transport* and expose the necessary UDP ports using the `-p` option. For more information on *RTI Real-Time WAN Transport*, refer to the [User’s Manual](https://community.rti.com/static/documentation/connext-dds/7.4.0/doc/manuals/connext_dds_professional/users_manual/users_manual/PartRealtimeWAN.htm). For more information on the `-p` option, refer to the [Docker running containers documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports).

*Perftest* allows configuring the transport properties using the `-transport` parameter. For more information on the `-transport` parameter, refer to the [RTI Perftest transport-specific options documentation](https://community.rti.com/static/documentation/perftest/4.1.1/command_line_parameters.html#transport-specific-options).

## Release Notes

Release notes for RTI *Connext* products are available on the RTI Community Portal at https://community.rti.com/documentation. For patch release notes, contact our support team at support@rti.com to request the relevant Release Notes Supplement. For Docker image release notes, check RTI’s Github containers repository at https://github.com/rticommunity/rticonnextdds-containers.

## License

RTI® Perftest is licensed under the following supplemental license terms and the Software License Agreement accompanying RTI Connext® Professional (https://www.rti.com/free-trial/terms).

This image uses Ubuntu as the base image, and your usage must comply with the applicable license terms found [here](https://hub.docker.com/_/ubuntu).

You can find the Software Bill of Materials (SBOM) third-party information in SPDX format in the ``/user/local/share/sbom/`` directory.

Additional third party information can be found at https://community.rti.com/documentation#doc_third_party.

Use the following command to retrieve the *RTI_License_Agreement.pdf* built-in file:

```
docker cp perftest:/opt/rti.com/rti_connext_dds-7.4.0/RTI_License_Agreement.pdf .
```

## How to get a license file

For an RTI Connext free trial, visit the following link: https://www.rti.com/free-trial/connext. With the free trial you will receive a limited time license file that contains an activation key for RTI Connext Professional, RTI Security Plugins, RTI Real-Time WAN Transport, and RTI Cloud Discovery Service.

If you are an RTI customer, and you need a license file, please contact [RTI support](https://www.rti.com/support).

* RTI Connext Professional
* RTI Security Plugins
* RTI Real-Time WAN Transport
* RTI Cloud Discovery Service

All the activation keys are included in the same license file.

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