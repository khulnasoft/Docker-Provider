# Azure Monitor – Containers

---

## Introduction

This article describes how to set up and use [Azure Monitor - Containers](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-health) to monitor the health and performance of your workloads deployed to Kubernetes and OpenShift v4 environments.

Monitoring your Kubernetes cluster and containers is critical, especially when running a production cluster, at scale, with multiple applications.

---

## Pre-requisites

- [Kubernetes versions and support policy  same as AKS supported versions](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)

- You will need to create a location to store your monitoring data.

1. [Create Azure Log Analytics Workspace](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-quick-create-workspace)

- You will need to add AzureMonitor-Containers solution to your workspace from #1 above

2. [Add the 'AzureMonitor-Containers' Solution to your Log Analytics workspace.](http://aka.ms/coinhelmdoc)

3. [For AKS-Engine or ACS-Engine K8S cluster hosted in Azure, add required tags on cluster resources, to be able to use Azure Container monitoring User experience (aka.ms/azmon-containers)](http://aka.ms/coin-acs-tag-doc)
     > Note: Pre-requisite #3 not applicable for the AKS-Engine or ACS-Engine clusters hosted in Azure Stack or On-premise.

---

## Installing the Chart

> Note: If you want to customize the chart, fork the chart code in https://github.com/khulnasoft/docker-provider/tree/ci_prod/charts/azuremonitor-containers

> Note: `--name` flag not required in Helm3 since this flag is deprecated

> Note: use `amalogs.proxy` parameter to set the proxy endpoint if your K8s cluster configured behind the proxy. Refer to [configure proxy](#Configuring-Proxy-Endpoint) for more details about  proxy.

### To Use Azure Log Analytics Workspace in Public Cloud

```bash
$ helm repo add microsoft https://microsoft.github.io/charts/repo
$ helm install --name azmon-containers-release-1 \
--set amalogs.secret.wsid=<your_workspace_id>,amalogs.secret.key=<your_workspace_key>,amalogs.env.clusterName=<my_prod_cluster>  microsoft/azuremonitor-containers
```

### To Use Azure Log Analytics Workspace in Azure China Cloud

```bash
$ helm repo add microsoft https://microsoft.github.io/charts/repo
$ helm install --name azmon-containers-release-1 \
--set amalogs.domain=opinsights.azure.cn,amalogs.secret.wsid=<your_workspace_id>,amalogs.secret.key=<your_workspace_key>,amalogs.env.clusterName=<your_cluster_name>  microsoft/azuremonitor-containers
```

### To Use Azure Log Analytics Workspace in Azure US Government Cloud

```bash
$ helm repo add microsoft https://microsoft.github.io/charts/repo
$ helm install --name azmon-containers-release-1 \
--set amalogs.domain=opinsights.azure.us,amalogs.secret.wsid=<your_workspace_id>,amalogs.secret.key=<your_workspace_key>,amalogs.env.clusterName=<your_cluster_name>  microsoft/azuremonitor-containers
```

## Upgrading an existing Release to a new version

If the previous version of the chart installed with Helm2, it can be upgraded successfully to current version using Helm2.
But, if the previous version of chart installed  with the Helm3 or release migrated to Helm3,then chart can�t be upgraded to latest version due to issues in Helm3 with regards to upgrading the existing release to new version, as described in [Helm issue #6850](https://github.com/helm/helm/issues/6850)

## Uninstalling the Chart

To uninstall/delete the `azmon-containers-release-1` release:
> Note: `--purge` flag not required in Helm3 since this flag deprecated
```bash

$ helm del --purge azmon-containers-release-1

```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the MSOMS chart and their default values.

The following table lists the configurable parameters of the MSOMS chart and their default values.

| Parameter                    | Description                                             | Default                                                                                                                     |
| -----------------------      | --------------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------- |
| `amalogs.image.tag`         | image tag for Linux Agent.                              | Most recent release                                                                                                         |
| `amalogs.image.tagWindows`  | image tag for Windows Agent.                            | Most recent release                                                                                                         |
| `amalogs.image.imagerepo`   | image repo for Liunx & Windows.                         | Image repo path is mcr.microsoft.com/azuremonitor/containerinsights/ciprod
| `amalogs.image.pullPolicy`  | image pull policy for the agent.                        | IfNotPresent                                                                                                                |
| `amalogs.secret.wsid`       | Azure Log analytics workspace id                        | Does not have a default value, needs to be provided                                                                         |
| `amalogs.secret.key`        | Azure Log analytics workspace key                       | Does not have a default value, needs to be provided                                                                         |
| `amalogs.domain`            | Azure Log analytics cloud domain (public,china, us govt)| opinsights.azure.com (Public cloud as default), opinsights.azure.cn (China Cloud), opinsights.azure.us (US Govt Cloud)      |
| `amalogs.env.clusterName`   | Name of your cluster                                    | Does not have a default value, needs to be provided                                                                         |
| `amalogs.rbac`              | rbac enabled/disabled                                   | true  (i.e.enabled)                                                                                                           |
| `amalogs.proxy`             | Proxy endpoint                                          | Doesnt have default value. Refer to [configure proxy](#Configuring-Proxy-Endpoint) |
| `amalogs.priority`          | DaemonSet Pod Priority                                  | This is the [priority](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) to use for the daemonsets such that they get scheduled onto the node ahead of "normal" pods - must be an integer, defaults to 10 |

> Note: For Azure Manage K8s clusters such as Azure Arc K8s and ARO v4, `amalogs.env.clusterId` with fully qualified azure resource id of the cluster should be used instead of `amalogs.env.clusterName`

### Note

- Parameter `amalogs.env.doNotCollectKubeSystemLogs` has been removed starting chart version 1.0.0. Refer to 'Agent data collection settings' section below to configure it using configmap.
- onboarding of multiple clusters with the same cluster name to same log analytics workspace not supported. If need this configuration, use the cluster FQDN name rather than cluster dns prefix to avoid collision with clusterName
- The `amalogs.priority` parameter sets the priority of the ama-logs daemonset priority class.  This pod priority class is used for daemonsets to allow them to have priority over pods that can be scheduled elsewhere.  Without a priority class, it is possible for a node to fill up with "normal" pods before the daemonset pods get to be created for the node or get scheduled.  Note that pods are not "daemonset" pods - they are just pods created by the daemonset controller but they have a specific affinity set during creation to the specific node each pod was created to run on.  You want this value to be greater than 0 (default is 10) and generally greater than pods that have the flexibility to run on different nodes such that they do not block the node specific pods.

## Agent data collection settings

Staring with chart version 1.0.0, agent data collection settings are controlled thru a config map. Refer to documentation about agent data collection settings [here](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-agent-config)

You can create a Azure Loganalytics workspace from portal.azure.com and get its ID & PRIMARY KEY from 'Advanced Settings' tab in the Ux.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,


```bash

$ helm install --name myrelease-1 \
--set amalogs.secret.wsid=<your_workspace_id>,amalogs.secret.key=<your_workspace_key>,amalogs.env.clusterName=<your_cluster_name>
  microsoft/azuremonitor-containers
```
Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash

$ helm install --name myrelease-1 -f values.yaml microsoft/azuremonitor-containers

```

After you successfully deploy the chart, you will be able to see your data in
- [azure public cloud portal](https://aka.ms/azmon-containers) for the clusters in Azure Public Cloud
- [azure china cloud portal](https://aka.ms/azmon-containers-mooncake) for the clusters in Azure China Cloud
- [azure us government cloud portal](https://aka.ms/azmon-containers-fairfax) for the clusters in Azure US Government Cloud

If you need help with this chart, please reach us out by [creating a support ticket](https://azure.microsoft.com/en-us/support/create-ticket) in Azure.

## Custom resource

Starting with chart version 2.0.0, chart will create a CRD (healthstates.azmon.container.insights) in kube-system namespace. This is used by the agent for cluster health monitoring.
## Container Runtime(s)

Starting with chart version 2.7.0, chart will support Container Runtime Interface(CRI) compatiable runtimes such as CRI-O and ContainerD etc. in addition to Docker/Moby.

## Configuring Proxy Endpoint

Starting with chart version 2.7.1, chart will support specifying the Proxy endpoint via `amalogs.proxy` chart parameter so that all remote outbound traffic will be routed via configured proxy endpoint.

Communication between the Azure Monitor for containers agent and Azure Monitor backend can use an HTTP or HTTPS proxy server.

Both anonymous and basic authentication (username/password) proxies are supported.

The proxy configuration value has the following syntax:
[protocol://][user:password@]proxyhost[:port]

Property|Description
-|-
Protocol|http or https
user|username for proxy authentication
password|password for proxy authentication
proxyhost|Address or FQDN of the proxy server
port|port number for the proxy server

For example:
`amalogs.proxy=http://user01:password@proxy01.contoso.com:8080`

> Note: Although you do not have any user/password set for the proxy, you will still need to add a psuedo user/password. This can be any username or password.

The Azure Monitor for containers agent only creates secure connection over http.
Even if you specify the protocol as http, please note that http requests are created using SSL/TLS secure connection so the proxy must support SSL/TLS.

## Support for Windows Container Logs

Starting with chart version 2.7.1, chart deploys the daemonset on windows nodes which collects std{out;err} logs of the containers running on windows nodes.

## Ux

Once the Azure Monitor for containers chart successfully onboarded, you should be able to view insights of your cluster [Azure Portal](http://aka.ms/azmon-containers)

# Contact

If you have any questions or feedback regarding the container monitoring addon, please reach us by [creating a support ticket](https://azure.microsoft.com/en-us/support/create-ticket) in Azure.
