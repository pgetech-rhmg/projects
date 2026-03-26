#!/bin/bash
set -euxo pipefail

export WORKSPACE_ID
WORKSPACE_ID=$(
	curl -f \
		--header "Authorization: Bearer $TFC_TOKEN" \
		--header "Content-Type: application/vnd.api+json" \
		"https://app.terraform.io/api/v2/organizations/pgetech/workspaces/$TFC_WS" \
	| jq -r '.data.id'
)

sleep 5 # Give TFC some time to start the new run

export RUN_ID
RUN_ID=$(
	# 404 is expected here, so we don't use `-f`.
	curl \
		--header "Authorization: Bearer $TFC_TOKEN" \
		--header "Content-Type: application/vnd.api+json" \
		"https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/runs?search%5Bcommit%5D=$GIT_HASH" \
	| jq -r '.data[0].id'
)
if [ "$RUN_ID" == "null" ]; then
	echo "No TFC run exists for this commit. Continuing with pipeline."
	exit 0
fi

while true; do
	RUN_STATUS=$(
		curl -f \
			--header "Authorization: Bearer $TFC_TOKEN" \
			--header "Content-Type: application/vnd.api+json" \
			"https://app.terraform.io/api/v2/runs/$RUN_ID" \
		| jq -r '.data.attributes.status'
	);

	echo "Status: $RUN_STATUS"
	if [[ "$RUN_STATUS" == "applied" ]]; then
		echo "Apply complete!"
		exit 0
	elif [[ "$RUN_STATUS" == "planned_and_finished" ]]; then
		echo "No changes."
		exit 0
	elif [[
		"$RUN_STATUS" == "errored"
		|| "$RUN_STATUS" == "discarded"
		|| "$RUN_STATUS" == "canceled"
		|| "$RUN_STATUS" == "force_canceled"
		|| "$RUN_STATUS" == "policy_soft_failed"
	]]; then
		echo "Run exited with error."
		exit 1
	fi

	sleep 5;
done
