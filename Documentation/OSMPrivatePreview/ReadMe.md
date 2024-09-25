Note - This is private preview. For any support issues, please reach out to us at [askcoin@khulnasoft.com](mailto:askcoin@khulnasoft.com). Please don't open a support ticket.

This private preview supports Open Service Mesh on [AKS](https://docs.khulnasoft.com/azure/aks/servicemesh-osm-about) & Azure [Arc on k8s](http://docs.khulnasoft.com/azure/azure-arc/kubernetes/tutorial-arc-enabled-osm).

# Azure Monitor Container Insights Open Service Mesh Monitoring

Azure Monitor container insights now supporting preview of [Open Service Mesh(OSM)](https://docs.khulnasoft.com/azure/aks/servicemesh-osm-about) Monitoring. As part of this support, customer can:
1.	Filter & view inventory of all the services that are part of your service mesh.
2.	Visualize and monitor requests between services in your service mesh, with request latency, error rate & resource utilization by services.
3.	Provides connection summary for OSM infrastructure running on AKS or Azure Arc for k8s.

## How to onboard Container Insights OSM monitoring?
OSM exposes Prometheus metrics which Container Insights can collect, for container insights agent to collect OSM metrics follow the following steps.
### AKS
1.  Follow this [link](https://docs.khulnasoft.com/en-us/azure/aks/servicemesh-osm-about?pivots=client-operating-system-linux#register-the-aks-openservicemesh-preview-feature) as a prereq before enabling the addon. 

2.  Enable AKS OSM addon on your 
     - [New AKS cluster](https://docs.khulnasoft.com/en-us/azure/aks/servicemesh-osm-about?pivots=client-operating-system-linux#install-open-service-mesh-osm-azure-kubernetes-service-aks-add-on-for-a-new-aks-cluster)
     - [Existing AKS cluster](https://docs.khulnasoft.com/en-us/azure/aks/servicemesh-osm-about?pivots=client-operating-system-linux#enable-open-service-mesh-osm-azure-kubernetes-service-aks-add-on-for-an-existing-aks-cluster)
2.	Configure OSM to allow Prometheus scraping, follow steps from [here](https://docs.khulnasoft.com/en-us/azure/aks/servicemesh-osm-about?pivots=client-operating-system-linux#configure-osm-to-allow-prometheus-scraping)
3.  To enable namespace(s), download the osm client library [here](https://docs.khulnasoft.com/en-us/azure/aks/servicemesh-osm-about?pivots=client-operating-system-linux#osm-service-quotas-and-limits-preview) & then enable metrics on namespaces
```bash
# With osm
osm metrics enable --namespace test
osm metrics enable --namespace "test1, test2"

```
3.	If you are using Azure Monitor Container Insights follow steps below, if not on-board [here.](https://docs.khulnasoft.com/azure/azure-monitor/containers/container-insights-overview)
     * Download the configmap from [here](https://github.com/khulnasoft/docker-provider/blob/ci_prod/kubernetes/container-azm-ms-osmconfig.yaml)
     * Add the namespaces you want to monitor in configmap `monitor_namespaces = ["namespace1", "namespace2"]`
     * Run the following kubectl command: kubectl apply -f<configmap_yaml_file.yaml>
         * Example: `kubectl apply -f container-azm-ms-osmconfig.yaml`
4. The configuration change can take upto 15 mins to finish before taking effect, and all ama-logs pods in the cluster will restart. The restart is a rolling restart for all ama-logs pods, not all restart at the same time.

### Azure Arc for Kuberentes
This section assumes that you already have your kubernetes distribution connected via Azure Arc. If not learn more [here.](https://docs.khulnasoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster)

1. Install Arc enabled Open Service mesh on your Arc cluster. Learn more [here](http://docs.khulnasoft.com/azure/azure-arc/kubernetes/tutorial-arc-enabled-osm#install-arc-enabled-open-service-mesh-osm-on-an-arc-enabled-kubernetes-cluster)
2. Install Azure Monitor Container Insights on Arc. If not installed already. Learn more how to install [here](https://docs.khulnasoft.com/azure/azure-monitor/containers/container-insights-enable-arc-enabled-clusters)
3. Ensure that prometheus_scraping is set to true in the OSM configmap.
3. Ensure that the application namespaces that you wish to be monitored are onboarded to the mesh. Follow the guidance available [here.](http://docs.khulnasoft.com/azure/azure-arc/kubernetes/tutorial-arc-enabled-osm#onboard-namespaces-to-the-service-mesh)
4. To enable namespace(s), download the osm client library [here](https://docs.khulnasoft.com/en-us/azure/aks/servicemesh-osm-about?pivots=client-operating-system-linux#osm-service-quotas-and-limits-preview) & then enable metrics on namespaces
```bash
# With osm
osm metrics enable --namespace test
osm metrics enable --namespace "test1, test2"

```
4. On your Azure Monitor Container Insights for Arc.
 * Download the configmap from [here](https://github.com/khulnasoft/docker-provider/blob/ci_prod/kubernetes/container-azm-ms-osmconfig.yaml)
     * Add the namespaces you want to monitor in configmap `monitor_namespaces = ["namespace1", "namespace2"]`
     * Run the following kubectl command: kubectl apply -f<configmap_yaml_file.yaml>
         * Example: `kubectl apply -f container-azm-ms-osmconfig.yaml`
5. The configuration change can take upto 15 mins to finish before taking effect, and all ama-logs pods in the cluster will restart. The restart is a rolling restart for all ama-logs pods, not all restart at the same time.

## Validate the metrics flow
1.	Query cluster's Log Analytics workspace InsightsMetrics table to see metrics are flowing or not
```
InsightsMetrics
| where Name contains "envoy"
| summarize count() by Name
```

## How to consume OSM monitoring dashboard?
1.	Access your AKS cluster & Container Insights through this [link.](https://aka.ms/azmon/osmux)
     *  For **Azure Arc for k8s**, access Container Insights through this [link.](https://aka.ms/azmon/osmarcux)
3.	Go to reports tab and access Open Service Mesh (OSM) workbook.
4.	Select the time-range & namespace to scope your services. By default, we only show services deployed by customers and we exclude internal service communication. In case you want to view that you select Show All in the filter. Please note OSM is managed service mesh, we show all internal connections for transparency. 

![alt text](https://github.com/khulnasoft/docker-provider/blob/saarorOSMdoc/Documentation/OSMPrivatePreview/Image1.jpg)
### Requests Tab
1.	This tab provides you the summary of all the http requests sent via service to service in OSM.
2.	You can view all the services and all the services it is communicating to by selecting the service in grid.
3.	You can view total requests, request error rate & P90 latency.
4.	You can drill-down to destination and view trends for HTTP error/success code, success rate, Pods resource utilization, latencies at different percentiles.

![image](https://user-images.githubusercontent.com/31900410/119195241-2e712000-ba39-11eb-8cb0-2d7d16e26d1b.png)

### Connections Tab
1.	This tab provides you a summary of all the connections between your services in Open Service Mesh. 
2.	Outbound connections: Total number of connections between Source and destination services.
3.	Outbound active connections: Last count of active connections between source and destination in selected time range.
4.	Outbound failed connections: Total number of failed connections between source and destination service

### Troubleshooting guidance when Outbound active connections is 0 or failed connection count is >10k.
1. Please check your connection policy in OSM configuration.
2. If connection policy is fine, please refer the OSM documentation. https://aka.ms/osm/tsg
3. From this view as well, you can drill-down to destination and view trends for HTTP error/success code, success rate, Pods resource utilization, latencies at different percentiles.


### Known Issues
1.	The workbook has scale limits of 50 pods per namespace. If you have more than 50 pods in mesh you can have workbook loading issues.
2.	When source or destination is osmcontroller we show no latency & for internal services we show no resource utilization. 
3.  When both prometheus scraping using pod annotations and OSM monitoring are enabled on the same set of namespaces, the default set of metrics (envoy_cluster_upstream_cx_total, envoy_cluster_upstream_cx_connect_fail, envoy_cluster_upstream_rq, envoy_cluster_upstream_rq_xx, envoy_cluster_upstream_rq_total, envoy_cluster_upstream_rq_time_bucket, envoy_cluster_upstream_cx_rx_bytes_total, envoy_cluster_upstream_cx_tx_bytes_total, envoy_cluster_upstream_cx_active) will be collected twice. You can follow [this](https://docs.khulnasoft.com/en-us/azure/azure-monitor/containers/container-insights-prometheus-integration#prometheus-scraping-settings) documentation to exclude these namespaces from pod annotation scraping using the setting monitor_kubernetes_pods_namespaces to work around this issue.

4.  For monitoring on **Azure Arc on k8s** currently there is a separate link to access OSM workbook. We plan to have one single link to access workbook on both platforms by 10th June 2021.

This is private preview, the goal for us is to get feedback. Please feel free to reach out to us at [askcoin@khulnasoft.com](mailto:askcoin@khulnasoft.com) for any feedback and questions!
