#!/bin/sh

set -e

IMAGE="centos:centos7"
KETCHUP_NAME=$(uuidgen)
KETCHUP_NGINX_NAME=$(uuidgen)
TEST_DIR="/tmp/ansible_test_runner"
ANSIBLE_VERSION="2.4.2.0"

docker run --detach --privileged --volume="$PWD":$TEST_DIR:rw --name $KETCHUP_NAME $opts $IMAGE /sbin/init
docker run --detach --privileged --volume="$PWD":$TEST_DIR:rw --name $KETCHUP_NGINX_NAME $opts $IMAGE /sbin/init

# Prepare to launch test playbook
docker exec $KETCHUP_NAME       /bin/bash -c "yum install -y epel-release && yum install -y ansible-${ANSIBLE_VERSION}"
docker exec $KETCHUP_NGINX_NAME /bin/bash -c "yum install -y epel-release && yum install -y ansible-${ANSIBLE_VERSION}"

# Launch test playbook for ketchup
docker exec $KETCHUP_NAME       /bin/bash -c "cd $TEST_DIR/tests && ansible-playbook -i travis_test_inventory -t ketchup       travis_test_ketchup.yml"

# Launch test playbook for ketchup_nginx
docker exec $KETCHUP_NGINX_NAME /bin/bash -c "cd $TEST_DIR/tests && ansible-playbook -i travis_test_inventory -t ketchup_nginx travis_test_ketchup.yml"

#
# [EOF]
#
