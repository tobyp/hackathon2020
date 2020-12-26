#!/bin/bash
TYPES=(enzyme amino ribosome);
for type in ${TYPES[@]}; do
	convert "yellow_${type}.png" -define modulate:colorspace=HSB -modulate 100,100,180 "blue_${type}.png";
	convert "yellow_${type}.png" -define modulate:colorspace=HSB -modulate 90,170,249 "pink_${type}.png";
	convert "yellow_${type}.png" -define modulate:colorspace=HSB -modulate 90,205,225 "purple_${type}.png";
	convert "yellow_${type}.png" -define modulate:colorspace=HSB -modulate 95,95,145 "green_${type}.png";
done;
