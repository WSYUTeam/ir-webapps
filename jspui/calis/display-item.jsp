<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Renders a whole HTML page for displaying item metadata.  Simply includes
  - the relevant item display component in a standard HTML page.
  -
  - Attributes:
  -    display.all - Boolean - if true, display full metadata record
  -    item        - the Item to display
  -    collections - Array of Collections this item appears in.  This must be
  -                  passed in for two reasons: 1) item.getCollections() could
  -                  fail, and we're already committed to JSP display, and
  -                  2) the item might be in the process of being submitted and
  -                  a mapping between the item and collection might not
  -                  appear yet.  If this is omitted, the item display won't
  -                  display any collections.
  -    admin_button - Boolean, show admin 'edit' button
  --%>

<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.mortbay.util.UrlEncoded"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.handle.HandleManager" %>
<%@ page import="org.dspace.license.CreativeCommons" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@ page import="org.dspace.versioning.Version"%>
<%@ page import="org.dspace.core.Context"%>
<%@ page import="org.dspace.app.webui.util.VersionUtil"%>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.authorize.AuthorizeManager"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Date"%>
<%@ page import="org.dspace.core.Constants"%>
<%@ page import="org.dspace.eperson.EPerson"%>
<%@ page import="org.dspace.versioning.VersionHistory"%>

<%@ page import="org.apache.commons.lang3.time.DateUtils"%>

<%@ page import="pt.uminho.dsi.util.*"%>
<%@ page import="edu.calis.ir.pku.util.*"%>
<%
    // Attributes
    Boolean displayAllBoolean = (Boolean) request.getAttribute("display.all");
    boolean displayAll = (displayAllBoolean != null && displayAllBoolean.booleanValue());
    Boolean suggest = (Boolean)request.getAttribute("suggest.enable");
    boolean suggestLink = (suggest == null ? false : suggest.booleanValue());
    Item item = (Item) request.getAttribute("item");
    Collection[] collections = (Collection[]) request.getAttribute("collections");
    Boolean admin_b = (Boolean)request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    
    // get the workspace id if one has been passed
    Integer workspace_id = (Integer) request.getAttribute("workspace_id");

    // get the handle if the item has one yet
    String handle = item.getHandle();

    // CC URL & RDF
    String cc_url = CreativeCommons.getLicenseURL(item);
    String cc_rdf = CreativeCommons.getLicenseRDF(item);

    // Full title needs to be put into a string to use as tag argument
    String title = "";
    if (handle == null)
 	{
		title = "Workspace Item";
	}
	else 
	{
		Metadatum[] titleValue = item.getDC("title", null, Item.ANY);
		if (titleValue.length != 0)
		{
			title = titleValue[0].value;
		}
		else
		{
			title = "Item " + handle;
		}
	}
    
    Boolean versioningEnabledBool = (Boolean)request.getAttribute("versioning.enabled");
    boolean versioningEnabled = (versioningEnabledBool!=null && versioningEnabledBool.booleanValue());
    Boolean hasVersionButtonBool = (Boolean)request.getAttribute("versioning.hasversionbutton");
    Boolean hasVersionHistoryBool = (Boolean)request.getAttribute("versioning.hasversionhistory");
    boolean hasVersionButton = (hasVersionButtonBool!=null && hasVersionButtonBool.booleanValue());
    boolean hasVersionHistory = (hasVersionHistoryBool!=null && hasVersionHistoryBool.booleanValue());
    
    Boolean newversionavailableBool = (Boolean)request.getAttribute("versioning.newversionavailable");
    boolean newVersionAvailable = (newversionavailableBool!=null && newversionavailableBool.booleanValue());
    Boolean showVersionWorkflowAvailableBool = (Boolean)request.getAttribute("versioning.showversionwfavailable");
    boolean showVersionWorkflowAvailable = (showVersionWorkflowAvailableBool!=null && showVersionWorkflowAvailableBool.booleanValue());
    
    String latestVersionHandle = (String)request.getAttribute("versioning.latestversionhandle");
    String latestVersionURL = (String)request.getAttribute("versioning.latestversionurl");
    
    VersionHistory history = (VersionHistory)request.getAttribute("versioning.history");
    List<Version> historyVersions = (List<Version>)request.getAttribute("versioning.historyversions");
    
    boolean is_cited_interface = ConfigurationManager.getBooleanProperty("webui.item.display.cited.interface");
	boolean isSame = true;
	if(is_cited_interface && ConfigurationManager.getBooleanProperty("webui.item.display.cited.frequene.day")) {
		isSame = false;//DateUtils.isSameDay(item.getLastModified(), new Date());	
	} else {
		isSame = PKUUtils.isSameWeekDates(item.getLastModified(), new Date());
	}
    Context context = Utility.obtainNewContext(request);
    int visits = PKUUtils.getItemVisits(context, item);
    int likes = PKUUtils.getItemLikes(context, item);
	int downloads = PKUUtils.getItemDownloads(context, item);
	int cited_sci = 0;
	Metadatum[] mdCitedbysci = item.getMetadata("dc", "description", "citedbysci", Item.ANY);
	if(mdCitedbysci != null && mdCitedbysci.length > 0){
		cited_sci = Integer.parseInt(mdCitedbysci[0].value);
	}
	
	String url = "";
	Metadatum[] mdSCIuri = item.getMetadata("dc", "description", "uri", Item.ANY);
	if(mdSCIuri != null && mdSCIuri.length > 0){
		url = mdSCIuri[0].value;
	}
	
	String doi = "";
	Metadatum[] mddoi = item.getMetadata("dc", "identifier", "doi", Item.ANY);
	if(mddoi != null && mddoi.length > 0){
		doi = mddoi[0].value;
	}

