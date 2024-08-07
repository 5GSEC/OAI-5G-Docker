# O-RAN SC RIC Deployment Guide

Env: Ubuntu 20.04 LTS (x86_64), Free storage ~1TB, 12 Intel I7 CPUs, 32G RAM

## Prerequisite

- Kubernetes (non-RT RIC requires at least v1.19+)
- Helm
- Docker

## Near-RT-RIC

Referenced and tweaked from: https://docs.o-ran-sc.org/projects/o-ran-sc-ric-plt-ric-dep/en/latest/installation-guides.html

### Getting and Preparing Deployment Scripts

Clone the ric-plt/dep git repository that has deployment scripts and support files on the target VM.

```
git clone https://gerrit.o-ran-sc.org/r/ric-plt/ric-dep
```

### Deploying the Infrastructure and Platform Groups

Use the scripts below to install kubernetes, kubernetes-CNI, helm and docker on a fresh Ubuntu 20.04 installation. Note that since May 2022 there’s no need for anything form the repo it/dep anymore.

```
# install kubernetes, kubernetes-CNI, helm and docker
cd ric-dep/bin
sudo ./install_k8s_and_helm.sh

# install chartmuseum into helm and add ric-common templates
sudo ./install_common_templates_to_helm.sh
```

After the recipes are edited and helm started, the Near Realtime RIC platform is ready to be deployed, but first update the deployment recipe as per instructions in the next section.


### Modify the deployment recipe

Choose a specific release, for example `example_recipe_latest_stable.yaml` for the latest stable release, `example_recipe_oran_i_release.yaml` for the I release.

Below uses `example_recipe_latest_stable.yaml` as an example.

Edit the recipe files ./RECIPE_EXAMPLE/example_recipe_latest_stable.yaml (which is a softlink that points to the latest release version). “example_recipe_latest_unstable.yaml points to the latest example file that is under current development.

```
extsvcplt:
  ricip: <YOUR_MACHINE_IP>
  auxip: <YOUR_MACHINE_IP>
```

Deployment scripts support both helm v2 and v3. The deployment script will determine the helm version installed in cluster during the deployment.

To specify which version of the RIC platform components will be deployed, update the RIC platform component container tags in their corresponding section.

You can specify which docker registry will be used for each component. If the docker registry requires login credential, you can add the credential in the following section. Please note that the installation suite has already included credentials for O-RAN Linux Foundation docker registries. Please do not create duplicate entries.

```
docker-credential:
  enabled: true
  credential:
    SOME_KEY_NAME:
      registry: ""
      credential:
        user: ""
        password: ""
        email: ""
```

Adapt the `e2mgr` config by specifying the `mcc` and `mnc` value to your gNB's:

```
e2mgr:
  image:
    registry: "nexus3.o-ran-sc.org:10002/o-ran-sc"
    name: ric-plt-e2mgr
    tag: 6.0.4
  privilegedmode: false
  globalRicId:
    ricId: "AACCE"
    mcc: "208"
    mnc: "99"
```

For more advanced recipe configuration options, please refer to the recipe configuration guideline.

### Installing the RIC

After updating the recipe you can deploy the RIC with the command below. Note that generally use the latest recipe marked stable or one from a specific release.

```
cd ric-dep/bin
sudo ./install -f ../RECIPE_EXAMPLE/example_recipe_latest_stable.yaml
```

### Checking the Deployment Status

Now check the deployment status after a short wait. Results similar to the output shown below indicate a complete and successful deployment. Check the STATUS column from both kubectl outputs to ensure that all are either “Completed” or “Running”, and that none are “Error” or “ImagePullBackOff”.

