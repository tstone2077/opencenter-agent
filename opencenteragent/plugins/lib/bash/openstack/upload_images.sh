#!/bin/bash
#
# Copyright 2012, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
source "$OPENCENTER_BASH_DIR/opencenter.sh"

if [[ -f /etc/redhat-release ]]; then
    DISTRO="redhat"
else
    DISTRO="debian"
fi
IMAGE_LIST="cirros precise"

if [[ ! -e /root/openrc ]]; then
    echo "/root/openrc does not exist and I cannot continue.  Good bye."
    exit 1
fi

if [[ ! -e /usr/bin/glance ]]; then
    echo "glance has not been installed and I cannot continue without it.  Good bye."
    exit 2
fi

. /root/openrc

for i in ${IMAGE_LIST}; do
    IMAGE_STATUS=$(/usr/bin/glance image-list --name ${i} | awk '/'${i}'/ {print $12}')
    if [[ -z ${IMAGE_STATUS} ]]; then
        # image does not exist
        case ${i} in
            cirros)
                /usr/bin/glance image-create --name cirros --disk-format qcow2 --container-format bare --location https://launchpadlibrarian.net/83305348/cirros-0.3.0-x86_64-disk.img --is-public True
                ;;
            precise)
                /usr/bin/glance image-create --name precise --disk-format qcow2 --container-format bare --location http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img --is-public True
                ;;
            *)
                echo "You have asked me to upload an image that I know nothing about and I cannot continue.  Good Bye."
                exit 3;
                ;;
        esac
    fi
done;

return_attr "glance_images_uploaded" "true"