%>
<% //out.print(doi); %>
<%@page import="org.dspace.app.webui.servlet.MyDSpaceServlet"%>

<script type="text/javascript" src="<%=request.getContextPath() %>/calis/js/raphael-min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/calis/js/g.raphael.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/calis/js/g.pie.js"></script>

<script type="text/javascript" charset="utf-8">
var r_alt;

function iLikeIt(hdl) {
	var aj = $.ajax({    
 	    url: '<%=request.getContextPath() %>/like',
 	    data: { hdl:escape(hdl) },
 	    type:'get',  
 	   	cache:false,
 	    dataType:'json',    
 	    success:function(data) {
 	    	if(data!=null) {
 	    		if(data.success) {
 	    			var ss = $('.likes').html().replace('[','').replace(']','');
 	    			$('.likes').empty();
 	    			$('.likes').html('[' + (parseInt(ss) + 1) + ']');
 	    			
 	    			var views = <%=visits %>;
 	    			var downloads = <%=downloads %>;
 	    			var likes = parseInt(ss) + 1;
 	    			
 	    			if((views+downloads+likes) != 0 ) {
 	    				// Creates canvas 640 x 480 at 10, 50
 	    			    r_alt.clear();
 	    			
 	    			    // Creates donut chart with center at 320, 200,
 	    			    // radius 100 and data: [55, 20, 13, 32, 5, 1, 2]
 	    			    
 	    			    var pie;
 	    			    if((views+downloads) == 0) {
 	    			    	pie = r_alt.piechart(120, 120, 100, [likes], {donut : true, legend: [likes + ' ' + '<fmt:message key="jsp.display-item.altmetrics.likes" />'], legendpos: "south"});
 	    			    } else if((views+likes) == 0){
 	    			    	pie = r_alt.piechart(120, 120, 100, [downloads], {donut : true, legend: [downloads + ' ' + '<fmt:message key="jsp.display-item.altmetrics.downloads" />'], legendpos: "south"});
 	    			    } else if((downloads+likes) == 0){
 	    			    	pie = r_alt.piechart(120, 120, 100, [views], {donut : true, legend: [views + ' ' + '<fmt:message key="jsp.display-item.altmetrics.views" />'], legendpos: "south"});
 	    			    } else { 
 	    			    	pie = r_alt.piechart(120, 120, 100, [views, downloads, likes], {donut : true, legend: [views + ' ' + '<fmt:message key="jsp.display-item.altmetrics.views" />', downloads + ' ' + '<fmt:message key="jsp.display-item.altmetrics.downloads" />', likes + ' ' + '<fmt:message key="jsp.display-item.altmetrics.likes" />'], legendpos: "south"});
 	    			    }
 	    			    
 	    			   r_alt.text(120, 100, '<fmt:message key="jsp.display-item.altmetrics.title" />').attr({ font: "20px sans-serif" });
 	    		        
 	    			    pie.hover(function () {
 	    			        var that = this.sector;
 	    			        this.sector.stop();
 	    			        this.sector.scale(1.1, 1.1, this.cx, this.cy);
 	    			
 	    			        pie.each(function() {
 	    			           if(this.sector.id === that.id) {
 	    			               //console.log(pie);
 	    			               //tooltip = r_alt.text(320, 240, this.sector.value.value).attr({"font-size": 35, "fill":"#000"});
 	    			           }
 	    			        });
 	    			
 	    			        if (this.label) {
 	    			            this.label[0].stop();
 	    			            this.label[0].attr({ r: 7.5 });
 	    			            this.label[1].attr({ "font-weight": 800 });
 	    			        }
 	    			    }, function () {
 	    			        this.sector.animate({ transform: 's1 1 ' + this.cx + ' ' + this.cy }, 500, "bounce");
 	    			        //tooltip.remove();
 	    			
 	    			        if (this.label) {
 	    			            this.label[0].animate({ r: 5 }, 500, "bounce");
 	    			            this.label[1].attr({ "font-weight": 400 });
 	    			        }
 	    			    });
 	    			}
 	    		} else {
 	    			alert('<fmt:message key="jsp.display-item.alert.1"/>');
 	    		}
 	    	}
 	    },
 	   error: function() {
 		   
 	   }
	});
}

