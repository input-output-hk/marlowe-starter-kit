# Marlowe Runtime on Debian Linux

These notes document setting up and deploying Marlowe Runtime on a cloud instance of Debian Linux.


## Machine configuration for Google Compute Engine (GCE)

```json
{
  "canIpForward": false,
  "confidentialInstanceConfig": {
    "enableConfidentialCompute": false
  },
  "cpuPlatform": "Intel Broadwell",
  "creationTimestamp": "2023-06-22T13:53:49.305-07:00",
  "deletionProtection": false,
  "description": "",
  "disks": [
    {
      "architecture": "X86_64",
      "guestOsFeatures": [
        {
          "type": "UEFI_COMPATIBLE"
        },
        {
          "type": "VIRTIO_SCSI_MULTIQUEUE"
        },
        {
          "type": "GVNIC"
        },
        {
          "type": "SEV_CAPABLE"
        }
      ],
      "type": "PERSISTENT",
      "licenses": [
        "projects/debian-cloud/global/licenses/debian-11-bullseye"
      ],
      "deviceName": "mrt-mainnet-4",
      "autoDelete": true,
      "source": "projects/xxx/zones/us-central1-b/disks/mrt-mainnet-4",
      "index": 0,
      "boot": true,
      "kind": "compute#attachedDisk",
      "mode": "READ_WRITE",
      "interface": "SCSI",
      "diskSizeGb": "768"
    }
  ],
  "displayDevice": {
    "enableDisplay": false
  },
  "fingerprint": "F4BszwuJEaw=",
  "id": "7287444135789267509",
  "keyRevocationActionType": "NONE",
  "kind": "compute#instance",
  "labelFingerprint": "42WmSpB8rSM=",
  "lastStartTimestamp": "2023-06-22T13:53:56.543-07:00",
  "machineType": "projects/xxx/zones/us-central1-b/machineTypes/e2-custom-6-20480",
  "metadata": {
    "fingerprint": "FQY2mfGVriQ=",
    "kind": "compute#metadata"
  },
  "name": "mrt-mainnet-4",
  "networkInterfaces": [
    {
      "stackType": "IPV4_ONLY",
      "name": "nic0",
      "network": "projects/xxx/global/networks/default",
      "accessConfigs": [
        {
          "name": "External NAT",
          "type": "ONE_TO_ONE_NAT",
          "natIP": "34.172.100.68",
          "kind": "compute#accessConfig",
          "networkTier": "PREMIUM"
        }
      ],
      "subnetwork": "projects/xxx/regions/us-central1/subnetworks/default-6827991f11af9532",
      "networkIP": "10.128.0.21",
      "fingerprint": "M2M_nWou6cU=",
      "kind": "compute#networkInterface"
    }
  ],
  "reservationAffinity": {
    "consumeReservationType": "ANY_RESERVATION"
  },
  "resourceStatus": {},
  "scheduling": {
    "onHostMaintenance": "MIGRATE",
    "provisioningModel": "STANDARD",
    "automaticRestart": true,
    "preemptible": false
  },
  "selfLink": "projects/xxx/zones/us-central1-b/instances/mrt-mainnet-4",
  "serviceAccounts": [
    {
      "email": "xxx@developer.gserviceaccount.com",
      "scopes": [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append"
      ]
    }
  ],
  "shieldedInstanceConfig": {
    "enableSecureBoot": false,
    "enableVtpm": true,
    "enableIntegrityMonitoring": true
  },
  "shieldedInstanceIntegrityPolicy": {
    "updateAutoLearnPolicy": true
  },
  "shieldedVmConfig": {
    "enableSecureBoot": false,
    "enableVtpm": true,
    "enableIntegrityMonitoring": true
  },
  "shieldedVmIntegrityPolicy": {
    "updateAutoLearnPolicy": true
  },
  "startRestricted": false,
  "status": "RUNNING",
  "tags": {
    "items": [
      "http-server"
    ],
    "fingerprint": "FYLDgkTKlA4="
  },
  "zone": "projects/xxx/zones/us-central1-b"
}
```


## Software installation for Debian Linux

```bash
# Install required software.
sudo apt-get update
sudo apt-get install -y git uidmap docker docker-compose dbus-user-session fuse-overlayfs slirp4netns

# Enable rootless use of docker.
curl -fsSL https://get.docker.com/rootless | sh

# Reboot.
sudo shutdown -r now
```


## Deploy Marlowe Runtime

```bash
# Set environment variables required by docker.
export PATH=$HOME/bin:$PATH
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Clone the Marlowe starter kit.
git clone https://github.com/input-output-hk/marlowe-starter-kit -b runtime@v0.0.2
cd marlowe-starter-kit

# Select the network.
export NETWORK=mainnet

# Start Marlowe Runtime.
docker-compose up -d

# Check to see that services have come up successfully.
docker-compose ps

# View the logs.
docker-compose logs --timestamp --tail 200 --follow
```
