<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Researcher home JSP
  -
  - Attributes required:
  -    researcher  - Researcher to render home page for
  --%>

<%@ page contentType="text/html;charset=UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace"%>

<%@ page import="org.dspace.app.webui.components.RecentSubmissions"%>

<%@ page
	import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet"%>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.app.webui.discovery.*"%>
<%@ page import="org.dspace.browse.*"%>
<%@ page import="org.dspace.discovery.*"%>
<%@ page import="org.dspace.content.*"%>
<%@ page import="org.dspace.core.*"%>
<%@ page import="org.dspace.eperson.EPerson"%>
<%@ page import="org.dspace.eperson.Group"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="org.apache.commons.lang.*"%>
<%@ page import="java.util.*"%>
<%@ page import="org.dspace.discovery.configuration.*"%>
<%@ page import="org.dspace.discovery.DiscoverResult.FacetResult"%>
<%@ page import="org.dspace.statistics.content.*"%>
<%@ page import="org.dspace.statistics.Dataset" %>
<%@ page import="org.dspace.app.webui.components.*" %>

<%@ page import="pt.uminho.dsi.util.*"%>

<%@ page import="edu.calis.ir.pku.components.Claim"%>
<%@ page import="edu.calis.ir.pku.components.Researcher"%>
<%@ page import="edu.calis.ir.pku.util.*"%>

<%
	Context context = Utility.obtainNewContext(request);

	Locale locale = context.getCurrentLocale();

	String fullName = request.getParameter("fullname");
	String uid = request.getParameter("uid");
	Item[] items = null;
	boolean border_flag = false;
	Map<String, List<FacetResult>> mapFacetes = null;
	List<DiscoverySearchFilterFacet> facetsConf = null;
	List<String> appliedFilterQueries = null;
	
	Researcher r = null;
	if (StringUtils.isNotEmpty(fullName)
			&& StringUtils.isNotEmpty(uid)) {
		r = (Researcher) request.getAttribute("researcher");
			
		String type = request.getParameter("type");
		type = (type == null) ? "author" : type;
		String authority = request.getParameter("authority");
		DSpaceObject scope = null;
		
		try{
			DiscoverQuery queryArgs = DiscoverUtility.getDiscoverQuery(context,
		            request, scope, true);
			DiscoveryConfiguration discoveryConfiguration = SearchUtils
		            .getDiscoveryConfiguration(scope);
			List<DiscoverySearchFilterFacet> availableFacet = discoveryConfiguration
		            .getSidebarFacets();
		    
			facetsConf = 
		            availableFacet != null ? availableFacet
		                    : new ArrayList<DiscoverySearchFilterFacet>();
			
			if(StringUtils.isNotEmpty(r.getAcademicName())) {
				if(r.getAcademicName().indexOf(";") >= 0) {
					String[] names = r.getAcademicName().split(";");
					String query = "author:(\"" + fullName;
					for(int i = 0; i < names.length; i++) {
						query += "\" OR \"" + names[i];
					}
					query += "\")";
					queryArgs.setQuery(query);
				} else {
					queryArgs.setQuery("author:(\"" + fullName + "\" OR \"" + r.getAcademicName() + "\")");
				}
			} else {
				StringBuffer fullName2 = new StringBuffer(fullName);
				fullName2.insert(1, ", ");
				String str1 = fullName.substring(0, 1);
				String str2 = fullName.substring(1);
				String fullName3 = str2 + ", " + str1;
				queryArgs.setQuery("author:(\"" + fullName + "\" OR \"" + fullName2.toString() + "\" OR \"" + fullName3 + "\")");
			}
			queryArgs.setMaxResults(Integer.MAX_VALUE);
			queryArgs.setSortField("dc.date.issued_dt", DiscoverQuery.SORT_ORDER.desc);
			
			List<String[]> appliedFilters = DiscoverUtility.getFilters(request);
			appliedFilterQueries = new ArrayList<String>();
		    for (String[] filter : appliedFilters)
		    {
		        appliedFilterQueries.add(filter[0] + "::" + filter[1] + "::"
		                + filter[2]);
		    }
			
			DiscoverResult qResults = null;
			qResults = SearchUtils.getSearchService().search(context, scope,
		            queryArgs);
			mapFacetes = qResults.getFacetResults();
		    
		    List<Item> resultsListItem = new ArrayList<Item>();
		
		    for (DSpaceObject dso : qResults.getDspaceObjects())
		    {
		        if (dso instanceof Item)
		        {
		            resultsListItem.add((Item) dso);
		        }
		    }
		
		    // Make objects from the handles - make arrays, fill them out
		    items = new Item[resultsListItem.size()];
		    items = resultsListItem.toArray(items);
		    border_flag = items.length > 5 ? true : false;
		} catch(Exception e) {
			
		}
	}

	Boolean admin = (Boolean)request.getAttribute("is.admin");
	boolean isAdmin = (admin == null ? false : admin.booleanValue());
	
	boolean isCurrentUserAndResearcher = ((Boolean)request.getAttribute("isCurrentUserAndResearcher")).booleanValue();
