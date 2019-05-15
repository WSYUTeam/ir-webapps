<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Default navigation bar
--%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="java.util.Map" %>
<%
    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Is the logged in user an admin
    Boolean admin = (Boolean)request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf( '?' );
    if( c > -1 )
    {
        currentPage = currentPage.substring( 0, c );
    }

    // E-mail may have to be truncated
    String navbarEmail = null;

    if (user != null)
    {
        navbarEmail = user.getEmail();
    }
    
    // get the browse indices
    
	BrowseIndex[] bis = BrowseIndex.getBrowseIndices();
    BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
    String browseCurrent = "";
    if (binfo != null)
    {
        BrowseIndex bix = binfo.getBrowseIndex();
        // Only highlight the current browse, only if it is a metadata index,
        // or the selected sort option is the default for the index
        if (bix.isMetadataIndex() || bix.getSortOption() == binfo.getSortOption())
        {
            if (bix.getName() != null)
    			browseCurrent = bix.getName();
        }
    }
 // get the locale languages
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);
%>

	   <div id="new_top">
	   	<a href="http://irt.wsyu.edu.cn/" style="color: white;">本库首页</a> &nbsp; &nbsp; 
	   	<a href="http://www.wsyu.edu.cn/" style="color: white;">学校主页</a>
	   	<!-- 登录-->
	   	<div class="nav navbar-nav navbar-right">
			<ul class="nav navbar-nav navbar-right">
	         <li class="dropdown">
	         <%
	    if (user != null)
	    {
			%>
			<a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <fmt:message key="jsp.layout.navbar-default.loggedin">
			      <fmt:param><%= StringUtils.abbreviate(navbarEmail, 20) %></fmt:param>
			  </fmt:message> <b class="caret"></b></a>
			<%
	    } else {
			%>
	             <a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <fmt:message key="jsp.layout.navbar-default.sign"/> <b class="caret"></b></a>
		<% } %>             
	             <ul class="dropdown-menu">
	               <li><a href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a></li>
	               <li><a href="<%= request.getContextPath() %>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a></li>
	               <%-- 
	               <li><a href="<%= request.getContextPath() %>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a></li>
	               --%>

			<%
			  if (isAdmin)
			  {
			%>
				   <li class="divider"></li>  
	               <li><a href="<%= request.getContextPath() %>/dspace-admin"><fmt:message key="jsp.administer"/></a></li>
			<%
			  }
			  if (user != null) {
			%>
			<li><a href="<%= request.getContextPath() %>/logout"><span class="glyphicon glyphicon-log-out"></span> <fmt:message key="jsp.layout.navbar-default.logout"/></a></li>
			<% } %>
	             </ul>
	           </li>
	          </ul>
	          
		<%-- Search Box --%>
		<%--weicf <form method="get" action="<%= request.getContextPath() %>/simple-search" class="navbar-form navbar-right">
		    <div class="form-group">
	          <input type="text" class="form-control" placeholder="<fmt:message key="jsp.layout.navbar-default.search"/>" name="query" id="tequery" size="25"/>
	        </div>
	        <button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span></button>
	<%--               <br/><a href="<%= request.getContextPath() %>/advanced-search"><fmt:message key="jsp.layout.navbar-default.advanced"/></a>
	<%
				if (ConfigurationManager.getBooleanProperty("webui.controlledvocabulary.enable"))
				{
	%>        
	              <br/><a href="<%= request.getContextPath() %>/subject-search"><fmt:message key="jsp.layout.navbar-default.subjectsearch"/></a>
	<%
	            }
	%> --%>
		<%--weicf</form>--%>
		
		</div>
	   	<!--中英文切换-->
	   		<% if (supportedLocales != null && supportedLocales.length > 1)
	     {
	 %>
	    <div class="nav navbar-nav navbar-right navbar-right-language">
	    	<ul class="nav navbar-nav">
      		<li class="">
	 <%   for (int i = 0; i < supportedLocales.length; i++)
	     {
		 if(i!=0)out.print("|");
	 %>
	        <a style="display: inline-block;" onclick="changeLanguage('<%=supportedLocales[i].toString()%>')" href="javascript:void(0);">
	         <%= supportedLocales[i].getDisplayLanguage(supportedLocales[i])%>
	       </a>
	 <%
	     }
	 %>
	 		</li>
	 		</ul>
	 		<form method="get" name="repost" action="">
		   		<input type="hidden" name="type" />
		   		<input type="hidden" name="sort_by" />
		   		<input type="hidden" name="order" />
		   		<input type="hidden" name="rpp" />
		   		<input type="hidden" name="etal" />	
		   		<input type="hidden" name="null" />
		   		<input type="hidden" name="offset" />
		   		<input type="hidden" name="starts_with" />
		   		<input type="hidden" name="value" />
				<input type="hidden" name="locale" />
				<input type="hidden" name="id" />
				<input type="hidden" name="uid" />
				<input type="hidden" name="fullname" />
				<input type="hidden" name="action" />
			</form>
		  </div>
		 <%
		   }
		 %>
	   </div>  
       <div class="navbar-header">
         <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
         </button>
         <a href="<%=request.getContextPath() %>/" class="navbar-brand"><img height="73" width="449" alt="calis logo" src="<%=request.getContextPath() %>/calis/images/logo-title.png"></a>
       </div>
       <nav class="collapse navbar-collapse bs-navbar-collapse navbar-collapse-default" role="navigation" style="width:1185px">
         <ul class="nav navbar-nav">
           <li><a class="<%= currentPage.endsWith("/researcher-list")? "active" : "" %>" href="<%= request.getContextPath() %>/researcher-list"><fmt:message key="jsp.layout.navbar-default.researchers" /></a></li>                
           <li class="dropdown">
             <a href="#" class="dropdown-toggle" data-toggle="dropdown" onfocus="this.style.backgroundColor='#003C80'"  onblur="this.style.backgroundColor=''"><fmt:message key="jsp.layout.navbar-default.browse"/> <b class="caret"></b></a>
             <ul class="dropdown-menu">
               <li><a href="<%= request.getContextPath() %>/community-list"><fmt:message key="jsp.layout.navbar-default.communities-collections"/></a></li>
				<li class="divider"></li>
        <li class="dropdown-header"><fmt:message key="jsp.layout.navbar-default.browseitemsby"/></li>
				<%-- Insert the dynamic browse indices here --%>
				
				<%
					for (int i = 0; i < bis.length; i++)
					{
						BrowseIndex bix = bis[i];
						String key = "browse.menu." + bix.getName();
						if(bix.getName().equals("author") || bix.getName().equals("subject")) {
					%>
								<li><a href="<%= request.getContextPath() %>/browse?type=<%= bix.getName() %>&order=ASC&rpp=20&starts_with=A"><fmt:message key="<%= key %>"/></a></li>
					<%
						} else {
					%>
				      			<li><a href="<%= request.getContextPath() %>/browse?type=<%= bix.getName() %>"><fmt:message key="<%= key %>"/></a></li>
					<%	
						}
					}
				%>
				    
				<%-- End of dynamic browse indices --%>

            </ul>
          </li>
          <li class="<%= currentPage.endsWith("/search")? "active" : "" %>"><a href="<%= request.getContextPath() %>/simple-search"><fmt:message key="nsfc.layout.navbar-default.search"/></a></li>
          <li class=""><a href="<%=request.getContextPath()%>/guide"><fmt:message key="jsp.layout.navbar-default.help" /></a></li>
          
          <li>         	
       <div class="row">
			<%-- Search Box --%>
			<div class="simple-search-form">
      		<form method="get" action="<%= request.getContextPath() %>/simple-search" style="width:300px;">
			<input class="form-control search-query-box" type="text" size="18" style="float:left;width:230px;"
							id="tquery" name="query"
							placeholder="<fmt:message key="jsp.layout.navbar-default.search"/>" /><input type="submit" id="main-query-submit" class="btn btn-primary" style="width:60px;float:right;color: #fff;text-indent: -8px;background-color:#003C80;"  
							value="<fmt:message key="jsp.general.go"/>" />
			</form>
			</div>
		</div>
          </li>
       </ul>
       <% 
       //String url = (request.getServletPath()).substring(7,15);
       //out.print(url.equals("home.jsp"));
       //out.print(request.getServletPath());
       //if(url.equals("home.jsp")) {
       %>
<!--        <form action="simple-search" method="get" style="padding-top: 10px;">
			<input type="hidden" value=""
				name="location" /> <input type="hidden"
				value="" name="query" />
			
			<select id="filtername" name="filtername">
				<option value="title">标题</option>
				<option value="author">学者</option>
				<option value="subject">成果</option>
				<option value="publisher">期刊</option>
			</select> 
			<select id="filtertype" name="filtertype" style="display:none">
				<option value="contains" selected>包含</option>
			</select> 
			<input type="text" id="filterquery" name="filterquery" size="18"
				required="required" /> <input type="hidden" value="20"
				name="rpp" /> <input type="hidden" value="score"
				name="sort_by" /> <input type="hidden" value="desc"
				name="order" /> <input style="color: #fff;margin-bottom: 5px;background-color:#003C80;" class="btn  btn-filter-add"
				type="submit" value="检索"
				onclick="return validateFilters()" />
		</form>
 -->		<% //}%>
 <div style='clear: both;'></div>
    </nav>
     