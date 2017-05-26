#!/usr/bin/env bash
# Copy ssh keys if there are presents
if [ -d "/root/ssh-keys" -a "$(ls /root/ssh-keys)" ]; then
  mkdir -p /root/.ssh
  cp /root/ssh-keys/* /root/.ssh
fi