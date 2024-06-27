#!/bin/bash

# Clean old containers
echo "Cleaning old containers..."
docker system prune -f


# Start Ditto
echo "Starting Ditto..."
cd /Users/belencarozo/projects/CuidaDitto/ditto/deployment/docker
docker-compose up -d

# Configure and start Mosquitto
echo "Configuring and starting Mosquitto..."
mkdir -p $(pwd)/mosquitto/config
echo "allow_anonymous true" > $(pwd)/mosquitto/config/mosquitto.conf
osascript <<EOF
tell application "iTerm"
    tell current window
        create tab with default profile
        tell current session of current tab
            write text "docker run -it --name mosquitto -p 1883:1883 -v $(pwd)/mosquitto:/mosquitto/ eclipse-mosquitto mosquitto -c /mosquitto/config/mosquitto.conf"
        end tell
    end tell
end tell
EOF

# Wait for Ditto and Mosquitto to initialize
echo "Waiting for Ditto and Mosquitto to initialize..."
sleep 10

# Create the policy in Ditto
echo "Creating policy in Ditto..."
curl -X PUT 'http://localhost:8080/api/2/policies/android:policy' -u 'ditto:ditto' -H 'Content-Type: application/json' -d '{
    "entries": {
        "owner": {
            "subjects": {
                "nginx:ditto": {
                    "type": "nginx basic auth user"
                }
            },
            "resources": {
                "thing:/": {
                    "grant": [
                        "READ","WRITE"
                    ],
                    "revoke": []
                },
                "policy:/": {
                    "grant": [
                        "READ","WRITE"
                    ],
                    "revoke": []
                },
                "message:/": {
                    "grant": [
                        "READ","WRITE"
                    ],
                    "revoke": []
                }
            }
        }
    }
}'

# Create the Thing in Ditto
echo "Creating Thing in Ditto..."
curl --location --request PUT -u ditto:ditto 'http://localhost:8080/api/2/things/:android:mobile' \
 --header 'Content-Type: application/json' \
 --data-raw '{
     "policyId": "android:policy",
     "definition": "https://raw.githubusercontent.com/GebelusDigitales/CuidaDitto/main/android.jsonld"
 }'

# Get the IP address of the Mosquitto container
echo "Getting Mosquitto IP address..."
mosquitto_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mosquitto)

# Create the MQTT connection in Ditto
echo "Creating MQTT connection in Ditto..."
curl -X POST \
 'http://localhost:8080/devops/piggyback/connectivity?timeout=10' \
 -H 'Content-Type: application/json' \
 -u 'devops:foobar' \
 -d '{
   "targetActorSelection": "/system/sharding/connection",
   "headers": {
       "aggregate": false
   },
   "piggybackCommand": {
       "type": "connectivity.commands:createConnection",
       "connection": {
           "id": "mqtt-connection-android",
           "connectionType": "mqtt",
           "connectionStatus": "open",
           "failoverEnabled": true,
           "uri": "tcp://ditto:ditto@127.0.0.1:1883",
           "sources": [{
               "addresses": ["android:mobile/things/twin/commands/modify"],
               "authorizationContext": ["nginx:ditto"],
               "qos": 0,
               "filters": []
           }],
           "targets": [{
               "address": "android:mobile/things/twin/events/modified",
               "topics": [
               "_/_/things/twin/events",
               "_/_/things/live/messages"
               ],
               "authorizationContext": ["nginx:ditto"],
               "qos": 0
           }]
       }
   }
}'

echo "Setup complete. You can verify the configuration through Ditto's web interface."
