#!/bin/bash

# Fail the script on any error
set -e

# Load environment variables from .env file
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi

REGISTRY_URL="${REGISTRY_URL:-https://dev-agentic-registry.house-of-communication.world}"
AUTH_USERNAME="${BASIC_AUTH_USERNAME}"
AUTH_PASSWORD="${BASIC_AUTH_PASSWORD}"
WORKFLOW_NAME="DependencyAnalysisWorkflow"
NODE_ID="e25de453-8b99-4e45-8c54-0cf2693825b1"

WORKFLOW_INPUTS='{
  "inputs": {
    "dependency_file_url": "https://costeaalex.com/hackathon/composer.json"
  },
  "workflow": "'"$WORKFLOW_NAME"'",
  "node_id": "'"$NODE_ID"'"
}'


echo "Starting workflow: $WORKFLOW_NAME"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$REGISTRY_URL/api/v1/jobs" \
  -u "$AUTH_USERNAME:$AUTH_PASSWORD" \
  -H "Content-Type: application/json" \
  -d "$WORKFLOW_INPUTS")

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Status: $HTTP_STATUS"
echo "Response Body: $RESPONSE_BODY"

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "Failed to start the workflow. HTTP Status: $HTTP_STATUS"
  exit 1
fi

JOB_ID=$(echo "$RESPONSE_BODY" | jq -r '.')

if [[ -z "$JOB_ID" || "$JOB_ID" == "null" ]]; then
  echo "Failed to start the workflow. No Job ID received."
  exit 1
fi

echo "Workflow started with Job ID: $JOB_ID"

while true; do
  sleep 5
  RESPONSE=$(curl -s -X GET "$REGISTRY_URL/api/v1/jobs/$JOB_ID" \
    -u "$AUTH_USERNAME:$AUTH_PASSWORD")

  JOB_STATUS=$(echo "$RESPONSE" | jq -r '.status')

  if [[ "$JOB_STATUS" == "completed" ]]; then
    echo "Job completed."
    break
  elif [[ "$JOB_STATUS" == "failed" ]]; then
    echo "Job failed."
    echo "Response: $RESPONSE"
    exit 1
  else
    echo "Job status: $JOB_STATUS. Waiting..."
  fi
done

OUTPUT=$(echo "$RESPONSE" | jq -r '.result')
echo "Job Output:"
echo "$OUTPUT"