%>

<%@page import="org.dspace.app.webui.servlet.MyDSpaceServlet"%>
<dspace:layout locbar="off" title="<%=fullName%>">
	<script type="text/javascript">
	function doMyClaim(action, resourceID) {
		$.ajaxSetup({ cache: false });
	   	$.getJSON(
	   		"<%=request.getContextPath()%>/claim?action="+action,
	   		{resourceID:resourceID},
	   		function(json) {
	   			if(json.success) {
	   				$('#claim_status_'+resourceID).empty();
	   				if(action == "add") {
		   				$('#claim_status_'+resourceID).html("<fmt:message key="jsp.researcher.profile.claim.ok"/>");
		   				$('#claim_status_'+resourceID).css('color', 'green');
		   				$('#claim_action_'+resourceID).attr('value', '<fmt:message key="jsp.researcher.profile.claim.cancel"/>');
	   				} else {
	   					$('#claim_status_'+resourceID).html('<fmt:message key="jsp.researcher.profile.claim.pending"/>');
		   				$('#claim_status_'+resourceID).css('color', 'red');
		   				$('#claim_action_'+resourceID).attr('value', '<fmt:message key="jsp.researcher.profile.claim"/>');
	   				}
	   			}
	   		});
	}
	
	</script>

	<div id="researcher" class="row">
		<%
			if (r!=null) {
		%>
		<div class="col-md-3" <%=border_flag?"":"style=\"border-right:1px solid #ccc;\"" %>>
			<div id="researcher_box">
				<div class="profile-image">
					<%
						String image = r.getImage();
						if (StringUtils.isNotEmpty(image)) {
							if(r.getSpecial() > 0) {
								if (image.equals("calis-self")) {
									String code = PKUUtils.encrypt(r.getUid(), "PkuLibIR");
									image = "<img width=200  height=200 src='" + request.getContextPath()
											+ "/imageshow?spec=" + code + "' />";
								}
								out.print(image);
							} else {
								if (r.getSex()) {
									image = "<img class='no-picture' src='"
											+ request.getContextPath()
											+ "/calis/images/man.png' />";
								} else {
									image = "<img class='no-picture' src='"
											+ request.getContextPath()
											+ "/calis/images/woman.png' />";
								}
								out.print(image);
							}
						} else {
							if (r.getSex()) {
								image = "<img class='no-picture' src='"
										+ request.getContextPath()
										+ "/calis/images/man.png' />";
							} else {
								image = "<img class='no-picture' src='"
										+ request.getContextPath()
										+ "/calis/images/woman.png' />";
							}
							out.print(image);
						}
					%>
				</div>
				<div class="profile-name">
					<span> <%=fullName%>
<%
 	if (isAdmin && r != null) {
 %> |
						&nbsp;<a
						href="<%=request.getContextPath()%>/researcher?action=preupdate&uid=<%=r.getUid()%>"><fmt:message
								key="jsp.dspace-admin.researcher.update" /></a>&nbsp;&nbsp;&nbsp;&nbsp;<a
						href="javascript:void(0);"
						onclick="javascript: if(confirm('<fmt:message key="jsp.dspace-admin.researcher.delete.confirm" /> <%=r.getName()%> ?')) {location.href='<%=request.getContextPath()%>/dspace-admin/researcher?action=delete&uid=<%=r.getUid()%>&name=<%=r.getName()%>';}"><fmt:message
								key="jsp.dspace-admin.researcher.delete" /></a> 
<%
 	}
	if (isCurrentUserAndResearcher) {
 %>
 |&nbsp;<a
						href="<%=request.getContextPath()%>/researcher?action=preupdate&uid=<%=r.getUid()%>"><fmt:message
								key="jsp.dspace-admin.researcher.update" /></a>
 
 <%
	}
 %>
					</span>
				</div>
					<div class="profile-unit">
						<%=request.getAttribute("unit_name")%>
					</div>
					<%
							if (StringUtils.isNotEmpty(r.getOrcid())) {
						%>
					<div class="profile-orcid"><fmt:message
									key="jsp.dspace-admin.researcher.form.orcid" />
							<br/><a href="http://orcid.org/<%=r.getOrcid()%>" target="_blank"><span><%=r.getOrcid() %></span></a>
					</div>
					
					<%
							}
							if (StringUtils.isNotEmpty(r.getAcademicName())) {
						%>
					<div class="profile-orcid"><fmt:message
									key="jsp.dspace-admin.researcher.form.academic-name" />
							<br/><span><%=r.getAcademicName() %></span></a>
					</div>
					<%
							}
							if (StringUtils.isNotEmpty(r.getTitle())) {
						%>
					<div class="profile-title"><fmt:message
									key="jsp.dspace-admin.researcher.form.title" />
							<br/><span><%=r.getTitle()%></span>
					</div>
					<%
							}
							if (StringUtils.isNotEmpty(r.getField())) {
					%>
						<div class="profile-field"><fmt:message
									key="jsp.dspace-admin.researcher.form.field" /><br/>
							<span><%=r.getField()%></span>
						</div>
						<%
							}
							if (StringUtils.isNotEmpty(r.getEducation())) {
						%>
						<div class="profile-education"><fmt:message
									key="jsp.dspace-admin.researcher.form.education" /><br/>
							<span><%=r.getEducation()%></span>
						</div>
						<%
							}
									if (StringUtils.isNotEmpty(r.getPhone())) {
						%>
						<!-- <div class="profile-phone"><fmt:message
									key="jsp.dspace-admin.researcher.form.phone" /><br/>
							 <span> <%=r.getPhone()%> </span>
						</div> -->
						<%
							}
									if (StringUtils.isNotEmpty(r.getEmail())) {
						%>
						<div class="profile-email"><fmt:message
									key="jsp.dspace-admin.researcher.form.email" /><br/>
							<span><%=r.getEmail()%></span>
						</div>
						<%
							}
									String url = r.getUrl();
									if (StringUtils.isNotEmpty(url)) {
						%>

						<div class="profile-website"><fmt:message key="jsp.dspace-admin.researcher.form.website" />
							<br/>
							<a href="<%=r.getUrl()%>" target="_blank"><%=r.getUrl()%></a>
						</div>
						<%
							}
						%>
						
						<div class="profile-coauthor">
							<fmt:message key="jsp.researcher.profile.coauthor" />
							<br/>
							<%
								List<FacetResult> facet = mapFacetes.get("author");
								int idx = 1;
								String classString = "";
								if(facet != null && facet.size() > 0) {
									for (FacetResult fvalue : facet)
								    { 
										if(idx == 1) {
											idx++;
											continue;
										}
								        if (!appliedFilterQueries.contains("author"+"::"+fvalue.getFilterType()+"::"+fvalue.getAsFilterQuery()))
								        {
								        	switch(idx){
									        	case 1: 
									        		classString = "xl";
									        		break;
									        	case 2:
									        		classString = "xl";
									        		break;
									        	case 3:
									        		classString = "l";
									        		break;
									        	case 4:
									        		classString = "l";
									        		break;
									        	case 5:
									        		classString = "m";
									        		break;
									        	case 6:
									        		classString = "m";
									        		break;
									        	case 7:
									        		classString = "s";
									        		break;
									        	case 8:
									        		classString = "s";
									        		break;
									        	default :
									        		classString = "xs";
								        	}
								        	idx++;
								        	%>
								        	<span class="<%=classString %>"><%=fvalue.getDisplayedValue() %></span>	
								        <%
								        }
								    }
								}
							%>
						</div>
			</div>
		</div>
		<div class="col-md-9" <%=border_flag?"style=\"border-left:1px solid #ccc;\"":"" %>>
			<div id="reference">
				<div class="relation row">
					<div class="col-md-2" style="font-size: 18px; margin-left: -15px;">
					<fmt:message key="jsp.researcher.profile.relation" />
					<div style="text-align: center;"><%=items.length %></div>
					<%
									if(isCurrentUserAndResearcher) {
								%>
							<form
								action="<%=request.getContextPath()%>/researcher">
								<input type="hidden" name="action" value="export" />
								<input type="hidden" name="uid" value="<%=uid %>" />				
								<input type="submit"
									class="btn btn-default btn-filter-add" name="submit_export_metadata"
									value='<fmt:message key="jsp.researcher.profile.claim.export.all"/>' />
							</form>
							<%
									}
								%>
					</div>
					<div class="col-md-8">
						<div class="row">
						<%
								List<FacetResult> facet2 = mapFacetes.get("type");
								int idx2 = 0;
								boolean omission = false;
								int threhold = 6;
								if(facet2 != null && facet2.size() > 0) {
									if(facet2.size() > threhold) {
										omission = true;
									}
									for (FacetResult fvalue : facet2)
								    { 
										if(idx2 == threhold) {
											break;
										}
								        if (!appliedFilterQueries.contains("type"+"::"+fvalue.getFilterType()+"::"+fvalue.getAsFilterQuery()))
								        {
						%>
											<div class="col-md-2"><%=LocaleSupport.getLocalizedMessage(pageContext, "jsp.researcher.profile.relation." + fvalue.getDisplayedValue().toLowerCase()) %><br/><%=fvalue.getCount() %></div>						
						<%
								        }
								        idx2++;
								    }
								}
						%>
						</div>
					</div>	
					<div class="col-md-2"><%=omission?"···":"" %></div>
				</div>
					<div id="reference_items">
						<%
							String year_temp = "";
							String year = "";
							boolean claim_status = false;
							EPerson ep = null;
							if(isCurrentUserAndResearcher) {
								ep = context.getCurrentUser();
							} else {
								ep = EPerson.findByNetid(context, PKUUtils.decrypt(uid, "PkuLibIR"));
							}
							for (Item item : items) {
								if(ep != null ) {
									claim_status = Claim.isClaim(context, ep, item.getID());
								}
								Metadatum[] value = item.getMetadata("dc", "date",
			 							"issued", Item.ANY);
								year = value[0].value.substring(0, 4);
								if(!year_temp.equals(year)){
									year_temp = year;
								} else {
									year = "";
								}
						%>
						<div class="reference-item row" style="<%=year.equals("")?"":"margin-top: 60px;" %>">
							<div class="year col-md-2">
								<span> <%
 									out.print(year);
 %>
								</span>
								<%
									if(!year.equals("") && isCurrentUserAndResearcher) {
								%>
							<form
								action="<%=request.getContextPath()%>/researcher">
								<input type="hidden" name="action" value="export" />
								<input type="hidden" name="uid" value="<%=uid %>" />				
								<input type="hidden" name="year" value="<%=year%>" />
								<input type="submit"
									class="btn btn-default btn-filter-add" name="submit_export_metadata"
									value='<fmt:message key="jsp.researcher.profile.claim.export.year"/>' />
							</form>
							<%
									}
								%>
							</div>
							<div class="title col-md-10" style="<%=year.equals("")?"padding-top: 5px;":"" %>">
								<%
										if(claim_status) {
								%>
									<sup id="claim_status_<%=item.getID() %>" style="color: green;"><fmt:message key="jsp.researcher.profile.claim.ok"/></sup>
								<%
										} else {
								%>
									<sup id="claim_status_<%=item.getID() %>" style="display:none;color: red;"><fmt:message key="jsp.researcher.profile.claim.pending"/></sup>
								<%
										}
								%>
								<a
									href='<%=(request.getContextPath() + "/handle/" + item
								.getHandle())%>'
									target='_blank'> <%=item.getName()%></a>
								<%
									Metadatum[] values = item.getMetadata("dc",
														"publisher", null, Item.ANY);
									if(values != null){
												for (int i = 0; i < values.length; i++) {
													out.print("<p><em>" + values[i].value + "</em></p>");
												}
									}
								%>
								<div class="statistics">
									<table>
										<tr>
										<td><%=PKUUtils.getItemVisits(context, item) %></td>
										<td><%=PKUUtils.getItemDownloads(context, item) %></td>
										</tr>
										<tr><td><fmt:message key="jsp.statistics.heading.views" /></td><td><fmt:message key="jsp.home.glance.downloads" /></td></tr>
									</table>
								</div>
								<%
									if(isCurrentUserAndResearcher) {
								%>
								<div class="claim">
								<%
										if(claim_status) {								
								%>
									<input id="claim_action_<%=item.getID() %>" class="btn btn-default btn-filter-add" onclick="doMyClaim('remove', <%=item.getID() %>)" value='<fmt:message key="jsp.researcher.profile.claim.cancel"/>'>
								<%	
										} else {
								%>
									<input id="claim_action_<%=item.getID() %>" class="btn btn-default btn-filter-add" onclick="doMyClaim('add', <%=item.getID() %>)" value='<fmt:message key="jsp.researcher.profile.claim"/>'>
								<%
										}
								%>
								</div>
								<%
									}
								%>
							</div>
							<div style="clear: both;"></div>
						</div>
						<%
				}
				%>
					</div>
					<%
				}
				%>
			</div>
		</div>
	</div>

</dspace:layout>

