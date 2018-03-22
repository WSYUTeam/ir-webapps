<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Home page JSP
  -
  - Attributes:
  -    communities - Community[] all communities in DSpace
  -    recent.submissions - RecetSubmissions
  --%>

<%@page import="org.dspace.core.Utils"%>
<%@page import="org.dspace.content.Bitstream"%>
<%@ page contentType="text/html;charset=UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace"%>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.File"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.core.*"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@ page import="org.dspace.core.I18nUtil"%>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.app.webui.components.RecentSubmissions"%>
<%@ page import="org.dspace.content.Community"%>
<%@ page import="org.dspace.core.ConfigurationManager"%>
<%@ page import="org.dspace.core.NewsManager"%>
<%@ page import="org.dspace.browse.ItemCounter"%>
<%@ page import="org.dspace.content.Metadatum"%>
<%@ page import="org.dspace.content.Item"%>

<%@ page import="net.sf.ehcache.Cache" %>
<%@ page import="net.sf.ehcache.CacheManager" %>
<%@ page import="net.sf.ehcache.Element" %>

<%@ page import="org.dspace.core.Context"%>
<%@ page import="edu.calis.ir.pku.components.Researcher" %>
<%@ page import="edu.calis.ir.pku.util.PKUUtils" %>

<%
	Community[] communities = (Community[]) request.getAttribute("communities");

    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);
    String topNews = NewsManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news.top.html"));
    String sideNews = NewsManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news.side.html"));

    boolean feedEnabled = ConfigurationManager.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled)
    {
        feedData = "ALL:" + ConfigurationManager.getProperty("webui.feed.formats");
    }

    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    RecentSubmissions submissions = (RecentSubmissions) request.getAttribute("recent.submissions");

	Context context = UIUtil.obtainContext(request);

    CacheManager manager = CacheManager.create();
	Cache cache = manager.getCache("calis.home.cache");
	List<String[]> rList = null;

	if (cache.get("calis_home_researchers_random") == null) {
		Researcher[] researchers = Researcher.getRandomResearchers(context, 4, 2);
		rList = new ArrayList<String[]>();
		for(int i = 0; i < researchers.length; i++){
			int id = researchers[i].getID();
			String uid = researchers[i].getUid();
			String name = researchers[i].getName();
			String unitName = researchers[i].getUnitName();
			String image = researchers[i].getImage();
			String title = researchers[i].getTitle();
			String field = researchers[i].getField();

			String code = PKUUtils.encrypt(uid, "PkuLibIR");
			if(image.equals("calis-self")) {
				image = "<img src='" + request.getContextPath() + "/imageshow?spec=" + code + "' />";
			}
			image = image.replace("<img", "<img class='pic-home'");
			if (StringUtils.isNotEmpty(field)) {
				if( field.length() > 50) {
					field = field.substring(0, 50) + "...";
				}
			} else {
				field = "";
			}
			String[] ss = new String[]{id + "", code, name, image, title, unitName, field};
			rList.add(ss);
		}
		Element e = new Element("calis_home_researchers_random", rList);
		cache.put(e);
	}
	rList = (List<String[]>) cache.get("calis_home_researchers_random").getObjectValue();
%>

<SCRIPT type="text/javascript"
	src="<%=request.getContextPath()%>/calis/js/jquery.featureList-1.0.0.js"></SCRIPT>
<SCRIPT type="text/javascript"
	src="<%=request.getContextPath()%>/calis/js/glance.js"></SCRIPT>
<script type="text/javascript" src="<%=request.getContextPath()%>/calis/js/jquery.ae.image.resize.js"></script>

