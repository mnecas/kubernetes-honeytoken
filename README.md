# Kubernetes honeytokens

## Cluster creation
```bash
export KUBERNETES_ADDR=10.43.17.42
export SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXXXX/YYYYYYYY/ZZZZZZZZZZZZz 
./setup_kind.sh
```

## User creation
```bash
./create_token.sh username
```

## Design

### Kind

### Auditlog webhook server