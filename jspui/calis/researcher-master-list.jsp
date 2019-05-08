<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>

<%--
  - Display hierarchical list of researchsers
  -
  - Attributes to be passed in:
  -    researchers         - array of researchers
  // 学者的css调节
	.col2
   	.col2 img
  	.col2 img.no-picture 

  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<script src="<%=request.getContextPath()%>/calis/js/jquery.json-2.3.min.js" charset="utf-8"></script>
<script src="<%=request.getContextPath()%>/calis/js/jquery.masonry.min.js" type="text/javascript" charset="utf-8"></script>
<script src="<%=request.getContextPath()%>/calis/js/box-maker.js" type="text/javascript" charset="utf-8"></script>

<dspace:layout locbar="off" titlekey="jsp.layout.navbar-default.researchers">
<script type="text/javascript">
	$(document).ready(function(){
		$(".btn-slide").click(function(){
			$("#panel").slideToggle("slow");
			$(this).toggleClass("active"); 
			$('#left').toggleClass("active");
			$('#right').toggleClass("active");
			return false;
		});
		
	}); 
	
  $(function(){
	var $container = $('#container');
	$container.imagesLoaded( function(){
		$container.masonry({
	      itemSelector: '.box',
	      columnWidth: 100,
	      gutterWidth : 20
	    });
	});
    
  });
  
  function getResearcher(uid, name, unitId, pageSize, startRow) {
  	pageSize = pageSize%12 == 0 ? pageSize : 12 * Math.floor(pageSize/12);
  	if(unitId != '') {
  		$('#unit_id')[0].value = unitId;
  	}
  	$.ajaxSetup({ cache: false });
   	$.getJSON(
   		"<%=request.getContextPath()%>/researcher-master-list-json?action=list",
   		{pageSize:pageSize,offset:startRow,uid:uid,name:name,unitId:$('#unit_id')[0].value},
   		function(json){
   			var unitMap = json.unitMap; 
  			var list = json.researcherList;
  			var html = '';
   			$.each(list,function(i){
   				/*html += '<div class="box col' + Math.floor(Math.random()*3+1) + '">';*/
   				html += '<div class="box col2">';
   				html += '<p><a id="' + list[i].researcherId + '" href="<%=request.getContextPath()%>/researcher?id=' + list[i].researcherId + '&uid=' + list[i].uid + '&fullname=' + encodeURI(list[i].name) + '" target="_blank">' + list[i].image + '</a></p>';
   				//html += '<br/>';
   				html += '<div class="text">'
   				html += '<p><a id="' + list[i].researcherId + '" href="<%=request.getContextPath()%>/researcher?id=' + list[i].researcherId + '&uid=' + list[i].uid + '&fullname=' + encodeURI(list[i].name) + '" target="_blank">' + list[i].name + '</a> ' + list[i].title + '</p>';
   				html += '<p>' + unitMap[list[i].unitId] + '</p>';
   				// var more = list[i].field.toLowerCase().replace(/<br\/>/g, '<br>');
      	// 		html += '<p>' + more.split('<br>')[0] + '</p>';
      			html += '<p class="click"><fmt:message key="jsp.researcher.profile.click"/>：' + list[i].visit + '</p>';
      			html += '</div>';
      			html += '</div>';
    		});
    		var container = $('#container');
  			container.empty();
    		container.html(html);
		  	newElems = container.css({ opacity: 0 });                    
		  	newElems.imagesLoaded(function(){
			  	var boxes = $( boxMaker.makeBoxes() );
			    container.prepend( boxes ).masonry( 'reload' );                      
			  	newElems.animate({ opacity: 1 });                                               
		  	});
		  
		   	var total = json.total;
		   	var page_size = json.pageSize;
		   	var total_page = total%page_size == 0 ? Math.floor(total/page_size) : (Math.floor(total/page_size) + 1);
		   	var start_row = json.offset;
		   	var current_page = start_row/page_size + 1;
		   	var pagingNav = $('#paging_nav');
		   	
		   	var html_paging = '';
		   	var info1 = '<fmt:message key="jsp.researcher.profile.paging.info1" />';
		   	var info2 = '<fmt:message key="jsp.researcher.profile.paging.info2" />';
		   	var info3 = '<fmt:message key="jsp.researcher.profile.paging.info3" />';
		   	var info4 = '<fmt:message key="jsp.researcher.profile.paging.info4" />';
		   	var info5 = '<fmt:message key="jsp.researcher.profile.paging.info5" />';
		   	var info6 = '<fmt:message key="jsp.researcher.profile.paging.info6" />';
		   	var info7 = '<fmt:message key="jsp.researcher.profile.paging.info7" />';
		   	var first = '<fmt:message key="jsp.researcher.profile.paging.first" />';
		   	var last = '<fmt:message key="jsp.researcher.profile.paging.last" />';
		   	var previous = '<fmt:message key="jsp.researcher.profile.paging.previous" />';
		   	var next = '<fmt:message key="jsp.researcher.profile.paging.next" />';
		   	if(total_page == 1 || total == 0) {
		   		html_paging += '<label>' + info3 + total + info4 + '</label>, &nbsp;<label id="page_size">' + info5 + page_size + info6 + '</label>, &nbsp;';
				html_paging += info1 + total_page + info2;
				$('#right').empty();
				$('#left').empty();
		   	} else {
		   		html_paging += '<div><label>' + info3 + ' ' + total + ' ' + info4 + '</label>, <label>' + info7 + ' ' + (start_row + 1) + '-' + (start_row + ((total-start_row-1-page_size)>0?page_size:(total-start_row))) + ' ' + info4 + '</div>';
			   	if(start_row == 0){
			   		$('#right').empty();
					$('#right').html('<input id="arrow_right" type="button" alt="' + next + '" title="' + next + '" value=" " onmouseover=\'javascript: this.style.backgroundImage = "url(calis/images/right-blue.png)";\' onmouseout=\'javascript: this.style.backgroundImage = "url(calis/images/right-white.png)";\' onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + page_size + ')\'/>');
					
					for(var i = 1; i < current_page; i++) {
	   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';  
		   			}
	   				html_paging += '<a class="current-page">' + current_page + '</a>';
	   				if(total_page - current_page >= 4) {
		   				for(var i = current_page + 1; i < current_page + 5 ; i++) {
		   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';  
			   			}
	   				} else {
	   					for(var i = current_page + 1; i < (total_page + 1) ; i++) {
			   				html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>'; 
			   			}
	   				}
			   		html_paging += '<a class="control" href="javascript:void(0);" alt="' + next + '" title="' + next + '" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + page_size + ')\'>' + next + '</a>&nbsp;';
			   		html_paging += '<a class="control" href="javascript:void(0);" alt="' + last + '" title="' + last + '" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + page_size*(total_page-1) + ')\'>' + last + '</a>&nbsp;';
			   		
			   		$('#left').empty();
			   	} else {
			   		html_paging += '<a class="control" href="javascript:void(0);" alt="' + first + '" title="' + first + '" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', 0)\'>' + first + '</a>&nbsp;';
			   		html_paging += '<a class="control" href="javascript:void(0);" alt="' + previous + '" title="' + previous + '" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (start_row - page_size) + ')\'>' + previous + '</a>&nbsp;';
			   		if(current_page - 5 >= 0) {
			   			if(total_page - current_page >= 4) {
			   				for(var i = current_page-4; i < current_page; i++) {
			   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';
				   			}
			   				html_paging += '<a class="current-page">' + current_page + '</a>';
				   			for(var i = current_page+1; i < current_page + 5; i++) {
				   				html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';
				   			}
			   			} else {
			   				for(var i = current_page-4; i < current_page; i++) {
			   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';
				   			}
			   				html_paging += '<a class="current-page">' + current_page + '</a>';
			   				for(var i = current_page+1; i < (total_page + 1) ; i++) {
			   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';
				   			}
			   			}
			   		} else {
			   			if(total_page - current_page >= 4) {
			   				for(var i = 1; i < current_page; i++) {
			   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';  
				   			}
			   				html_paging += '<a class="current-page">' + current_page + '</a>';
			   				for(var i = current_page + 1; i < current_page + 5 ; i++) {
			   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';  
				   			}
			   			} else {
			   				for(var i = 1; i < current_page; i++) {
			   					html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>';  
				   			}
			   				html_paging += '<a class="current-page">' + current_page + '</a>';
			   				for(var i = current_page + 1; i < (total_page + 1) ; i++) {
				   				html_paging += '<a class="" href="javascript:void(0);" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (i-1)*page_size + ')\'>'+i+'</a>'; 
				   			}
			   			}
			   		}
			   		
			   		$('#left').empty();
			   		$('#left').html('<input id="arrow_left" type="button" alt="' + previous + '" title="' + previous + '" value=" " onmouseover=\'javascript: this.style.backgroundImage = "url(calis/images/left-blue.png)";\' onmouseout=\'javascript: this.style.backgroundImage = "url(calis/images/left-white.png)";\' onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (start_row - page_size) + ')\'/>');
			   		$('#right').empty();
			   		if(total - start_row > page_size){
			   			$('#right').empty();
			   			$('#right').html('<input id="arrow_right" type="button" alt="' + next + '" title="' + next + '" value=" " onmouseover=\'javascript: this.style.backgroundImage = "url(calis/images/right-blue.png)";\' onmouseout=\'javascript: this.style.backgroundImage = "url(calis/images/right-white.png)";\' onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (start_row + page_size) + ')\'/>');
			   			html_paging += '<a class="control" href="javascript:void(0);" alt="' + next + '" title="' + next + '" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + (start_row + page_size) + ')\'>' + next + '&nbsp;';
			   			html_paging += '<a class="control" href="javascript:void(0);" alt="' + last + '" title="' + last + '" onclick=\'getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', ' + page_size*(total_page-1) + ')\'>' + last + '</a>&nbsp;';
			   		} else {
			   			
			   		}
			   	}
			   	html_paging += '<div><label id="page_size">' + info5 + '<input type="text" id="current_pagesize" value="' + page_size + '" onkeydown=\'javascript:if(event.keyCode==13 && parseInt(this.value) <= ' + total + ' ){ getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", this.value, (parseInt($("#current_page").val()) - 1)*parseInt(this.value));}\' style="width:30px;text-align: right;"/>' + info6 + '</label>, &nbsp;';
				html_paging += '<label>' + info1 + '<input type="text" id="current_page" value="' + (start_row/page_size + 1) + '" onkeydown=\'javascript:if(event.keyCode==13 && parseInt(this.value) <= ' + total_page + '){ getResearcher("", "'+ name +'", "' + $('#unit_id').val() + '", ' + page_size + ', (parseInt(this.value) - 1)*' + page_size + ');}\' style="width:30px;text-align: right;"/>' + info2 + '</label></div>';
		   	}

			pagingNav.empty();
			pagingNav.html(html_paging);
			
			var sss = '<div class="container">';
			var i = 0;
			for(key in unitMap) {
				if(i%4 == 0) {
					sss += '<div class="row">';
				}
				sss += '<div class="col-md-3 unit-item"><a href="javascript:void(0);" onclick=\'javascript:$(".btn-slide").click();getResearcher("", "' + $("#researcher_name").val() + '", "' + key + '", 12, 0)\'>' + unitMap[key] + '</a></div>';
				if(i%4 == 3) {
					sss += '</div>';
				}
				i++;
			}
			sss += '</div>';
			$("#panel").empty();
			$("#panel").html(sss);
			
			if($("#unit_id").val() != "") {
				$("#unit_name_select").empty();
				$("#unit_name_select").html(unitMap[$("#unit_id").val()] + " X");
				$("#unit_name_select").click(function(){
					$("#unit_id").val("");
					getResearcher("", $("#researcher_name").val(), "", 12, 0);
				});
				$("#unit_name_select").css("display", "block");
			} else {
				$("#unit_name_select").empty();
				$("#unit_name_select").css("display", "none");
			}
		});
   	
   	  $('#arrow_left').mouseover(function(){
		  $("#arrow_left").css("background",'url("images/left-blue.png")');
	  });
	  
	  $('#arrow_left').mouseout(function(){
		  $("#arrow_left").css("background",'url("images/left-white.png")');
	  });
  }
  
  function findResearcherByName() {
	  if($("#researcher_name").val() == "") {
		  return;
	  }
	  
	  var name = $("#researcher_name").val();
	  getResearcher("", name, $('#unit_id').val(), 12, 0);
  }
  
  function visitResearcher(a_ctrl, uid, name) {
    if(a_ctrl.href == 'javascript:void(0);'){
	    var id = a_ctrl.id;
	    a_ctrl.href = '<%=request.getContextPath()%>/researcher?action=visit&id=' + id + '&uid=' + uid + '&fullname=' + encodeURI(name);	
  	}
  }
  
