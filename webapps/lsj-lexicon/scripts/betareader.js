
var betareader = function() {
    /*
    if (typeof(bString) != "string") {
        throw new Error(" betareader Constructor: Parameter `bString` ='" + bString + "' is not of type 'string'!");
    }
    this.bString = bString;
    */

    const breathings = ["(",")"];
    const numbers = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    const editorialsigns = [ "#6"  , "#8"  , "#9"  , "#10" , "#11" , "#12" , "#13" , "#14" , "#15" , "#16" , "#17" , "#18" , "#19" , "#53", "?", "%", "%13", "%158", "%163", "#305", "?" ];
    const archaic = ["#1","#2","#3","#4","#5", "#400"]
    const mathematical = ["#150"];
    const accents = [ "/", "\\", "=" ];
    const iotasubscript = "|";
    const dieresis = "+";
    const uppercasemarker = "*";
    const diacriticals = breathings.concat(accents, iotasubscript, dieresis);
    const punctuation = [ ",", ".", `"`, "'", ";", "[", "]", "-", "—", ":", " ", "#", "\t", "\n"];
    const validLCConsonants = "bgdvzqklmncprstfxy".split(""); // We want an array
    const validUCConsonants = "BGDVZQKLMNCPRSTFXY".split("");
    const validLCVowels = "aehiouw".split("");
    const validUCVowels = "aehiouw".toUpperCase().split("");
    const diphthongs = ["ai", "ei", "oi", "ui", "au", "eu", "hu", "ou", "Ai", "Ei", "Oi", "Ui", "Au", "Eu", "Hu", "Ou"];
    const sigmaterminators = [",", ".", "'", '"', ":", ";", " ", "\t", "\n", "–", "—"];


    this.ispunctuation = function( testChar ) {
        if ( punctuation.includes(testChar)) {
            return true;
        } else {
            return false;
        }
    }

    this.isSigmaTerminator = function( testChar ) {
        if ( sigmaterminators.includes(testChar)) {
            return true;
        } else {
            return false;
        }
    }

    this.isdiacritic = function( testChar ) {
        if ( diacriticals.includes( testChar ) ){
            return true;
        } else {
            return false;
        };
    }

    this.isUC = function( testChar ) {
        if ( validUCConsonants.concat(validUCVowels).includes(testChar) ) {
            return true;
        } else {
            return false;
        };
    };

    this.isUCMarker = function( testChar ) {
        if ( uppercasemarker.includes( testChar )) {
            return true;
        } else {
            return false;
        };
    };

    this.isNumber = function( testChar ) {
        if ( numbers.includes(testChar) ) {
            return true;
        } else {
            return false;
        };
    };

}

/*
    Other functions
*/

//"Simply look up `testChar` in `BetaReader.bigLookup`, in file `CharDict.jl`. If the lookup fails, return the invalid-beta-code sign `#`."
betareader.prototype.resolve = function( testChar ) {
    //console.log(`Resolving "${testChar}".`);
    let inDict =  testChar in this.chardict;
    if (inDict) {
        let answer = this.chardict[testChar].Ucode;
        //console.log(`Resolved to "${this.chardict[testChar].Ucode}", "${this.chardict[testChar].Name}".`);
        return answer
    } else {
        // Invalid (or at least un-trapped) beta-code character or sequence
        let answer = "❌"; // change to "#" for elegance later
        return answer
    }
 };


// Pre-compile the following regex for efficiency if this function is called multiple times
betareader.prototype.GREEK_PREPROCESS_REGEX = /\*([)(/\\=]+)([a-zA-Z])/g;
// Pre-compile the following regex for efficiency if this function is called multiple times



/**
 * Pre-process a string of Beta-code, correcting the order of accented capital letters.
 * The function changes the order from *diacriticalsletter to *letterdiacriticals.
 * 
 * @param {string} s - Input string in Beta-code format.
 * @returns {string} Processed string where the order of accented capitals is corrected.
 * 
 * @example
 * preprocessGreek("*\=A"); // Returns "*A\="
 */
betareader.prototype.preprocessGreek = function(s) {
    // Replace the pattern where the asterisk is followed by diacriticals and then a letter
    // with asterisk, letter, and then diacriticals
    firstPass = s.replace(this.GREEK_PREPROCESS_REGEX, (match, diacritics, letter) => `*${letter}${diacritics}`);
    // For pipe chars, we can use either %5 or ||, or precede it with whitespace
    secondPass = firstPass.replaceAll(/\|\|\|/g, "|%5"); 
    thirdPass = secondPass.replaceAll(/\|\|/g, "%5"); 
    fourthPass = thirdPass.replaceAll(/(\s)\|/g, "$1%5"); 
    // get dialytika in the right order
    fifthPass = fourthPass.replaceAll(/([iu])([\/=\\])\+/g, "$1+$2");
    return fifthPass;
}





