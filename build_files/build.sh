#!/bin/bash

set -ouex pipefail

rsync -rvK /ctx/system_files/ /

dnf5 install -y mpdris2
