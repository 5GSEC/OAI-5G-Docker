# O-RAN SC RIC Deployment Guide

Env: Ubuntu 20.04 VM, 100GB storage, 6 virtual CPUs, 8G RAM, libvirt provider. Clean environment.



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
# sudo helm list
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

(NOT successful so far)

Check the health of the application manager platform component by querying it via the ingress controller using the following command.

```
$ curl -v http://localhost:32080/appmgr/ric/v1/health/ready
```

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

### RIC Applications

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
pip3 install ./
```

You may need to update the `PATH` env variable to access the executables.

Step 6: (OPTIONAL ) If the host user is non-root user, after installing the packages, please assign the permissions to the below filesystems

```
#Assign relevant permission for non-root user
sudo chmod 755 /usr/local/bin/dms_cli
sudo chmod -R 755 /usr/local/lib/python3.6
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





### Undeploying the Infrastructure and Platform Groups

```
$ cd bin
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

### Connect OAI gNB to OSC nRT-RIC

Obtain the E2T's service IP address and port from the deployed RIC:

```
$ sudo kubectl get svc -n ricplt
NAME                                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                           AGE
...
service-ricplt-e2term-sctp-alpha            NodePort    10.111.203.170   <none>        36422:32222/SCTP                  67s
...
```

In the example, IP address of the SCTP serice of the E2T is `10.111.203.170` on port `36422`.

Update the OAI gNB config to specify the E2T IP:

```
e2_agent = {
  near_ric_ip_addr = "10.111.203.170"; #"127.0.0.1";
  sm_dir = "/usr/local/lib/flexric/"
}
```

Specify the port number in OAI. This is current hardcoded (as of v2.0.1 version) within the OAI's E2 agent. Locate file at `<OAI-ROOT>/openair2/E2AP/flexric/src/agent/e2_agent_api.c` and adapt the following line:

```
const int e2ap_server_port = 36421;
``` 

Then recompile OAI:

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

Indication from the E2T pod (replace the actual pod name with yours):

```
$ sudo kubectl logs deployment-ricplt-e2term-alpha-5dc768bcb7-kqfvz -n ricplt
...
{"ts":1708289046752,"crit":"INFO","id":"E2Terminator","mdc":{"PID":"140457342383872","POD_NAME":"deployment-ricplt-e2term-alpha-5dc768bcb7-kqfvz","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"RIC_E2_TERM","HOST_NAME":"o-ran-sc-test","SYSTEM_NAME":"SEP"},"msg":"New connection request from sctp network "}
{"ts":1708289046752,"crit":"INFO","id":"E2Terminator","mdc":{"PID":"140457333991168","POD_NAME":"deployment-ricplt-e2term-alpha-5dc768bcb7-kqfvz","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"RIC_E2_TERM","HOST_NAME":"o-ran-sc-test","SYSTEM_NAME":"SEP"},"msg":"New connection request from sctp network "}

gNB_CU_UP_ID and gNB_DU_ID is null
cuupid =-1
duid =-1
ranName =gnb_208_099_00000e00
{"ts":1708289046885,"crit":"INFO","id":"E2Terminator","mdc":{"PID":"140457350776576","POD_NAME":"deployment-ricplt-e2term-alpha-5dc768bcb7-kqfvz","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"RIC_E2_TERM","HOST_NAME":"o-ran-sc-test","SYSTEM_NAME":"SEP"},"msg":"send message to gnb_208_099_00000e00 address"}
{"ts":1708289048349,"crit":"ERROR","id":"E2Terminator","mdc":{"PID":"140457333991168","POD_NAME":"deployment-ricplt-e2term-alpha-5dc768bcb7-kqfvz","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"RIC_E2_TERM","HOST_NAME":"o-ran-sc-test","SYSTEM_NAME":"SEP"},"msg":"epoll error, events 8 on fd 20, RAN NAME : gnb_208_099_00000e00"}
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
      "nbId": "00000000000000000000111000000000"
    },
    "connectionStatus": "DISCONNECTED"
  }
]
```



## Non-RT-RIC

