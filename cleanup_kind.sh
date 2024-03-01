#!/bin/bash
set -e

docker kill webhook
kind delete cluster
