/*
 * FeatureList - simple and easy creation of an interactive "Featured Items" widget
 * Examples and documentation at: http://jqueryglobe.com/article/feature_list/
 * Version: 1.0.0 (01/09/2009)
 * Copyright (c) 2009 jQueryGlobe
 * Licensed under the MIT License: http://en.wikipedia.org/wiki/MIT_License
 * Requires: jQuery v1.3+
*/
;(function($) {
	$.fn.featureList = function(options) {
		var tabs	= $(this);
		var output	= $(options.output);

		new jQuery.featureList(tabs, output, options);

		return this;	
	};

	$.featureList = function(tabs, output, options) {
		function getSub(str,n){
			   var strReg=/[^\x00-\xff]/g;
			   var _str=str.replace(strReg,"**");
			   var _len=_str.length;
			   if(_len>n){
			     var _newLen=Math.floor(n/2);
			     var _strLen=str.length;
			     for(var i=_newLen;i<_strLen;i++){
			         var _newStr=str.substr(0,i).replace(strReg,"**");
			         if(_newStr.length>=n){
			        	 if(str.substr(0,i) == "undefined") {
			        		 return str.substr(0,i-1)+"...";
			        	 } else {
			        		 return str.substr(0,i)+"...";
			        	 }
			             break;
			        }
			     }
			   }else{
			     return str;
			   }
			}
		
		function showhotview(data, handle) {
			//$("#"+handle+"_hotview").empty();
			// alert(JSON.stringify(data));
			$("#hot_view").empty();
			var matrix = data.matrix;
			var colLabels = data.colLabels;
			var colLabelsAttrs = data.colLabelsAttrs;
			var aps = data.aps;
		    var html = "";
		    var flag = true;
		    html += "<div class='row item'>";
		    for(var i = 0; i < aps.length; i++) {
		    	if(aps[i] != null && aps[i] != "" && aps[i].length > 0) {
		        	var url = colLabelsAttrs[i].url;
		        	
		        	if(i%2==0) {
		        		//html += "<div class='row item'>";
		        	} 
		        	html += "<div class='col-md-6'>";
		    	    html += "<div class='title'>";
		    	    html += "<a href='" + url + "' title='" + colLabels[i] + "' target='_blank'>" + (getSub(colLabels[i], 30)===undefined?getSub(colLabels[i], 39):getSub(colLabels[i], 30)) + "</a>";
		    	    html += " &nbsp;  <span class=\"a1\">作者：</span>" + aps[i][0] + " &nbsp;  <span class=\"a1\">出版者：</span>" + getSub(aps[i][1], 30);
		    	    html += "</div>";
		    	    var douhao_flag = (aps[i][1] && aps[i][1]!="" && aps[i][1]!="null") && (aps[i][2] &&aps[i][2]!="" && aps[i][2]!="null");
		    	    //出版社
		    	    if(douhao_flag) {
		    	    	// html += "<div class='publisher'>" + aps[i][1] + ", " + aps[i][2] + "</div>";
		    	    } else {
		    	    	if(aps[i][1] || aps[i][2]) {
			    	    	if(!aps[i][1] || aps[i][1]=="" || aps[i][1]=="null") {
			    	    		// html += "<div class='publisher'>" + aps[i][2] + "</div>";
			    	    	} else if(!aps[i][2] || aps[i][2]=="" && aps[i][2]=="null") {
			    	    		// html += "<div class='publisher'>" + aps[i][1] + "</div>";
			    	    	}
		    	    	} else {
		    	    		// html += "<div class='publisher'> </div>";
		    	    	}
		    	    }
		    	    html += "<div>";
		    	    if(aps[i][0] && aps[i][0]!="" && aps[i][0]!="null") {
		    	    	//html += "<div class='author'><span class=\"a1\">作者：</span>" + aps[i][0] + "</div>";
		    	    } else {
		    	    	//html += "<div class='author'> </div>";
		    	    }
					//html += "<div class='views'>" + matrix[0][i] + " " + hot_views + " &nbsp; &nbsp; <span class=\"a2 a1\">ISSN：</span></div>";
					//html += "<div class='views'><span class=\"a1\">作者：</span>" + aps[i][0] + " &nbsp;  &nbsp; <span class=\"a1\">期刊：</span>" + aps[i][1] + " " + hot_views + " &nbsp; &nbsp; <span class=\"a2 a1\"></span></div>";//ISSN：
					html += "<div style='clear: both;'></div>"
		    	    html += "</div>";
		    	    html += "</div>";
		    	    if((i%2==1)) {
		    	    	//html += "</div>";
		    	    }

		    	} else {
		    		//html += "</div>";
		    	}
		    }
		    html += "</div>";
		    //$("#"+handle+"_hotview").append(html);
		    $("#hot_view").append(html);
		}
		slide();
		function slide(nr) {
			
			if (typeof nr == "undefined") {
				nr = visible_item + 1;
				nr = nr >= total_items ? 0 : nr;
			}
			
			//var handle = tabs.filter(":eq(" + nr + ")").parent().attr("id");  
			var handle = '470302_1';
			var hotview_url = context + '/hotview?handle=' + encodeURI(handle.replace("_", "/"));
			//var hotview_url = context + '/hotview?handle=470302/1');
			//alert(hotview_url)
		    if(localCache.exist(hotview_url)){
		    	showhotview(localCache.get(hotview_url), handle);
		    } else {
			    var aj = $.ajax({    
			    	   url:hotview_url,
			    	    type:'get',    
			    	    cache:true,    
			    	    dataType:'json',    
			    	    success:function(data) {    
			    	        if(data.aps != null ){  
			    	        	// alert(JSON.stringify(data));
			    	        	showhotview(data, handle);
			    	        	//localCache.set(hotview_url, data);
			    	        }  
			    	     },    
			    	     error : function() {  
			    	          // alert("Sorry, there is something wrong.");    
			    	     }    
			    	});   
		    }
			

			var img_old = tabs.filter('.current').find('img');
			img_old.attr('src', img_old.attr("src").replace('_green', ''));
			tabs.removeClass('current').filter(":eq(" + nr + ")").addClass('current').find('img').addClass('current');
			var img_new = tabs.filter('.current').find('img');
			img_new.attr('src', img_new.attr("src").replace('.png', '_green.png'));

			output.stop(true, true).filter(":visible").fadeOut();
			output.filter(":eq(" + nr + ")").fadeIn(function() {
				visible_item = nr;	
			});
		}

		var options			= options || {}; 
		var total_items		= tabs.length;
		var visible_item	= options.start_item || 0;

		options.pause_on_hover		= options.pause_on_hover		|| true;
		options.transition_interval	= options.transition_interval	|| 5000;

		output.hide().eq( visible_item ).show();
		tabs.eq( visible_item ).addClass('current');
		tabs.eq( visible_item ).find('img').addClass('current');
		var img = tabs.filter('.current').find('img');
		img.attr('src', img.attr("src").replace('.png', '_green.png'));

		tabs.click(function() {
			if ($(this).hasClass('current')) {
				return false;	
			}

			slide( tabs.index( this) );
		});

		slide();
		if (options.transition_interval > 0) {
			timer = setInterval(function () {
				slide();
			}, options.transition_interval);

			if (options.pause_on_hover) {
				tabs.mouseenter(function() {
					clearInterval( timer );

				}).mouseleave(function() {
					clearInterval( timer );
					timer = setInterval(function () {
						slide();
					}, options.transition_interval);
				});
			}
		}
		
		output.mouseout(function() {  
		 	window.clearInterval(timer); 
		 	timer = setInterval(function () {
				slide();
			}, options.transition_interval);
		}).mouseover(function() {  
				if(timer!=null) window.clearInterval(timer);  
				timer=null;  
			}); 
	};
})(jQuery);