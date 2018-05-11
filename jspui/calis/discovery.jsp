<!-- 是否为成果分类的显示，不是则为搜索的显示界面  -->
<%  if(request.getParameter("cgfl")==null) { %>
<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>

<%--
  - Display the form to refine the simple-search and dispaly the results of the search
  -
  - Attributes to pass in:
  -
  -   scope            - pass in if the scope of the search was a community
  -                      or a collection
  -   scopes 		   - the list of available scopes where limit the search
  -   sortOptions	   - the list of available sort options
  -   availableFilters - the list of filters available to the user
  -
  -   query            - The original query
  -   queryArgs		   - The query configuration parameters (rpp, sort, etc.)
  -   appliedFilters   - The list of applied filters (user input or facet)
  -
  -   search.error     - a flag to say that an error has occurred
  -   spellcheck	   - the suggested spell check query (if any)
  -   qResults		   - the discovery results
  -   items            - the results.  An array of Items, most relevant first
  -   communities      - results, Community[]
  -   collections      - results, Collection[]
  -
  -   admin_button     - If the user is an admin
  --%>

<%@page import="org.dspace.core.Utils"%>
<%@page import="com.coverity.security.Escape"%>
<%@page import="org.dspace.core.Constants"%>
<%@page import="org.dspace.content.Bundle"%>
<%@page import="org.dspace.content.Metadatum" %>
<%@page
	import="org.dspace.discovery.configuration.DiscoverySearchFilterFacet"%>
<%@page import="org.dspace.app.webui.util.UIUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.dspace.discovery.DiscoverFacetField"%>
<%@page
	import="org.dspace.discovery.configuration.DiscoverySearchFilter"%>
<%@page import="org.dspace.discovery.DiscoverFilterQuery"%>
<%@page import="org.dspace.discovery.DiscoverQuery"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="java.util.Map"%>
<%@page import="org.dspace.discovery.DiscoverResult.FacetResult"%>
<%@page import="org.dspace.discovery.DiscoverResult"%>
<%@page import="org.dspace.content.DSpaceObject"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="org.dspace.content.Community"%>
<%@ page import="org.dspace.content.Collection"%>
<%@ page import="org.dspace.content.Item"%>
<%@ page import="org.dspace.search.QueryResults"%>
<%@ page import="org.dspace.sort.SortOption"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Set"%>

<%@ page import="org.dspace.browse.BrowseIndex"%>
<%@ page import="org.dspace.browse.CrossLinks"%>
<%@ page import="org.dspace.content.authority.MetadataAuthorityManager"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%
	// Get the attributes
    DSpaceObject scope = (DSpaceObject) request.getAttribute("scope" );
    String searchScope = scope!=null?scope.getHandle():"";
    List<DSpaceObject> scopes = (List<DSpaceObject>) request.getAttribute("scopes");
    List<String> sortOptions = (List<String>) request.getAttribute("sortOptions");

    String query = (String) request.getAttribute("query");
	if (query == null)
	{
	    query = "";
	}
    Boolean error_b = (Boolean)request.getAttribute("search.error");
    boolean error = (error_b == null ? false : error_b.booleanValue());
    
    DiscoverQuery qArgs = (DiscoverQuery) request.getAttribute("queryArgs");
    String sortedBy = qArgs.getSortField();
    String order = qArgs.getSortOrder().toString();
    String ascSelected = (SortOption.ASCENDING.equalsIgnoreCase(order)   ? "selected=\"selected\"" : "");
    String descSelected = (SortOption.DESCENDING.equalsIgnoreCase(order) ? "selected=\"selected\"" : "");
    String httpFilters ="";
	String spellCheckQuery = (String) request.getAttribute("spellcheck");
    List<DiscoverySearchFilter> availableFilters = (List<DiscoverySearchFilter>) request.getAttribute("availableFilters");
	List<String[]> appliedFilters = (List<String[]>) request.getAttribute("appliedFilters");
	List<String> appliedFilterQueries = (List<String>) request.getAttribute("appliedFilterQueries");
	if (appliedFilters != null && appliedFilters.size() >0 ) 
	{
	    int idx = 1;
	    for (String[] filter : appliedFilters)
	    {
	        httpFilters += "&amp;filter_field_"+idx+"="+URLEncoder.encode(filter[0],"UTF-8");
	        httpFilters += "&amp;filter_type_"+idx+"="+URLEncoder.encode(filter[1],"UTF-8");
	        httpFilters += "&amp;filter_value_"+idx+"="+URLEncoder.encode(filter[2],"UTF-8");
	        idx++;
	    }
	}
    int rpp          = qArgs.getMaxResults();
    int etAl         = ((Integer) request.getAttribute("etal")).intValue();

    String[] options = new String[]{"equals","contains","authority","notequals","notcontains","notauthority"};
    
    // Admin user or not
    Boolean admin_b = (Boolean)request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
%>

<c:set var="dspace.layout.head.last" scope="request">
	<script type="text/javascript">
	//var jQ = jQuery.noConflict();
	$(document).ready(function() {
		$( "#spellCheckQuery").click(function(){
			$("#query").val($(this).attr('data-spell'));
			$("#main-query-submit").click();
		});
		
		$( "#filterquery" )
			.autocomplete({
				source: function( request, response ) {
					$.ajax({
						url: "<%=request.getContextPath()%>/json/discovery/autocomplete?query=<%=URLEncoder.encode(query,"UTF-8")%><%=httpFilters.replaceAll("&","&")%>",
						dataType: "json",
						cache: false,
						data: {
							auto_idx: $("#filtername").val(),
							auto_query: request.term,
							auto_sort: 'count',
							auto_type: $("#filtertype").val(),
							location: '<%=searchScope%>'
						},
						success : function(data) {
							response($.map(
								data.autocomplete,
								function(item) {
									var tmp_val = item.authorityKey;
									if (tmp_val == null
											|| tmp_val == '') {
										tmp_val = item.displayedValue;
									}
									return {
										label : item.displayedValue
												+ " ("
												+ item.count
												+ ")",
										value : tmp_val
									};
								}
							));
						}
					});
				}
			});
		});
	
		function validateFilters() {
			return document.getElementById("filterquery").value.length > 0;
		}
	</script>
</c:set>

<script type="text/javascript">
	$(document).ready(function() {
		$('.hide-advanced-filters').click(function() {
			var b = $("#aspect_discovery_SimpleSearch_div_search-filters");
			b.fadeOut(500, function() {
				<% if(!StringUtils.isNotBlank(spellCheckQuery)) { %>
				$('#content').css("padding-top", "160px");
				<% } else { %>
				$('#content').css("padding-top", (160 + $('.lead').height()) + "px");
				<% } %>				
			});
			$(this).addClass("hidden");
			$('.show-advanced-filters').removeClass("hidden");
		});

		$('.show-advanced-filters').click(function() {
			var b = $("#aspect_discovery_SimpleSearch_div_search-filters");
			b.fadeIn(500, function() {
				<% if(!StringUtils.isNotBlank(spellCheckQuery)) { %>
				$('#content').css("padding-top", "260px");
				<% } else { %>
				$('#content').css("padding-top", (260 + $('.lead').height()) + "px");
				<% } %>	
			});
			$(this).addClass("hidden");
			$('.hide-advanced-filters').removeClass("hidden");
		});

		$('.hide-advanced-filters').click();
	});
</script>

<style>
#content {
	padding-top: 260px;
}

