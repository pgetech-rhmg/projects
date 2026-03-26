import boto3
rds = boto3.client('rds')

def lambda_handler(event, context):
    print("Lambda function started")

    try:
        # Start DB Instances
        print("Describing DB instances...")
        dbs = rds.describe_db_instances()
        print(f"Found {len(dbs['DBInstances'])} DB instances")

        for db in dbs['DBInstances']:
            # Exclude DocumentDB and Aurora instances
            if db['Engine'] in ['docdb', 'aurora', 'aurora-mysql', 'aurora-postgresql']:
                print(f"Skipping {db['Engine']} instance: {db['DBInstanceIdentifier']}")
                continue

            print(f"Checking DB instance: {db['DBInstanceIdentifier']} with status {db['DBInstanceStatus']}")

            # Check if DB instance stopped. Start it if eligible.
            if db['DBInstanceStatus'] == 'stopped':
                print(f"DB instance {db['DBInstanceIdentifier']} is stopped. Checking tags...")

                try:
                    GetTags = rds.list_tags_for_resource(ResourceName=db['DBInstanceArn'])['TagList']
                    print(f"Tags for {db['DBInstanceIdentifier']}: {GetTags}")

                    for tag in GetTags:
                        # If tag "autostart=yes" is set for instance, start it
                        if tag['Key'] == 'autostart' and tag['Value'] == 'yes':
                            print(f"Tag 'autostart=yes' found for {db['DBInstanceIdentifier']}. Starting instance...")
                            result = rds.start_db_instance(DBInstanceIdentifier=db['DBInstanceIdentifier'])
                            print(f"Starting instance: {db['DBInstanceIdentifier']}. Result: {result}")
                            break
                    else:
                        print(f"No 'autostart=yes' tag found for {db['DBInstanceIdentifier']}. Skipping start.")
                except Exception as e:
                    print(f"Cannot start instance {db['DBInstanceIdentifier']}. Error: {e}")
            else:
                print(f"DB instance {db['DBInstanceIdentifier']} is not stopped. Current status: {db['DBInstanceStatus']}")
    except Exception as e:
        print(f"Error describing DB instances: {e}")

    try:
        # Start DB Clusters
        print("Describing DB clusters...")
        clusters = rds.describe_db_clusters()
        print(f"Found {len(clusters['DBClusters'])} DB clusters")

        for cluster in clusters['DBClusters']:
            # Include only Aurora clusters
            if cluster['Engine'] not in ['aurora', 'aurora-mysql', 'aurora-postgresql']:
                print(f"Skipping non-Aurora cluster: {cluster['DBClusterIdentifier']}")
                continue

            print(f"Checking DB cluster: {cluster['DBClusterIdentifier']} with status {cluster['Status']}")

            # Check if DB cluster stopped. Start it if eligible.
            if cluster['Status'] == 'stopped':
                print(f"DB cluster {cluster['DBClusterIdentifier']} is stopped. Checking tags...")

                try:
                    GetTags = rds.list_tags_for_resource(ResourceName=cluster['DBClusterArn'])['TagList']
                    print(f"Tags for {cluster['DBClusterIdentifier']}: {GetTags}")

                    for tag in GetTags:
                        # If tag "autostart=yes" is set for cluster, start it
                        if tag['Key'] == 'autostart' and tag['Value'] == 'yes':
                            print(f"Tag 'autostart=yes' found for {cluster['DBClusterIdentifier']}. Starting cluster...")
                            result = rds.start_db_cluster(DBClusterIdentifier=cluster['DBClusterIdentifier'])
                            print(f"Starting cluster: {cluster['DBClusterIdentifier']}. Result: {result}")
                            break
                    else:
                        print(f"No 'autostart=yes' tag found for {cluster['DBClusterIdentifier']}. Skipping start.")
                except Exception as e:
                    print(f"Cannot start cluster {cluster['DBClusterIdentifier']}. Error: {e}")
            else:
                print(f"DB cluster {cluster['DBClusterIdentifier']} is not stopped. Current status: {cluster['Status']}")
    except Exception as e:
        print(f"Error describing DB clusters: {e}")

    print("Lambda function completed")

if __name__ == "__main__":
    lambda_handler(None, None)