/**
 *  The big iterator that does all the work. 
 * 
 */
betareader.prototype.accumulate = function(s, acc, ret, upperCaseThisOne) {
    //console.log(`Accumulating s="${s}" with acc="${acc}" and ret="${ret}".`)
    
    /* When we're done, an all characters in the original `s` 
     * have been treated, `s` will be empty, so we return `ret`. 
     * Invalid characters will be transliterated to `#`.
    */
    if (s.length == 0){ 
        //console.log(`returning ${ret}`);
        return ret;
    } else { // before we're done…

        // Deal with first character!
        var charVec = s.split("");
        // Get the first character
        let firstChar = charVec[0];
        // Remove it from charVec
        charVec = charVec.slice(1);

        // We need the second characters, for handling sigmas and the `*` form of upper-case.
        let secondChar = (() => {
            if (charVec.length < 1) {
                return "";
            } else {
                return charVec[0];
            }
        })();

        
        // Remember, for above and below, we've already "popped" the first char off! 
        let thirdChar = (() => {
            if (charVec.length < 2) {
                return "";
            } else {
                return charVec[1];
            }
        })();

        //  We only need to peek at the fourth and fifth chars for some of those esoteric "#…" codes
        let fourthChar = (() => {
            if (charVec.length < 3) {
                return "";
            } else {
                return charVec[2];
            }
        })();


        // Handle medial and terminal sigmas
        if (firstChar == "s") {
            if (this.isSigmaTerminator(secondChar) || (secondChar == "") ) {
                // No need to be fancy, just stick a terminal sigma in there.
                let newAcc = (() => {
                    if (this.upperCaseThisOne) {
                        return acc + "Σ";
                    } else {
                        return acc + "ς";
                    }
                })();
                return this.accumulate(charVec.join(""),newAcc,newAcc);
            } else {
                // Sigma is transliterated to medial form
                let newAcc = (() => {
                    if (this.upperCaseThisOne) {
                        return acc + "Σ";
                    } else {
                        return acc + "σ";
                    }
                })();
                return this.accumulate(charVec.join(""),newAcc,newAcc, false);                
            }

        // Handle the `*` form of upper-case letters
        } else if ((this.isUCMarker(firstChar))) {
            // Asterisk as a stand-alone character is not allowed
            if (charVec.length < 1) {
                // iterate
                let newAcc = acc + "";
                return this.accumulate(charVec.join(""), newAcc, newAcc, false);
            } else {
                return this.accumulate(charVec.join(""), acc, ret, true); 
            }

        // Handle the "#" and "%" codes, for funky letters and critical signs
        } else if ("#%[]".includes(firstChar)) {
            //console.log("+++Got here with: " + firstChar);
            if (this.isNumber(secondChar) == false) { 
                // resolve firstChar alone
                //      not subject to upper-casing
                newAcc = acc + this.resolve(firstChar);
                //console.log("+++ Resolved " + firstChar + " to " + newAcc);
                if (charVec.length < 1) {
                    return newAcc; // resolve and return!
                } else {
                    // iterate
                    return this.accumulate(charVec.join(""), newAcc, newAcc, false); 
                }
            } else {
                //console.log("+++ got here with " + firstChar + secondChar);
                if (this.isNumber(thirdChar) == false) { 
                    // pass through "#" + secondChar
                    if (secondChar != "") {
                        // remove secondChar
                        charVec = charVec.slice(1);
                    } 
                    let resolvedChar = (() => { 
                        console.log("Got here with: " + firstChar + secondChar + upperCaseThisOne);
                        if (upperCaseThisOne) {
                            let retChar1 = this.resolve((firstChar + secondChar)); 
                            let retChar2 = retChar1.toUpperCase();
                            return retChar2;
                        } else {
                            let retChar = this.resolve((firstChar + secondChar)); 
                            console.log(retChar + " : " + retChar.charCodeAt() + " " + upperCaseThisOne);
                            //return this.resolve(firstChar + secondChar);
                            return retChar;
                        }
                    })();
                    newAcc = acc + resolvedChar;
                    // Iterate
                    return this.accumulate(charVec.join(""), newAcc, newAcc, false);

                } else {
                    if (this.isNumber(fourthChar) == false ) {
                        //console.log("+++ got here with " + firstChar + secondChar + thirdChar);
                        // pass through "#" + secondChar + thirdChar
                        charVec = charVec.slice(2); // get rid of secondChar and thirdChar.
                        let resolvedChar = (() => { 
                            if (upperCaseThisOne) {
                                return this.resolve(firstChar + secondChar + thirdChar).toUpperCase();
                            } else {
                                return this.resolve(firstChar + secondChar + thirdChar);
                            }
                        })();
                        newAcc = acc + resolvedChar;
                        // Iterate
                        return this.accumulate(charVec.join(""), newAcc, newAcc, false);
                    } else {
                       
                        //console.log("+++ got here with " + firstChar + secondChar + thirdChar + fourthChar);
                        // pass through "#" + secondChar + thirdChar + fourthChar
                        charVec = charVec.slice(3); // get rid of secondChar and thirdChar and fourthChar.
                        let resolvedChar = (() => { 
                            if (upperCaseThisOne) {
                                return this.resolve(firstChar + secondChar + thirdChar + fourthChar).toUpperCase();
                            } else {
                                return this.resolve(firstChar + secondChar + thirdChar + fourthChar);
                            }
                        })();
                        newAcc = acc + resolvedChar;
                        // Iterate
                        return this.accumulate(charVec.join(""), newAcc, newAcc, false);
                        
                    }
                }
            } 

        // We'll accept both upper-case in Beta, or the `*` 
        } else if (this.isUC(firstChar)) {
            // Rather than having a lookup dictionary twice as long as needed, 
            // we use our functions, and the affordances of `Unicode` to work around it.
            // Whatever it is, lower-case it and resolve…
            let resolvedLC = this.resolve(firstChar.toLowerCase());
            let resolvedUC = resolvedLC.toUpperCase();
            newAcc = acc + resolvedUC;
            return this.accumulate(charVec.join(""), newAcc, newAcc, false);

        // Arabic numbers should just go through
        } else if (this.isNumber(firstChar)) {
            let newAcc = acc + firstChar;
            return this.accumulate(charVec.join(""),newAcc,newAcc, false);   

        // Fall-through default: resolve and iterate
        } else {
            let newAcc = (() => {
                if (upperCaseThisOne) {
                    return acc + this.resolve(firstChar).toUpperCase();
                } else {
                    return acc + this.resolve(firstChar);
                }
            })();
            return  this.accumulate(charVec.join(""),newAcc,newAcc, false);
        }
    }
}

