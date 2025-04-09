Welcome to *RTI® Recording Service*, an *RTI Connext®* application that records DDS *Topics* and discovery data.

For additional information on *RTI Recording Service*, refer to the [RTI documentation](https://community.rti.com/static/documentation/connext-dds/7.4.0/doc/manuals/connext_dds_professional/services/recording_service/index.html).

The documentation shown on this page applies to the *Recording Service* Docker image with the `latest` tag. The latest tag refers to the most recent Long Term Support (LTS) version released from RTI. For specific tag documentation, refer to the https://github.com/rticommunity/rticonnextdds-containers repository.

## Using the Recording Service container image

Running *Recording Service* on Docker is as simple as running the ``docker run`` command:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=recording_service \
        rticom/recording-service:latest \
        -cfgName default
```

This command starts *Recording Service* with an example configuration that records all _Topics_ in domain 0. The database files are going to be created in  ```/home/rtiuser/rti_workspace/7.4.0/database/```.

To run *Recording Service*, you will need an RTI license file. Bind-mount your license from the host by using the following command-line parameter:

```
-v $PWD/your/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat
```

The *Recording Service* container image uses the following user and group:

* User: rtiuser (1000)
* Group: rtigroup (1000)

The *Recording Service* container image uses the following working directory:

* ```/home/rtiuser/rti_workspace/7.4.0/user_config/recording_service```

## Built-in configuration

Use the following command to retrieve the *Recording Service* built-in configuration file:

```
docker cp recording_service:/opt/rti.com/rti_connext_dds-7.4.0/resource/xml/RTI_RECORDING_SERVICE.xml .
```

The built-in configuration supports the following execution modes:

|Configuration Name|Description|
|------------------|-----------|
|default|This configuration records all _Topics_ in domain 0. It records in XCDR_AUTO storage format.|
|defaultJson|This configuration records all _Topics_ in domain 0. It records in JSON_SQLITE storage format.|

To select an execution mode, pass the ``-cfgName`` parameter with the desired configuration name. For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --name=recording_service \
        rticom/recording-service:latest \
        -cfgName default
```

When running the Docker container, there are several parameters you can set 
using environment variables:

**General Parameters**

```
-e ADMINISTRATION_DOMAIN=<The domain ID Recording Service uses for the administration channel. default: 0>
-e MONITORING_DOMAIN=<The domain ID Recording Service uses for the monitoring channel. default: 0>
-e DATA_DOMAIN=<The domain ID Recording Service uses for the data channel. default: 0>
-e WORKSPACE_DIR=<The folder where the database file is going to be generated. default: working directory>
```

### Database files storage using default storage directory

The default and defaultJson configurations store the database files in ``/home/rtiuser/rti_workspace/7.4.0/database``. Without additional configuration parameters, the files created in this directory are not persisted across container restarts.

To persist data across container restarts, you have two options: 
* bind-mount a directory from the host to the database directory
* create a managed volume and mount it to the database directory

The second option is recommended for persisting the database files across container restarts. While bind mounts are dependent on the directory structure and OS of the host machine, volumes are completely managed by Docker; volumes also have much higher performance than bind mounts.

**Volume example (Linux OS)**

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        --mount type=volume,source=recording_service_database,target=/home/rtiuser/rti_workspace/7.4.0/database \
        --name=recording_service \
        rticom/recording-service:latest \
        -cfgName default
```

It is not necessary to create the volume ``recording_service_database``. Docker creates it automatically when running the container if it does not already exist.

**Bind-mount example**

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        -v $PWD/recording_service_database:/home/rtiuser/rti_workspace/7.4.0/database \
        --name=recording_service \
        rticom/recording-service:latest \
        -cfgName default
```
**Important**: The directory ``recording_service_database`` must exist in the host machine, and the user running the container (UID 1000, GID 1000) must have read and write permissions to it.

### Database files storage using non-default storage directory
You can change the directory where the database files are stored in the container by setting the ``WORKSPACE_DIR`` environment variable.

**Volume example (Linux OS)**


1) Create a managed volume:

   ```
   docker volume create recording_service_database
   ```

2) Change the permissions of the volume mount point to the user and group used by the container:

   ```
   docker volume inspect recording_service_database
   ```

You will see the mount point in the Mountpoint field. For example:

```json
[
    {
        "CreatedAt": "2024-05-11T23:56:27-07:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/recording_service_database/_data",
        "Name": "recording_service_database",
        "Options": null,
        "Scope": "local"
    }
]
```

  Then you can change the permissions of the mount point to the  user and group used by the container:

  ```shell
  sudo chown -R 1000:1000 /var/lib/docker/volumes/recording_service_database/_data
  ```

3) Run the container:

   ```
   docker run -dt \
           --network host \
           -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
           --mount type=volume,source=recording_service_database,target=/home/rtiuser/database \
           -e WORKSPACE_DIR=/home/rtiuser/database \
           --name=recording_service \
           rticom/recording-service:latest \
           -cfgName default
   ```