$(document).ready(function () {
	$('.dc-title').parent().find('.metadataFieldLabel').remove();
	$('.dc-title').attr('colspan', '2');

	$('#baiduLink').attr('href', "http://xueshu.baidu.com/s?=&=&wd=" + encodeURI('"' + $('.dc-title').html() + '"') + "&tn=SE_baiduxueshu_c1gjeupa&bs=&ie=utf-8&sc_f_para=sc_tasktype%3D%7BfirstAdvancedSearch%7D&sc_from=&sc_as_para=");
	$('#cnkiLink').attr('href', "http://kns.cnki.net/kns/brief/Default_Result.aspx?code=SCDB&kw=" + encodeURI('' + $('.dc-title').html() + '') + "");//&korder=0&sel=1
	$('#chaoxingLink').attr('href', "http://jour.duxiu.com/searchJour?sw=" + encodeURI('' + $('.dc-title').html() + '') + "&channel=searchJour&bCon=&ecode=utf-8&searchtype=&Field=1");
	$('.dc-title').append('<a href="javascript:void(0);" onclick=\'iLikeIt("<%=handle%>")\'><img width="32" src="<%=request.getContextPath() %>/calis/images/like.png"></a><span class="likes">[<%=likes %>]</span>');
	
	var views = <%=visits %>;
	var downloads = <%=downloads %>;
	var likes = <%=likes %>;
	
	if((views+downloads+likes) != 0 ) {
		// Creates canvas 640 x 480 at 10, 50
	    r_alt = Raphael("altmetrics");
	
	    // Creates donut chart with center at 320, 200,
	    // radius 100 and data: [55, 20, 13, 32, 5, 1, 2]
	    
	    var pie;
	    if((views+downloads) == 0) {
	    	pie = r_alt.piechart(120, 120, 100, [likes], {donut : true, legend: [likes + ' ' + '<fmt:message key="jsp.display-item.altmetrics.likes" />'], legendpos: "south"});
	    } else if((views+likes) == 0){
	    	pie = r_alt.piechart(120, 120, 100, [downloads], {donut : true, legend: [downloads + ' ' + '<fmt:message key="jsp.display-item.altmetrics.downloads" />'], legendpos: "south"});
	    } else if((downloads+likes) == 0){
	    	pie = r_alt.piechart(120, 120, 100, [views], {donut : true, legend: [views + ' ' + '<fmt:message key="jsp.display-item.altmetrics.views" />'], legendpos: "south"});
	    } else { 
	    	pie = r_alt.piechart(120, 120, 100, [views, downloads, likes], {donut : true, legend: [views + ' ' + '<fmt:message key="jsp.display-item.altmetrics.views" />', downloads + ' ' + '<fmt:message key="jsp.display-item.altmetrics.downloads" />', likes + ' ' + '<fmt:message key="jsp.display-item.altmetrics.likes" />'], legendpos: "south"});
	    }
	
	    r_alt.text(120, 100, '<fmt:message key="jsp.display-item.altmetrics.title" />').attr({ font: "20px sans-serif" });
	        
	    pie.hover(function () {
	        var that = this.sector;
	        this.sector.stop();
	        this.sector.scale(1.1, 1.1, this.cx, this.cy);
	
	        pie.each(function() {
	           if(this.sector.id === that.id) {
	               //console.log(pie);
	               //tooltip = r_alt.text(320, 240, this.sector.value.value).attr({"font-size": 35, "fill":"#000"});
	           }
	        });
	
	        if (this.label) {
	            this.label[0].stop();
	            this.label[0].attr({ r: 7.5 });
	            this.label[1].attr({ "font-weight": 800 });
	        }
	    }, function () {
	        this.sector.animate({ transform: 's1 1 ' + this.cx + ' ' + this.cy }, 500, "bounce");
	        //tooltip.remove();
	
	        if (this.label) {
	            this.label[0].animate({ r: 5 }, 500, "bounce");
	            this.label[1].attr({ "font-weight": 400 });
	        }
	    });
	}
	
	if(<%=is_cited_interface %> && !<%=isSame %>) {
		var aj = $.ajax({    
	 	    url: '<%=request.getContextPath() %>/cited-retrieve',
	 	    data: { item_id:<%=item.getID() %> },
	 	    type:'get',    
	 	    cache:true,    
	 	    dataType:'json',    
	 	    success:function(data) {
	 	    	if(data.flag != null && !data.flag) {
	 	    		$('#sci').css('display', 'none');
	 	    	} else {
		 	    	if(data.citedbysci == 0) {
		 	    		$('#wos-counter-view').html('<%=cited_sci %>');
		 	    	} else {
		 	    		$('#wos-counter-view').html(data.citedbysci);
		 	    	}
		 	    	$('#sci a').attr('href', data.sourceurl);
	 	    	}
	 	    },
	 	    error: function() {
	 	    	$('#wos-counter-view').html('<%=cited_sci %>');
	 	    	$('#sci a').attr('href', '<%=url %>');
	 	   	}
	 	});
	} else {
		$('#wos-counter-view').html('<%=cited_sci %>');
	    $('#sci a').attr('href', '<%=url %>');
	}
});
</script>

