# Bunny's extended speedbar datafield
![GitHub Release](https://img.shields.io/github/v/release/bunnyhu/ExtendedSpeedBar)
![GitHub Release Date](https://img.shields.io/github/release-date/bunnyhu/ExtendedSpeedBar)

**Extended speed datafield for Garmin Edge 1050**

This is a garmin Edge cycling computer extended speed datafield. It working only on full width layout bar on *Garmin Edge 1050*.

![App Screenshot](https://github.com/bunnyhu/ExtendedSpeedBar/blob/master/readme-items/animation_v100.gif)  

## Adapted data
* current speed with color support (see below)
* average speed
* delta speed (current for average speed)
* compass with wind (see below)
* radar speed with color support

### Enhanced data fields

**Current speed** color marked: Green if the current speed is the same or faster than the average speed. Yellow if it is slower but not more than 1km/h or 1Mi/h, and red if it is even slower than that.

**Delta speed bar** color marked, same as the current speed. It is show the different (delta) between the actual speed and the average speed.

**compass , wind , radar speed** Those data using the same place and changing dinamic.
* Default is the compass. If there is weather informations the wind direction also appers on the circle around the compass. If there is fresh wind data - we using is, anyway if we are offline and it is more than one hour old, it start use the hourly forecast.
* If we have radar and vehicle(s) arriving, it show the fastest one's speed. If the speed moderate the number in a green circle, the ok speed means yellow and the fast one with red circle. After the vehicle passed, it turn back to compass.

## Install from Garmin store
https://apps.garmin.com/apps/78396c21-0ddd-4d5c-9cf3-0a311750d3f4

## Manual install
* Download the latest version from Github Releases section and unpack it. https://github.com/bunnyhu/ExtendedSpeedBar/releases
* Connect your garmin Edge to the PC with a USB cable, if you did it right a new drive will appear. 
* Copy the downloaded .prg file to the "\Internal Storage\Garmin\Apps\Media" folder on this new drive. 
* Disconnect the Garmin device and you will find this in the IQ fields when editing the screen. Depending on the block size you assign to the three layout will be automatically selected.

## Project home
https://github.com/bunnyhu/ExtendedSpeedBar

## History
v1.0.0    Initial release.  2025. marc. 16.