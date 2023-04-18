#!/bin/bash

firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --zone=public --add-port=8082/tcp --permanent

firewall-cmd --reload
firewall-cmd --list-ports
