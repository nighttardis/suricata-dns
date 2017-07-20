# Suricata DNS Monitoring

A suricata install configured to only monitor DNS requests to/from a given interface. This was orginally used to emulate Pi-Hole[https://pi-hole.net/] on a BIND server. While this is not a full feature it can be expanded to do more than just DNS monitoring.

Uses logstash to tail the suricata eve.json log file and ships it off to an elasticsearch cluster. The cluster can be updated by overwritting the '/logstash/02-output.conf' file, otherwise it will default to '127.0.0.1:9200'. It will use a semi-custom elasticsearch template to make the best use of the data it is loading.

## Running

To run eplace "<INTERFACE>" with the name of the interface you are wanting to monitor.

'''
docker run -it --rm --net=host -e INTERFACE=<INTERFACE> night_tardis/suricata-dns
'''
