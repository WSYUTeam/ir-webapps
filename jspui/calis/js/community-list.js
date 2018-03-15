/**
 * 
 */
function communityList(ctxPath,comID,label,noajax) {
		
	if(noajax){
		$("#com_id")[0].value = comID;
	} else {
		if($.isNumeric(comID)) {
			jQuery.ajax({
				url: ctxPath + "/eperson-community",
				type: "post",
				data: {
					action : "getSubCommunity",
					com_id : comID
				},
				dataType: "json",
				success: function(data) {
					var rs = data;
					if(rs.has_sub){
						var sub = $("#sub_community");
						var html = "<select onchange='communityList(\"" + ctxPath + "\", this[selectedIndex].value, \"" + label + "\")'>";
						html += "<option value=''>" + label + "</option>";
						var list = rs.subCommunity;
						for(var i = 0; i < list.length; i++) {
							html += "<option value='" + list[i].id + "'>" + list[i].name + "</option>";
						}
						html += "</select>";
						sub[0].innerHTML = html;
					} else {
						$("#com_id")[0].value = rs.comID;
					}
				}
			});
		}
	}
}

function checkData(msg,msg2){
	if($('#community_id')[0].value == '/'){
		alert(msg);
		return false;
	}	
	if($("#com_id")[0].value == ''){
		alert(msg);
		return false
	}
	if($("#temail")[0].value == ''){
		alert(msg2);
		return false;
	} else {
		if(!isEmail($("#temail")[0].value)){
			alert(msg2);
			return false;
		}
	}
	
	return true;
}

function isEmail(strEmail) {
	if (strEmail
			.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1) {
		return true;
	} else {
		return false;
	}

}
