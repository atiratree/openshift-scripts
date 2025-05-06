#!/usr/bin/env bash

# Script to remove dangling resources after the cluster has been garbage collected
# without calling openshift-install destroy

cluster_name=${1:-clustername}
hosted_zone_dns_name=${2:-group-b.devcluster.openshift.com}
profile=${3:-openshift-group-b}

hosted_zone_id=$(
    aws route53 list-hosted-zones-by-name \
        --profile "${profile}" \
        --dns-name ${hosted_zone_dns_name} \
        --query HostedZones[0].Id \
        --output text
)

resource_record_sets=$( \
    aws route53 list-resource-record-sets \
        --profile "${profile}" \
        --hosted-zone-id "${hosted_zone_id}" \
        --query "ResourceRecordSets[?contains(Name,'${cluster_name}')]" \
        --output json
)

if [ "${resource_record_sets}" = "[]" ] ; then
    printf "No resource record sets found for cluster %s\n" "${cluster_name}"
    exit
fi

batch=$( \
    jq '{ "Changes":[ .[] | {"Action":"DELETE", "ResourceRecordSet": . }]}' <<< "${resource_record_sets}"
)

names=$( \
    jq  -r '.[].Name' <<< "${resource_record_sets}"
)

printf "Requesting deletion of resource record sets...\n"
printf "${names}"
change_info_id=$(
    aws route53 change-resource-record-sets \
        --profile "${profile}" \
        --hosted-zone-id "${hosted_zone_id}" \
        --query ChangeInfo.Id \
        --output text \
        --change-batch "${batch}"
)
printf "\n"

printf "Waiting for resource record sets to be deleted..."
aws route53 wait resource-record-sets-changed --profile "${profile}" --id "${change_info_id}"

printf "\n"