/** 
 * Take a string of Beta-Code and return NFKC Unicode.
 *      We preprocess to get the diacriticals in the correct order.
 *      We use the recurive function br.accumulate, which is initialized
 *      with our preprocessed string, and blanks.
 *      The result will have combinging diacritics, so we
 *      normatlize to NFKC.
 * 
 * @param {string} s - Input string in Beta-code format.
 * 
 * @example
 * br.transcodeGreek("mh=nin"); // Returns "μῆνιν"

 * "Initialize the iterator, `accumulate()`; 
 * get the final result, which will be using combining diacritics; 
 * then normalize to `:NFKC`, using pre-combined diacritics."
 * 
*/
betareader.prototype.transcodeGreek = function(s) {
    var preprocessedGreek = this.preprocessGreek(s);
    //console.log("-----1 got here: " + preprocessedGreek);
    var combiningDiacritics = this.accumulate(preprocessedGreek, "", "", false);
    // And those damned dialytikos-combos!
    var ucgreek = combiningDiacritics.normalize('NFKC');
    // Maybe make this optional?
    var fixedoxia = this.fixoxia(ucgreek);
    return fixedoxia;
}

/** 
 * Utility for seeing precisely what is going on.
 * Take a string in BetaCode, transcode it.
 * Report each code-point after both NFKC and NFKD normalization
 */




// we want oxia, dammit, not tonos!
betareader.prototype.fixoxia = function(s) {
    let returnString = s.replaceAll("\u0390", "\u1FD3") // iota, dialytika, oxia
     .replaceAll("\u03B0", "\u1FE3") // upsilon, dialytika, oxia
     .replaceAll("\u03AC", "\u1F71") // alpha
     .replaceAll("\u03AD", "\u1F73") // epsilon
     .replaceAll("\u03AE", "\u1F75") // eta
     .replaceAll("\u03AF", "\u1F77") // iota
     .replaceAll("\u03CC", "\u1F79") // omicron
     .replaceAll("\u03CD", "\u1F7B") // upsilon
     .replaceAll("\u03CE", "\u1F7D") // omega
     .replaceAll("\u0386", "\u1FBB") // Alpha
     .replaceAll("\u0388", "\u1FC9") // Epsilon
     .replaceAll("\u0389", "\u1FCB") // Eta
     .replaceAll("\u038A", "\u1FDB") // Iota
     .replaceAll("\u038C", "\u1FF9") // Omicron
     .replaceAll("\u038E", "\u1FEB") // Upsilon
     .replaceAll("\u038F", "\u1FFB"); // Omega
    return returnString;
}

