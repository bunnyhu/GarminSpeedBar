import Toybox.System;
import Toybox.Lang;
using Toybox.Graphics as Gfx;

/*
EXAMPLE:
>>>>> layouts.xml
    <drawable id="w_compass" class="WindCompass">
        <param name="locX">150</param>
        <param name="locY">80</param>        
        <param name="height">80</param>
        <param name="font">Gfx.FONT_XTINY</param>
    </drawable>

>>>>> onUpdate()
    (findDrawableById("w_compass") as WindCompass).setHeading( currentHeading );

>>>>> Dependency:
    Align class + resources
    resource.xml  (font sizes in pixel for all device [eg: edge1050])
        <jsonData id="fontSizes">[21, 28, 33, 38, 61, 71, 82, 109, 136]</jsonData>
*/


//! Compass with wind, north moving
//!
//! Drawable params: 
//! locX, locY, height  (arrow center and height)
//!
//! Unique params: 
//! heading, font (for label), pen (circle contour), showLabel (0|1|2 = heading label: off | number | text)
class WindCompass extends Toybox.WatchUi.Drawable {
    private var _padding;           // Align::
    private var _directionTexts;    // compass directions
    private var currentHeading;     // radians
    private var northRadian;        // radians
    private var windDirection;      // radians
    private var circleR;
    private var showLabel = 1;      // 0 - none, 1 - numeric heading, 2 - short heading text
    private var labelHeight = 21;
    private var labelFont = Gfx.FONT_XTINY;

    var arrowColor = Gfx.COLOR_RED;
    var circleColor = Gfx.COLOR_LT_GRAY;
    var circleBackground = Gfx.COLOR_WHITE;
    var labelColor = Gfx.COLOR_BLACK;

    var circlePen = 10;
    var fontSizes = [0, 0, 0, 0, 0, 0, 0, 0, 0]; // Edge1050
    var points = [      // arrow corners in 4x4 matrix, 0;0 center
        [  0, -2],
        [ -1,  2],
        [  0,  1],
        [  1,  2],
    ];


    function initialize(options) {
        Drawable.initialize(options);       
        _padding = new Align();
        fontSizes = loadResource(Rez.JsonData.fontSizes);
        var n = WatchUi.loadResource( Rez.Strings.North ) as String;
        var w = WatchUi.loadResource( Rez.Strings.West ) as String;
        var e = WatchUi.loadResource( Rez.Strings.East ) as String;
        var s = WatchUi.loadResource( Rez.Strings.South ) as String;
        _directionTexts = [n, n+e, e, s+e, s, s+w, w, n+w, n];
        setParams(options);
    }


    //! Re set all calculated setting
    function resetAll() {
        // calculate real arrow corners pixel with the height parameter
        var pixels = Math.round( height / 4 );
        for (var f=0; f<points.size(); f++) {
            points[f] = [points[f][0]*pixels, points[f][1]*pixels];
        }       
        circleR = Math.round( Math.sqrt( (points[1][0]*points[1][0]) + (points[1][1]*points[1][1]) ) );
        labelHeight = fontSizes[ labelFont.toNumber() ];
    }


    //! setting the unique parameters 
    //! :heading, :font, :pen
    function setParams(options) as Void {
        if (options[:heading]!=null) {
            setHeading(options[:heading]);
        }
        if (options[:wind]!=null) {
            setWind(options[:wind]);
        }
        if (options[:font]!=null) {
            labelFont = options[:font];
        }
        if (options[:pen]!=null) {
            circlePen = options[:pen];
        }
        if (options[:showLabel]!=null) {
            showLabel = options[:showLabel];
        }
        resetAll();
    }


    //! Set heading and calculated moving North radian
    function setHeading(p_currentHeading) as Void {
        if (p_currentHeading != null) {
            // 0 is north. -PI/2 radians (90deg CCW) is west, and +PI/2 radians (90deg CW) is east. PI is South. 2*PI = full circle
            // Make this nonsense to a normal positive Radian number
            currentHeading = (p_currentHeading<0) ? (Math.PI*2) + p_currentHeading : p_currentHeading;
            // North moving
            northRadian = 0 - currentHeading;
            northRadian = (northRadian<0) ? (Math.PI*2) + northRadian : northRadian;
        }
    }