**Bind-mount example**

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        -v $PWD/recording_service_database:/home/rtiuser/database \
        -e WORKSPACE_DIR=/home/rtiuser/database \
        --name=recording_service \
        rticom/recording-service:latest \
        -cfgName default
```

**Note:** The directory ``recording_service_database`` must exist in the host machine, and the user running the container (UID 1000, GID 1000) must have read and write permissions to it.

**Troubleshooting**

With both options, make sure that the permissions of the storage directory are set to the user and group used by the container (rtiuser:rtigroup).

To find the managed volume mount point, use the following command:

```shell
docker volume inspect recording_service_database
```

You will see the mount point in the Mountpoint field. For example:

```json
[
    {
        "CreatedAt": "2024-05-11T23:56:27-07:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/recording_service_database/_data",
        "Name": "recording_service_database",
        "Options": null,
        "Scope": "local"
    }
]
```

Then you can change the permissions of the mount point to the user and group used by the container:

```shell
sudo chown -R 1000:1000 /var/lib/docker/volumes/recording_service_database/_data
```

## Custom configuration

To provide your own configuration, follow these steps when running the container:

* bind-mount your configuration file (for example, MyRecordingService.xml) from the host into the following location in the Docker container: 
```/home/rtiuser/rti_workspace/7.4.0/user_config/recording_service/USER_RECORDING_SERVICE.xml```
* select the *Recording Service* configuration in the configuration file by adding the ``-cfgName`` parameter with the name of your selected configuration

For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        -v $PWD/MyRecordingService.xml:/home/rtiuser/rti_workspace/7.4.0/user_config/recording_service/USER_RECORDING_SERVICE.xml \
        --name=recording_service \
        rticom/recording-service:latest \
        -cfgName MyRecordingService
```

## Command-line parameters

To provide your command-line parameters to *Recording Service*, add them to the end of the ``docker run`` command. For example:

```
docker run -dt \
        --network host \
        -v $PWD/rti_license.dat:/opt/rti.com/rti_connext_dds-7.4.0/rti_license.dat \
        -v $PWD/MyRecordingService.xml:/home/rtiuser/rti_workspace/7.4.0/user_config/recording_service/USER_RECORDING_SERVICE.xml \
        --name=recording_service \
        rticom/recording-service:latest \
        -cfgName MyRecordingService \
        -verbosity WARN
```

The above example runs *Recording Service* with the verbosity level set to WARN.

To see the list of allowed parameters, use the ``-h`` parameter:

```
docker run --rm -t rticom/recording-service:latest -h
```

## Network configuration

The previous examples use the ``--network host`` parameter to run the containers in the host network. The host network is the most straightforward way to run the containers because it allows the containers to communicate with each other and with the host machine. However, the host network is not available on all platforms and has different levels of support depending on the operating system.

If you want to run the containers in a custom network isolated from the host network, you can create a custom network using `docker network create` and run the containers in that network. See the [Docker networking overview documentation](https://docs.docker.com/network/) for more information on Docker networks.

If you  want to make the containers accessible from outside the Docker environment without using the host network, the recommendation is to use *RTI Real-Time WAN Transport* and expose the necessary UDP ports using the `-p` option. For more information on *RTI Real-Time WAN Transport*, refer to the [User’s Manual](https://community.rti.com/static/documentation/connext-dds/7.4.0/doc/manuals/connext_dds_professional/users_manual/users_manual/PartRealtimeWAN.htm). For more information on the `-p` option, refer to the [Docker running containers documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports).

This image does not provide built-in configuration for *RTI Real-Time WAN Transport*. If you want to use it, you will need to provide your own configuration file.

## Release Notes

Release notes for RTI *Connext* products are available on the RTI Community Portal at https://community.rti.com/documentation. For patch release notes, contact our support team at support@rti.com to request the relevant Release Notes Supplement. For Docker image release notes, check RTI’s Github containers repository at https://github.com/rticommunity/rticonnextdds-containers.

## License

RTI® Recording Service is licensed under the following supplemental license terms and the Software License Agreement accompanying RTI Connext® Professional (https://www.rti.com/free-trial/terms).

This image uses Ubuntu as the base image, and your usage must comply with the applicable license terms found [here](https://hub.docker.com/_/ubuntu).

You can find the Software Bill of Materials (SBOM) third-party information in SPDX format in the ``/user/local/share/sbom/`` directory.

Additional third party information can be found at https://community.rti.com/documentation#doc_third_party.

Use the following command to retrieve the *RTI_License_Agreement.pdf* built-in file:

```
docker cp recording_service:/opt/rti.com/rti_connext_dds-7.4.0/RTI_License_Agreement.pdf .
```

## How to get a license file

An RTI license file is always required to run Recording Service in a Docker container.

### Existing customers

If you are an RTI customer, and you need an RTI Connext license file, contact [RTI support](https://www.rti.com/support). 

### Evaluators

If you are not an RTI customer, visit https://www.rti.com/free-trial/connext to get an RTI Connext free trial for release 7.5.0 or higher. With the free trial you will receive a limited-time license file that contains an activation key for RTI Connext Professional, RTI Security Plugins, RTI Real-Time WAN Transport, and RTI Cloud Discovery Service.

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