</script>

	<div id="unit">
		<div id="panel"></div>
		<p class="master">
			<a class="btn-slide-style" href="<%=request.getContextPath()%>/researcher-master-list">学者大师</a>
		</p><p class="leader">
			<a class="btn-slide-style" href="<%=request.getContextPath()%>/researcher-leader-list">学科带头人</a>
		</p><p class="cadre">
			<a class="btn-slide-style" href="<%=request.getContextPath()%>/researcher-cadre-list">骨干教师</a>
		</p><p class="cultivation">
			<a class="btn-slide-style" href="<%=request.getContextPath()%>/researcher-cultivation-list">骨干教师培养对象</a>
		</p>
		<p class="slide">
			<a class="btn-slide" href="javascript:void(0);"><fmt:message
					key="jsp.home.researcher.browse.unit" /></a>
		</p>
		<div id="unit_name_select"  class="unit_name_select_style"></div>
		<div class="search-form">
			<input type="text" class="form-control researcher-query-box" placeholder='<fmt:message key="jsp.home.researcher.browse.search.input"/>' id="researcher_name" onkeypress="if(event.keyCode==13) {findResearcherByName();return false;}" /> 
			<input type="button" class="btn btn-primary btn-resarcher-search" onclick="findResearcherByName()" value='<fmt:message key="jsp.home.researcher.browse.search.button"/>' /> 
			<input type="button" class="btn btn-primary btn-resarcher-search" onclick='javascript:$("#researcher_name").val("");getResearcher("", "", $("#unit_id").val(), 12, 0);' value='<fmt:message key="jsp.home.researcher.browse.clear"/>' />
		</div>
	</div>
	<div>
		<input type="hidden" id="unit_id" />
	</div>
	<div id="test"></div>
	<div id="masonry">
		<div id="left" class="left"></div>
		<div id="right" class="right"></div>
		<div id="container" class="clearfix"></div>
	</div>
	<div id="paging_nav"></div>
	
<script type="text/javascript">
	if (document.all && document.body.readyState == "complete") {
		getResearcher("", "", "", 12, 0);
	} else {
		getResearcher("", "", "", 12, 0);
	}
	// $("#panel").slideToggle("slow");
	$(".btn-slide").toggleClass("active");
	setTimeout(function(){
		// $("#panel").slideToggle("slow");
		$(".btn-slide").toggleClass("active");
	},1500);
	</script>
</dspace:layout>