<SCRIPT type="text/javascript">
	var context = "<%=request.getContextPath() %>";
	var hot_views = '<fmt:message key="jsp.home.hotview.views"/>';

	var localCache = {
		    /**
		     * timeout for cache in millis
		     * @type {number}
		     */
		    timeout: 300000,
		    /**
		     * @type {{_: number, data: {}}}
		     **/
		    data: {},
		    remove: function (url) {
		        delete localCache.data[url];
		    },
		    exist: function (url) {
		        return !!localCache.data[url] && ((new Date().getTime() - localCache.data[url]._) < localCache.timeout);
		    },
		    get: function (url) {
		        console.log('Getting in cache for url' + url);
		        return localCache.data[url].data;
		    },
		    set: function (url, cachedData) {
		        localCache.remove(url);
		        localCache.data[url] = {
		            _: new Date().getTime(),
		            data: cachedData
		        };
		    }
		};

	$(document).ready(function() {
		var timer;
		var random = Math.floor(Math.random()*7);
		$.featureList($("#tabs li a"), $("#output li"), {
			start_item : random
		});

		/*
		// Alternative
		$('#tabs li a').featureList({
			output			:	'#output li',
			start_item		:	1
		});
		 */
	});

	if ($.browser.webkit) {
		$(window).on("load", function(){
			$('.pic-home').each(function(){
				// Get on screen image
				var screenImage = $(this);
				var width = 139;
				var height = 159;

				var img_w = screenImage.width();
				var img_h = screenImage.height();
				if(img_w/img_h < width/height) {
					screenImage.aeImageResize({width: width});
				} else {
					screenImage.aeImageResize({height: height});
				}

				var imageWidth = screenImage.width();
				var imageHeight = screenImage.height();

				if(imageWidth > width) {
					$(this).css('left', '-' + (imageWidth - width)/2 + 'px');
				}

				if(imageHeight > height) {
					$(this).css('top', '-' + (imageHeight - height)/2 + 'px');
				}
			});
		});
	} else {
		$(document).ready(function() {
			$('.pic-home').each(function(){
				// Get on screen image
				var screenImage = $(this);
				var width = 139;
				var height = 159;

				var img_w = screenImage.width();
				var img_h = screenImage.height();
				if(img_w/img_h < width/height) {
					screenImage.aeImageResize({width: width});
				} else {
					screenImage.aeImageResize({height: height});
				}

				var imageWidth = screenImage.width();
				var imageHeight = screenImage.height();

				if(imageWidth > width) {
					$(this).css('left', '-' + (imageWidth - width)/2 + 'px');
				}

				if(imageHeight > height) {
					$(this).css('top', '-' + (imageHeight - height)/2 + 'px');
				}
			});
		});
	}

</SCRIPT>


