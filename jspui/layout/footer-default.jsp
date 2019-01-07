<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Footer for home page
  --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>

<%

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

    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
%>

            <%-- Right-hand side bar if appropriate --%>
<%
    if (sidebar != null)
    {
%>
	</div>
	<div class="col-md-3">
                    <%= sidebar %>
    </div>
    </div>       
<%
    }
%>
</div>
</main>
            <%-- Page footer --%>
	<footer class="navbar navbar-inverse navbar-bottom">
    <div id="footerPan" class="container">
		
		<div class="col-md-12 nav-footer">
		<ul class="nav navbar-nav">
		   <li class=""><a href="<%= request.getContextPath() %>/"><fmt:message key="jsp.layout.navbar-default.home"/></a></li>
           <li class=""><a href="<%= request.getContextPath() %>/simple-search"><fmt:message key="nsfc.layout.navbar-default.search"/></a></li>
           <li><a class="" href="<%= request.getContextPath() %>/researcher-list"><fmt:message key="jsp.layout.navbar-default.researchers" /></a></li>     
           <li class="dropdown">
             <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.layout.navbar-default.browse"/> <b class="caret"></b></a>
             <ul class="dropdown-menu dropup-menu">
               <li><a href="<%= request.getContextPath() %>/community-list"><fmt:message key="jsp.layout.navbar-default.communities-collections"/></a></li>
				<li class="divider"></li>
        <li class="dropdown-header"><fmt:message key="jsp.layout.navbar-default.browseitemsby"/></li>
				<%-- Insert the dynamic browse indices here --%>
				
				<%
					for (int i = 0; i < bis.length; i++)
					{
						BrowseIndex bix = bis[i];
						String key = "browse.menu." + bix.getName();
					%>
				      			<li><a href="<%= request.getContextPath() %>/browse?type=<%= bix.getName() %>"><fmt:message key="<%= key %>"/></a></li>
					<%	
					}
				%>
				    
				<%-- End of dynamic browse indices --%>

            </ul>
          </li>
          <li class=""><a href="<%=request.getContextPath()%>/guide"><fmt:message key="jsp.layout.navbar-default.help" /></a></li>
          <li class=""><a href="mailto: dspace-help@wsyu.edu.cn"><fmt:message key="nsfc.layout.navbar-default.contact"/></a></li>
       </ul>
		</div>
    
    	<div style="clear: both;"></div>
    
		<div class="col-md-12 copyright">
			<fmt:message key="jsp.layout.footer-default.text" >
				<fmt:param>
				<%
					Calendar cal = Calendar.getInstance();
					int year = cal.get(Calendar.YEAR);
					out.print(year);
				%>
				 </fmt:param>
			</fmt:message> 
			| <a  href="<%= request.getContextPath() %>/feedback" ><fmt:message key="jsp.layout.footer-default.feedback"/></a>
                                <a href="<%= request.getContextPath() %>/htmlmap"></a>
		</div>
	</div>
    </footer>

    </body>
</html>
