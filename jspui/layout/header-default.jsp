<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - HTML header for main home page
  --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.util.Util" %>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>

<%@ page import="org.dspace.core.Context"%>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="java.util.Locale"%>
<%@page import="org.apache.commons.lang.StringUtils"%>

<%
	Context context = null;
	context = UIUtil.obtainContext(request);
	Locale locale = context.getCurrentLocale();

    String title = (String) request.getAttribute("dspace.layout.title");
    String navbar = (String) request.getAttribute("dspace.layout.navbar");
    boolean locbar = ((Boolean) request.getAttribute("dspace.layout.locbar")).booleanValue();

    String siteName = locale.getLanguage() == "en"? ConfigurationManager.getProperty("dspace.name") : ConfigurationManager.getProperty("dspace.name.zh_CN");
    String feedRef = (String)request.getAttribute("dspace.layout.feedref");
    boolean osLink = ConfigurationManager.getBooleanProperty("websvc.opensearch.autolink");
    String osCtx = ConfigurationManager.getProperty("websvc.opensearch.svccontext");
    String osName = ConfigurationManager.getProperty("websvc.opensearch.shortname");
    List parts = (List)request.getAttribute("dspace.layout.linkparts");
    String extraHeadData = (String)request.getAttribute("dspace.layout.head");
    String extraHeadDataLast = (String)request.getAttribute("dspace.layout.head.last");
    String dsVersion = Util.getSourceVersion();
    String generator = dsVersion == null ? "DSpace" : "DSpace "+dsVersion;
    String analyticsKey = ConfigurationManager.getProperty("jspui.google.analytics.key");
    
%>

<!DOCTYPE html>
<html>
    <head>
        <title><%= siteName %>: <%= title %></title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="Generator" content="<%= generator %>" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="shortcut icon" href="<%= request.getContextPath() %>/favicon.ico" type="image/x-icon"/>
	    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/jquery-ui-1.10.3.custom/redmond/jquery-ui-1.10.3.custom.css" type="text/css" />
	    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/bootstrap.min.css" type="text/css" />
	    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/bootstrap-theme.min.css" type="text/css" />
	    <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/dspace-theme.css" type="text/css" />
<%
    if (!"NONE".equals(feedRef))
    {
        for (int i = 0; i < parts.size(); i+= 3)
        {
%>
        <link rel="alternate" type="application/<%= (String)parts.get(i) %>" title="<%= (String)parts.get(i+1) %>" href="<%= request.getContextPath() %>/feed/<%= (String)parts.get(i+2) %>/<%= feedRef %>"/>
<%
        }
    }
    
    if (osLink)
    {
%>
        <link rel="search" type="application/opensearchdescription+xml" href="<%= request.getContextPath() %>/<%= osCtx %>description.xml" title="<%= osName %>"/>
<%
    }

    if (extraHeadData != null)
        { %>
<%= extraHeadData %>
<%
        }