<dspace:layout locbar="off" titlekey="jsp.home.title"
	feedData="<%=feedData%>">
	<div class="container row pic">
		<!-- 轮播图 start -->
		<DIV id=carousel-example-generic class="carousel slide"  data-ride="carousel">
			<!-- 轮播图小圆点 -->
			<OL class=carousel-indicators>
				<!-- class="active"  被选中的状态 -->
				<li class="active" data-target="#carousel-example-generic" data-slide-to="0"/></LI>
				<LI  data-target="#carousel-example-generic" data-slide-to="1"></LI>
				<LI  data-target="#carousel-example-generic" data-slide-to="2"></LI>
				<LI  data-target="#carousel-example-generic" data-slide-to="3"></LI>
			</OL>
			<!-- 轮播图小圆点 -->
			<!-- 轮播图部分 -->
			<DIV class=carousel-inner role=listbox>
				<DIV class="item active">
					<A href="?#1" target=_blank><IMG  src="calis/images/index_two.png"> </A>
					<!-- onerror="this.src='public/img/wu.jpg'" -->
					<DIV class=carousel-caption>
						<A style="COLOR: #ffffff" title="测试效果" href="?#1" target=_blank>测试效果 </A>
					</DIV>
				</DIV>
				<DIV class=item>
					<A href="?#2" target=_blank><IMG  src="calis/images/index_three.png"> </A>
					<!-- onerror="this.src='public/img/wu.jpg'" -->
					<DIV class=carousel-caption>
						<A style="COLOR: #ffffff" title="Observation of a new particle in the search for the Standard Model Higgs boson with the ATLAS ..." href="?#2" target=_blank>Observation of </A>
					</DIV>
				</DIV>
				<DIV class=item>
					<A href="?#4" target=_blank><IMG  src="calis/images/index_four.png"> </A>
					<!-- onerror="this.src='public/img/wu.jpg'" -->
					<DIV class=carousel-caption>
						<A style="COLOR: #ffffff" title="Observation of a new particle in the search for the Standard Model Higgs boson with the ATLAS ..." href="?#4" target=_blank>Observation of a new particle in  </A>
					</DIV>
				</DIV>
				<DIV class="item">
					<A href="?#3" target=_blank><IMG   src="calis/images/index_imgs.png" > </A>
					<!-- onerror="this.src='public/img/wu.jpg'" -->
					<DIV class=carousel-caption>
						<A style="COLOR: #ffffff" title=中国山水画论笔墨说的形而上底蕴——以唐岱的天地观与笔墨说为考察核心 href="?#3" target=_blank>中国山水画论笔墨说的形而上底 </A>
					</DIV>
				</DIV>
			</DIV>
			<!-- 轮播图部分 -->
		</DIV>
	</div>
	<!-- 轮播图 end -->
	<!-- 热门成功能 start -->
	<div class="container row popular">
		<div id="feature_list" class="col-md-12">
			<div
				style="">
				<div class="row-title-zh"><img src="calis\images\x.png"> &nbsp; 热门成果</div>
				<div class=""></div>
			</div>
			<div class=""></div>
			
				<%
				Map<String, String> map = new HashMap<String, String>();
				String commStr = ConfigurationManager.getProperty("webui.home.hotview.slideshow.community");
				String specialHandles = ConfigurationManager.getProperty("webui.home.hotview.slideshow.community.special");
				Community[] specialComms = PKUUtils.getSpecialCommunities(context);
				int threshold = ConfigurationManager.getIntProperty("webui.home.hotview.slideshow.community.show.count");
				int count_of_show = threshold;
				int count_of_show2 = threshold;
				int current_of_show = 0;
				int current_of_show2 = 0;
				String[] commArray = commStr.split(";");
				for(int i = 0; i < commArray.length; i++) {
					String[] array = commArray[i].split("\\|");
					map.put(array[0], array[1]);
				}

				if(specialComms != null && specialComms.length > 0) {
					for(Community comm : specialComms) {
						if(current_of_show > threshold) {
							break;
						}
						if(comm == null) {
							continue;
						}
						current_of_show++;
				%>
				<li id="<%=comm.getHandle().replace("/", "_") %>">
				<a href="javascript:void(0);"><img class="img-responsive visible-xs-block hidden-xs visible-sm-block hidden-sm visible-md-block hidden-md"
						src="<%=request.getContextPath()%>/calis/images/<%=map.get(comm.getName()) %>">
						<h3 class="h3"><%=comm.getName() %></h3> <span><%=comm.getMetadata("short_description") %></span></a></li>
				<%
					}
				}

				if(communities != null && communities.length > 0) {
					Community[] subcommunities = PKUUtils.getSubcommunities(UIUtil.obtainContext(request), communities[0].getID(), "DESC");

					for(Community comm : subcommunities) {
						if(current_of_show > threshold) {
							break;
						}
						if(count_of_show <= 0) {
							break;
						}
						if(specialHandles.contains(comm.getHandle())) {
							count_of_show--;
							continue;
						}
						count_of_show--;
						current_of_show++;
				%>
				<li id="<%=comm.getHandle().replace("/", "_") %>">
				<a href="javascript:void(0);">
						<h3 class="h3"><%=comm.getName() %></h3> <span><%=comm.getMetadata("short_description") %></span></a></li>
				<%
					}
				%>
			</ul>
				<%
				}
				%>
			
		</div>
	</div>
	<div style="clear: both"></div>
	<!-- 热门成功能 end -->
	<div class="container banner-home">
	<div class="col-md-6">
	<%
		if(rList.size() >= 4) {
	%>
		<div class="row">
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(0)[0] %>&uid=<%=rList.get(0)[1] %>&fullname=<%=URLEncoder.encode(rList.get(0)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(0))[3] %></div></a>
				</div>
				<div class="col-md-3">
					<div class="pic-home-text arrow-left-1" style="min-width:100px ;">
						<p>
						<span class="title">
				          	<%=rList.get(0)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(0)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%//=rList.get(0)[5] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(1)[0] %>&uid=<%=rList.get(1)[1] %>&fullname=<%=URLEncoder.encode(rList.get(1)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(1))[3] %></div></a>
				</div>
				<div class="col-md-3">
					<div class="pic-home-text arrow-left-1">
						<p>
						<span class="title">
				          	<%=rList.get(1)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(1)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%//=rList.get(1)[5] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(2)[0] %>&uid=<%=rList.get(2)[1] %>&fullname=<%=URLEncoder.encode(rList.get(2)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(2))[3] %></div></a>
				</div>
				<div class="col-md-3">
					<div class="pic-home-text arrow-left-1">
						<p>
						<span class="title">
				          	<%=rList.get(2)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(2)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%//=rList.get(2)[5] %>
				        </span>
				        </p>
					</div>
				</div>
		</div>
		<%
			}
		%>
	</div>

	<div class="col-md-6 xy">
		<div class="row">
			<div class="about-text">
				<fmt:message key="jsp.home.about" />
			</div>
		</div>
		<div class="row">
			<%-- Search Box --%>
			<div class="simple-search-form">
			<form method="get" action="<%= request.getContextPath() %>/simple-search" >
			<input class="form-control search-query-box" type="text" size="50"
							id="tquery" name="query"
							placeholder="<fmt:message key="jsp.layout.navbar-default.search"/>" />
							<input type="submit" id="main-query-submit" class="btn btn-primary"
							value="<fmt:message key="jsp.general.go"/>" />
		<%--               <br/><a href="<%= request.getContextPath() %>/advanced-search"><fmt:message key="jsp.layout.navbar-default.advanced"/></a>
		<%
					if (ConfigurationManager.getBooleanProperty("webui.controlledvocabulary.enable"))
					{
		%>
		              <br/><a href="<%= request.getContextPath() %>/subject-search"><fmt:message key="jsp.layout.navbar-default.subjectsearch"/></a>
		<%
		            }
		%> --%>
			</form>
			</div>
		</div>
	</div>

	</div>

	<div class="container row" style="margin-top: 70px;">
		<div id="glanceshow_bg" class="visible-xs-block hidden-xs visible-sm-block hidden-sm visible-md-block hidden-md"></div>
		<div class="glance">
			<div class="row">
				<div class="col-md-3">
					<div class="icon">
						<img src="<%=request.getContextPath()%>/calis/images/IR-3_19.png" />
					</div>
					<div id="metadata" class="">
						<div class="name">
							<fmt:message key="jsp.home.glance.metadata" />
						</div>
						<div class="number"><img src="<%=request.getContextPath() %>/calis/images/loading.gif" /></div>
					</div>
				</div>

				<div class="col-md-3">
					<div class="icon">
						<img src="<%=request.getContextPath()%>/calis/images/IR-3_27.png" />
					</div>
					<div id="fulltext" class="">
						<div class="name">
							<fmt:message key="jsp.home.glance.fulltext" />
						</div>
						<div class="number"><img src="<%=request.getContextPath() %>/calis/images/loading.gif" /></div>
					</div>
				</div>

				<div class="col-md-3">
					<div class="icon">
						<img src="<%=request.getContextPath()%>/calis/images/IR-3_32.png" />
					</div>
					<div id="views" class="">
						<div class="name">
							<fmt:message key="jsp.home.glance.views" />
						</div>
						<div class="number"><img src="<%=request.getContextPath() %>/calis/images/loading.gif" /></div>
					</div>
				</div>

				<div class="col-md-3">
					<div class="icon">
						<img src="<%=request.getContextPath()%>/calis/images/IR-3_33.png" />
					</div>
					<div id="downloads" class="">
						<div class="name">
							<fmt:message key="jsp.home.glance.downloads" />
						</div>
						<div class="number"><img src="<%=request.getContextPath() %>/calis/images/loading.gif" /></div>
					</div>
				</div>
			</div>
		</div>
	</div>

	


	<div class="container row statistics">
		<div
				style="border-bottom: 3px solid #949c9c; display: inline-block; padding-bottom: 25px; margin-bottom: 30px;">
				<div class="row-title-zh">统计</div>
				<div class="row-title-en">STATISTICS</div>
			</div>
		<%
				int discovery_panel_cols = 12;
				int discovery_facet_cols = 3;
				int discovery_facet_list = 4;
		%>
		<%@ include file="../discovery/static-sidebar-facet.jsp"%>
	</div>

	<div class="row">
		<%@ include file="../discovery/static-tagcloud-facet.jsp"%>
	</div>

	</div>
</dspace:layout>
