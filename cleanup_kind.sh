#!/bin/bash
set -e

podman kill webhook
kind delete cluster