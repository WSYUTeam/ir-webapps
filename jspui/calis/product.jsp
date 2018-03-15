<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Page that displays the email/password login form
  --%>

<%@ page contentType="text/html;charset=UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace"%>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>

<%@ page import="org.dspace.content.*"%>
<%@ page import="org.dspace.core.Context"%>
<%@ page import="org.dspace.browse.*"%>
<%@ page import="org.dspace.eperson.*"%>
<%@ page import="org.dspace.sort.*"%>
<%@ page import="org.apache.commons.lang.*"%>
<%@ page import="java.util.*"%>
<%@ page import="edu.calis.ir.pku.components.*"%>
<%
	Item item = (Item) request.getAttribute("shekebu_item");
	Product product = (Product) request.getAttribute("shekebu_product");
	boolean is_add_item = false;
	boolean is_add_product = false;
	String author = "";
	String contributor = "";
	String keyword = "";
	String alternative = "";
	String issued = "";
	String publisher = "";
	String abs = "";
	String type = "";
	if (item == null) {
		is_add_item = true;
		is_add_product = true;
	} else {
		if (product == null) {
			is_add_product = true;
		}
		DCValue[] dcvs = item.getMetadata("dc.contributor.author");
		for (int i = 0; i < dcvs.length; i++) {
			author += dcvs[i].value + ";";
		}
		if (author.length() > 0) {
			author = author.substring(0, (author.length() - 1));
		}

		dcvs = null;
		dcvs = item.getMetadata("dc.contributor");
		for (int i = 0; i < dcvs.length; i++) {
			contributor += dcvs[i].value + ";";
		}
		if (contributor.length() > 0) {
			contributor = contributor.substring(0,
					(contributor.length() - 1));
		}

		dcvs = null;
		dcvs = item.getMetadata("dc.subject");
		for (int i = 0; i < dcvs.length; i++) {
			keyword += dcvs[i].value + ";";
		}
		if (keyword.length() > 0) {
			keyword = keyword.substring(0, (keyword.length() - 1));
		}

		dcvs = null;
		dcvs = item.getMetadata("dc.title.alternative");
		if (dcvs != null && dcvs.length > 0) {
			alternative = dcvs[0].value;
		}

		dcvs = null;
		dcvs = item.getMetadata("dc.date.issued");
		if (dcvs != null && dcvs.length > 0) {
			issued = dcvs[0].value;
		}

		dcvs = null;
		dcvs = item.getMetadata("dc.publisher");
		if (dcvs != null && dcvs.length > 0) {
			publisher = dcvs[0].value;
		}

		dcvs = null;
		dcvs = item.getMetadata("dc.description.abstract");
		if (dcvs != null && dcvs.length > 0) {
			abs = dcvs[0].value;
		}
		
		dcvs = null;
		dcvs = item.getMetadata("dc.type");
		if (dcvs != null && dcvs.length >0 ) {
			type = dcvs[0].value;
		}
	}
%>

<script src="<%=request.getContextPath()%>/jquery-1.6.4.min.js"
	charset="utf-8"></script>
<script src="<%=request.getContextPath()%>/jquery.json-2.3.min.js"
	charset="utf-8"></script>