/*
    Big dictionary of Greek!
*/

betareader.prototype.chardict = {

    // consonants

    "b" : { Ucode : "β", Name : "beta" },
    "g" : { Ucode : "γ", Name : "gamma" },
    "d" : { Ucode : "δ", Name : "delta" },
    "v" : { Ucode : "ϝ", Name : "digamma" },
    "z" : { Ucode : "ζ", Name : "zeta" },
    "q" : { Ucode : "θ", Name : "theta" },
    "k" : { Ucode : "κ", Name : "kappa" },
    "l" : { Ucode : "λ", Name : "lambda" },
    "m" : { Ucode : "μ", Name : "mu" },
    "n" : { Ucode : "ν", Name : "nu" },
    "c" : { Ucode : "ξ", Name : "xi" },
    "p" : { Ucode : "π", Name : "pi" },
    "r" : { Ucode : "ρ", Name : "rho" },
    "t" : { Ucode : "τ", Name : "tau" },
    "f" : { Ucode : "φ", Name : "phi" },
    "x" : { Ucode : "χ", Name : "chi" },
    "y" : { Ucode : "ψ", Name : "psi" },

    // terminal sigma handled separately in Main.jl; the user shouldn't have to care

    "s": { Ucode: "σ", Name: "sigma" },

    //vowels

    "a": { Ucode: "α", Name: "alpha" },
    "e": { Ucode: "ε", Name: "epsilon" },
    "h": { Ucode: "η", Name: "eta" },
    "i": { Ucode: "ι", Name: "iota" },
    "o": { Ucode: "ο", Name: "omicron" },
    "u": { Ucode: "υ", Name: "upsilon" },
    "w": { Ucode: "ω", Name: "omega" },

    // diacriticals

    "(": { Ucode: "\u0314", Name: "rough breathing" },
    ")": { Ucode: "\u0313", Name: "smooth breathing" },
    "\\": { Ucode: "\u0300", Name: "grave accent" },
    "/": { Ucode: "\u0301", Name: "acute accent (oxia)" },
    "=": { Ucode: "\u0342", Name: "circumflex" },
    "+": { Ucode: "\u0308", Name: "diaeresis" },
    "|": { Ucode: "\u0345", Name: "iota-subscript" },

    // punctuation
    " ": { Ucode: " ", Name: "space" },
    ".": { Ucode: ".", Name: "period" },
    ",": { Ucode: ",", Name: "comma" },
    ":": { Ucode: "\u00b7", Name: "colon" },
    ";": { Ucode: ";", Name: "Greek question mark" },
    "-": { Ucode: "-", Name: "hyphen" },
    "\n": { Ucode: "\n", Name: "carriage-return '\\n'" },
    "\t": { Ucode: "\t", Name: "tab character" },
    "'": { Ucode: "\u2019", Name: "apostrophe, mark of elision" },
    "\"": { Ucode: "\"", Name: "quotation mark" },
    "_": { Ucode: "—", Name: "em-dash" },
    "—": { Ucode: "—", Name: "em-dash" },
    "–": { Ucode: "–", Name: "en-dash" },
    "#": { Ucode: "\u02b9", Name: "Greek numeral sign" }, // greek numeral sign

    // archaic letters

    "#1": { Ucode: "\u03DF", Name: "koppa" }, // koppa
    "#2": { Ucode: "\u03DB", Name: "stigma" }, // stigma
    "#3": { Ucode: "\u03D9", Name: "archaic koppa" }, // Greek Letter Archaic Koppa
    "#4": { Ucode: "\u03DE", Name: "glyph variant of archaic koppa" }, // Greek Letter Koppa → glyph variant of Greek Letter Koppa
    "#5": { Ucode: "\u03E1", Name: "sampi" }, // sampi
    "#400": { Ucode: "\u0371", Name: "heta" }, // letter heta
    "#711": { Ucode: "\u03FB", Name: "san LC" }, // letter san

    //"v": { Ucode: "\u03DD", Name: "lower-case digamma" }, // letter digamma

    // critical signs

    "#6": { Ucode: "\u2E0F", Name: "paragraphos" }, // paragraphos
    "#8": { Ucode: "\u2E10", Name: "forked paragraphos" }, // forked paragraphos
    "#9": { Ucode: "\u0301", Name: "Combining Acute Accent → editorial" }, // Combining Acute Accent → editorial
    "#10": { Ucode: "\u03FD", Name: "Reversed Lunate Sigma Symbol" }, // Greek Capital Reversed Lunate Sigma Symbol
    "#11": { Ucode: "\u03FF", Name: "Reversed Dotted Lunate Sigma Symbol" }, // Greek Capital Reversed Dotted Lunate Sigma Symbol
    "#12": { Ucode: "\u2014", Name: "obelus; em-dash" }, // obelus
    "#13": { Ucode: "\u203B", Name: "asteriskos" }, // ※ Reference Mark ‣ Asteriskos
    "#14": { Ucode: "\u2E16", Name: "diple periestigmene" }, // ⸖ Dotted Right Pointing Angle • Diple Periestigmene
    "#15": { Ucode: "\u003E", Name: "diple" }, // > Greater-Than Sign ‣ Diple
    "#16": { Ucode: "\u03FE", Name: "dotted lunate sigma" }, // Greek Capital Dotted Lunate Sigma Symbol
    "#17": { Ucode: "\u002F", Name: "solidus" }, // / Solidus ‣ Obelus
    "#18": { Ucode: "\u003C", Name: "reversed diple" }, // < Less-Than Sign ‣ Reversed Diple
    "#19": { Ucode: "\u0300", Name: "editorial combining grave accent" }, // ◌̂ Combining Grave Accent → editorial

    "#22": { Ucode: "\u0375", Name: "Greek Lower Numeral Sign" }, //  Greek Lower Numeral Sign
    "#74": { Ucode: "⁝", Name: "tricolon" }, 

    "#53": { Ucode: "\u205D", Name: "tricolon" }, //  ⁝ tricolon
    "#150": { Ucode: "\u221E", Name: "infinity" }, // ∞ infinity
    "#310": { Ucode: "\u2E0E", Name: "editorial coronis" }, // ⸎ Editorial Coronis 
    "#465": { Ucode: "\u2627", Name: "chi rho" }, // ☧ chi-rho
    "%": { Ucode: "\u2020", Name: "dagger/crux" }, //  † dagger/crux
    "%1": { Ucode: "?", Name: "Latin question mark" }, 
    "%5": { Ucode: "\u007c", Name: "long vertical bar" }, // | 
    "%17": { Ucode: "\u2016", Name: "double vertical line" }, // ‖
    "%40": { Ucode: "\u23d1", Name: "metrical breve" }, // ⏑

    "%40": { Ucode: "\u23d1", Name: "metrical breve" }, // ⏑
    "%41": { Ucode: "\u2013", Name: "metrical macron" }, // — 
    "%42": { Ucode: "\u23D5", Name: "two shorts over one long" }, // ⏕
    "%43": { Ucode: "\u00D7", Name: "metrical anceps" }, // × 
    "%44": { Ucode: "\u23D2", Name: "metrical long over short" }, // ⏒ 
    "%45": { Ucode: "\u23D3", Name: "metrical short over long" }, // ⏓
    "%46": { Ucode: "\u23D4", Name: "metrical long over two shorts" }, // ⏔
    "%141": { Ucode: "\u23D6", Name: "metrical two shorts joined" }, // ⏖

    "%13": { Ucode: "\u2021", Name: "double dagger" }, //  ‡ double-dagger
    "%158": { Ucode: "\u2042", Name: "asterism" }, //  ⁂ asterism
    "%163": { Ucode: "\u00B6", Name: "paragraph sign" }, // ¶ paragraph sign
    "?": { Ucode: "\u0323", Name: "under-dot" },

    // Parentheses

    "[" : { Ucode: "[", Name: "left square bracket" },
    "]" : { Ucode: "]", Name: "right square bracket" },
    "[1" : { Ucode: "(", Name: "left parenthesis" },
    "]1" : { Ucode: ")", Name: "right parenthesis" },
    "[2" : { Ucode: "\u3008", Name: "left-pointing angle bracket" },
    "]2" : { Ucode: "\u3009", Name: "right-pointing angle bracket" },
    "[3" : { Ucode: "{", Name: "left curly bracket" },
    "]3" : { Ucode: "}", Name: "right curly bracket" },
    "{" : { Ucode: "{", Name: "left curly bracket" },
    "}" : { Ucode: "}", Name: "right curly bracket" },
    "[4" : { Ucode: "\u27E6", Name: "left white square bracket" },
    "]4" : { Ucode: "\u27E7", Name: "right white square bracket" },

    // Other signs

    //"#": { Ucode: "❌", Name: "invalid beta-code" },
};