#content .container .row .col-md-9 {
	border-left: 1px solid #ccc;
	float: right;
}

#content .container .row .col-md-3 {
	float: right;
}
</style>

<dspace:layout locbar="off" titlekey="jsp.search.title">

	<%-- <h1>Search Results</h1> --%>

	<%
		DiscoverResult qResults = (DiscoverResult)request.getAttribute("queryresults");
	Item      [] items       = (Item[]      )request.getAttribute("items");
	Community [] communities = (Community[] )request.getAttribute("communities");
	Collection[] collections = (Collection[])request.getAttribute("collections");

	if( error )
	{
	%>
	<p align="center" class="submitFormWarn">
		<fmt:message key="jsp.search.error.discovery" />
	</p>
	<%
		}
	else if( qResults != null && qResults.getTotalSearchResults() == 0 )
	{
	%>
	<%-- <p align="center">Search produced no results.</p> --%>
	<p align="center">
		<fmt:message key="jsp.search.general.noresults" />
	</p>
	<%
		}
	else if( qResults != null)
	{
	    long pageTotal   = ((Long)request.getAttribute("pagetotal"  )).longValue();
	    long pageCurrent = ((Long)request.getAttribute("pagecurrent")).longValue();
	    long pageLast    = ((Long)request.getAttribute("pagelast"   )).longValue();
	    long pageFirst   = ((Long)request.getAttribute("pagefirst"  )).longValue();
	    
	    // create the URLs accessing the previous and next search result pages
	    String baseURL =  request.getContextPath()
	                    + (!searchScope.equals("") ? "/handle/" + searchScope : "")
	                    + "/simple-search?query="
	                    + URLEncoder.encode(query,"UTF-8")
	                    + httpFilters
	                    + "&amp;sort_by=" + sortedBy
	                    + "&amp;order=" + order
	                    + "&amp;rpp=" + rpp
	                    + "&amp;etal=" + etAl
	                    + "&amp;start=";

	    String nextURL = baseURL;
	    String firstURL = baseURL;
	    String lastURL = baseURL;

	    String prevURL = baseURL
	            + (pageCurrent-2) * qResults.getMaxResults();

	    nextURL = nextURL
	            + (pageCurrent) * qResults.getMaxResults();
	    
	    firstURL = firstURL +"0";
	    lastURL = lastURL + (pageTotal-1) * qResults.getMaxResults();
	%>

	<div class="discovery-result-pagination row container">
		<%
			long lastHint = qResults.getStart()+qResults.getMaxResults() <= qResults.getTotalSearchResults()?
			        qResults.getStart()+qResults.getMaxResults():qResults.getTotalSearchResults();
		%>
		<%-- <p align="center">Results <//%=qResults.getStart()+1%>-<//%=qResults.getStart()+qResults.getHitHandles().size()%> of --%>
		<div class="paging_total pull-left">
			<fmt:message key="jsp.search.results.results">
				<fmt:param><%=qResults.getStart()+1%></fmt:param>
				<fmt:param><%=lastHint%></fmt:param>
				<fmt:param><%=qResults.getTotalSearchResults()%></fmt:param>
				<fmt:param><%=(float) qResults.getSearchTime() / 1000%></fmt:param>
			</fmt:message>
		</div>
		<%-- Include a component for modifying sort by, order, results per page, and et-al limit --%>
		<div class="discovery-pagination-controls pull-right">
			<form action="simple-search" method="get">
				<input type="hidden" value="<%=Utils.addEntities(searchScope)%>"
					name="location" /> <input type="hidden"
					value="<%=Utils.addEntities(query)%>" name="query" />
				<%
					if (appliedFilterQueries.size() > 0 ) { 
						int idx = 1;
						for (String[] filter : appliedFilters)
						{
						    boolean found = false;
				%>
				<input type="hidden" id="filter_field_<%=idx%>"
					name="filter_field_<%=idx%>"
					value="<%=Utils.addEntities(filter[0])%>" /> <input
					type="hidden" id="filter_type_<%=idx%>"
					name="filter_type_<%=idx%>"
					value="<%=Utils.addEntities(filter[1])%>" /> <input
					type="hidden" id="filter_value_<%=idx%>"
					name="filter_value_<%=idx%>"
					value="<%=Utils.addEntities(filter[2])%>" />
				<%
					idx++;
						}
					}
				%>
				<label for="rpp"><fmt:message key="search.results.perpage" /></label>
				<select name="rpp">
					<%
						for (int i = 5; i <= 100 ; i += 5)
					               {
					                   String selected = (i == rpp ? "selected=\"selected\"" : "");
					%>
					<option value="<%=i%>" <%=selected%>><%=i%></option>
					<%
						}
					%>
				</select> &nbsp;|&nbsp;
				<%
					if (sortOptions.size() > 0)
				           {
				%>
				<label for="sort_by"><fmt:message
						key="search.results.sort-by" /></label> <select name="sort_by">
					<option value="score"><fmt:message
							key="search.sort-by.relevance" /></option>
					<%
						for (String sortBy : sortOptions)
					               {
					                   String selected = (sortBy.equals(sortedBy) ? "selected=\"selected\"" : "");
					                   String mKey = "search.sort-by." + Utils.addEntities(sortBy);
					%>
					<option value="<%= Utils.addEntities(sortBy) %>" <%=selected%>><fmt:message
							key="<%=mKey%>" /></option>
					<%
						}
					%>
				</select>
				<%
					}
				%>
				<select name="order">
					<option value="ASC" <%=ascSelected%>><fmt:message
							key="search.order.asc" /></option>
					<option value="DESC" <%=descSelected%>><fmt:message
							key="search.order.desc" /></option>
				</select> <label for="etal"><fmt:message key="search.results.etal" /></label>
				<select name="etal">
					<%
						String unlimitedSelect = "";
					               if (etAl < 1)
					               {
					                   unlimitedSelect = "selected=\"selected\"";
					               }
					%>
					<option value="0" <%=unlimitedSelect%>><fmt:message
							key="browse.full.etal.unlimited" /></option>
					<%
						boolean insertedCurrent = false;
					               for (int i = 0; i <= 50 ; i += 5)
					               {
					                   // for the first one, we want 1 author, not 0
					                   if (i == 0)
					                   {
					                       String sel = (i + 1 == etAl ? "selected=\"selected\"" : "");
					%><option value="1" <%=sel%>>1</option>
					<%
						}

					                   // if the current i is greated than that configured by the user,
					                   // insert the one specified in the right place in the list
					                   if (i > etAl && !insertedCurrent && etAl > 1)
					                   {
					%><option value="<%=etAl%>" selected="selected"><%=etAl%></option>
					<%
						insertedCurrent = true;
					                   }

					                   // determine if the current not-special case is selected
					                   String selected = (i == etAl ? "selected=\"selected\"" : "");

					                   // do this for all other cases than the first and the current
					                   if (i != 0 && i != etAl)
					                   {
					%>
					<option value="<%=i%>" <%=selected%>><%=i%></option>
					<%
						}
					               }
					%>
				</select> <input class="btn btn-primary btn-control-update" type="submit"
					name="submit_search" value="<fmt:message key="search.update" />" />

				<%
					if (admin_button)
				    {
				%>
				<input type="submit" class="btn btn-default"
					name="submit_export_metadata"
					value="<fmt:message key="jsp.general.metadataexport.button"/>" />
				<%
					}
				%>
			</form>
		</div>
		<!-- give a content to the div -->
	</div>
	<div class="discovery-result-results">
		<%
			if (communities.length > 0 ) {
		%>
		<div class="panel panel-info">
			<dspace:communitylist communities="<%=communities%>" />
		</div>
		<%
			}
		%>

		<%
			if (collections.length > 0 ) {
		%>
		<div class="panel panel-info">
			<div class="panel-heading">
				<fmt:message key="jsp.search.results.colhits" />
			</div>
			<dspace:collectionlist collections="<%=collections%>" />
		</div>
		<%
			}
		%>

		<%
			if (items.length > 0) {
		%>
		<div class="">
			<%
				for(Item item : items) {
			    		Bundle[] bundles = item.getBundles(Constants.DEFAULT_BUNDLE_NAME);
			    		
			    		boolean filesExist = false;

				for (Bundle bnd : bundles) {
					filesExist = bnd.getBitstreams().length > 0;
					if (filesExist) {
						break;
					}
				}
			%>
			<div class="row doc-display">
				<div class="col-md-6">
					<div class="doc-display-title">
						<%
							if(item.isWithdrawn()) {
						%>
						<%=Utils.addEntities(item.getName())%>
						<%
							} else {
						%>
						<a
							href="<%=request.getContextPath()%>/handle/<%=item.getHandle()%>"
							target="_blank"> <%=Utils.addEntities(item.getName())%>
						</a>
						<%
							}
						%>
					</div>
					<div class="doc-display-type">
						<div class="type">
							<%//=(item.getMetadata("dc.type")==null?"":item.getMetadata("dc.type"))%>
							<%
								if(item.getMetadata("dc.type")==null) {
									
								} else {
									if(item.getMetadata("dc.type").equals("Book")) { 
										out.print("教师著作");
									} else if(item.getMetadata("dc.type").equals("Journal")) { 
										out.print("期刊论文");
									} else if(item.getMetadata("dc.type").equals("Conference")) { 
										out.print("会议论文");
									} else if(item.getMetadata("dc.type").equals("Thesis")) { 
										out.print("学位论文");
									}
									//out.print(item.getMetadata("dc.type"));
								}
							%>
							</div>
						<%
							if(filesExist){
						%>
						<div class="fulltext"><fmt:message key="jsp.search.results.fulltext" /></div>
						<%
							}
						%>
						<div class="clear"></div>
					</div>
					<div class="doc-display-author">
						<%
							Metadatum[] metadataArray = item.getMetadata("dc", "contributor", "author", Item.ANY);
							int loopLimit = metadataArray.length;
							int fieldMax = (etAl > 0 ? etAl : metadataArray.length);
						    loopLimit = (fieldMax > metadataArray.length ? metadataArray.length : fieldMax);
						    boolean truncated = (fieldMax < metadataArray.length);
						    
						    String metadata = "";
						    boolean disableCrossLinks = true;
						    CrossLinks cl = new CrossLinks();
						    String browseType = null;
						    boolean viewFull = false;
						    if(cl.hasLink("dc.contributor.author")) {
						    	browseType = cl.getLinkType("dc.contributor.author");
						    	viewFull = BrowseIndex.getBrowseIndex(browseType).isItemIndex();
						    }
						    StringBuffer sb = new StringBuffer();
                            for (int j = 0; j < loopLimit; j++)
                            {
                                String startLink = "";
                                String endLink = "";
                                if (!StringUtils.isEmpty(browseType) && !disableCrossLinks)
                                {
                                    String argument;
                                    String value;
                                    if (metadataArray[j].authority != null &&
                                            metadataArray[j].confidence >= MetadataAuthorityManager.getManager()
                                                .getMinConfidence(metadataArray[j].schema, metadataArray[j].element, metadataArray[j].qualifier))
                                    {
                                        argument = "authority";
                                        value = metadataArray[j].authority;
                                    }
                                    else
                                    {
                                        argument = "value";
                                        value = metadataArray[j].value;
                                    }
                                    if (viewFull)
                                    {
                                        argument = "vfocus";
                                    }
                                    startLink = "<a href=\"" + request.getContextPath() + "/browse?type=" + browseType + "&amp;" +
                                        argument + "=" + URLEncoder.encode(value,"UTF-8");

                                    if (metadataArray[j].language != null)
                                    {
                                        startLink = startLink + "&amp;" +
                                            argument + "_lang=" + URLEncoder.encode(metadataArray[j].language, "UTF-8");
                                    }

                                    if ("authority".equals(argument))
                                    {
                                        startLink += "\" class=\"authority " +browseType + "\">";
                                    }
                                    else
                                    {
                                        startLink = startLink + "\">";
                                    }
                                    endLink = "</a>";
                                }
                                sb.append(startLink);
                                sb.append(Utils.addEntities(metadataArray[j].value));
                                sb.append(endLink);
                                if (j < (loopLimit - 1))
                                {
                                    sb.append("; ");
                                }
                            }
                            if (truncated)
                            {
                                String etal = LocaleSupport.getLocalizedMessage(pageContext, "itemlist.et-al");
                                sb.append(", ").append(etal);
                            }
                            metadata = sb.toString();
                            out.print(metadata);
						%>
					</div>
					<div class="doc-display-publisher"><%=(item.getMetadata("dc.publisher")==null?"":item.getMetadata("dc.publisher"))%></div>
					<div class="doc-display-year"><%=(item.getMetadata("dc.date.issued")==null?"":item.getMetadata("dc.date.issued"))%></div>
				</div>

				<div class="col-md-6">
					<div class="doc-display-abstract">[<fmt:message key="jsp.search.results.abstract" />]&nbsp;<%=(item.getMetadata("dc.description.abstract")==null?"":StringUtils.abbreviate(item.getMetadata("dc.description.abstract"), 150)) %></div>
					<div class="doc-display-subject">[<fmt:message key="jsp.search.results.keywords" />]&nbsp;<%
							metadataArray = item.getMetadata("dc", "subject", "*", Item.ANY);
							loopLimit = metadataArray.length;
						    String metadata2 = "";
						    StringBuffer sb2 = new StringBuffer();
                            for (int j = 0; j < loopLimit; j++)
                            {
                                sb2.append(Utils.addEntities(metadataArray[j].value));
                                if (j < (loopLimit - 1))
                                {
                                    sb2.append("; ");
                                }
                            }
                            
                            metadata2 = sb2.toString();
                            out.print(metadata2);
						%>
					</div>
				</div>
			</div>
			<%
				}
			%>
			<%--
    <dspace:itemlist items="<%= items %>" authorLimit="<%= etAl %>" />
    --%>
		</div>
		<%
			}
		%>
	</div>
	<%-- if the result page is enought long... --%>
	<%-- weicf if ((communities.length + collections.length + items.length) > 10) {--%>
	<%-- show again the navigation info/links --%>
	<div class="discovery-result-pagination row container">
		<%-- <p align="center">Results <//%=qResults.getStart()+1%>-<//%=qResults.getStart()+qResults.getHitHandles().size()%> of --%>
		<div class="paging_total">
			<fmt:message key="jsp.search.results.results">
				<fmt:param><%=qResults.getStart()+1%></fmt:param>
				<fmt:param><%=lastHint%></fmt:param>
				<fmt:param><%=qResults.getTotalSearchResults()%></fmt:param>
				<fmt:param><%=(float) qResults.getSearchTime() / 1000%></fmt:param>
			</fmt:message>
		</div>
		<div class="col-md-12">
			<ul class="pagination">
				<%
					if (pageFirst != pageCurrent)
				{
				%><li><a href="<%=prevURL%>"><fmt:message
							key="jsp.search.general.previous" /></a></li>
				<%
					}
				else
				{
				%><li class="disabled"><span><fmt:message
							key="jsp.search.general.previous" /></span></li>
				<%
					}    

				if (pageFirst != 1)
				{
				%><li><a href="<%=firstURL%>">1</a></li>
				<li class="disabled"><span>...</span></li>
				<%
					}

				for( long q = pageFirst; q <= pageLast; q++ )
				{
				    String myLink = "<li><a href=\""
				                    + baseURL;


				    if( q == pageCurrent )
				    {
				        myLink = "<li class=\"active\"><span>" + q + "</span></li>";
				    }
				    else
				    {
				        myLink = myLink
				            + (q-1) * qResults.getMaxResults()
				            + "\">"
				            + q
				            + "</a></li>";
				    }
				%>

				<%=myLink%>

				<%
					}

				if (pageTotal > pageLast)
				{
				%><li class="disabled"><span>...</span></li>
				<li><a href="<%=lastURL%>"><%=pageTotal%></a></li>
				<%
					}
				if (pageTotal > pageCurrent)
				{
				%><li><a href="<%=nextURL%>"><fmt:message
							key="jsp.search.general.next" /></a></li>
				<%
					}
				else
				{
				%><li class="disabled"><span><fmt:message
							key="jsp.search.general.next" /></span></li>
				<%
					}
				%>
			</ul>
		</div>
		<!-- give a content to the div -->
	</div>
	<%-- weicf } --%>
	<%
		}
	%>
	<dspace:sidebar>
		<%
			boolean brefine = false;
			
			List<DiscoverySearchFilterFacet> facetsConf = (List<DiscoverySearchFilterFacet>) request.getAttribute("facetsConfig");
			Map<String, Boolean> showFacets = new HashMap<String, Boolean>();
				
			for (DiscoverySearchFilterFacet facetConf : facetsConf)
			{
				if(qResults!=null) {
				    String f = facetConf.getIndexFieldName();
				    List<FacetResult> facet = qResults.getFacetResult(f);
				    if (facet.size() == 0)
				    {
				        facet = qResults.getFacetResult(f+".year");
			    if (facet.size() == 0)
			    {
			        showFacets.put(f, false);
			        continue;
			    }
				    }
				    boolean showFacet = false;
				    for (FacetResult fvalue : facet)
				    { 
				if(!appliedFilterQueries.contains(f+"::"+fvalue.getFilterType()+"::"+fvalue.getAsFilterQuery()))
			    {
			        showFacet = true;
			        break;
			    }
				    }
				    showFacets.put(f, showFacet);
				    brefine = brefine || showFacet;
				}
			}
			if (brefine) {
		%>

		<h3 class="facets">
			<fmt:message key="jsp.search.facet.refine" />
		</h3>
		<div id="facets" class="facetsBox">

			<%
				for (DiscoverySearchFilterFacet facetConf : facetsConf)
				{
				    String f = facetConf.getIndexFieldName();
				    if (!showFacets.get(f))
				        continue;
				    List<FacetResult> facet = qResults.getFacetResult(f);
				    if (facet.size() == 0)
				    {
				        facet = qResults.getFacetResult(f+".year");
				    }
				    int limit = facetConf.getFacetLimit()+1;
				    
				    String fkey = "jsp.search.facet.refine."+f;
			%><div id="facet_<%=f%>" class="panel panel-success">
				<div class="panel-heading">
					<fmt:message key="<%=fkey%>" />
				</div>
				<ul class="list-group">
					<%
						int idx = 1;
						    int currFp = UIUtil.getIntParameter(request, f+"_page");
						    if (currFp < 0)
						    {
						        currFp = 0;
						    }
						    for (FacetResult fvalue : facet)
						    { 
						        if (idx != limit && !appliedFilterQueries.contains(f+"::"+fvalue.getFilterType()+"::"+fvalue.getAsFilterQuery()))
						        {
					%><li class="list-group-item"><span class="badge"><%=fvalue.getCount()%></span>
						<a
						href="<%=request.getContextPath()
                + (!searchScope.equals("")?"/handle/"+searchScope:"")
                + "/simple-search?query="
                + URLEncoder.encode(query,"UTF-8")
                + "&amp;sort_by=" + sortedBy
                + "&amp;order=" + order
                + "&amp;rpp=" + rpp
                + httpFilters
                + "&amp;etal=" + etAl
                + "&amp;filtername="+URLEncoder.encode(f,"UTF-8")
                + "&amp;filterquery="+URLEncoder.encode(fvalue.getAsFilterQuery(),"UTF-8")
                + "&amp;filtertype="+URLEncoder.encode(fvalue.getFilterType(),"UTF-8")%>"
						title="<fmt:message key="jsp.search.facet.narrow"><fmt:param><%=fvalue.getDisplayedValue()%></fmt:param></fmt:message>">
					<% 
	                if(f.equals("type")) {
	                	String type_value = "jsp.researcher.profile.relation." + fvalue.getDisplayedValue().toLowerCase();
	                %>
	                	<fmt:message key="<%= type_value %>" />
	                <%
	                } else {
	                	out.print(StringUtils.abbreviate(fvalue.getDisplayedValue(),36));
	                } 
	                %>
	                </a></li>
					<%
						idx++;
						        }
						        if (idx > limit)
						        {
						            break;
						        }
						    }
						    if (currFp > 0 || idx == limit)
						    {
					%><li class="list-group-item"><span
						style="visibility: hidden;">.</span> <%
 	if (currFp > 0) {
 %> <a
						class="pull-left"
						href="<%=request.getContextPath()
	            + (!searchScope.equals("")?"/handle/"+searchScope:"")
                + "/simple-search?query="
                + URLEncoder.encode(query,"UTF-8")
                + "&amp;sort_by=" + sortedBy
                + "&amp;order=" + order
                + "&amp;rpp=" + rpp
                + httpFilters
                + "&amp;etal=" + etAl  
                + "&amp;"+f+"_page="+(currFp-1)%>"><fmt:message
								key="jsp.search.facet.refine.previous" /></a> <%
 	}
 %> <%
 	if (idx == limit) {
 %>
						<a
						href="<%=request.getContextPath()
	            + (!searchScope.equals("")?"/handle/"+searchScope:"")
                + "/simple-search?query="
                + URLEncoder.encode(query,"UTF-8")
                + "&amp;sort_by=" + sortedBy
                + "&amp;order=" + order
                + "&amp;rpp=" + rpp
                + httpFilters
                + "&amp;etal=" + etAl  
                + "&amp;"+f+"_page="+(currFp+1)%>"><span
							class="pull-right"><fmt:message
									key="jsp.search.facet.refine.next" /></span></a> <%
 	}
 %></li>
					<%
						}
					%>
				</ul>
			</div>
			<%
				}
			%>

		</div>
		<%
			}
		%>
	</dspace:sidebar>

	<script type="text/javascript">
		$(document).ready(function() {
			$('select').selectBox();
		});
	</script>