<dspace:layout titlekey="jsp.shekebu.title" nocache="true">
	<script type="text/javascript">
	//去除字符串首尾空格
	String.prototype.trim = function()
	 {
	     return this.replace(/(^\s*)|(\s*$)/g, "");
	 }
	
	  //判断输入框中输入的日期格式是否为 yyyy-mm-dd   或yyyy-m-d
	   function isDate(dateString){
		  if(dateString.trim() == '') {
			  return true;
		  }
		  //年月日正则表达式
		 var r=dateString.match(/^(\d{4})(-|\/)(\d{2})\2(\d{2})$/); 
		   if(r==null){
		   alert("请输入格式正确的日期\n\r日期格式：yyyy-mm-dd\n\r例    如：2008-08-08\n\r");
		   return false;
		  }
		        var d=new Date(r[1],r[3]-1,r[4]);   
		  var num = (d.getFullYear()==r[1]&&(d.getMonth()+1)==r[3]&&d.getDate()==r[4]);
		  if(num==0){
		   alert("请输入格式正确的日期\n\r日期格式：yyyy-mm-dd\n\r例    如：2008-08-08\n\r");
		  }
		  return (num!=0);
		  
		}  	
	
		function checkForm() {
			if($('#dc_title').val().trim() == '') {
				alert('标题不能为空！');
				return false;
			}
			if($('#dc_contributor_author').val().trim() == '') {
				alert('作者姓名不能为空！');
				return false;
			} 
			if($('#dc_contributor').val().trim() == '') {
				alert('作者单位不能为空！');
				return false;
			} 
			if($('#dc_date_issued').val().trim() == '') {
				alert('发表/出版时间不能为空！');
				return false;
			} else {
				if(!isDate($('#dc_date_issued').val())){
					return false;
				}
			}
			if($('#dc_publisher').val().trim() == '') {
				alert('出版社/刊名不能为空！');
				return false;
			}
			if($('#dc_subject').val().trim() == '') {
				alert('关键词不能为空！');
				return false;
			} 
			if($('#unitId').val().trim() == '') {
				alert('请选择成果所属单位！');
				return false;
			}
			if($('#projectSourceId').val().trim() == '') {
				alert('请选择成果来源！');
				return false;
			}
			if($('#subjectId').val().trim() == '') {
				alert('请选择成果学科门类！');
				return false;
			}
			if($('#productResearchTypeId').val().trim() == '') {
				alert('请选择成果研究类别！');
				return false;
			}
			
			if($('#ispublish').length > 0 && $('#ispublish').val().trim() == '') {
				alert('请选择是否公开发表！');
				return false;
			} else {
				if($('#publishRangeId').length > 0 && $('#publishRangeId').val().trim() == '') {
					alert('请选择发表范围！');
					return false;
				}
			}
			if($('#istranslated').length > 0 && $('#istranslated').val().trim() == '') {
				alert('请选择是否译成外文！');
				return false;
			}
			if($('#productApplicationTypeId').length > 0 && $('#productApplicationTypeId').val().trim() == '') {
				alert('请选择是否提交有关部门！');
				return false;
			}
			if($('#isaccept').length > 0 && $('#isaccept').val().trim() == '') {
				alert('请选择是否被采纳！');
				return false;
			}
			if($('#productType').length > 0 && $('#productType').val().trim() == '') {
				alert('请选择著作类别！');
				return false;
			} else {
				if($('#productType').val().trim() == "专著") {
					if($('#istranslateforeign').val().trim() == '') {
						alert('由于成果为专著，因此请选择是否译成外文！');
						return false;
					}
				}
			}
			return true;
		}
	</script>
	<div id="signup_form">
		<h2>
			※
			<%
				if(product != null) {
			%>
			<fmt:message key="jsp.shekebu.view" />
			<%
				} else {
			%>
			<fmt:message key="jsp.shekebu.title" />
			<%
				}
			%>
		</h2>
		<br />
		<form method="post"
			action="<%=request.getContextPath()%>/product?action=<%=is_add_product?"add":"update" %>"
			onsubmit="return checkForm();">

			<fieldset id="fieldset_store">
				<legend>基本信息</legend>

				<h2 id="signup_store">基本信息</h2>

				<dl>

					<dt>
						<input type="hidden" id="item_id" name="item_id"
							value="<%=item.getID()%>" />
					</dt>

					<dt>
						<label for="account_store_name">成果名称<span
							style="color: red;">(*)</span> </label>
					</dt>
					<dd>
						<input type="text" value="<%=item.getName()%>" size="100"
							name="dc_title" maxlength="100" id="dc_title" autocomplete="off">
					</dd>

					<dt>
						<label for="account_store_name">其他名称</label>
					</dt>
					<dd>
						<input type="text" value="<%=alternative%>" size="100"
							name="dc_title_alternative" maxlength="100"
							id="dc_title_alternative" autocomplete="off">
						<p>如英文名称、副标题</p>
					</dd>

					<dt>
						<label for="account_store_name">作者列表<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<input type="text" value="<%=author%>" size="100"
							name="dc_contributor_author" maxlength="100"
							id="dc_contributor_author" autocomplete="off">
						<p>按发表顺序排列，分号分隔</p>
					</dd>

					<dt>
						<label for="account_store_name">作者单位<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<input type="text" value="<%=contributor%>" size="100"
							name="dc_contributor" maxlength="100" id="dc_contributor"
							autocomplete="off">
						<p>按发表顺序排列，分号分隔</p>
					</dd>

					<dt>
						<label for="account_store_name">发表/出版时间<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<input type="text" value="<%=issued%>" size="100"
							name="dc_date_issued" maxlength="100" id="dc_date_issued"
							autocomplete="off">
						<p>格式：2013-06-08，需精确到日，若日不清楚，就默认为每月1日</p>
					</dd>
					<%
						if(!type.equals("ResearchReport")) {
					%>
					<dt>
						<label for="account_store_name">发行商/出版社/刊名<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<input type="text" value="<%=publisher%>" size="100"
							name="dc_publisher" maxlength="100" id="dc_publisher"
							autocomplete="off">
					</dd>
					<%
						}
					%>
					<dt>
						<label for="account_store_name">关键词<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<input type="text" value="<%=keyword%>" size="100"
							name="dc_subject" maxlength="100" id="dc_subject"
							autocomplete="off">
						<p>分号分隔</p>
					</dd>

					<dt>
						<label for="account_store_name">成果摘要</label>
					</dt>
					<dd>
						<textarea name="dc_description_abstract" maxlength="100"
							id="dc_description_abstract" cols="48" rows="6"><%=abs%></textarea>
					</dd>
				</dl>
			</fieldset>

			<fieldset id="fieldset_orders">
				<legend>学术成果基本属性</legend>

				<h2 id="signup_paypal">学术成果基本属性</h2>
				<dl>
					<dt>
						<label for="account_store_name">成果属于<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<select name="unitId" id="unitId">
							<option value="">请选择所属单位</option>
							<option value="479">对外汉语教育学院</option>
							<option value="477">法学院</option>
							<option value="1797">歌剧研究院</option>
							<option value="478">光华管理学院</option>
							<option value="495">国际关系学院</option>
							<option value="481">国家发展研究院</option>
							<option value="480">教育学院</option>
							<option value="482">经济学院</option>
							<option value="483">考古文博学院</option>
							<option value="500">历史学系</option>
							<option value="484">马克思主义学院</option>
							<option value="485">人口研究所</option>
							<option value="1735">社会科学部</option>
							<option value="486">社会学系</option>
							<option value="487">体育教研部</option>
							<option value="488">图书馆</option>
							<option value="489">外国语学院</option>
							<option value="1733">心理学系</option>
							<option value="491">新闻与传播学院</option>
							<option value="490">信息管理系</option>
							<option value="1734">医学部公共教学部</option>
							<option value="496">艺术学院</option>
							<option value="493">哲学系</option>
							<option value="492">政府管理学院</option>
							<option value="497">中国语言文学系</option>
						</select>
					</dd>

					<dt>
						<label for="account_store_name">成果来源<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<select name="projectSourceId" id="projectSourceId">
							<option value="">请选择成果来源</option>
							<option value="999">无依托项目研究成果</option>
							<option value="04">国家社科基金项目</option>
							<option value="03">国家社科基金单列学科项目</option>
							<option value="06">国家自然科学基金项目</option>
							<option value="05">教育部人文社科研究项目</option>
							<option value="051">全国教育科学规划（教育部）项目</option>
							<option value="07">中央其他部门社科专门项目</option>
							<option value="09">省、市、自治区社科基金项目</option>
							<option value="10">省教育厅社科项目</option>
							<option value="11">地、市、厅、局等政府部门项目</option>
							<option value="15">学校社科项目</option>
							<option value="08">高校古籍整理研究项目</option>
							<option value="12">国际合作研究项目</option>
							<option value="13">与港、澳、台合作研究项目</option>
							<option value="14">企事业单位委托项目</option>
							<option value="16">外资项目</option>
							<option value="99">其他研究项目</option>
						</select>
					</dd>

					<dt>
						<label for="account_store_name">学科门类<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<select name="subjectId" id="subjectId">
							<option value="">请选择学科门类</option>
							<option value="630">管理学</option>
							<option value="820">法学</option>
							<option value="GAT">港澳台研究</option>
							<option value="GJW">国际问题研究</option>
							<option value="880">教育学</option>
							<option value="790">经济学</option>
							<option value="780">考古学</option>
							<option value="770">历史学</option>
							<option value="72040">逻辑学</option>
							<option value="710">马克思主义</option>
							<option value="850">民族学</option>
							<option value="840">社会学</option>
							<option value="890">体育学</option>
							<option value="910">统计学</option>
							<option value="870">图书馆、情报与文献学</option>
							<option value="75047-99">外国文学</option>
							<option value="XLX">心理学</option>
							<option value="860">新闻学与传播学</option>
							<option value="760">艺术学</option>
							<option value="740">语言学</option>
							<option value="720">哲学</option>
							<option value="810">政治学</option>
							<option value="75011-44">中国文学</option>
							<option value="730">宗教学</option>
						</select>
					</dd>

					<dt>
						<label for="account_store_name">研究类别<span
							style="color: red;">(*)</span>
						</label>
					</dt>
					<dd>
						<select name="productResearchTypeId" id="productResearchTypeId">
							<option value="">请选择研究类别</option>
							<option value="1">基础研究</option>
							<option value="2">应用研究</option>
						</select>
					</dd>
				</dl>
			</fieldset>

			<fieldset id="fieldset_you">
				<legend>学术成果个别属性</legend>

				<h2 id="signup_you">学术成果个别属性</h2>

				<dl>
				<%
					if(!type.equals("")) {
						if(type.equals("Book")) {
				%>
					<dt>
						<label for="account_store_name">著作类别<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="productType" id="productType">
							<option value="">请选择著作类别</option>
							<option value="专著">专著</option>
							<option value="编著或教材">编著或教材</option>
							<option value="工具书或参考书">工具书或参考书</option>
							<option value="古籍整理著作">古籍整理著作</option>
							<option value="译著">译著</option>
						</select>
					</dd>
					
					<dt>
						<label for="account_store_name">是否译成外文（针对专著）<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="istranslated" id="istranslated">
							<option value="">请选择是否译成外文</option>
							<option value="0">否</option>
							<option value="1">是</option>
						</select>
					</dd>
					
					<%
						} else if(type.equals("Literature") || type.equals("MeetingThesis")) {
					%>
					
					<dt>
						<label for="account_store_name">是否公开发表<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="ispublish" id="ispublish">
							<option value="">请选择是否公开发表</option>
							<option value="0">否</option>
							<option value="1">是</option>
						</select>
					</dd>
				
					<dt>
						<label for="account_store_name">发表范围<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="publishRangeId" id="publishRangeId">
							<option value="">请选择发表范围</option>
							<option value="1">国外学术刊物</option>
							<option value="2">国内外公开发行</option>
							<option value="3">国内公开发行</option>
							<option value="4">港澳台刊物</option>
						</select>
					</dd>
					<%
							if(type.equals("Literature")) {
					%>
					<dt>
						<label for="account_store_name">是否从外文翻译而来<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="istranslateforeign" id="istranslateforeign">
							<option value="">请选择是否从外文翻译而来</option>
							<option value="0">否</option>
							<option value="1">是</option>
						</select>
					</dd>
					<%
							}
						} else if (type.equals("Book chapter")) {
					%>
					<dt>
						<label for="account_store_name">是否从外文翻译而来<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="istranslateforeign" id="istranslateforeign">
							<option value="">请选择是否从外文翻译而来</option>
							<option value="0">否</option>
							<option value="1">是</option>
						</select>
					</dd>
					<%
						} else if(type.equals("ResearchReport")) {
					%>
					<dt>
						<label for="account_store_name">是否提交有关部门<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="productApplicationTypeId"
							id="productApplicationTypeId">
							<option value="">请选择是否提交有关部门</option>
							<option value="1">提交有关部门</option>
							<option value="2">得到鉴定</option>
							<option value="3">其他</option>
						</select>
					</dd>

					<dt>
						<label for="account_store_name">是否被采纳<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="isaccept" id="isaccept">
							<option value="">请选择是否被采纳</option>
							<option value="0">否</option>
							<option value="1">是</option>
						</select>
					</dd>
					
					<%
						} else {
					%>
					<dt>
						<label for="account_store_name">是否公开发表<span
							style="color: red;">(*)</span></label>
					</dt>
					<dd>
						<select name="ispublish" id="ispublish">
							<option value="">请选择是否公开发表</option>
							<option value="0">否</option>
							<option value="1">是</option>
						</select>
					</dd>
					<%
						}
					}
					%>
				</dl>
			</fieldset>

			<div id="form_footer">
				<button type="submit" title="提交" id="btn_sign_up" class="button">
					<span>提交</span>
				</button>
				<button type="button" title="返回" id="btn_sign_up" class="button" onclick="javascript: history.back(-1);">
					<span>返回</span>
				</button>
			</div>
		</form>
	</div>
<%
	if(product != null) {
%>
<script type="text/javascript">
	$('#unitId').val('<%=product.getBelongto() %>');
	$('#projectSourceId').val('<%=product.getProjectSourceId() %>');
	$('#subjectId').val('<%=product.getSubjectId() %>');
	$('#productResearchTypeId').val('<%=product.getProductResearchTypeId() %>');
	$('#publishRangeId').val('<%=product.getPublishRangeId() %>');
	$('#istranslated').val('<%=product.getIstranslated() %>');
	$('#productApplicationTypeId').val('<%=product.getProductApplicationTypeId() %>');
	$('#isaccept').val('<%=product.getIsaccept() %>');
	$('#ispublish').val('<%=product.getIspublish() %>');
	$('#productType').val('<%=product.getProductType() %>');
	$('#istranslateforeign').val('<%=product.getIstranslateforeing() %>');
</script>
<%
	}
%>
</dspace:layout>