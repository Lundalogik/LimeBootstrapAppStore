var helperFunctions = (function () {

/**
 * Uses canvas.measureText to compute and return the width of the given text of given font in pixels.
 * 
 * @param text The text to be rendered.
 * @param {String} font The css font descriptor that text is to be rendered with (e.g. "14px verdana").
 * 
 * @see http://stackoverflow.com/questions/118241/calculate-text-width-with-javascript/21015393#21015393
 */
    var getTextWidth = function (text, font) {
        // if given, use cached canvas for better performance
        // else, create new canvas
        var canvas = getTextWidth.canvas || (getTextWidth.canvas = document.createElement("canvas"));
        var context = canvas.getContext("2d");
        context.font = font;
        var metrics = context.measureText(text);
        return metrics.width;
    };


    var COLOR_REGEX = /^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/;

    var colorHexToRGB = function (htmlColor) {

        arrRGB = htmlColor.match(COLOR_REGEX);
        if (arrRGB == null) {
            alert("Invalid color passed, the color should be in the html format. Example: #ff0033");
        }
        var red = parseInt(arrRGB[1], 16);
        var green = parseInt(arrRGB[2], 16);
        var blue = parseInt(arrRGB[3], 16);
        return {"r":red, "g":green, "b":blue};
    }

    var colorRGBToHex = function (red, green, blue) {
        if (red < 0 || red > 255 || green < 0 || green > 255 || blue < 0 || blue > 255) {
            alert("Invalid color value passed. Should be between 0 and 255.");
        }
        var formatHex = function(value) {
            value = value + "";
            if (value.length == 1) {
                return "0" + value;
            }
            return value;
        }
        hexRed = formatHex(red.toString(16));
        hexGreen = formatHex(green.toString(16));
        hexBlue = formatHex(blue.toString(16));

        return "#" + hexRed + hexGreen + hexBlue;
    }

    var calculateTransparentColor = function (foregroundColor, backgroundColor, opacity) {
        if (opacity < 0.0 || opacity > 1.0) {
            alert("assertion, opacity should be between 0 and 1");
        }
        opacity = opacity * 1.0; // to make it float
        var foregroundRGB = colorHexToRGB(foregroundColor);
        var backgroundRGB = colorHexToRGB(backgroundColor);
        var finalRed = Math.round(backgroundRGB.r * (1-opacity) + foregroundRGB.r * opacity);
        var finalGreen = Math.round(backgroundRGB.g * (1-opacity) + foregroundRGB.g * opacity);
        var finalBlue = Math.round(backgroundRGB.b * (1-opacity) + foregroundRGB.b * opacity);
        return colorRGBToHex(finalRed, finalGreen, finalBlue);
    }

    return {
        getTextWidth: getTextWidth,
        calculateTransparentColor: calculateTransparentColor
    };
}());