</dspace:layout>

<div class="discovery-search-form">
	<div class="container">
		<%-- Controls for a repeat search --%>
		<div class="discovery-query panel-heading">
			<div class="row">
				<div class="col-md-9">
					<form action="simple-search" method="get">
						<input class="form-control search-query-box" type="text" size="50"
							id="query" name="query"
							placeholder="<fmt:message key="jsp.layout.navbar-default.search"/>"
							value="<%=(query==null ? "" : Utils.addEntities(query))%>" /> <input
							type="submit" id="main-query-submit" class="btn btn-primary"
							value="<fmt:message key="jsp.general.go"/>" />

						<%
							if (StringUtils.isNotBlank(spellCheckQuery)) {
						%>
						<p class="lead">
							<fmt:message key="jsp.search.didyoumean">
								<fmt:param>
									<a id="spellCheckQuery"
										data-spell="<%=Utils.addEntities(spellCheckQuery)%>"
										href="#"><%=spellCheckQuery%></a>
								</fmt:param>
							</fmt:message>
						</p>
						<%
							}
						%>
						<input type="hidden" value="<%=rpp%>" name="rpp" /> <input
							type="hidden" value="<%= Utils.addEntities(sortedBy) %>" name="sort_by" /> <input
							type="hidden" value="<%= Utils.addEntities(order) %>" name="order" />
						<%
							if (appliedFilters.size() > 0 ) {
						%>
						<div class="discovery-search-appliedFilters">
							<%
								int idx = 1;
								for (String[] filter : appliedFilters)
								{
								    boolean found = false;
							%>
							<div style="display: none;">
								<select id="filter_field_<%=idx%>"
									name="filter_field_<%=idx%>">
									<%
										for (DiscoverySearchFilter searchFilter : availableFilters)
												{
												    String fkey = "jsp.search.filter."+Escape.uriParam(searchFilter.getIndexFieldName());
									%><option
										value="<%=Utils.addEntities(searchFilter.getIndexFieldName())%>"
										<%if (filter[0].equals(searchFilter.getIndexFieldName()))
					            {%>
										selected="selected"
										<%found = true;
					            }%>><fmt:message
											key="<%=fkey%>" /></option>
									<%
										}
												if (!found)
												{
												    String fkey = "jsp.search.filter."+Escape.uriParam(filter[0]);
									%><option value="<%=Utils.addEntities(filter[0])%>"
										selected="selected"><fmt:message key="<%=fkey%>" /></option>
									<%
										}
									%>
								</select> <select id="filter_type_<%=idx%>" name="filter_type_<%=idx%>">
									<%
										for (String opt : options)
												{
												    String fkey = "jsp.search.filter.op."+Escape.uriParam(opt);
									%><option value="<%=Utils.addEntities(opt)%>"
										<%=opt.equals(filter[1])?" selected=\"selected\"":""%>><fmt:message
											key="<%=fkey%>" /></option>
									<%
										}
									%>
								</select>
							</div>
							<input type="hidden" id="filter_value_<%=idx%>"
								name="filter_value_<%=idx%>"
								value="<%=Utils.addEntities(filter[2])%>" size="45" /> <input
								class="btn btn-default btn-search-filter btn-search-filter-<%=Utils.addEntities(filter[1]) %>" type="submit"
								title='<fmt:message	key='<%=("jsp.search.filter.op."+filter[1]) %>' />'
								id="submit_filter_remove_<%=idx%>"
								name="submit_filter_remove_<%=idx%>"
								value="<%=Utils.addEntities(filter[2])%> X" /> &nbsp;
							<%
								idx++;
								}
							%>
						</div>
						<%
							}
						%>
					</form>
				</div>
				<div class="ds-static-div col-md-3">
					<a class="hide-advanced-filters" href="#"><fmt:message key="jsp.general.search.filters.hide" /></a>
					<a class="show-advanced-filters hidden" href="#"><fmt:message key="jsp.general.search.filters.show" /></a>
				</div>
			</div>
		</div>
		<%
			if (availableFilters.size() > 0) {
		%>
		<div class="discovery-search-filters panel-body row">
			<div class="col-md-12">
				<div id="aspect_discovery_SimpleSearch_div_search-filters">
					<h5>
						<fmt:message key="jsp.search.filter.heading" />
					</h5>
					<p class="discovery-search-filters-hint">
						<fmt:message key="jsp.search.filter.hint" />
					</p>
					<form action="simple-search" method="get">
						<input type="hidden" value="<%=Utils.addEntities(searchScope)%>"
							name="location" /> <input type="hidden"
							value="<%=Utils.addEntities(query)%>" name="query" />
						<%
							if (appliedFilterQueries.size() > 0 ) { 
								int idx = 1;
								for (String[] filter : appliedFilters)
								{
								    boolean found = false;
						%>
						<input type="hidden" id="filter_field_<%=idx%>"
							name="filter_field_<%=idx%>"
							value="<%=Utils.addEntities(filter[0])%>" /> <input
							type="hidden" id="filter_type_<%=idx%>"
							name="filter_type_<%=idx%>"
							value="<%=Utils.addEntities(filter[1])%>" /> <input
							type="hidden" id="filter_value_<%=idx%>"
							name="filter_value_<%=idx%>"
							value="<%=Utils.addEntities(filter[2])%>" />
						<%
							idx++;
								}
								}
						%>
						<select id="filtername" name="filtername">
							<%
								for (DiscoverySearchFilter searchFilter : availableFilters)
								{
								    String fkey = "jsp.search.filter."+Escape.uriParam(searchFilter.getIndexFieldName());
							%><option value="<%= Utils.addEntities(searchFilter.getIndexFieldName()) %>"><fmt:message
									key="<%=fkey%>" /></option>
							<%
								}
							%>
						</select> <select id="filtertype" name="filtertype">
							<%
								for (String opt : options)
								{
								    String fkey = "jsp.search.filter.op."+Escape.uriParam(opt);
							%><option value="<%=opt%>"><fmt:message
									key="<%=fkey%>" /></option>
							<%
								}
							%>
						</select> <input type="text" id="filterquery" name="filterquery" size="45"
							required="required" /> <input type="hidden" value="<%= rpp %>"
							name="rpp" /> <input type="hidden" value="<%= Utils.addEntities(sortedBy) %>"
							name="sort_by" /> <input type="hidden" value="<%= Utils.addEntities(order) %>"
							name="order" /> <input class="btn btn-primary btn-filter-add"
							type="submit" value="<fmt:message key="jsp.search.filter.add"/>"
							onclick="return validateFilters()" />
					</form>
				</div>
			</div>
		</div>
		<% } %>

	</div>