%>
    <%--weicf --%>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/calis/css/jquery.selectBox.css" type="text/css" />
    <link rel="stylesheet" href="<%= request.getContextPath() %>/calis/css/styles_kyxm.css" type="text/css" />
    <%--weicf --%>
        
	<script type='text/javascript' src="<%= request.getContextPath() %>/static/js/jquery/jquery-1.10.2.min.js"></script>
	<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/jquery/jquery-ui-1.10.3.custom.min.js'></script>
	<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/bootstrap/bootstrap.min.js'></script>
	<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/holder.js'></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/utils.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/static/js/choice-support.js"> </script>
    
    <script type="text/javascript" src="<%=request.getContextPath()%>/calis/js/jquery.selectBox.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/calis/js/gaoliang.js"></script>
    <%--Gooogle Analytics recording.--%>
    <%
    if (analyticsKey != null && analyticsKey.length() > 0)
    {
    %>
        <script type="text/javascript">
            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', '<%= analyticsKey %>']);
            _gaq.push(['_trackPageview']);

            (function() {
                var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
        </script>
    <%
    }
    if (extraHeadDataLast != null)
    { %>
		<%= extraHeadDataLast %>
		<%
		    }
    %>
    
<script type="text/javascript">
    function getUrlParam(name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
        var r = window.location.search.substr(1).match(reg);  //匹配目标参数
        if (r != null) return decodeURI(r[2]); return null; //返回参数值
    }
    
    function changeLanguage(lang) {
    	document.repost.locale.value=lang;
		if(getUrlParam('type') != null && getUrlParam('type') != ''){
			$('input[name=type]').val(getUrlParam('type'));
		}else{
			$('input[name=type]').prop('disabled', true);
		}
		if(getUrlParam('sort_by') != null && getUrlParam('sort_by') != ''){
			$('input[name=sort_by]').val(getUrlParam('sort_by'));
		}else{
			$('input[name=sort_by]').prop('disabled', true);
		}
		
		if (getUrlParam('order') != null
				&& getUrlParam('order') != '') {
			$('input[name=order]').val(getUrlParam('order'));
		} else {
			$('input[name=order]').prop('disabled', true);
		}
		if (getUrlParam('rpp') != null
				&& getUrlParam('rpp') != '') {
			$('input[name=rpp]').val(getUrlParam('rpp'));
		} else {
			$('input[name=rpp]').prop('disabled', true);
		}
		if (getUrlParam('etal') != null
				&& getUrlParam('etal') != '') {
			$('input[name=etal]').val(getUrlParam('etal'));
		} else {
			$('input[name=etal]').prop('disabled', true);
		}
		if (getUrlParam('null') != null
				&& getUrlParam('null') != '') {
			$('input[name=null]').val(getUrlParam('null'));
		} else {
			$('input[name=null]').prop('disabled', true);
		}
		if (getUrlParam('offset') != null
				&& getUrlParam('offset') != '') {
			$('input[name=offset]').val(getUrlParam('offset'));
		} else {
			$('input[name=offset]').prop('disabled', true);
		}
		if (getUrlParam('starts_with') != null
				&& getUrlParam('starts_with') != '') {
			$('input[name=starts_with]').val(
					getUrlParam('starts_with'));
		} else {
			$('input[name=starts_with]').prop('disabled',
					true);
		}
		if (getUrlParam('value') != null
				&& getUrlParam('value') != '') {
			$('input[name=value]').val(
					getUrlParam('value'));
		} else {
			$('input[name=value]').prop('disabled',
					true);
		}
		if (getUrlParam('id') != null
				&& getUrlParam('id') != '') {
			$('input[name=id]').val(
					getUrlParam('id'));
		} else {
			$('input[name=id]').prop('disabled',
					true);
		}
		if (getUrlParam('uid') != null
				&& getUrlParam('uid') != '') {
			$('input[name=uid]').val(
					getUrlParam('uid'));
		} else {
			$('input[name=uid]').prop('disabled',
					true);
		}
		if (getUrlParam('fullname') != null
				&& getUrlParam('fullname') != '') {
			$('input[name=fullname]').val(
					getUrlParam('fullname'));
		} else {
			$('input[name=fullname]').prop('disabled',
					true);
		}
		if (getUrlParam('action') != null
				&& getUrlParam('action') != '') {
			$('input[name=action]').val(
					getUrlParam('action'));
		} else {
			$('input[name=action]').prop('disabled',
					true);
		}
		document.repost.submit();
	}
</script>  

<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
  <script src="<%= request.getContextPath() %>/static/js/html5shiv.js"></script>
  <script src="<%= request.getContextPath() %>/static/js/respond.min.js"></script>
<![endif]-->
    </head>

    <%-- HACK: leftmargin, topmargin: for non-CSS compliant Microsoft IE browser --%>
    <%-- HACK: marginwidth, marginheight: for non-CSS compliant Netscape browser --%>
    <body class="undernavigation">
<a class="sr-only" href="#content">Skip navigation</a>
<header class="navbar navbar-inverse navbar-fixed-top <%= navbar.equals("off")?navbar:navbar.substring(navbar.lastIndexOf("/") + 1, navbar.lastIndexOf(".")) %>">  
	<div id="header_bg">
	    <%
	    if (!navbar.equals("off"))
	    {
	%>
	            <div class="container">
	                <dspace:include page="<%= navbar %>" />
	            </div>
	<%
	    }
	    else
	    {
	    	%>
	        <div class="container">
	            <dspace:include page="/layout/navbar-minimal.jsp" />
	        </div>
	<%    	
	    }
	%>
	</div>  
</header>

<main id="content" role="main">
<%-- add weicf
<div class="container banner">
	<div class="row">
		<div class="col-md-9 brand">
		<h1><fmt:message key="jsp.layout.header-default.brand.heading" /></h1>
        <fmt:message key="jsp.layout.header-default.brand.description" /> 
        </div>
        <div class="col-md-3"><img class="pull-right" src="<%= request.getContextPath() %>/image/logo.gif" alt="DSpace logo" />
        </div>
	</div>
</div>	
<br/>
add weicf --%>
                <%-- Location bar --%>
<%
    if (locbar)
    {
%>
<div class="container">
                <dspace:include page="/layout/location-bar.jsp" />
</div>                
<%
    }
%>


        <%-- Page contents --%>
<div class="container">
<% if (request.getAttribute("dspace.layout.sidebar") != null) { %>
	<div class="row">
		<div class="col-md-9">
<% } %>		
