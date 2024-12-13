#!/bin/bash

cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

ram_usage=$(free | grep Mem | awk '{print "Uso de RAM: " $3/$2 * 100.0 "%"}')

cpu_temp=$(sensors | grep -i 'Core 0' | awk '{print "Temperatura da CPU: " $3}')

# Output
echo "Uso de CPU: $cpu_usage"
echo "$ram_usage"
echo "$cpu_temp"