```
# sudo helm list -A
NAME                  REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
r3-a1mediator         1               Thu Jan 23 14:29:12 2020        DEPLOYED        a1mediator-3.0.0        1.0             ricplt
r3-appmgr             1               Thu Jan 23 14:28:14 2020        DEPLOYED        appmgr-3.0.0            1.0             ricplt
r3-dbaas1             1               Thu Jan 23 14:28:40 2020        DEPLOYED        dbaas1-3.0.0            1.0             ricplt
r3-e2mgr              1               Thu Jan 23 14:28:52 2020        DEPLOYED        e2mgr-3.0.0             1.0             ricplt
r3-e2term             1               Thu Jan 23 14:29:04 2020        DEPLOYED        e2term-3.0.0            1.0             ricplt
r3-infrastructure     1               Thu Jan 23 14:28:02 2020        DEPLOYED        infrastructure-3.0.0    1.0             ricplt
r3-jaegeradapter      1               Thu Jan 23 14:29:47 2020        DEPLOYED        jaegeradapter-3.0.0     1.0             ricplt
r3-rsm                1               Thu Jan 23 14:29:39 2020        DEPLOYED        rsm-3.0.0               1.0             ricplt
r3-rtmgr              1               Thu Jan 23 14:28:27 2020        DEPLOYED        rtmgr-3.0.0             1.0             ricplt
r3-submgr             1               Thu Jan 23 14:29:23 2020        DEPLOYED        submgr-3.0.0            1.0             ricplt
r3-vespamgr           1               Thu Jan 23 14:29:31 2020        DEPLOYED        vespamgr-3.0.0          1.0             ricplt

# sudo kubectl get pods -n ricplt
NAME                                               READY   STATUS             RESTARTS   AGE
deployment-ricplt-a1mediator-69f6d68fb4-7trcl      1/1     Running            0          159m
deployment-ricplt-appmgr-845d85c989-qxd98          2/2     Running            0          160m
deployment-ricplt-dbaas-7c44fb4697-flplq           1/1     Running            0          159m
deployment-ricplt-e2mgr-569fb7588b-wrxrd           1/1     Running            0          159m
deployment-ricplt-e2term-alpha-db949d978-rnd2r     1/1     Running            0          159m
deployment-ricplt-jaegeradapter-585b4f8d69-tmx7c   1/1     Running            0          158m
deployment-ricplt-rsm-755f7c5c85-j7fgf             1/1     Running            0          158m
deployment-ricplt-rtmgr-c7cdb5b58-2tk4z            1/1     Running            0          160m
deployment-ricplt-submgr-5b4864dcd7-zwknw          1/1     Running            0          159m
deployment-ricplt-vespamgr-864f95c9c9-5wth4        1/1     Running            0          158m
r3-infrastructure-kong-68f5fd46dd-lpwvd            2/2     Running            3          160m

# sudo kubectl get pods -n ricinfra
NAME                                        READY   STATUS      RESTARTS   AGE
deployment-tiller-ricxapp-d4f98ff65-9q6nb   1/1     Running     0          163m
tiller-secret-generator-plpbf               0/1     Completed   0          163m
```

### Checking Container Health


Check the health of the application manager platform component by querying it via the ingress controller using the following command.

```
$ curl -v http://localhost:32080/appmgr/ric/v1/health/ready
```

