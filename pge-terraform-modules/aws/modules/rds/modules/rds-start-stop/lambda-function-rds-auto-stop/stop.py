import boto3
rds = boto3.client('rds')

def lambda_handler(event, context):
    print("Lambda function started")

    try:
        # Stop DB instances
        print("Describing DB instances...")
        dbs = rds.describe_db_instances()
        print(f"Found {len(dbs['DBInstances'])} DB instances")

        for db in dbs['DBInstances']:
            # Exclude DocumentDB and Aurora instances
            if db['Engine'] in ['docdb', 'aurora', 'aurora-mysql', 'aurora-postgresql']:
                print(f"Skipping {db['Engine']} instance: {db['DBInstanceIdentifier']}")
                continue

            print(f"Checking DB instance: {db['DBInstanceIdentifier']} with status {db['DBInstanceStatus']}")

            # Check if DB instance is not already stopped
            if db['DBInstanceStatus'] == 'available':
                print(f"DB instance {db['DBInstanceIdentifier']} is available. Checking tags...")

                try:
                    GetTags = rds.list_tags_for_resource(ResourceName=db['DBInstanceArn'])['TagList']
                    print(f"Tags for {db['DBInstanceIdentifier']}: {GetTags}")

                    for tag in GetTags:
                        # If tag "autostop=yes" is set for instance, stop it
                        if tag['Key'] == 'autostop' and tag['Value'] == 'yes':
                            print(f"Tag 'autostop=yes' found for {db['DBInstanceIdentifier']}. Stopping instance...")
                            result = rds.stop_db_instance(DBInstanceIdentifier=db['DBInstanceIdentifier'])
                            print(f"Stopping instance: {db['DBInstanceIdentifier']}. Result: {result}")
                            break
                    else:
                        print(f"No 'autostop=yes' tag found for {db['DBInstanceIdentifier']}. Skipping stop.")
                except Exception as e:
                    print(f"Cannot stop instance {db['DBInstanceIdentifier']}. Error: {e}")
            else:
                print(f"DB instance {db['DBInstanceIdentifier']} is not available. Current status: {db['DBInstanceStatus']}")
    except Exception as e:
        print(f"Error describing DB instances: {e}")

    try:
        # Stop DB clusters
        print("Describing DB clusters...")
        clusters = rds.describe_db_clusters()
        print(f"Found {len(clusters['DBClusters'])} DB clusters")

        for cluster in clusters['DBClusters']:
            # Exclude DocumentDB clusters
            # Include only Aurora clusters
            if cluster['Engine'] not in ['aurora', 'aurora-mysql', 'aurora-postgresql']:
                print(f"Skipping non-Aurora cluster: {cluster['DBClusterIdentifier']}")
                continue

            print(f"Checking DB cluster: {cluster['DBClusterIdentifier']} with status {cluster['Status']}")

            # Check if DB cluster is not already stopped
            if cluster['Status'] == 'available':
                print(f"DB cluster {cluster['DBClusterIdentifier']} is available. Checking tags...")

                try:
                    GetTags = rds.list_tags_for_resource(ResourceName=cluster['DBClusterArn'])['TagList']
                    print(f"Tags for {cluster['DBClusterIdentifier']}: {GetTags}")

                    for tag in GetTags:
                        # If tag "autostop=yes" is set for cluster, stop it
                        if tag['Key'] == 'autostop' and tag['Value'] == 'yes':
                            print(f"Tag 'autostop=yes' found for {cluster['DBClusterIdentifier']}. Stopping cluster...")
                            result = rds.stop_db_cluster(DBClusterIdentifier=cluster['DBClusterIdentifier'])
                            print(f"Stopping cluster: {cluster['DBClusterIdentifier']}. Result: {result}")
                            break
                    else:
                        print(f"No 'autostop=yes' tag found for {cluster['DBClusterIdentifier']}. Skipping stop.")
                except Exception as e:
                    print(f"Cannot stop cluster {cluster['DBClusterIdentifier']}. Error: {e}")
            else:
                print(f"DB cluster {cluster['DBClusterIdentifier']} is not available. Current status: {cluster['Status']}")
    except Exception as e:
        print(f"Error describing DB clusters: {e}")

    print("Lambda function completed")

if __name__ == "__main__":
    lambda_handler(None, None)