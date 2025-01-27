$TTL 60
$ORIGIN purefield.nl.
@ 3600 IN SOA dns.air.purefield.nl. admin@purefield.nl. (
  2307111951 ; serial
  7200       ; refresh (2 hours)
  3600       ; retry (1 hour)
  1209600    ; expire (2 weeks)
  3600       ; minimum (1 hour)
  )

$ORIGIN air.purefield.nl.
dns     in A     192.168.100.1

$ORIGIN sno.air.purefield.nl.
control in A     192.168.100.2
worker  in A     192.168.100.3
api     in CNAME control
api-int in CNAME control 
*.apps  in CNAME control 
