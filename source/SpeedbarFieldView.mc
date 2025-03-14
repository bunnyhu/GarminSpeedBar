import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;
using Toybox.Graphics as Gfx;

// ********************************
// Main DF Class
// ********************************
class SpeedbarFieldView extends WatchUi.DataField {
    //! rotation radian
    var _currentHeading = 0;
    var _currentSpeed = 0;
    var _windBearing;
    var _align;

    function initialize() {
        DataField.initialize();
        _align = new Align();
    }

    function onLayout(dc as Gfx.Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        _align.reAlign(findDrawableById("speed") as Text);
        _align.reAlign(findDrawableById("speedLabel") as Text);
    }

    function compute(info as Info) {
        if (info.currentHeading != null) {
            _currentHeading = info.currentHeading;
        }
        if (info.currentSpeed != null) {
            _currentSpeed = (info.currentSpeed * 3.6);
        }
        if ((Weather.getCurrentConditions() != null) && (Weather.getCurrentConditions() has :windBearing)) {
            _windBearing = Weather.getCurrentConditions().windBearing;
        }
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE); // Háttér törlése
        dc.clear();
        (findDrawableById("w_compass") as WindCompass).setHeading(_currentHeading);
        if (_windBearing != null) {
            (findDrawableById("w_compass") as WindCompass).setWind(_windBearing);
        }
        (findDrawableById("speed") as Text).setText( _currentSpeed.format("%0.1f"));
        View.onUpdate(dc);  // update the layouts, do it BEFORE extra drawing !!!!!!!

    }

}
