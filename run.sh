#!/bin/sh

# Verify there are currently no Trip "Sagas" or Flight/Hotel bookings
curl http://hotel.otmm.svc.cluster.local:8082/hotelService/api/hotel
curl http://flight.otmm.svc.cluster.local:8083/flightService/api/flight
curl http://trip-manager.otmm.svc.cluster.local:8081/trip-service/api/trip

# Initiate a Trip and note the LRA ID
id=$(echo $(
    curl -s -X POST -d '' http://trip-manager.otmm.svc.cluster.local:8081/trip-service/api/trip?hotelName=Alpha &
    flightNumber=BA123
) | jq -r .id)
decodedId=$(echo ${id} | base64 -d)

# See PROVISIONAL Flight and Hotel Bookings
curl http://hotel.otmm.svc.cluster.local:8082/hotelService/api/hotel
curl http://flight.otmm.svc.cluster.local:8083/flightService/api/flight

# Confirm the Saga
curl --location --request PUT -H "Long-Running-Action: $decodedId" -d '' http://trip-manager.otmm.svc.cluster.local:8081/trip-service/api/trip/$id

# Verify confirmed statuses of Flights and Hotels
curl http://hotel.otmm.svc.cluster.local:8082/hotelService/api/hotel
curl http://flight.otmm.svc.cluster.local:8083/flightService/api/flight