</div>
<%  } else{ %>
	<!--成果分类 start -->
	<style  type="text/css">
	#article_list ul, #article_list ul li, #article_list_sl ul, #article_list_sl ul li {
		padding-left: 0px;
		margin-left:  12px;
		color:#65A3E8;
		padding-bottom:5px;
	}
	#article_list ul, #article_list ul li a, #article_list_sl ul, #article_list_sl ul li a {
		color:#000;
	}
	</style>
	<%@page import="org.dspace.core.Utils"%><%@page import="com.coverity.security.Escape"%><%@page import="org.dspace.core.Constants"%><%@page import="org.dspace.content.Bundle"%><%@page import="org.dspace.content.Metadatum" %><%@page import="org.dspace.discovery.configuration.DiscoverySearchFilterFacet"%><%@page import="org.dspace.app.webui.util.UIUtil"%><%@page import="java.util.HashMap"%><%@page import="java.util.ArrayList"%><%@page import="org.dspace.discovery.DiscoverFacetField"%><%@page import="org.dspace.discovery.configuration.DiscoverySearchFilter"%><%@page import="org.dspace.discovery.DiscoverFilterQuery"%><%@page import="org.dspace.discovery.DiscoverQuery"%><%@page import="org.apache.commons.lang.StringUtils"%><%@page import="java.util.Map"%><%@page import="org.dspace.discovery.DiscoverResult.FacetResult"%><%@page import="org.dspace.discovery.DiscoverResult"%><%@page import="org.dspace.content.DSpaceObject"%><%@page import="java.util.List"%><%@ page contentType="text/html;charset=UTF-8"%><%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%><%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%><%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace"%><%@ page import="java.net.URLEncoder"%><%@ page import="org.dspace.content.Community"%><%@ page import="org.dspace.content.Collection"%><%@ page import="org.dspace.content.Item"%><%@ page import="org.dspace.search.QueryResults"%><%@ page import="org.dspace.sort.SortOption"%><%@ page import="java.util.Enumeration"%><%@ page import="java.util.Set"%><%@ page import="org.dspace.browse.BrowseIndex"%><%@ page import="org.dspace.browse.CrossLinks"%><%@ page import="org.dspace.content.authority.MetadataAuthorityManager"%><%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %><%
	// Get the attributes
    DSpaceObject scope = (DSpaceObject) request.getAttribute("scope" );
    List<String> sortOptions = (List<String>) request.getAttribute("sortOptions");
    String query = (String) request.getAttribute("query");
	if (query == null)
	{
	    query = "";
	}
    Boolean error_b = (Boolean)request.getAttribute("search.error");
    boolean error = (error_b == null ? false : error_b.booleanValue());
