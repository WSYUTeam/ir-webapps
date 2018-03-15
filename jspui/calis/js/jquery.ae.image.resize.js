(function(jQuery){ 

if(jQuery.browser) return; 

jQuery.browser = {}; 
jQuery.browser.mozilla = false; 
jQuery.browser.webkit = false; 
jQuery.browser.opera = false; 
jQuery.browser.msie = false; 

var nAgt = navigator.userAgent; 
jQuery.browser.name = navigator.appName; 
jQuery.browser.fullVersion = ''+parseFloat(navigator.appVersion); 
jQuery.browser.majorVersion = parseInt(navigator.appVersion,10); 
var nameOffset,verOffset,ix; 

// In Opera, the true version is after "Opera" or after "Version" 
if ((verOffset=nAgt.indexOf("Opera"))!=-1) { 
jQuery.browser.opera = true; 
jQuery.browser.name = "Opera"; 
jQuery.browser.fullVersion = nAgt.substring(verOffset+6); 
if ((verOffset=nAgt.indexOf("Version"))!=-1) 
jQuery.browser.fullVersion = nAgt.substring(verOffset+8); 
} 
// In MSIE, the true version is after "MSIE" in userAgent 
else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) { 
jQuery.browser.msie = true; 
jQuery.browser.name = "Microsoft Internet Explorer"; 
jQuery.browser.fullVersion = nAgt.substring(verOffset+5); 
} 
// In Chrome, the true version is after "Chrome" 
else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) { 
jQuery.browser.webkit = true; 
jQuery.browser.name = "Chrome"; 
jQuery.browser.fullVersion = nAgt.substring(verOffset+7); 
} 
// In Safari, the true version is after "Safari" or after "Version" 
else if ((verOffset=nAgt.indexOf("Safari"))!=-1) { 
jQuery.browser.webkit = true; 
jQuery.browser.name = "Safari"; 
jQuery.browser.fullVersion = nAgt.substring(verOffset+7); 
if ((verOffset=nAgt.indexOf("Version"))!=-1) 
jQuery.browser.fullVersion = nAgt.substring(verOffset+8); 
} 
// In Firefox, the true version is after "Firefox" 
else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) { 
jQuery.browser.mozilla = true; 
jQuery.browser.name = "Firefox"; 
jQuery.browser.fullVersion = nAgt.substring(verOffset+8); 
} 
// In most other browsers, "name/version" is at the end of userAgent 
else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < 
(verOffset=nAgt.lastIndexOf('/')) ) 
{ 
jQuery.browser.name = nAgt.substring(nameOffset,verOffset); 
jQuery.browser.fullVersion = nAgt.substring(verOffset+1); 
if (jQuery.browser.name.toLowerCase()==jQuery.browser.name.toUpperCase()) { 
jQuery.browser.name = navigator.appName; 
} 
} 
// trim the fullVersion string at semicolon/space if present 
if ((ix=jQuery.browser.fullVersion.indexOf(";"))!=-1) 
jQuery.browser.fullVersion=jQuery.browser.fullVersion.substring(0,ix); 
if ((ix=jQuery.browser.fullVersion.indexOf(" "))!=-1) 
jQuery.browser.fullVersion=jQuery.browser.fullVersion.substring(0,ix); 

jQuery.browser.majorVersion = parseInt(''+jQuery.browser.fullVersion,10); 
if (isNaN(jQuery.browser.majorVersion)) { 
jQuery.browser.fullVersion = ''+parseFloat(navigator.appVersion); 
jQuery.browser.majorVersion = parseInt(navigator.appVersion,10); 
} 
jQuery.browser.version = jQuery.browser.majorVersion; 
})(jQuery); 

(function( $ ) {

  $.fn.aeImageResize = function( params ) {

    var aspectRatio = 0
      // Nasty I know but it's done only once, so not too bad I guess
      // Alternate suggestions welcome :)
      ,	isIE6 = $.browser.msie && (6 == ~~ $.browser.version)
      ;

    // We cannot do much unless we have one of these
    if ( !params.height && !params.width ) {
      return this;
    }

    // Calculate aspect ratio now, if possible
    if ( params.height && params.width ) {
      aspectRatio = params.width / params.height;
    }

    // Attach handler to load
    // Handler is executed just once per element
    // Load event required for Webkit browsers
    return this.one( "load", function() {

      // Remove all attributes and CSS rules
      this.removeAttribute( "height" );
      this.removeAttribute( "width" );
      this.style.height = this.style.width = "";

      var imgHeight = this.height
        ,	imgWidth = this.width
        ,	imgAspectRatio = imgWidth / imgHeight
        ,	bxHeight = params.height
        ,	bxWidth = params.width
        ,	bxAspectRatio = aspectRatio;
				
      // Work the magic!
      // If one parameter is missing, we just force calculate it
      if ( !bxAspectRatio ) {
        if ( bxHeight ) {
          bxAspectRatio = imgAspectRatio + 1;
        } else {
          bxAspectRatio = imgAspectRatio - 1;
        }
      }

      // Only resize the images that need resizing
      if ( (bxHeight && imgHeight > bxHeight) || (bxWidth && imgWidth > bxWidth) ) {

        if ( imgAspectRatio > bxAspectRatio ) {
          bxHeight = ~~ ( imgHeight / imgWidth * bxWidth );
        } else {
          bxWidth = ~~ ( imgWidth / imgHeight * bxHeight );
        }

        this.height = bxHeight;
        this.width = bxWidth;
      }
    })
    .each(function() {

      // Trigger load event (for Gecko and MSIE)
      if ( this.complete || isIE6 ) {
        $( this ).trigger( "load" );
      }
    });
  };
})( jQuery );