<dspace:layout locbar="off" title="<%= title %>">
<%
if (displayAll)
{
%>
<div class="col-md-12 display-item-details">	
<%	
} else {
%>
<div class="col-md-<%=admin_button?"8":"9" %> display-item-details">
<%
}
    if (handle != null)
    {
%>

		<%		
		if (newVersionAvailable)
		   {
		%>
		<div class="alert alert-warning"><b><fmt:message key="jsp.version.notice.new_version_head"/></b>		
		<fmt:message key="jsp.version.notice.new_version_help"/><a href="<%=latestVersionURL %>"><%= latestVersionHandle %></a>
		</div>
		<%
		    }
		%>
		
		<%		
		if (showVersionWorkflowAvailable)
		   {
		%>
		<div class="alert alert-warning"><b><fmt:message key="jsp.version.notice.workflow_version_head"/></b>		
		<fmt:message key="jsp.version.notice.workflow_version_help"/>
		</div>
		<%
		    }
		%>
		
<%
        if (admin_button)  // admin edit button
        { %>
        <dspace:sidebar>
            <div class="panel panel-warning">
            	<div class="panel-heading"><fmt:message key="jsp.admintools"/></div>
            	<div class="panel-body">
                <form method="get" action="<%= request.getContextPath() %>/tools/edit-item">
                    <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                    <%--<input type="submit" name="submit" value="Edit...">--%>
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.edit.button"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath() %>/mydspace">
                    <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_EXPORT_ARCHIVE %>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.mydspace.request.export.item"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath() %>/mydspace">
                    <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_MIGRATE_ARCHIVE %>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.mydspace.request.export.migrateitem"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath() %>/dspace-admin/metadataexport">
                    <input type="hidden" name="handle" value="<%= item.getHandle() %>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.metadataexport.button"/>" />
                </form>
					<% if(hasVersionButton) { %>       
                	<form method="get" action="<%= request.getContextPath() %>/tools/version">
                    	<input type="hidden" name="itemID" value="<%= item.getID() %>" />                    
                    	<input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.version.button"/>" />
                	</form>
                	<% } %> 
                	<% if(hasVersionHistory) { %>			                
                	<form method="get" action="<%= request.getContextPath() %>/tools/history">
                    	<input type="hidden" name="itemID" value="<%= item.getID() %>" />
                    	<input type="hidden" name="versionID" value="<%= history.getVersion(item)!=null?history.getVersion(item).getVersionId():null %>" />                    
                    	<input class="btn btn-info col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.version.history.button"/>" />
                	</form>         	         	
					<% } %>
             </div>
          </div>
        </dspace:sidebar>
<%      } %>

<%
    }

    String displayStyle = (displayAll ? "full" : "");
