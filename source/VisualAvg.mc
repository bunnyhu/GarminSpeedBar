import Toybox.System;
import Toybox.Lang;
import Toybox.Graphics;

class VisualAvg extends Toybox.WatchUi.Drawable {
    var actual = 0;             // actual number
    var avg = 0;                // average number
    var _padding;               // Align class
    var step = 1f;              // one ruler step in pixel
    var mainRulerSteps = 8;     // all main steps (zero in half)
    var subRulerSteps = 10;     // substeps between main steps
    var rulerSteps;             // all steps in ruler
    var color;
    var speedColors = [Graphics.COLOR_DK_GREEN, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];

    function initialize(options) {
        Drawable.initialize(options);
        color = Graphics.COLOR_BLACK;
        setParams(options);
        _padding = new Align();
        rulerSteps = mainRulerSteps * subRulerSteps;
        step = width / rulerSteps;        
    }

    function setParams(options) as Void {
        if (options[:actual]!=null) {
            actual = options[:actual];
        }
        if (options[:average]!=null) {
            avg = options[:average];
        }
        if (options[:color]!=null) {
            color = options[:color];
        }

    }

    function draw(dc as Graphics.Dc) as Void {
        drawRuler(dc);
        var deltaSpd = actual-avg;
        var delta = (deltaSpd * step * subRulerSteps );

        if (delta < width/-2) {
            delta = width/-2;
        }
        if (delta > width/2) {
            delta = width/2;
        }
        var centerX = locX + (width/2) + delta;
        var spdColor = Graphics.COLOR_PURPLE;
        if (deltaSpd >= 0) {
            spdColor = speedColors[0];
        } else if (deltaSpd > -1) {
            spdColor = speedColors[1];                
        } else {
            spdColor = speedColors[2];
        }

        dc.setColor(spdColor, Graphics.COLOR_TRANSPARENT);
        if (deltaSpd>=0) {
            dc.fillRectangle(locX + (width/2), locY + (height/2)-4, delta, 8);
        } else {
            dc.fillRectangle(locX + (width/2)+delta, locY + (height/2)-4, -delta, 8);
        }
        // dc.setPenWidth(8);
        // dc.drawCircle(centerX, locY + (height/2), 8);
    }

    function drawRuler(dc as Graphics.Dc) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(locX, locY + (height/2) , locX + width, locY + (height/2) );
        dc.setPenWidth(1);
        var nums = 0-(mainRulerSteps / 2);
        for (var f=0; f<=rulerSteps; f++) {
            if (f % subRulerSteps == 0) {
                dc.setPenWidth(3);
                dc.drawLine(locX+(step*f), locY+(height/2), locX+(step*f), locY);
                dc.setPenWidth(1);
                dc.drawText(locX+(step*f), _padding.reAlignY(locY+(height/2)+5, Graphics.FONT_XTINY), Graphics.FONT_XTINY, nums.format("%0.0d"), Graphics.TEXT_JUSTIFY_CENTER);
                nums += 1;
            } else if (f % subRulerSteps == (subRulerSteps/2)) {
                dc.drawLine(locX+(step*f), locY+(height/2), locX+(step*f), locY+(height/6));
            } else {
                dc.drawLine(locX+(step*f), locY+(height/2), locX+(step*f), locY+(height/4));
            }
        }
        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(locX+(step*rulerSteps/2), locY+(height*0.75), locX+(step*rulerSteps/2), locY);
    }
}