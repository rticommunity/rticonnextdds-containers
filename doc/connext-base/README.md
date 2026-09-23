Welcome to the _RTI Connext®_ Base Docker image, a public foundation for
building containerized RTI Connext applications. It is intended to be extended
to create SDK, Runtime, tools and service images.

## Releases

The documentation on this page applies to the _Connext Base_ Docker image with
the `latest` tag, which refers to the most recent image released by RTI. To
confirm the corresponding _Connext_ release or review the available tags, see
[Connext Base on Docker Hub](https://hub.docker.com/r/rticom/connext-base/tags).

For documentation from previous releases, see the
[RTI Connext container repository](https://github.com/rticommunity/rticonnextdds-containers)
and select the appropriate release branch.

## Using the Connext Base container image

_Connext Base_ is intended to be extended by another Dockerfile rather than run
as a standalone application. Use it as the base for your image:

```dockerfile
FROM rticom/connext-base:7.7.0
```

See the [available tags](https://hub.docker.com/r/rticom/connext-base/tags)
before selecting a version.

## Release Notes

Release notes for _RTI Connext®_ products are available on the
[RTI Community Portal](https://community.rti.com/documentation). For patch
release notes, contact [RTI support](mailto:support@rti.com). Docker image
release notes are available in the
[RTI Connext container repository](https://github.com/rticommunity/rticonnextdds-containers).

## License

The _RTI Connext®_ Base Docker image is licensed under the following
supplemental license terms and the Software License Agreement accompanying RTI
Connext® Professional (https://www.rti.com/free-trial/terms).

For an RTI Connext Professional free trial, visit
https://www.rti.com/free-trial/connext.

This image uses Ubuntu as its base image. Your use must comply with the
[applicable Ubuntu license terms](https://hub.docker.com/_/ubuntu).

Software Bill of Materials (SBOM) third-party information is available in SPDX
format in the `/usr/local/share/sbom/` directory.

Additional third-party information is available in the
[RTI documentation](https://community.rti.com/documentation#doc_third_party).

The _RTI_License_Agreement_LM.pdf_ file is included in the image and can be
extracted with:

```sh
docker create --name connext_base rticom/connext-base:7.7.0
docker cp connext_base:/opt/rti.com/rti_connext_dds-7.7.0/RTI_License_Agreement_LM.pdf .
docker rm connext_base
```

## How to get a license file

An RTI license file is required to run RTI Connext software in a container based
on _Connext Base_.

### Existing customers

If you are an RTI customer and need an RTI Connext license file, contact
[RTI support](https://www.rti.com/support).

### Evaluators

If you are not an RTI customer, visit
https://www.rti.com/free-trial/connext to get an RTI Connext free trial for
release 7.7.0 or later. The free trial provides a limited-time license file
with activation for RTI Connext Professional, RTI Security Plugins, RTI
Real-Time WAN Transport and RTI Cloud Discovery Service.

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