%>
	<dspace:item-preview item="<%= item %>" />
   	<dspace:item item="<%= item %>" collections="<%= collections %>" style="<%= displayStyle %>" />
</div>
<div class="media baidu" style="padding:10px;margin-top: 0;">
	<!-- <div class="media-body text-center" id="baiduCitedResult"> -->
		<h4>&nbsp; &nbsp;<b><!-- 参考搜索 --><fmt:message key="jsp.display-item.baidu"/></b></h4>
	<!-- </div> -->
	<div class="" style="text-indent : 40px;"><!-- text-center -->
		<span class="metric-counter"><h4 class="media-heading"><a id="cnkiLink" href="" title="See more details" target="_blank" data-toggle="tooltip" data-original-title="See more details"><img src="../../calis/images/cnki1.png" style="width: 90px;" ><!-- CNKI™查看 --></a></h4></span>
		<p>
		<span class="metric-counter"><h4 class="media-heading"><a id="chaoxingLink" href="" title="See more details" target="_blank" data-toggle="tooltip" data-original-title="See more details"><img src="../../calis/images/cx1.png" style="width: 90px;" ><!-- 超星™查看 --></a></h4></span>
		<p>
		<span class="metric-counter"><h4 class="media-heading"><a id="baiduLink" href="" title="See more details" target="_blank" data-toggle="tooltip" data-original-title="See more details"><!-- 百度学术™<fmt:message key="jsp.display-item.baidu"/> --><img src="../../calis/images/bd1.png" style="width: 90px;" ></a></h4></span>

	</div>
</div>
<br/>
<%
if (displayAll)
{
%>
<div class="col-md-12 display-item-sidebar">	
<%	
} else {
%>
<div class="col-md-<%=admin_button?"4":"3" %> display-item-sidebar">
<%
}
	PKUUtils.listBitstreams(pageContext, item);
