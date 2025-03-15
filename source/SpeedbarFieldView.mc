import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;
using Toybox.Graphics as Gfx;

// ********************************
// Main DF Class
// ********************************
class SpeedbarFieldView extends WatchUi.DataField {
    var _align;             // Text align class
    var _weather;           // Weather function class
    var _sensors;           // calculated sensor data
    var _sizeOK;            // DataField size fit for my app
    var _mps;               // km/h or Mi/h
    var _colorizeLabels = ["speedLabel", "avgSpeed"];

    // current speed colors [ok, little slow, real slow]
    var speedColors = [Graphics.COLOR_DK_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_RED];


    function initialize() {
        DataField.initialize();
        _align = new Align();
        _weather = new MyWeather();        
        if ( System.getDeviceSettings().distanceUnits == System.UNIT_METRIC) {
            _mps = 3.6;
        } else {
            _mps = 2.23694;
        }
    }


    function onLayout(dc as Gfx.Dc) as Void {
        // var screenWidth = System.getDeviceSettings().screenWidth;
        // var screenHeight = System.getDeviceSettings().screenHeight;        
        // var fieldWidth = dc.getWidth();
        // var fieldHeight = dc.getHeight();

        if (dc.getWidth() < System.getDeviceSettings().screenWidth-10) {
            View.setLayout(Rez.Layouts.TooSmallLayout(dc));
            _sizeOK = false;
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            _align.reAlignWithFont(findDrawableById("speed") as Text, Gfx.FONT_NUMBER_THAI_HOT);
            _align.reAlignWithFont(findDrawableById("speedLabel") as Text, Gfx.FONT_TINY);
            _align.reAlignWithFont(findDrawableById("avgSpeed") as Text, Gfx.FONT_SMALL);
            _sizeOK = true;            
        }
    }


    function compute(info as Info) {
        resetSensors();
        if (info.currentHeading != null) {
            _sensors[:heading] = info.currentHeading;
        }
        if (info.currentSpeed != null) {
            _sensors[:speed] = (info.currentSpeed * _mps);
        }
        if (info.averageSpeed != null) {
            _sensors[:avgSpeed] = (info.averageSpeed * _mps);
        }
        // if ((Weather.getCurrentConditions() != null) && (Weather.getCurrentConditions() has :windBearing)) {
        //     _sensors[:windDir] = Weather.getCurrentConditions().windBearing;
        // }
        if (_weather.get(info)) {            
            var wind = _weather.getWind();
            _sensors[:windDir] = wind[:dir];
            _sensors[:windSpeed] = wind[:speed];
        }        
    }


    function onUpdate(dc as Gfx.Dc) as Void {
        var numColor;
        var labelColor;

        if (_sizeOK) {
            if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                numColor = Graphics.COLOR_WHITE;
                labelColor = Graphics.COLOR_DK_GRAY;
            } else {
                numColor = Graphics.COLOR_BLACK;
                labelColor = Graphics.COLOR_LT_GRAY;
            }
            (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());
            for (var f=0; f<_colorizeLabels.size(); f++) {
                (findDrawableById(_colorizeLabels[f]) as Text).setColor( numColor );
            }

            var wc = View.findDrawableById("w_compass") as WindCompass;
            wc.setHeading(_sensors[:heading]);
            wc.labelColor = numColor;
            if (_sensors[:windDir] != null) {
                wc.setWind(_sensors[:windDir]);
            }
            drawSpeed(numColor);
            (View.findDrawableById("visualAvg") as VisualAvg).setParams({
                :actual =>  _sensors[:speed],
                :average => _sensors[:avgSpeed]
            });
            (View.findDrawableById("avgSpeed") as Text).setText(_sensors[:avgSpeed].format("%0.1f")+ "");
        }
        View.onUpdate(dc);  // update the layouts, do it BEFORE extra drawing !!!!!!!
    }

    function resetSensors() {
        _sensors = {
            :speed       => 0,
            :avgSpeed    => 0,
            :heading     => 0.0f,
            :carSpeed    => 0,
            :carRelSpeed => 0,
            :carDanger   => 0,
            :windDir     => null,
            :windSpeed   => null,
        };        
    }


    /*
        Colorized speed number, for triange dot we use ( and ) char
    */
    function drawSpeed( numColor ) {
        var spdColor = numColor;
        var deltaDot = ".";
        if ((_sensors[:speed] > 1) && (_sensors[:avgSpeed] > 0) ) {
            var deltaSpd = _sensors[:speed] - _sensors[:avgSpeed];
            if (deltaSpd >= 0) {
                spdColor = speedColors[0];
                deltaDot = "(";     // UP
            } else if (deltaSpd > -1) {
                spdColor = speedColors[1];                
                deltaDot = ")";     // DOWN
            } else {
                spdColor = speedColors[2];
                deltaDot = ")";     // DOWN
            }
        }
        var speed;
        if (_sensors[:speed] < 100) {
            speed = _sensors[:speed].format("%0.1f");
        } else {
            speed = Math.round(_sensors[:speed]).format("%0.0f");
        }
        // var dot = speed.find(".");
        // if (dot != null) {
        //     speed = speed.substring(null, dot) + deltaDot + speed.substring(dot+1, null);
        // }        
        var elem = findDrawableById("speed") as Text;
        if (elem != null) {
            elem.setColor(spdColor);
            elem.setText(speed);
        }
    }

}