//<h1>Search Results</h1> 
		DiscoverResult qResults = (DiscoverResult)request.getAttribute("queryresults");
	Item      [] items       = (Item[]      )request.getAttribute("items");
	if( error )
	{
	%>
	<!-- <p align="center" class="submitFormWarn">
		<fmt:message key="jsp.search.error.discovery" />
	</p> -->
	<%
		}
	else if( qResults != null && qResults.getTotalSearchResults() == 0 )
	{
	%>
	<%-- <p align="center">Search produced no results.</p> --%>
	<!-- <p align="center">
		无检索结果
		<fmt:message key="jsp.search.general.noresults" />
	</p> -->
	<%
		}
	else if( qResults != null)
	{
			if (items.length > 0) {
				%>
				<ul>
				<% 
				for(Item item : items) {
			    		Bundle[] bundles = item.getBundles(Constants.DEFAULT_BUNDLE_NAME);		    		
			    		boolean filesExist = false;
					for (Bundle bnd : bundles) {
						filesExist = bnd.getBitstreams().length > 0;
						if (filesExist) {
							break;
						}
					}
					if(item.isWithdrawn()) {
					%>
					<!-- <%=Utils.addEntities(item.getName())%> -->
					<%
					} else {
					%><li><a href="<%=request.getContextPath()%>/handle/<%=item.getHandle()%>" target="_blank"> <%=Utils.addEntities(item.getName())%></a></li><%
					}
				}
				%>
				</ul>
				<%
			}
		}
	%>
	<!--成果分类 end -->
<%  } %>