    function setWind(p_wind) as Void {
        windDirection = Math.toRadians(p_wind);
    }


    //! Get compass 1/8 direction number, 0 - North CW
    function getDirection(pHeadingValue) as Number {
        var r = Math.round(pHeadingValue / 45).toNumber();
        // if (r>7) { r = r-8; }
        return r % 8;
    }


    function getWindArcs() as Dictionary {
        var _arcHalfDegree = 23;
        var _arcMargin = 12;
        var pHeading = Math.toDegrees(northRadian);
        var pWind = Math.toDegrees(windDirection);
        var _wind = pHeading.toFloat() + pWind.toFloat();

        var _center = (360 - _wind);
        _center = _center + 90;

        var result = [_center-_arcHalfDegree-_arcMargin, _center+_arcHalfDegree+_arcMargin, _center-_arcHalfDegree, _center+_arcHalfDegree];
        for (var f=0; f<result.size(); f++) {
            if (result[f] < 0) {
                result[f] = 360 + result[f];
            } else if (result[f]>360) {
                result[f] = result[f] - 360;
            }
        }
        //  cut begin/end, wind begin/end
        return {:cb=>result[0], :ce=>result[1], :wb=>result[2], :we=>result[3]};

    }


    function draw(dc as Gfx.Dc) as Void {
        drawCircle(dc);
        drawArrow(dc);
        drawLabel(dc);
    }


    //! draw Direction label
    function drawLabel(dc as Gfx.Dc) as Void {
        var label = "";
        if (showLabel == 0) {
            return;
        } else if (showLabel == 1) {
            label = (currentHeading) ? Math.toDegrees(currentHeading).format("%0.0d") : "--";
        } else if (showLabel == 2) {
            label = (currentHeading) ? _directionTexts[getDirection(Math.toDegrees(currentHeading))] : "--";
        }
        var y = locY-circleR-(circlePen/2)-labelHeight-5;
        dc.setColor(labelColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(locX, _padding.reAlignY(y, labelFont), labelFont, label, Gfx.TEXT_JUSTIFY_CENTER );
    }


    //! draw moving North arrow
    function drawArrow(dc as Gfx.Dc) as Void {
        if (northRadian == null) {
            return;
        }
        var rotatedPoints = new [points.size()];
        for (var i = 0; i < points.size() ; i++) {
            var x = points[i][0];
            var y = points[i][1];
            // Forgatás képlete: x' = x*cos(θ) - y*sin(θ), y' = x*sin(θ) + y*cos(θ)
            var newX = x * Math.cos(northRadian) - y * Math.sin(northRadian);
            var newY = x * Math.sin(northRadian) + y * Math.cos(northRadian);
            rotatedPoints[i] = [locX + newX, locY + newY];
        }
        dc.setColor(arrowColor, Gfx.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatedPoints);
    }


    //! draw circle
    function drawCircle(dc as Gfx.Dc) as Void {
        // white bg stroke circle area
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        // dc.fillCircle(locX, locY, circleR);

        dc.setColor(circleColor, circleBackground);
        dc.setPenWidth(2);

        if (windDirection == null) {
            dc.drawCircle(locX, locY, circleR+4);
        } else {
            var windArc = getWindArcs();
            dc.setPenWidth(2);
            dc.drawArc(locX, locY, circleR+4, Graphics.ARC_CLOCKWISE , windArc[:cb], windArc[:ce]);
            dc.setPenWidth(circlePen);
            dc.setColor(Graphics.COLOR_PURPLE, circleBackground);
            dc.drawArc(locX, locY, circleR+4, Graphics.ARC_COUNTER_CLOCKWISE , windArc[:wb], windArc[:we]);
        }
    }

}
