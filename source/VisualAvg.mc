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

    function initialize(options) {
        Drawable.initialize(options);
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
    }

    function draw(dc as Graphics.Dc) as Void {
        // dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        // dc.fillRoundedRectangle(locX-(width/2), locY, width, height, 5);
        drawRuler(dc);
        var delta = actual-avg;
        var centerX = locX + (width/2) + (delta * step * subRulerSteps );
        if (centerX < locX) {
            centerX = locX;
        }
        if (centerX > locX + width) {
            centerX = locX + width;
        }
        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(8);
        dc.drawCircle(centerX, locY + (height/2), 8);
    }

    function drawRuler(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
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
            } else {
                dc.drawLine(locX+(step*f), locY+(height/4), locX+(step*f), locY+(height/2));
            }
        }
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(locX+(step*rulerSteps/2), locY+(height*0.75), locX+(step*rulerSteps/2), locY);
    }
}