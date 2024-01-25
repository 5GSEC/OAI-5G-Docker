# OAI-5G-Docker

## Colosseum

### RF Scenario Setup

| ID    |                                Scenario Name             | Center Freq (GHZ)    | #Nodes | Duration(s)   |
|-------|---------------------------------------------------------:|---------|----|-----|
| 52003 |                                All Paths 0 dB - 2.54 GHz | 2.54    | 20 | 1   |
| 10012 |                                            All Paths 0dB | 2.59335 | 10 | 600 |
| 10018 |                                            All Paths 0dB | 2.63    | 10 | 10  |
| 90006 |              Channel Sounding - Increasing losses - 3GHz | 3       | 5  | 1   |
| 10016 |                                            All Paths 0dB | 3.52128 | 2  | 600 |
| 10017 |                                            All Paths 0dB | 3.52128 | 2  | 600 |
| 10021 |                                            All Paths 0dB | 3.52128 | 10 | 600 |
| 10011 |                                            All Paths 0dB | 3.6     | 10 | 600 |
| 20051 |                                  Directional 2 - 3.6 GHz | 3.6     | 5  | 1   |
| 20052 |                       Directional 3 (11 nodes) - 3.6 GHz | 3.6     | 11 | 1   |
| 20053 |                                           IAB Scenario 1 | 3.6     | 14 | 1   |
| 20054 |                                           IAB Scenario 2 | 3.6     | 14 | 1   |
| 20061 |                                     IAB White Scenario 1 | 3.6     | 11 | 1   |
| 20062 | IAB 0dB 2 Donors 2 Relays 20 UEs                         | 3.6     | 26 | 1   |
| 35004 | Cellular Rural Small 3.6 GHz Static 1 at 3.6 GHz + 51 dB | 3.6     | 13 | 1   |
| 35005 |	Cellular Rural Small 3.6 GHz Static 1 at 3.6 GHz + 40 dB | 3.6     | 13 |	1   |
| 52004	| All Paths 0 dB - 3.6 GHz                                 | 3.6     | 20 |	1   |
| 10078 |	Rome no mobility (close) - 3.62 GHz	                     | 3.62    | 50 |	2   |
| 10079 |	Rome low mobility - 3.62 GHz	                           | 3.62    | 50 |	600 |
| 33010 |	Samarcanda Mobility 1 + 70 dB	                           | 3.7     | 14 |	520 |

NR at band 78 (Center frequency = 3.6GHZ):
```
colosseumcli rf start 10011 -c
```

LTE at band 7 ? (Center frequency = 2.6GHZ):
```
colosseumcli rf start 10012 -c
```

OR 10018?

### Useful commands

Download and import file
```
rsync -vP -e ssh haohuangwen@file-proxy:/share/nas/common/<base-image-name>.tar.gz <local path>
lxc image import <base-image-name>.tar.gz --alias <image-name>
```

Init
```
lxc init local:<image-name> <container-name>
lxc start <container-name>
lxc exec <container-name> /bin/bash
```

Export
```
lxc stop <container-name>
lxc publish <container-name> --alias <new-image-name>
lxc image export <new-image-name> <path to tarball>/<tarball-name>
```

Upload file (LXC and Docker)
```
rsync -vP -e ssh <image name> haohuangwen@file-proxy:/share/nas/osu-seclab/images
rsync -vP -e ssh <image name> haohuangwen@file-proxy:/share/nas/osu-seclab/push-images
```

SnapShot
```
colosseumcli snapshot <new-image-name>
```


## TODO

- Support multiple xNBs and UEs
- Support network slicing deployment
- Support ONOS SD-RAN RIC Agent (w/ SECSM)
- Support FlexRIC
