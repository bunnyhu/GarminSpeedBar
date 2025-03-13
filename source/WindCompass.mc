import Toybox.System;
import Toybox.Lang;
using Toybox.Graphics as Gfx;

/*
EXAMPLE:

layouts.xml
===========
<drawable id="w_compass" class="WindCompass">
    <param name="locX">150</param>
    <param name="locY">80</param>        
    <param name="height">80</param>
    <param name="font">Gfx.FONT_XTINY</param>
</drawable>

resource.xml  (font sizes in pixel for all using device [edge1050])
============
    <jsonData id="fontSizes">[21, 28, 33, 38, 61, 71, 82, 109, 136]</jsonData>

...View.mc => onUpdate()
========================
    (findDrawableById("w_compass") as WindCompass).setHeading( currentHeading );
*/


//! Compass with wind, north moving
//!
//! Drawable params: locX, locY, height
//! Unique params: heading, font, labelHeight
class WindCompass extends Toybox.WatchUi.Drawable {
    private var currentHeading;
    private var northRadian;
    private var windDirection;
    private var circleR;
    private var labelHeight = 21;

    var arrowColor = Gfx.COLOR_RED;
    var circleColor = Gfx.COLOR_GREEN;
    var circleBackground = Gfx.COLOR_WHITE;
    var labelColor = Gfx.COLOR_BLACK;

    var centerX = 0;
    var centerY = 0;
    var labelFont = Gfx.FONT_XTINY;
    var circlePen = 10;
    var fontSizes = [0, 0, 0, 0, 0, 0, 0, 0, 0]; // Edge1050
    var points = [      // arrow corners in 4x4 matrix, 0;0 center
            [  0, -2],
            [ -1,  2],
            [  0,  1],
            [  1,  2],
        ];

    // Initialize
    function initialize(options) {
        Drawable.initialize(options);
        centerX = locX;
        centerY = locY; 
        setParams(options);

        // calculate real arrow corners pixel based by the height parameter
        var pixels = Math.round( height / 4 );

        for (var f=0; f<points.size(); f++) {
            points[f] = [points[f][0]*pixels, points[f][1]*pixels];
        }       
        circleR = Math.round( Math.sqrt( (points[1][0]*points[1][0]) + (points[1][1]*points[1][1]) ) );
        if (Rez.JsonData.fontSizes) {
            fontSizes = loadResource(Rez.JsonData.fontSizes);
        }
        labelHeight = fontSizes[ labelFont.toNumber() ];
    }


    //! setting the unique parameters 
    //! :heading, :font, :pen
    function setParams(options) as Void {
        if (options[:heading]) {
            setHeading(options[:heading]);
        }
        if (options[:font]) {
            labelFont = options[:font];
        }
        if (options[:pen]) {
            circlePen = options[:pen];
        }        
    }


    //! Set heading and calculated moving North radian
    function setHeading(p_currentHeading) as Void {
        if (p_currentHeading != null) {
            // 0 is north. -PI/2 radians (90deg CCW) is west, and +PI/2 radians (90deg CW) is east. PI is South. 2*PI = full circle
            // Make this nonsense to a normal positive Radian number
            currentHeading = (p_currentHeading<0) ? (Math.PI*2) + p_currentHeading : p_currentHeading;
            // North moving
            northRadian = 0 - currentHeading;
        }
    }


    //! draw Direction label
    function drawLabel(dc as Gfx.Dc) as Void {
        var y = locY-circleR-(circlePen/2)-labelHeight;
        var label = (currentHeading) ? Math.toDegrees(currentHeading).format("%0.0d") : "--";
        dc.setColor(labelColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(locX, y, labelFont, label, Gfx.TEXT_JUSTIFY_CENTER );
    }


    //! draw moving North arrow
    function drawArrow(dc as Gfx.Dc) as Void {
        if (northRadian == null) {
            return;
        }
        // Forgatás alkalmazása
        var rotatedPoints = new [points.size()];
        for (var i = 0; i < points.size() ; i++) {
            var x = points[i][0];
            var y = points[i][1];
            // Forgatás képlete: x' = x*cos(θ) - y*sin(θ), y' = x*sin(θ) + y*cos(θ)
            var newX = x * Math.cos(northRadian) - y * Math.sin(northRadian);
            var newY = x * Math.sin(northRadian) + y * Math.cos(northRadian);
            rotatedPoints[i] = [centerX + newX, centerY + newY];
        }
        System.println(rotatedPoints);
        // Háromszög kirajzolása
        dc.setColor(arrowColor, Gfx.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatedPoints);
    }

    //! draw circle
    function drawCircle(dc as Gfx.Dc) as Void {
        dc.setColor(circleColor, circleBackground);
        dc.setPenWidth(circlePen);
        dc.drawCircle(centerX, centerY, circleR+(circlePen/2));
        dc.fillCircle(centerX, centerY, 5);
    }


    // drawable draw
    function draw(dc as Gfx.Dc) as Void {
        drawCircle(dc);
        drawArrow(dc);
        drawLabel(dc);
    }
}
