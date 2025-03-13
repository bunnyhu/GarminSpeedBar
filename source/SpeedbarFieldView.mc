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

    function initialize() {
        DataField.initialize();
    }

    function onLayout(dc as Gfx.Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));
    }

    function compute(info as Info) {
        if (info.currentHeading != null) {
            _currentHeading = info.currentHeading;
        }
        // _currentHeading += Math.PI / 45; // 1 Fok = π / 180 radián
        // if (_currentHeading >= 2 * Math.PI) {
        //     _currentHeading -= 2 * Math.PI; // Visszaállítás 360° után
        // }   

        // _currentHeading = Math.toRadians(270);
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE); // Háttér törlése
        dc.clear();
        (findDrawableById("w_compass") as WindCompass).setHeading(_currentHeading);
        View.onUpdate(dc);  // update the layouts, do it BEFORE extra drawing !!!!!!!

    }

}