%>
<div id="altmetrics" style="display:none;"></div>
<%
	if(ConfigurationManager.getBooleanProperty("webui.item.display.cited.interface")) {
%>
<div id="sci" class="media wos">
	<div class="media-body text-center" id="wosCitedResult">
		<h4 class="media-heading">Web of Science®</h4>
	</div>
	<br/>
	<div class="text-center">
		<a href="" target="_blank" title="See more details" data-toggle="tooltip" data-original-title="See more details">
			<span class="metric-counter" id="wos-counter-view">
			<%=cited_sci %>
			</span>
		</a>
	</div>
	<br/>
	<div class="row">
		<div class="col-lg-12 text-center small">
					<fmt:message key="jsp.display-item.wos.tip1"/>
		</div>
	</div>
</div>
<br/>
<%
	}
if(!doi.equals("")) {
	String scopusApiKey = ConfigurationManager.getProperty("webui.item.display.scopus.apikey");
	if(StringUtils.isNotEmpty(scopusApiKey)) {
%>
<div class="media scopus">
	<div class="media-body text-center" id="scopusCitedResult">
		<h4 class="media-heading">Scopus®</h4>
	</div>
	<br/>
	<div class="text-center">
	<iframe width="199" height="25" frameborder="no" border="0" marginwidth="0" marginheight="0" scrolling="no" allowtransparency="yes" src="http://api.elsevier.com/content/abstract/citation-count?doi=<%=doi %>&httpAccept=text/html&apiKey=<%=ConfigurationManager.getProperty("webui.item.display.scopus.apikey") %>"></iframe>
	</div>
	<br/>
	<div class="row">
		<div class="col-lg-12 text-center small">
					<fmt:message key="jsp.display-item.scopus.tip1"/>
		</div>
	</div>
</div>
<br/>
<%
	}
%>
<div class="media google">
	<div class="media-body text-center" id="googleCitedResult">
		<h4 class="media-heading">Google Scholar™</h4>
	</div>
	<br/>
	<div class="text-center">
	<span class="metric-counter"><a href="http://scholar.google.com/scholar?q=<%=UrlEncoded.encodeString("doi:\""+doi+"\"") %>" title="See more details" target="_blank" data-toggle="tooltip" data-original-title="See more details"><fmt:message key="jsp.display-item.google"/></a></span>
	</div>
</div>
<br/>
<%
}
%>

<br/>
<div class="container row item-operators" <%=displayAll?"style='text-align:unset;'":"" %>>
<%
    String locationLink = request.getContextPath() + "/handle/" + handle;

    if (displayAll)
    {
%>
<%
        if (workspace_id != null)
        {
%>
    <form class="col-md-2" method="post" action="<%= request.getContextPath() %>/view-workspaceitem">
        <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue() %>" />
        <input class="btn btn-default" type="submit" name="submit_simple" value="<fmt:message key="jsp.display-item.text1"/>" />
    </form>
<%
        }
        else
        {
%>
    <a class="btn btn-default" href="<%=locationLink %>?mode=simple" style="display: none;">
        <fmt:message key="jsp.display-item.text1"/>
    </a>
<%
        }
%>
<%
    }
    else
    {
%>
<%
        if (workspace_id != null)
        {
%>
    <form class="col-md-12" method="post" action="<%= request.getContextPath() %>/view-workspaceitem">
        <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue() %>" />
        <input class="btn btn-default" type="submit" name="submit_full" value="<fmt:message key="jsp.display-item.text2"/>" />
    </form>
<%
        }
        else
        {
%>
    <a class="btn btn-default" href="<%=locationLink %>?mode=full" style="display: none;">
        <fmt:message key="jsp.display-item.text2"/>
    </a>
<%
        }
    }

    if (workspace_id != null)
    {
%>
	<br/>
   <form class="col-md-12" method="post" action="<%= request.getContextPath() %>/workspace">
        <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue() %>"/>
        <input class="btn btn-primary" type="submit" name="submit_open" value="<fmt:message key="jsp.display-item.back_to_workspace"/>"/>
    </form>

<%
    } else {

		if (suggestLink)
        {
%>
    <a class="btn btn-success" href="<%= request.getContextPath() %>/suggest?handle=<%= handle %>" target="new_window" style="display: none;">
       <fmt:message key="jsp.display-item.suggest"/></a>
<%
        }
%>

<a class="statisticsLink  btn btn-primary" href="<%= request.getContextPath() %>/handle/<%= handle %>/statistics"><fmt:message key="jsp.display-item.display-statistics"/></a>

    <%-- SFX Link --%>
<%
    if (ConfigurationManager.getProperty("sfx.server.url") != null)
    {
        String sfximage = ConfigurationManager.getProperty("sfx.server.image_url");
        if (sfximage == null)
        {
            sfximage = request.getContextPath() + "/image/sfx-link.gif";
        }
%>
        <a style="display: none;" class="btn btn-default" href="<dspace:sfxlink item="<%= item %>"/>" /><img src="<%= sfximage %>" border="0" alt="SFX Query" /></a>
<%
    }
    }
