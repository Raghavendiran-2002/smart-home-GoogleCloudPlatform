# SmartHome

A new Smart-Home Flutter project.

## Getting Started

`flutter create --org com.<orgName> <AppName>`

Open Firebase : https://console.firebase.google.com/

`Create Project <name>`

- Under Project select Flutter
- Follow the Instructions
- Enable Authentication

## Google Cloud Workflow

![alt text](https://firebasestorage.googleapis.com/v0/b/gccp-project-373305.appspot.com/o/GCCP%20workflow.png?alt=media&token=21e00844-1c8a-43fd-8636-4154ba55fb92)

## Create a VM in Compute Engine GCP

```
gcloud compute instances create <project-name> --project=<projectID> --zone=asia-south1-c --machine-type=e2-medium --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=1096058629309-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=smart-home,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20221213,mode=rw,size=15,type=projects/gccp-project-373305/zones/asia-south1-c/diskTypes/pd-ssd --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
```

Step 1 — Installing MongoDB

```
- curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
- echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
- sudo apt update
- sudo apt install mongodb-org
```

Step 2 — Starting the MongoDB Service and Testing the Database

```
- sudo systemctl start mongod.service
- sudo systemctl status mongod
- sudo systemctl enable mongod
- mongo --eval 'db.runCommand({ connectionStatus: 1 })'
```

Step 3 — Managing the MongoDB Service

```
- sudo systemctl status mongod
- sudo systemctl stop mongod
- sudo systemctl start mongod
- sudo systemctl restart mongod
- sudo systemctl disable mongod
- sudo systemctl disable mongod
```

Step 4 - Install the Mosquitto Server

```
- sudo apt update
- sudo apt install -y mosquitto
- sudo systemctl status mosquitto // Status
- sudo systemctl stop mosquitto // Stop
- sudo systemctl start mosquitto // Start
- sudo systemctl restart mosquitto // Restart
```

Step 5 - Install and Test the Mosquitto Clients

```
- sudo apt install -y mosquitto-clients
```

Step 6 - Secure the Mosquitto Server

```
- sudo nano /etc/mosquitto/conf.d/default.conf

- "add"
  allow_anonymous false
  password_file /etc/mosquitto/passwd
- sudo nano /etc/mosquitto/passwd
- "add"
  admin:Password
  <username>:<password>
- sudo mosquitto_passwd -U /etc/mosquitto/passwd
- sudo systemctl restart mosquitto
```

Step 7 - Setting up Firewall

- Source filters
  IP ranges
  0.0.0.0/0
- Protocols and ports
  tcp:27017 // Mongo
- Protocols and ports
  tcp:1883 // MQTT

## Host API on Cloud RUN

https://github.com/Raghavendiran-2002/smart-home-cloudRUN.git

## Modify Variables

lib > homescreen-workflow > screens > homeScreen.dart > IP = <CLOUD RUN URL>

## HostWebsite on Firebase

firebase init hosting

- ? What do you want to use as your public directory?
  - build/web
- ? Configure as a single-page app (rewrite all urls to /index.html)?
  - No
- ? Set up automatic builds and deploys with GitHub?
  - No
- ? File build/web/404.html already exists. Overwrite?
  - No

flutter build web
firebase deploy --only hosting

## Finally release on Android or IOS

flutter run --release

Login Page
![alt text](https://firebasestorage.googleapis.com/v0/b/gccp-project-373305.appspot.com/o/mob2.png?alt=media&token=e91f2efd-5068-4765-a463-b30ad12ee0b3)

Home Page
![alt text](https://firebasestorage.googleapis.com/v0/b/gccp-project-373305.appspot.com/o/mob1.png?alt=media&token=11893a7f-5d18-4683-ae17-52fce34daa5a)

Web Page
![alt text](https://firebasestorage.googleapis.com/v0/b/gccp-project-373305.appspot.com/o/web1.png?alt=media&token=6501f37e-d3e4-4fd2-abac-8308487b9447)
