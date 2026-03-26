resource "aws_cloudwatch_dashboard" "main" {
  count          = var.create_eks_dashboard ? 1 : 0
  dashboard_name = "${var.eks_cluster_id}-cluster"



  dashboard_body = <<EOF
  {
        "widgets": [
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": 
                    [
                        [{"expression":"SEARCH('{ContainerInsights,ClusterName,InstanceId,NodeName} ClusterName=\"${var.eks_cluster_id}\" InstanceId node_memory_utilization', 'Maximum', 300)"}]
                    ],
                    "title": "EKS Nodes Memory % Utilization",
                    "stat":"Maximum",
                    "region":"${var.aws_region}",
                    "view": "timeSeries",
                    "stacked": false,
                    "period": 300
                }
            },
            {   
                "type": "metric",
                "x": 12,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": 
                    [ 
                      [{"expression":"SEARCH('{ContainerInsights,ClusterName,InstanceId,NodeName} ClusterName=\"${var.eks_cluster_id}\" InstanceId node_cpu_utilization', 'Maximum', 300)"}]
                    ],              
                    "title": "EKS Nodes CPU % Utilization",
                    "stat":"Maximum",
                    "region":"${var.aws_region}",
                    "view": "timeSeries",
                    "stacked": false,
                    "period": 300
                }
            }, 
            {
                "type": "metric",
                "x": 0,
                "y": 6,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": 
                    [
                          [{"expression":"SEARCH('{ContainerInsights,ClusterName,InstanceId,NodeName} ClusterName=\"${var.eks_cluster_id}\" InstanceId node_filesystem_utilization', 'Maximum', 300)"}]   
                    ],
                    "title": "EKS Nodes FileSystem % Utilization",
                    "stat":"Maximum",
                    "region":"${var.aws_region}",
                    "view": "timeSeries",
                    "stacked": false,
                    "period": 300
                }
            },
            {
                "type": "metric",
                "x": 12,
                "y": 6,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": 
                    [
                          [{"expression":"SEARCH('{ContainerInsights,ClusterName,InstanceId,NodeName} ClusterName=\"${var.eks_cluster_id}\" InstanceId node_network_total_bytes', 'Maximum', 300)"}]   
                    ],
                    "title": "EKS Nodes Networking",
                    "stat":"Average",
                    "region":"${var.aws_region}",
                    "view": "timeSeries",
                    "stacked": false,
                    "period": 300
                }
            },
            {
                "type": "metric",
                "x": 12,
                "y": 12,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics":
                    [
                          [{"expression":"SEARCH('{ContainerInsights,ClusterName,InstanceId,NodeName} ClusterName=\"${var.eks_cluster_id}\" InstanceId number_of_running_pods', 'Maximum', 300)"}]   
                    ],
                    "title": "EKS Running Pods",
                    "stat":"Maximum",
                    "region":"${var.aws_region}",
                    "view": "timeSeries",
                    "stacked": false,
                    "period": 300
                }
            },
            {
            "height": 6,
            "width": 6,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "cluster_node_count", "ClusterName", "${var.eks_cluster_id}", { "period": 300, "stat": "Maximum" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "EKS:Clusters.NumberOfNodes",
                "region": "${var.aws_region}",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "singleValue",
                "stacked": false
            }
           },
           {
            "height": 6,
            "width": 6,
            "y": 12,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "cluster_failed_node_count", "ClusterName", "${var.eks_cluster_id}", { "period": 300, "stat": "Maximum" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "EKS:Clusters.NumberOfFailedNodes",
                "region": "${var.aws_region}",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "singleValue",
                "stacked": false
            }
           }
        ]
    }
EOF
}



