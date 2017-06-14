var utils = {
    /* Checks if the specified value is undefined. If so, returns -1 and otherwise returns the value times 100. */
    fixCompletionRate: function(val) {
        if (val) {
            return parseFloat(val * 100).toFixed(0);
        }
        else {
            return -1;
        }
    },

    /*  Returns the specified sum as a string either with two decimals or without decimals
        depending on if they are "00" or not. */
    numericStringMakePretty: function(str) {

        // Check if integer or float
        if (parseFloat(str).toFixed(2).toString().substr(-2) === "00") {
            return utils.localizeNumber(numeral(str).format('0,0'));
        }
        else {
            return utils.localizeNumber(numeral(str).format('0,0.00'));
        }
    },

    /*  Makes a string pretty depending on what kind of info it contains. */
    strMakePretty: function(str) {
        if (str === undefined) {
            str = '';
        }

        if (str === '' || isNaN(str)) {
            return str;
        }
        else {
            return utils.numericStringMakePretty(str);
            //##TODO: Cover dates here as well (maybe relevant for additionalInfo on helpdesk table). Use moment?
        }
    },

    /*  Returns the string passed as a correctly formatted string according to the environment language.
        Only has support for sv or en-us (default) at the moment. */
    localizeNumber: function(str) {
        if (self.lang === 'sv') {
            return str.split(',').join(' ').replace('.', ',');      //Use split and join to replace ALL occurrencies of ','.
        }
        else return str;
    },

    /*  Returns the first valid icon name provided. If both are invalid undefined is returned. */
    chooseCardIcon: function(i1, i2) {
        if (utils.isValidCardIcon(i1)) {
            return i1;                
        }
        else {
            if (utils.isValidCardIcon(i2)) {
                return i2;
            }
            else {
                return undefined;
            }
        }
    },

    /*  Returns true if the specified iconName is a valid name for a card icon and otherwise false. */
    isValidCardIcon: function(iconName) {
        if (iconName === undefined
                || (iconName !== 'completion' && iconName !== 'happy' && iconName !== 'sad' && iconName !== 'wait') ) {
            return false;
        }
        else {
            return true;
        }
    }
}