S0PCM-Reader
============

This is the Docker setup for the S0PCM-Reader application. This small Python application reads the pulse counters of a S0PCM-2 or S0PCM-5 and send the total and daily counters via MQTT to your favorite domotica application like Home Assistant. The S0PCM-2 or 5 are the S0 Pulse Counter Module sold by http://www.smartmeterdashboard.nl

I myself use it to count my water meter usage.

Docker Link: https://hub.docker.com/r/ualex73/s0pcm-reader/

Pulse vs liter vs m3
--------------------
I use the S0PCM-Reader to measure my water meter and normally in the Netherlands the water usage is measurement in m3 and not in liters. Only this S0PCM-Reader isn't really aware of liters vs m3, because it counts the pulses. So it is important for you to check how your e.g. water meter is counting the usage, my Itron water meter send 1 pulse per liter of water. This then means the 'measurement.yaml' file, which stores the total and daily counters, all should be in liters and not in m3.

The conversion from m3 to liter is easy, because you can just multiple it by 1000. E.g. 770.123 m3 is 770123 liter.

![alt text](https://raw.githubusercontent.com/ualex73/docker-s0pcm-reader/master/screenshots/water-meter.png "Water meter")

Configure your initial meter reader
-----------------------------------
After you have downloaded and started the S0PCM-Reader, you need to configure your total pulse count to allow the S0PCM-Reader to relay the correct total count. Follow the following procedure:
- Stop the S0PCM-Reader container
- Open the `<config>/measurement.yaml` file
- Check which input you use, e.g. for input 'M1' modify the following:
```
1:
  total: 370689
```
- Save the file
- Start the S0PCM-Reader container

MQTT Message
------------
The totals and day counters will be published with the following topics:

```
<basetopic>/1/total
<basetopic>/1/today
<basetopic>/1/yesterday
<basetopic>/2/total
<basetopic>/2/today
<basetopic>/2/yesterday
<basetopic>/X/total
<basetopic>/X/today
<basetopic>/X/yesterday
```
The `<basetopic>` you can configure in the `mqtt` section of the configuration file, the default is 's0pcm-reader'. The `X` is the input number, the name is configurable in the measurement file.

S0PCM
-----
The following S0PCM (ascii) protocol is used by this S0PCM-Reader, a simple S0PCM telegram:
```
Header record (once, after start-up):
/a: S0 Pulse Counter V0.6 - 30/30/30/30/30ms

Data record (repeated every interval):
For S0PCM-5: ID:a:I:b:M1:c:d:M2:e:f:M3:g:h:M4:i:j:M5:k:l
For S0PCM-2: ID:a:I:b:M1:c:d:M2:e:f

Legenda:
a -> Unique ID of the S0PCM
b -> interval between two telegrams in seconds, this is set in the firmware at 10 seconds.
c/e/g/i/k -> number of pulses in the last interval of register 1/2/3/4/5
d/f/h/j/l/ -> number of pulses since the last start-up of register 1/2/3/4/5

Data example:
/8237:S0 Pulse Counter V0.6 - 30/30/30/30/30ms
ID:8237:I:10:M1:0:0:M2:0:0:M3:0:0:M4:0:0:M5:0:0
```

Also the S0PCM-Reader uses the following serialport configuration (used by S0PCM-2 and S0PCM-5):
```
Speed: 9600 baud
Parity: Even
Databits: 7
Stopbit: 1
Xon/Xoff: No
Rts/Cts: No
```

If you own a different type of S0PCM device, which you like to have supported, please contact me.

Configuration
-------------
```
# #######
# Logging
# #######
log:
  # loglevel to use. Supported are critical, error, warning, info and debug. Default is warning.
  level: warning
  # The size in MB of a logfile. Default is 10 (MB).
  #size: 10
  # The number of logfiles which should be kept. Default is 3.
  #count: 3

# #############
# MQTT Settings
# #############
mqtt:
  # Hostname or IP of the MQTT broker
  host: 192.168.1.1
  # Port of the MQTT broker. Normally 1883 or 8883 (TLS)
  port: 1883
  # Basictopic to use to publish the values
  basetopic: s0pcmreader
  # Username and password required to connect to the MQTT broker
  #username: s0pcmreader
  #password: password
  # If a client id should be used, if not configured - a random value will be used
  #client_id: <random>
  # If messages should have the retain flag. Default it is yes.
  #retain: yes

  # TLSv1/1.1/1.2 Configuration
  # Enable TLS, without a "tls_ca" it still connects, but no certificate verification is done.
  #tls: yes
  # Optional certificate to check against.
  #tls_ca: CA.pem
  # Default we check if the hostname/IP returned matches our certificate.
  #tls_check_peer: yes
  # Retry interval in seconds, if a connection to the MQTT broker fails.
  # If an IP address is not reachable, it could take longer to reconnect.
  #connect_retry: 5

# ###################
# SerialPort Settings
# ###################
serial:
  # the serialport to which the pulse counter is connected to
  port: /dev/ttyACM0
  # The baudrate of the serial device. Default is 9600.
  #baudrate: 9600
  #parity:
  #stopbits:
  #bytesize: 7
  #timeout: None
  #connect_retry: 5

# ##############
# S0PCM Settings
# ##############
s0pcm:
  # The MQTT publish interval. If not configured, it will publish on every S0PCM packet.
  # This value shouldn't be configured lower then 10 seconds (default pulse counter interval).
  # Default is to follow the S0PCM packet interval (10 seconds).
  #publish_interval: 10
  # If only changes should be published. Default is yes.
  #publish_onchange: yes

  # If enabled, which input should be counted/used, all other ones are ignored.
  # Default is all available inputs.
  #include:
  #  - 1
  #  - 2

  # If enabled, the daily counters will be written to a CSV file named "daily-<input>.txt"
  # Default is disabled.
  #dailystat:
  #  - 1
  #  - 2

# End
```

Volumes
-------
`/config`

Run
---
Launch the S0PCM-Reader docker container with the following command:

```
docker run [-d] \
    --name=s0pcm \
    -v /etc/localtime:/etc/localtime:ro \
    -v /docker/config:/config \
    --device /dev/ttyACM0:/dev/ttyACM0 \
    ualex73/s0pcm-reader

```

Docker-compose.yaml Example
---
```
version: '3'

services:

  s0pcm:
    container_name: s0pcm
    image: ualex73/s0pcm-reader:latest
    restart: unless-stopped
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /docker/s0pcm:/config
      - /dev:/dev
    devices:
      - /dev/serial/by-id/usb-Arduino_LLC_Arduino_Leonardo-if00:/dev/serial/by-id/usb-Arduino_LLC_Arduino_Leonardo-if00

```