(Replace `localhost` with your machine's IP if not successful)

The output should look as follows.

```
*   Trying 10.0.2.100...
* TCP_NODELAY set
* Connected to 10.0.2.100 (10.0.2.100) port 32080 (#0)
> GET /appmgr/ric/v1/health/ready HTTP/1.1
> Host: 10.0.2.100:32080
> User-Agent: curl/7.58.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 0
< Connection: keep-alive
< Date: Wed, 22 Jan 2020 20:55:39 GMT
< X-Kong-Upstream-Latency: 0
< X-Kong-Proxy-Latency: 2
< Via: kong/1.3.1
<
* Connection #0 to host 10.0.2.100 left intact
```

## RIC Applications

### General Instructions

**xApp Onboarding using CLI tool called dms_cli**

xApp onboarder provides a cli tool called dms_cli to fecilitate xApp onboarding service to operators. It consumes the xApp descriptor and optionally additional schema file, and produces xApp helm charts.

Below are the sequence of steps to onboard, install and uninstall the xApp.

Step 1: (OPTIONAL ) Install python3 and its dependent libraries, if not installed.

Step 2: Prepare the xApp descriptor and an optional schema file. xApp descriptor file is a config file that defines the behavior of the xApp. An optional schema file is a JSON schema file that validates the self-defined parameters.

Step 3: Before any xApp can be deployed, its Helm chart must be loaded into this private Helm repository.

```
#Create a local helm repository with a port other than 8080 on host
docker run --rm -u 0 -it -d -p 8090:8080 -e DEBUG=1 -e STORAGE=local -e STORAGE_LOCAL_ROOTDIR=/charts -v $(pwd)/charts:/charts chartmuseum/chartmuseum:latest
```

Step 4: Set up the environment variables for CLI connection using the same port as used above.

```
#Set CHART_REPO_URL env variable
export CHART_REPO_URL=http://0.0.0.0:8090
```

Step 5: Install dms_cli tool

```
#Git clone appmgr
git clone "https://gerrit.o-ran-sc.org/r/ric-plt/appmgr"

#Change dir to xapp_onboarder
cd appmgr/xapp_orchestrater/dev/xapp_onboarder

#If pip3 is not installed, install using the following command
apt install python3-pip

#In case dms_cli binary is already installed, it can be uninstalled using following command
pip3 uninstall xapp_onboarder

#Install xapp_onboarder using following command
sudo pip3 install ./
```

(Note: if you run `kubectl` with `sudo` then you need to install with root user here)

You may need to update the `PATH` env variable to access the executables.

Step 6: (OPTIONAL ) If the host user is non-root user, after installing the packages, please assign the permissions to the below filesystems

```
#Assign relevant permission for non-root user
sudo chmod 755 /usr/local/bin/dms_cli
sudo chmod -R 755 /usr/local/lib/python3.6
```

Step 7: Onboard your xApp

```
# Make sure that you have the xapp descriptor config file and the schema file at your local file system
dms_cli onboard CONFIG_FILE_PATH SCHEMA_FILE_PATH
OR
dms_cli onboard --config_file_path=CONFIG_FILE_PATH --shcema_file_path=SCHEMA_FILE_PATH

#Example:
dms_cli onboard /files/config-file.json /files/schema.json
OR
dms_cli onboard --config_file_path=/files/config-file.json --shcema_file_path=/files/schema.json
```

### MobiFlow Auditor xApp

An xApp supporting fine-grained and security-aware statistics monitoring over the RAN data plane. It is an essential part of the [5G-Spector](https://github.com/5GSEC/5G-Spector). Project repo: https://github.com/5GSEC/MobiFlow-Auditor/tree/osc. Quick start instructions below:

Download:

```
$ git clone https://github.com/5GSEC/MobiFlow-Auditor.git
$ cd MobiFlow-Auditor
$ git checkout osc
```


Onboard:

```
$ cd init
$ sudo -E dms_cli onboard --config_file_path=config-file.json --shcema_file_path=schema.json
```

Build:

```
$ cd ../
$ ./build.sh
```

**Currently, you need to start the gNB and let it complete the E2 setup procedure first, then run the xApp that subscribes to the gNB.**

Deploy

```
$ ./deploy.sh
```

Undeploy

```
$ ./undeploy.sh
```

### MobieXpert xApp

A programmable xApp for L3 cellular attack detection using the P-BEST language based on MobiFlow security telemetry. It is an essential part of the [5G-Spector](https://github.com/5GSEC/5G-Spector). Project repo: https://github.com/5GSEC/MobiFlow-Auditor/tree/osc. Quick start instructions below:

Download:

```
$ git clone https://github.com/5GSEC/MobieXpert.git
$ cd MobieXpert
$ git checkout osc
```


Onboard:

```
$ cd init
$ sudo -E dms_cli onboard --config_file_path=config-file.json --shcema_file_path=schema.json
```

Build:

```
$ cd ../
$ ./build.sh
```

Deploy

```
$ ./deploy.sh
```

Undeploy

```
$ ./undeploy.sh
```

### Python xApp Development Template

This is an xApp template based on [OSC's xApp Python Framework](https://github.com/o-ran-sc/ric-plt-xapp-frame-py). The template has included basic xApp operations such as subscription and SDL interactions. Adapt this development template to create your (Python) xApp on the OSC RIC: https://github.com/5GSEC/OSC-RIC-xApp-Template. 

### Hello World Python xApp

An example nRT-RIC xApp from OSC's official [repository](https://github.com/o-ran-sc/ric-app-hw-python). Installation is adapted from https://gerrit.o-ran-sc.org/r/gitweb?p=ric-app/hw-python.git;a=blob;f=docs/onboard-and-deploy.rst;h=0308a48e31f108ac7e77701a39ce47d68555f34b;hb=HEAD

First checkout the [hw-python](https://gerrit.o-ran-sc.org/r/ric-app/hw-python) repository from gerrit.

```
git clone "https://gerrit.o-ran-sc.org/r/ric-app/hw-python"
```

`hw-python` has the following folder structure

```
+---docs
|
+---hw_python.egg-info
|
+---init
|       config-file.json # descriptor for xapp deployment.
|       init_script.py
|       test_route.rt
|       schema.json #schema for validating the config-file.json
|
+---releases
|
+---resources
|
+---src
```

For onboarding `hw-python` make sure that `dms_cli` and helm3 is installed. One can follow [documentation](https://docs.o-ran-sc.org/projects/o-ran-sc-it-dep/en/latest/installation-guides.html#ric-applications) to configure `dms_cli`.

Once `dms_cli` is available we can proceed to onboarding process.


Check if `dms_cli` working fine:
```
$ sudo -E dms_cli health
True
```

Now move to `init` folder to initiate onboarding.

```
$ cd hw-python/init

$ sudo -E dms_cli onboard --config_file_path=config-file.json --shcema_file_path=schema.json
{
"status": "Created"
}
```

List helm chart:

```
$ sudo -E dms_cli get_charts_list
{
    "hw-python": [
        {
            "apiVersion": "v1",
            "appVersion": "1.0",
            "created": "2024-03-04T02:13:17.39324061Z",
            "description": "Standard xApp Helm Chart",
            "digest": "30732e2ada2ad32d981b0f0b8fca5739df6b69cd969469bb8d0a9c7dd61ecf05",
            "name": "hw-python",
            "urls": [
                "charts/hw-python-1.0.0.tgz"
            ],
            "version": "1.0.0"
        }
    ]
}
```

Download helm chart:

```
$ sudo -E dms_cli download_helm_chart hw-python 1.0.0 --output_path=./
status: OK
```

Build xApp as a Docker container:

```
$ cd <hw-python>
$ sudo docker build -t nexus3.o-ran-sc.org:10004/o-ran-sc/ric-app-hw-python:1.1.0 .
```

Then verify:

```
$ sudo docker images
REPOSITORY                                                TAG          IMAGE ID       CREATED          SIZE
nexus3.o-ran-sc.org:10004/o-ran-sc/ric-app-hw-python      1.1.0        dc30c08c64cf   27 seconds ago   229MB
```

Deploy xApp:

```
$ sudo -E dms_cli install hw-python 1.0.0 ricxapp
status: OK
```

Verify:

```
$ sudo kubectl get pods -n ricxapp
NAME                                 READY   STATUS    RESTARTS   AGE
ricxapp-hw-python-5849d9bdfd-w9s4m   1/1     Running   0          8s
```

Undeploy xApp:

```
$ sudo -E dms_cli uninstall hw-python ricxapp
status: OK
```


### KPI Mon xApp

OSC's official KPM monitor xApp in Golang.

Clone the xApp:

```
git clone "https://gerrit.o-ran-sc.org/r/ric-app/kpimon-go"
```

Init:

```
$ cd kpimon-go/deploy
$ sudo -E dms_cli onboard --config_file_path=config.json --shcema_file_path=schema.json
{
"status": "Created"
}
```

Build:

```
$ cd kpimon-go
$ sudo docker build -t nexus3.o-ran-sc.org:10004/o-ran-sc/ric-app-kpimon-go:1.0.1 .
```

Deploy:

```
Check the version numbetr mentioned in the 'kpimon-go/deploy/config.json' file e.g.  ```"version": "2.0.2-alpha"```
$ sudo -E dms_cli install kpimon-go 2.0.2-alpha ricxapp
status: OK
```

Undeploy:

```
$ sudo -E dms_cli uninstall kpimon-go ricxapp
status: OK
```


### Undeploying the Infrastructure and Platform Groups

```
$ cd ric-dep/bin
$ sudo ./uninstall
```

To resolve error `./uninstall: line 22: /tmp/recipe.yaml: Permission denied`, simply remove the file `rm /tmp/recipe.yaml` and try again.

Results similar to below indicate a complete and successful cleanup.

```
release "r3-appmgr" deleted
release "r3-rtmgr" deleted
release "r3-dbaas1" deleted
release "r3-e2mgr" deleted
release "r3-e2term" deleted
release "r3-a1mediator" deleted
release "r3-submgr" deleted
release "r3-vespamgr" deleted
release "r3-rsm" deleted
release "r3-jaegeradapter" deleted
release "r3-infrastructure" deleted
configmap "ricplt-recipe" deleted
namespace "ricxapp" deleted
namespace "ricinfra" deleted
namespace "ricplt" deleted
```


## Connect OAI gNB to OSC RIC

You may use OAI with either the ONOS E2 agent or the OAI E2 agent to connect with the OSC nRT-RIC. 

### ONOS E2 Agent

This is an E2 agent originally implemented in the [ONOS's openairinterface](https://github.com/onosproject/openairinterface5g) mirror. However, the maintenance of the project has stopped. We have extended this E2 agent implementation so that it supports OSC RIC and the [5G-Spector](https://github.com/5GSEC/5G-Spector) components.

Clone the `OAI-5G` repository from [https://github.com/5GSEC/OAI-5G](https://github.com/5GSEC/OAI-5G). Our latest update on the RIC agent has been integrated into OAI [v2.1.0](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/CHANGELOG.md?ref_type=heads). Checkout the correct branch:

```
git checkout v2.1.0.secsm.osc
```

Then compile OAI. Be sure to include the `--build-ric-agent` arg to build the E2 agent:

```
cd <OAI-ROOT>/cmake_targets
./build_oai -w SIMU --gNB --nrUE --build-ric-agent --ninja
```

(Change `-w SIMU` to `-w USRP` if you run the gNB on a USRP instead of simulation)

Obtain the E2T's service IP address and port from the deployed RIC:

```
$ sudo kubectl get svc -n ricplt
NAME                                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                           AGE
...
service-ricplt-e2term-sctp-alpha            NodePort    10.111.203.170   <none>        36422:32222/SCTP                  67s
...
```

Update the OAI gNB config to specify the E2T IP and port (template gNB config can be found [here](https://github.com/5GSEC/OAI-5G-Docker/blob/master/nr-rfsim/gnb.conf#L19):

```
# Begin RIC-specific settings
RIC : {
    remote_ipv4_addr = "10.111.203.170"; # TODO Replace it with the actual RIC e2t Address
    remote_port = 36422;
    enabled = "yes";
};
```

Also, update the `local_s_address` field to the public host IP running the gNB.

```
local_s_address  = "192.168.121.191";
```

Next, follow this [tutorial](https://github.com/5GSEC/5G-Spector/wiki/Build-5G%E2%80%90Spector-from-scratch-in-an-OAI-5G-network#24-deploy-the-gnb) to run OAI gNB in RFSIM mode.

Success indication of E2 Setup procedure from the gNB log:

```
[RIC_AGENT]   ranid 0 connecting to RIC at 10.106.85.115:36422 with IP 192.168.121.191 (my addr: 192.168.121.191)
[RIC_AGENT]   new sctp assoc resp 171, sctp_state 2 for nb 0
[RIC_AGENT]   new sctp assoc resp 171 for nb 0
[RIC_AGENT]   Send SCTP data, ranid:0, assoc_id:171, len:616
[RIC_AGENT]   decoded successful outcome E2SetupResponse (1)
[RIC_AGENT]   Received E2SetupResponse (ranid 0)
[RIC_AGENT]   E2SetupResponse (ranid 0) from RIC (mcc=310,mnc=141,id=0)
```


### OAI E2 Agent

**WARNING: currently running OAI baremetal will cause the E2 agent to release the E2 connection immediately. Binding logic is needed to stablize the connection.**

Clone and compile the OAI's official repository from [https://gitlab.eurecom.fr/oai/openairinterface5g/](https://gitlab.eurecom.fr/oai/openairinterface5g/) and compile it. Remember to specify the `--build-e2` arg.

Obtain the E2T's service IP address and port from the deployed RIC:

```
$ sudo kubectl get svc -n ricplt
NAME                                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                           AGE
...
service-ricplt-e2term-sctp-alpha            NodePort    10.111.203.170   <none>        36422:32222/SCTP                  67s
...
```

In the example, IP address of the SCTP service of the E2T is `10.111.203.170` on port `36422`.

Update the OAI gNB config to specify the E2T IP (this should be added to the end of the gNB config, template [here](https://github.com/5GSEC/OAI-5G-Docker/blob/master/nr-usrp/gnb.conf#L301)):

```
e2_agent = {
  near_ric_ip_addr = "10.111.203.170";
  sm_dir = "/usr/local/lib/flexric/"
}
```

Specify the port number in OAI. This is currently hardcoded (as of v2.0.1 version) within the OAI's E2 agent. Locate file at `<OAI-ROOT>/openair2/E2AP/flexric/src/agent/e2_agent_api.c` and adapt the following line:

```
const int e2ap_server_port = 36421;
``` 

Then compile OAI:

```
cd <OAI-ROOT>/cmake_targets
./build_oai -w SIMU --gNB --nrUE --build-e2 --ninja
```

Rerun the gNB and you'll see E2 Setup Request and response from the log:

```
[E2-AGENT]: E2 SETUP-REQUEST tx
...
[E2-AGENT]: E2 SETUP RESPONSE rx
[E2-AGENT]: Transaction ID E2 SETUP-REQUEST 0 E2 SETUP-RESPONSE 0
```

### Verification on the nRT-RIC

Indication from the E2T pod (replace the actual pod name with yours):

```
$ sudo kubectl logs deployment-ricplt-e2term-alpha-5dc768bcb7-kqfvz -n ricplt
...
{"ts":1708618899379,"crit":"INFO","id":"E2Terminator","mdc":{"PID":"140212327921408","POD_NAME":"deployment-ricplt-e2term-alpha-5dc768bcb7-q5mbc","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"RIC_E2_TERM","HOST_NAME":"o-ran-sc-test","SYSTEM_NAME":"SEP"},"msg":"New connection request from sctp network "}

gNB_CU_UP_ID and gNB_DU_ID is null
cuupid =-1
duid =-1
ranName =gnb_208_099_00000e00
{"ts":1708618899415,"crit":"INFO","id":"E2Terminator","mdc":{"PID":"140212344706816","POD_NAME":"deployment-ricplt-e2term-alpha-5dc768bcb7-q5mbc","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"RIC_E2_TERM","HOST_NAME":"o-ran-sc-test","SYSTEM_NAME":"SEP"},"msg":"send message to gnb_208_099_00000e00 address"}
```

Query E2 node status through the E2 manager APIs. Obtain the IP address of the `e2mgr` service:

```
$ sudo kubectl get svc -n ricplt
service-ricplt-e2mgr-http                   ClusterIP   10.96.118.190    <none>        3800/TCP                          16m
```

Use `curl` to query node status (replace the IP address with yours):

```
$ curl -X GET http://10.96.118.190:3800/v1/nodeb/states 2>/dev/null|jq
[
  {
    "inventoryName": "gnb_208_099_00000e00",
    "globalNbId": {
      "plmnId": "02F899",
      "nbId": "0000000000000000111000000000"
    },
    "connectionStatus": "CONNECTED"
  }
]
```

## Shared Data Layer (SDL)

Shared Data Layer (SDL) provides a lightweight, high-speed interface (API) for accessing shared data storage. SDL can be used for storing and sharing any data. Data can be shared at VNF level. One typical use case for SDL is sharing the state data of stateful application processes. Thus enabling stateful application processes to become stateless, conforming with, e.g., the requirements of the fifth generation mobile networks. Refer to: https://wiki.o-ran-sc.org/pages/viewpage.action?pageId=20874400

By default, the OSC near-RT RIC will deploy the redis database as a service backend.

```
$ sudo kubectl get pods -n ricplt
NAME                                                         READY   STATUS    RESTARTS   AGE
...
statefulset-ricplt-dbaas-server-0                            1/1     Running   0          100m
```

After logging into the container, you can use some command line tools to query the databases:

```
# sdlcli -h
Shared Data Layer (SDL) troubleshooting command line tool

Usage:
  sdlcli [flags]
  sdlcli [command]

Available Commands:
  completion  Generate shell completion script
  get         Display one or many resources
  healthcheck Validate SDL database healthiness
  help        Help about any command
  remove      Remove key(s) under given namespace from SDL DB
  set         Set a key-value pair to SDL DB under given namespace
  statistics  Display statistics.

Flags:
  -h, --help   help for sdlcli

Use "sdlcli [command] --help" for more information about a command.
```



## Non-RT-RIC

Adapted from [https://docs.o-ran-sc.org/projects/o-ran-sc-nonrtric/en/latest/installation-guide.html](https://docs.o-ran-sc.org/projects/o-ran-sc-nonrtric/en/latest/installation-guide.html)

Prerequisites

- kubernetes v1.19 +
- docker and docker-compose (latest)
- git
- Text editor, e.g. vi, notepad, nano, etc.
- helm
- helm3
- ChartMuseum to store the HELM charts on the server, multiple options are available:
	- Execute the install script: `./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh`
	- Install chartmuseum manually on port 18080 (https://chartmuseum.com/#Instructions, https://github.com/helm/chartmuseum)



First, clone to repo:

```
git clone "https://gerrit.o-ran-sc.org/r/it/dep"
```

Or clone a specific release branch:

```
git clone "https://gerrit.o-ran-sc.org/r/it/dep" -b h-release
```

Configuration of components to install, edit `dep/RECIPE_EXAMPLE/NONRTRIC/example_recipe.yaml` to configure your settings.

The file shown below is a snippet from the override `example_recipe.yaml`.

All parameters beginning with 'install' can be configured 'true' for enabling installation and 'false' for disabling installation.

For the parameters installNonrtricgateway and installKong, only one can be enabled.

There are many other parameters in the file that may require adaptation to fit a certain environment. For example hostname, namespace and port to message router etc. These integration details are not covered in this guide.  

```
nonrtric:
  installPms: true
  installA1controller: true
  installA1simulator: true
  installControlpanel: true
  installInformationservice: true
  installRappcatalogueservice: true
  installRappcatalogueEnhancedservice: true
  installNonrtricgateway: true
  installKong: false
  installDmaapadapterservice: true
  installDmaapmediatorservice: true
  installHelmmanager: true
  installOruclosedlooprecovery: true
  installOdusliceassurance: true
  installCapifcore: true
  installRanpm: true
  installrappmanager: true
  installdmeparticipant: true
   
   volume1:
    # Set the size to 0 if you do not need the volume (if you are using Dynamic Volume Provisioning)
    size: 2Gi
    storageClassName: pms-storage
  volume2:
     # Set the size to 0 if you do not need the volume (if you are using Dynamic Volume Provisioning)
    size: 2Gi
    storageClassName: ics-storage
  volume3:
    size: 1Gi
    storageClassName: helmmanager-storage
 
...
...
...
```

For installation, run:

```
cd dep
sudo bin/deploy-nonrtric -f nonrtric/RECIPE_EXAMPLE/example_recipe.yaml
```

Verify the non RT RIC has been deployed:


```
$ sudo kubectl get po -n nonrtric
            NAME                                                 READY     STATUS     RESTARTS            AGE 
bundle-server-7f5c4965c7-vsgn7                                    1/1     Running        0               8m16s
dfc-0                                                             2/2     Running        0               6m31s
influxdb2-0                                                       1/1     Running        0               8m15s
informationservice-776f789967-dxqrj                               1/1     Running        0               6m32s
kafka-1-entity-operator-fcb6f94dc-fkx8z                           3/3     Running        0               7m17s
kafka-1-kafka-0                                                   1/1     Running        0               7m43s
kafka-1-zookeeper-0                                               1/1     Running        0               8m7s
kafka-client                                                      1/1     Running        0               10m
kafka-producer-pm-json2influx-0                                   1/1     Running        0               6m32s
kafka-producer-pm-json2kafka-0                                    1/1     Running        0               6m32s
kafka-producer-pm-xml2json-0                                      1/1     Running        0               6m32s
keycloak-597d95bbc5-nsqww                                         1/1     Running        0               10m
keycloak-proxy-57f6c97984-hl2b6                                   1/1     Running        0               10m
message-router-7d977b5554-8tp5k                                   1/1     Running        0               8m15s
minio-0                                                           1/1     Running        0               8m15s
minio-client                                                      1/1     Running        0               8m16s
opa-ics-54fdf87d89-jt5rs                                          1/1     Running        0               6m32s
opa-kafka-6665d545c5-ct7dx                                        1/1     Running        0               8m16s
opa-minio-5d6f5d89dc-xls9s                                        1/1     Running        0               8m16s
pm-producer-json2kafka-0                                          2/2     Running        0               6m32s
pm-rapp                                                           1/1     Running        0               67s
pmlog-0                                                           2/2     Running        0               82s
redpanda-console-b85489cc9-nqqpm                                  1/1     Running        0               8m15s
strimzi-cluster-operator-57c7999494-kvk69                         1/1     Running        0               8m53s
ves-collector-bd756b64c-wz28h                                     1/1     Running        0               8m16s
zoo-entrance-85878c564d-59gp2                                     1/1     Running        0               8m16s
```


To uninstall, run:

```
sudo bin/undeploy-nonrtric
```

## OSC AI / ML Framework 

Adapted from [https://docs.o-ran-sc.org/projects/o-ran-sc-aiml-fw-aimlfw-dep/en/latest/installation-guide.html](https://docs.o-ran-sc.org/projects/o-ran-sc-aiml-fw-aimlfw-dep/en/latest/installation-guide.html)


## Install Legacy K8S

Note: After March 2024, it's impossible to install the legacy Kubernetes packages (< v1.25) through central repositories with `apt`. ~~However, as of April 2024, the OSC RIC infrastructure depends on legacy Kubernetes (near-RT RIC uses v1.16 while non-RT RIC requires > v1.19), and thus the newer versions are not applicable.~~ In the latest O-RAN SC J Release, it has supported K8S v1.28 so this guide is **NOT necessary** any more. Simply use the provided script `./bin/install_k8s_and_helm.sh` in the `ric-dep` nRT-RIC repo is sufficient.
 
For K8S ver after v1.25, you can still install through their official guides: https://v1-25.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

However, there are still ways to install the legacy versions, such as https://flex-solution.com/page/blog/install-k8s-lower-than-1_24 (many thanks to the author!)

Below are the guides to instantiate a v1.21 K8S cluster without using the guide from OSC:

After you install the corresponding version of the K8S packages, initialize the cluster:

```
kubeadm init --pod-network-cidr=10.96.0.0/16 --service-cidr=10.97.0.0/16
```

Init the config folder:

```
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
```

Apply the network plugin (this example uses calico v3.22 which is mentioned in the OSC AI/ML init scripts)

```
sudo kubectl apply -f "https://projectcalico.docs.tigera.io/archive/v3.22/manifests/calico.yaml"
```

Taint nodes:

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Validate the deployment:

```
$ sudo kubectl get pods -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-7c87c5f9b8-zvb7m   1/1     Running   0          2m45s
kube-system   calico-node-xwqzk                          1/1     Running   0          2m45s
kube-system   coredns-558bd4d5db-jd597                   1/1     Running   0          3m18s
kube-system   coredns-558bd4d5db-kb2f8                   1/1     Running   0          3m18s
kube-system   etcd-*                        		 1/1     Running   15         3m32s
kube-system   kube-apiserver-*              		 1/1     Running   0          3m38s
kube-system   kube-controller-manager-*			 1/1     Running   0          3m38s
kube-system   kube-proxy-dwpct                           1/1     Running   0          3m19s
kube-system   kube-scheduler-*              		 1/1     Running   13         3m37s
```

You can allow non-root users to use the `kubectl` command:

```
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chmod +r $HOME/.kube/config
```


If you want to undeploy the pods, use `kubectl delete -f`, or `kubeadm reset` to remove the whole cluster.



## Useful Links

About O-RAN SC: [https://wiki.o-ran-sc.org/display/ORAN](https://wiki.o-ran-sc.org/display/ORAN)

Integration of OSC RIC and xApps with E2 simulation (I Release): 
[https://wiki.o-ran-sc.org/download/attachments/78217540/deploy_h_release_near_rt_ric.mp4?api=v2](https://wiki.o-ran-sc.org/download/attachments/78217540/deploy_h_release_near_rt_ric.mp4?api=v2)

OSC near-RT RIC: 
[https://wiki.o-ran-sc.org/pages/viewpage.action?pageId=1179659](https://wiki.o-ran-sc.org/pages/viewpage.action?pageId=1179659)

OAI demo with OSC:
[https://wiki.o-ran-sc.org/display/EV/Material+for+O-RAN+October+f2f+in+Phoenix](https://wiki.o-ran-sc.org/display/EV/Material+for+O-RAN+October+f2f+in+Phoenix)

OSC non-RT RIC (docs & arch & install guide): [https://wiki.o-ran-sc.org/display/RICNR](https://wiki.o-ran-sc.org/display/RICNR)

OSC RIC AI / ML tutorial (H release): [https://wiki.o-ran-sc.org/display/AIMLFEW/Files+for+H+release](https://wiki.o-ran-sc.org/display/AIMLFEW/Files+for+H+release)

xApp python framework: [https://docs.o-ran-sc.org/projects/o-ran-sc-ric-plt-xapp-frame-py/en/latest/index.html](https://docs.o-ran-sc.org/projects/o-ran-sc-ric-plt-xapp-frame-py/en/latest/index.html)

OSC RIC RMR library: [https://github.com/o-ran-sc/ric-plt-lib-rmr](https://github.com/o-ran-sc/ric-plt-lib-rmr)

OSC RIC message type definition: [https://github.com/o-ran-sc/ric-plt-lib-rmr/blob/master/src/rmr/common/include/RIC_message_types.h](https://github.com/o-ran-sc/ric-plt-lib-rmr/blob/master/src/rmr/common/include/RIC_message_types.h) 

OSC RIC RMR user guide: [https://wiki.o-ran-sc.org/display/RICP/RMR_user_guide](https://wiki.o-ran-sc.org/display/RICP/RMR_user_guide)

Subscription manager doc: [https://docs.o-ran-sc.org/projects/o-ran-sc-ric-plt-submgr/en/latest/user-guide.html](https://docs.o-ran-sc.org/projects/o-ran-sc-ric-plt-submgr/en/latest/user-guide.html)

OSC documentation (I Release): [https://docs.o-ran-sc.org/en/latest/](https://docs.o-ran-sc.org/en/latest/)

Install Kubernete (v1.25+): [https://v1-25.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://v1-25.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

Install Helm: [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)
