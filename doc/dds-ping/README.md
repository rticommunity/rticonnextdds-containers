Welcome to *RTI® DDS Ping*, an *RTI Connext®* command-line utility that is invaluable for debugging issues with DDS applications. It sends and receives simple "ping" messages using *Connext*, which can help determine whether there are issues with discovery or misconfiguration in the DDS communication between applications.

For additional information on *RTI DDS Ping*, refer to the [RTI documentation](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/connext_dds_professional/tools/rti_dds_ping/introduction.html).

## Releases

The documentation on this page applies to the *DDS Ping* Docker image with the `latest` tag, which refers to the most recent image released by RTI. To confirm the *Connext* release that corresponds to the `latest` tag, or to review the other *Connext* releases that support the *DDS Ping* image, go to https://hub.docker.com/r/rticom/dds-ping/tags.

For documentation on previous releases of the *DDS Ping* image, refer to the https://github.com/rticommunity/rticonnextdds-containers repository.

# Using the DDS Ping container image

Running *DDS Ping* on Docker is as simple as running the ``docker run`` command.

**Publisher:**

The following command starts a *DDS Ping* publisher that sends ping messages in the domain ID 0:

```
docker run -t \
        --network host \
        --name=dds_ping_publisher \
        rticom/dds-ping:latest \
        -domainId 0
```

You should see output similar to the following:

```sh
RTI Connext DDS Ping built with DDS version: 7.5.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sending data...   value: 0000000 
Sending data...   value: 0000001 
Sending data...   value: 0000002 
```

**Subscriber:**

The following command starts a *DDS Ping* subscriber that receives ping messages in the domain ID 0:

```
docker run -t \
        --network host \
        --name=dds_ping_subscriber \
        rticom/dds-ping:latest \
        -domainId 0 \
        -subscriber
```

You should see output similar to the following:

```
RTI Connext DDS Ping built with DDS version: 7.5.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rtiddsping, issue received: 0000000
rtiddsping, issue received: 0000001
rtiddsping, issue received: 0000002
```

The above ``docker run`` command-line options run the containers in the foreground. To run the containers in the background, add the ``-d`` parameter to the ``docker run`` command.

With the ``-d`` parameter, you can view the container logs using the following additional commands:

```
docker logs dds_ping_publisher
docker logs dds_ping_subscriber
```

The *DDS Ping* container image uses the following user and group:

* User: rtiuser (1000)
* Group: rtigroup (1000)

The *DDS Ping* container image uses the following working directory:

* ```/home/rtiuser/rti_workspace/7.5.0/user_config/ping```

## Built-in configuration
Use the following command to retrieve the *DDS Ping* built-in configuration file:

```
docker cp dds_ping_publisher:/opt/rti.com/rti_connext_dds-7.5.0/resource/xml/RTI_DDS_PING_QOS_PROFILES.xml .
```

The built-in configuration uses the built-in transports UDPv4 and SHMEM, and publishes and subscribes using best effort reliability.

## Custom configuration
To provide your own configuration, follow these steps when running the container:

* bind-mount your QoS configuration file from the host into the following location in the Docker container:
```/home/rtiuser/rti_workspace/7.5.0/user_config/ping/USER_DDS_PING_QOS_PROFILES.xml```
* select the *DDS Ping* QoS configuration file by adding the ``-qosFile`` parameter with the name of your mounted QoS configuration file
* select the configuration profile by adding the ``-qosProfile`` parameter with the name of the profile you want to use

For example:

```
docker run -dt \
        --network host \
        -v $PWD/MyQOSProfiles.xml:/home/rtiuser/rti_workspace/7.5.0/user_config/ping/USER_DDS_PING_QOS_PROFILES.xml \
        --name=dds_ping_publisher \
        rticom/dds-ping:latest \
        -qosFile USER_DDS_PING_QOS_PROFILES.xml
        -qosProfile MyProfile
```

The above example runs a *DDS Ping* publisher with the custom QoS configuration file.

## Command-line parameters

To provide your command-line parameters to *DDS Ping*, add 
them to the end of the ``docker run`` command. For example:

```
docker run -dt \
        --network host \
        --name=dds_ping_publisher \
        rticom/dds-ping:latest \
        -domainId 1 \
        -verbosity 3 \
        -peer 192.168.1.10
```

The above example runs a *DDS Ping* publisher with the domain ID set to 1 and verbosity level set to 3, and adds a peer with the address 192.168.1.10.

To see the list of allowed parameters, use the ``-h`` parameter:

```
docker run --rm -t rticom/dds-ping:latest -h
```

## Network configuration

The previous examples use the ``--network host`` parameter to run the containers in the host network. The host network is the most straightforward way to run the containers because it allows the containers to communicate with each other and with the host machine. However, the host network is not available on all platforms and has different levels of support depending on the operating system.

If you want to run the containers in a custom network isolated from the host network, you can create a custom network using `docker network create` and run the containers in that network. See the [Docker networking overview documentation](https://docs.docker.com/network/) for more information on Docker networks.

If you  want to make the containers accessible from outside the Docker environment without using the host network, the recommendation is to use *RTI Real-Time WAN Transport* and expose the necessary UDP ports using the `-p` option. For more information on *RTI Real-Time WAN Transport*, refer to the [User’s Manual](https://community.rti.com/static/documentation/connext-dds/7.5.0/doc/manuals/connext_dds_professional/users_manual/users_manual/PartRealtimeWAN.htm). For more information on the `-p` option, refer to the [Docker running containers documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports).

This image does not provide built-in configuration for *RTI Real-Time WAN Transport*. If you want to use it, you will need to provide your own configuration file.

## Release Notes

Release notes for RTI *Connext* products are available on the RTI Community Portal at https://community.rti.com/documentation. For patch release notes, contact our support team at support@rti.com to request the relevant Release Notes Supplement. For Docker image release notes, check RTI’s Github containers repository at https://github.com/rticommunity/rticonnextdds-containers.

## License

RTI® DDS Ping is licensed under the following supplemental license terms and the Software License Agreement accompanying RTI Connext® Professional (https://www.rti.com/free-trial/terms).

This image uses Ubuntu as the base image, and your usage must comply with the applicable license terms found [here](https://hub.docker.com/_/ubuntu).

You can find the Software Bill of Materials (SBOM) third-party information in SPDX format in the ``/user/local/share/sbom/`` directory.

Additional third party information can be found at https://community.rti.com/documentation#doc_third_party.

Use the following command to retrieve the *RTI_License_Agreement.pdf* built-in file:

```
docker cp dds_ping:/opt/rti.com/rti_connext_dds-7.5.0/RTI_License_Agreement.pdf .
```

## How to get a license file

An RTI license file is always required to run DDS Ping in a Docker container.

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