%>
</div>
<br/>
    <%-- Versioning table --%>
<%
    if (versioningEnabled && hasVersionHistory)
    {
        boolean item_history_view_admin = ConfigurationManager
                .getBooleanProperty("versioning", "item.history.view.admin");
        if(!item_history_view_admin || admin_button) {         
%>
	<div id="versionHistory" class="panel panel-info">
	<div class="panel-heading"><fmt:message key="jsp.version.history.head2" /></div>
	
	<table class="table panel-body">
		<tr>
			<th id="tt1" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column1"/></th>
			<th 			
				id="tt2" class="oddRowOddCol"><fmt:message key="jsp.version.history.column2"/></th>
			<th 
				 id="tt3" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column3"/></th>
			<th 
				
				id="tt4" class="oddRowOddCol"><fmt:message key="jsp.version.history.column4"/></th>
			<th 
				 id="tt5" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column5"/> </th>
		</tr>
		
		<% for(Version versRow : historyVersions) {  
		
			EPerson versRowPerson = versRow.getEperson();
			String[] identifierPath = VersionUtil.addItemIdentifier(item, versRow);
		%>	
		<tr>			
			<td headers="tt1" class="oddRowEvenCol"><%=versRow.getVersionNumber() %></td>
			<td headers="tt2" class="oddRowOddCol"><a href="<%=request.getContextPath() + identifierPath[0] %>"><%=identifierPath[1] %></a><%=item.getID()==versRow.getItemID()?"<span class=\"glyphicon glyphicon-asterisk\"></span>":""%></td>
			<td headers="tt3" class="oddRowEvenCol"><% if(admin_button) { %><a
				href="mailto:<%=versRowPerson.getEmail() %>"><%=versRowPerson.getFullName() %></a><% } else { %><%=versRowPerson.getFullName() %><% } %></td>
			<td headers="tt4" class="oddRowOddCol"><%=versRow.getVersionDate() %></td>
			<td headers="tt5" class="oddRowEvenCol"><%=versRow.getSummary() %></td>
		</tr>
		<% } %>
	</table>
	<div class="panel-footer"><fmt:message key="jsp.version.history.legend"/></div>
	</div>
<%
        }
    }
%>
<br/>
    <%-- Create Commons Link --%>
<%
    if (cc_url != null)
    {
%>
    <p class="submitFormHelp alert alert-info"><fmt:message key="jsp.display-item.text3"/> <a href="<%= cc_url %>"><fmt:message key="jsp.display-item.license"/></a>
    <a href="<%= cc_url %>"><img src="<%= request.getContextPath() %>/image/cc-somerights.gif" border="0" alt="Creative Commons" style="margin-top: -5px;" class="pull-right"/></a>
    </p>
    <!--
    <%= cc_rdf %>
    -->
<%
    } else {
%>
    <p class="submitFormHelp alert alert-info"><fmt:message key="jsp.display-item.copyright"/></p>
<%
    } 
%>   
<code><%//= HandleManager.getCanonicalForm(handle) %></code></div>
<%//= item.getID() %>
</div>
</dspace:layout>
