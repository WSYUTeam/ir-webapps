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
<!-- start -->
<%@page import="org.apache.commons.lang.StringUtils"%>

    
<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.ItemCountException" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>



<%
	Community[] communities = (Community[]) request.getAttribute("communities");

    Locale sessionLocale = UIUtil.getSessionLocale(request);

    //院系导航 start
    Map collectionMap = (Map) request.getAttribute("collections.map");
    Map subcommunityMap = (Map) request.getAttribute("subcommunities.map");
    Boolean admin_b = (Boolean)request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    // ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
    
    Community[] subCommunity = null;
    //院系导航 end

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
		Researcher[] researchers = Researcher.getRandomResearchers(context, 10, 2);
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
	// out.print(rList);


%>
<%!
//院系导航 start
    void showCommunity(Community c, JspWriter out, HttpServletRequest request, ItemCounter ic,
            Map collectionMap, Map subcommunityMap) throws ItemCountException, IOException, SQLException
    {
        out.println( "<li> " );
        //out.println( "<div class=\"media-body\"><div class=\"col-md-12\"><h4 class=\"media-heading\"><a id=" + c.getID() + " href=\"" + request.getContextPath() + "/handle/" 
        //    + c.getHandle() + "\">" + c.getMetadata("name") + "</a>");
        out.println( "<div ><h4><a id=" + c.getID() + " href=\"" + request.getContextPath() + "/handle/" 
            + c.getHandle() + "\">" + c.getMetadata("name") + "</a>");
        if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
        {
            out.println(" <span class=\"\" style=\"height:25px;width:80px;font-weight:bold;text-align:center;line-height:25px;font-size:16px;color:#fff;background-color:#003C80;float:right\">" + ic.getCount(c) + "</span>");
        }
        //out.println("</h4>");
        
        //out.println("</div>");
        // Get the collections in this community

        
        out.println("</h4></div>");
        out.println("</li><hr>");
    }
//院系导航 END
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
			<div class="row-title-zh"><img src="calis\images\x.png"> &nbsp; 热门成果
				<span style="font-size:12px;line-height:41px;float:right;font-family;padding-right:70px">
					<a href="simple-search?query=" target="_blank" class="more">更多&gt;&gt;</a>
				</span>
			</div>
			<div id="470302_1_hotview">
				
			</div>
		</div>
	</div>
	<div style="clear: both"></div>
	<!-- 热门成功能 end -->
	<div class="container banner-home">
		<div class="row-title-zh xztj"><img src="calis\images\c.png"> &nbsp; 学者推荐
			<span style="font-size:12px;line-height:41px;float:right;font-family;padding-right:70px">
				<a href="/researcher-list" target="_blank" class="more">更多&gt;&gt;</a>
			</span>
		</div>
		<div class="row-title-zh yxdh"><img src="calis\images\v.png"> &nbsp; 院系导航
			<span style="font-size:12px;line-height:41px;float:right;font-family;padding-right:70px">
				<a href="/community-list" target="_blank" class="more">更多&gt;&gt;</a>
			</span></div>
		<div style="clear: both"></div>
	<div class="col-md-6" style="width:795px">
	<%
		if(rList.size() >= 10) {
	%>
		<div class="row" style="margin-top: 30px;padding-left:30px">
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(0)[0] %>&uid=<%=rList.get(0)[1] %>&fullname=<%=URLEncoder.encode(rList.get(0)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(0))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;" style= "width:80px;">
					<div class="pic-home-text arrow-left-1" >
						<p>
						<span class="title">
				          	<%//=rList.get(0)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(0)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(0)[6] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(1)[0] %>&uid=<%=rList.get(1)[1] %>&fullname=<%=URLEncoder.encode(rList.get(1)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(1))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1" >
						<p>
						<span class="title">
				          	<%//=rList.get(1)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(1)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(1)[6] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(2)[0] %>&uid=<%=rList.get(2)[1] %>&fullname=<%=URLEncoder.encode(rList.get(2)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(2))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1" >
						<p>
						<span class="title">
				          	<%//=rList.get(2)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(2)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(2)[6] %>
				        </span>
				        </p>
					</div>
				</div>
		</div>
		<div style="clear: both"></div>
		<div class="row" style="margin-top: 30px;padding-left:30px">
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(3)[0] %>&uid=<%=rList.get(3)[1] %>&fullname=<%=URLEncoder.encode(rList.get(3)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(3))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1" >
						<p>
						<span class="title">
				          	<%//=rList.get(3)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(3)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(3)[6] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(4)[0] %>&uid=<%=rList.get(4)[1] %>&fullname=<%=URLEncoder.encode(rList.get(4)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(4))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1">
						<p>
						<span class="title">
				          	<%//=rList.get(4)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(4)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(4)[6] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(5)[0] %>&uid=<%=rList.get(5)[1] %>&fullname=<%=URLEncoder.encode(rList.get(5)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(5))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1">
						<p>
						<span class="title">
				          	<%//=rList.get(5)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(5)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(5)[6] %>
				        </span>
				        </p>
					</div>
				</div>
		</div>
		<div style="clear: both"></div>
		<div class="row" style="margin-top: 30px;padding-left:30px">
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(6)[0] %>&uid=<%=rList.get(6)[1] %>&fullname=<%=URLEncoder.encode(rList.get(6)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(6))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1">
						<p>
						<span class="title">
				          	<%//=rList.get(6)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(6)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(6)[6] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(7)[0] %>&uid=<%=rList.get(7)[1] %>&fullname=<%=URLEncoder.encode(rList.get(7)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(7))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1">
						<p>
						<span class="title">
				          	<%//=rList.get(7)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(7)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(7)[6] %>
				        </span>
				        </p>
					</div>
				</div>
				<div class="col-md-3">
					<a href="<%=request.getContextPath() %>/researcher?id=<%=rList.get(8)[0] %>&uid=<%=rList.get(8)[1] %>&fullname=<%=URLEncoder.encode(rList.get(8)[2]) %>" target="_blank"><div class="pic-home-wrap"><%=(rList.get(8))[3] %></div></a>
				</div>
				<div class="col-md-3 text_w" style= "width:80px;">
					<div class="pic-home-text arrow-left-1">
						<p>
						<span class="title">
				          	<%//=rList.get(8)[4] %>
				        </span>
				        </p>
				        <p>
				        <span class="name">
				          <%=rList.get(8)[2] %>
				        </span>
				        </p>
				        <p>
				        <span class="unit">
				          <%=rList.get(8)[6] %>
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
			<div class="">
			</div>
		</div>
		<div class="row">
			<% if (communities.length != 0)
			{
			    subCommunity = PKUUtils.getSubcommunities(UIUtil.obtainContext(request), communities[0].getID(), "ASC");
			%>
			<div id="community_list">
			    <ul style="padding-left:10px;padding-top:25px">
			<%			        
			        for (int i = 0; i < subCommunity.length; i++)
			        {
			            showCommunity(subCommunity[i], out, request, ic, collectionMap, subcommunityMap);
			        }
			%>
			    </ul>
			</div>
			<% }
			%>		
		</div>
	</div>

	</div>

	<div class="container banner-home" style="margin-top:30px">
		<div class="row-title-zh xztj"><img src="calis\images\a.png"> &nbsp; 成果分类
			<span style="font-size:12px;line-height:41px;float:right;font-family;padding-right:70px">
			</span>
		</div>
		<div class="row-title-zh yxdh"><img src="calis\images\b.png"> &nbsp; 被收录情况
			<span style="font-size:12px;line-height:41px;float:right;font-family;padding-right:70px">
			</span>
		</div>
		<div style="clear: both"></div>
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
