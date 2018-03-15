<%@ page contentType="text/html;charset=UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace"%>
<%-- add by weicf 2013.04.12 --%>
<%@ taglib uri="http://www.dspace.org/commenting-tags.tld"
	prefix="commenting"%>
<%-- add by weicf --%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.Constants"%>
<%@ page import="org.dspace.core.Context"%>
<%@ page import="org.dspace.content.Community"%>
<%@ page import="org.dspace.eperson.EPerson"%>
<%@ page import="edu.calis.ir.pku.components.Unit" %>
<%@ page import="edu.calis.ir.pku.components.Researcher" %>
<%@ page import="edu.calis.ir.pku.util.PKUUtils"%>
<%@ page import="org.apache.commons.lang.*"%>
<%@ page import="java.util.*" %>

<%
	EPerson user = (EPerson) request
			.getAttribute("dspace.current.user");
	Researcher r = (Researcher)request.getAttribute("dspace.researcher");
	String template = (String)request.getAttribute("dspace.researcher.template");
	
	Boolean admin = (Boolean)request.getAttribute("is.admin");
	boolean isAdmin = (admin == null ? false : admin.booleanValue());
%>

<script src="../jquery-1.6.4.min.js" charset="utf-8"></script>
<script src="../jquery.json-2.3.min.js" charset="utf-8"></script>
<script type="text/javascript">
		
	function checkForm() {
		if($('#uid').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.form.uid.valid"/>');
			return false;
		}
		if($('#name').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.form.name.valid"/>');
			return false;
		}
		if($('input:radio[name="sex"]:checked').val() == null) {
			alert('<fmt:message key="jsp.dspace-admin.researcher.form.sex.valid"/>');
			return false;
		}
		if($('#title').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.form.title.valid"/>');
			return false;
		}
		if($('#unitId').val() == -1) {
			alert('<fmt:message key="jsp.dspace-admin.researcher.form.unit.valid"/>');
			return false;
		}
		if($('#field').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.form.field.valid"/>');
			return false;
		}
		if($('#imageurl').val() == 'http://') {
			$('#imageurl').val('');
		}
		return true;
	}
	
	function checkForm2() {
		if($('#unitId').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.unit.id.valid" />');
			return false;
		}
		if($('#name').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.unit.name.valid" />');
			return false;
		}
		if($('#interface').val() == 'http://') {
			$('#interface').val('');
		}
		return true;
	}
	
	function checkForm3() {
		if($('#departmentId').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.department.id.valid" />');
			return false;
		}
		if($('#name').val() == '') {
			alert('<fmt:message key="jsp.dspace-admin.researcher.department.name.valid" />');
			return false;
		}
		return true;
	}
</script>

<dspace:layout titlekey="jsp.dspace-admin.researcher.title"
	locbar="off" parenttitlekey="jsp.mydspace"
	parentlink="/mydspace" nocache="true">
	<div id="signup_form">	
	<h2>| <%=(String)request.getAttribute("dspace.researcher.msg")%></h2>
	<br/>
	<%
		if("add_unit".equals(template)) {
	%>
	<form method="post" action="<%=request.getContextPath()%>/dspace-admin/researcher?action=addunit" onsubmit="return checkForm2();">
				
		<fieldset id="fieldset_store">		
			<legend><fmt:message key="jsp.dspace-admin.researcher.info"/></legend>
			
			<h2 id="signup_store"><fmt:message key="jsp.dspace-admin.researcher.info"/></h2>
			
			<dl>	
				<dt><label for="account_store_name">Unit ID(*)</label></dt>
				<dd>
					<input type="text" value="" size="100" name="unitId" maxlength="100" id="unitId" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.unit.name" />(*)</label></dt>
				<dd>
					<input type="text" value="" size="100" name="name" maxlength="100" id="name" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.unit.interface" /></label></dt>
				<dd>
					<input type="text" value="http://" size="100" name="interface" maxlength="100" id="interface" autocomplete="off">
				</dd>
			</dl>
		</fieldset>
		
		<div id="form_footer">			
			<button type="submit" title="<fmt:message key="jsp.dspace-admin.researcher.submit" />" id="btn_sign_up" class="button"><span><fmt:message key="jsp.dspace-admin.researcher.submit" /></span></button>					
		</div>	
	</form>
	<%
		} else if("add_department".equals(template)) {
			String unitId = (String) request.getAttribute("dspace.researcher.unit.id");
			String name = (String) request.getAttribute("dspace.researcher.unit.name");
	%>
	<form method="post" action="<%=request.getContextPath()%>/dspace-admin/researcher?action=adddepartment" onsubmit="return checkForm3();">
				
		<fieldset id="fieldset_store">		
			<legend><fmt:message key="jsp.dspace-admin.researcher.info"/></legend>
			
			<h2 id="signup_store"><fmt:message key="jsp.dspace-admin.researcher.info"/></h2>
			
			<dl>	
				
				<dt><fmt:message key="jsp.dspace-admin.researcher.department.unit" /></dt>
				<dd>
					<input type="text" value="<%=name %>" disabled="disabled"/>
					<input type="hidden" value="<%=unitId%>" name="unitId" />
				</dd>
				
				<dt><label for="account_store_name">Department ID(*)</label></dt>
				<dd>
					<input type="text" value="" size="100" name="departmentId" maxlength="100" id="departmentId" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.department.name" />(*)</label></dt>
				<dd>
					<input type="text" value="" size="100" name="name" maxlength="100" id="name" autocomplete="off">
				</dd>
			</dl>
		</fieldset>
		
		<div id="form_footer">			
			<button type="submit" title="<fmt:message key="jsp.dspace-admin.researcher.submit" />" id="btn_sign_up" class="button"><span><fmt:message key="jsp.dspace-admin.researcher.submit" /></span></button>					
		</div>	
	</form>
	<%
		} else {
			Map<String, String> userInfoMap = null;
			if( r==null ) {
				userInfoMap = (Map<String, String>) request.getSession().getAttribute("researcher.user.info.map");
			}
	%>
	<form method="post" action="<%=request.getContextPath()%>/researcher?action=<%=(r!=null?("update&uid="+r.getUid()):"add") %>" enctype="multipart/form-data" onsubmit="return checkForm();">
				
		<fieldset id="fieldset_store">		
			<legend><fmt:message key="jsp.dspace-admin.researcher.info"/></legend>
			
			<h2 id="signup_store"><fmt:message key="jsp.dspace-admin.researcher.info"/></h2>
			
			<dl>								
				<dt><label for="account_store_name">UID(*)</label></dt>
				<dd>
					<input type="text" value="<%=(r!=null?r.getUid():user.getNetid()) %>" readonly="readonly" size="100" name="uid" maxlength="100" id="uid" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.name"/>(*)</label></dt>
				<dd>
					<input type="text" value="<%=(r!=null?r.getName():user.getFullName()) %>" size="100" name="name" maxlength="100" id="name" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.orcid"/></label></dt>
				<dd>
					<input type="text" value="<%=((r!=null&&r.getOrcid()!=null)?r.getOrcid():"") %>" size="100" name="orcid" maxlength="100" id="orcid" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.academic-name"/></label></dt>
				<dd>
					<input type="text" value="<%=((r!=null&&r.getAcademicName()!=null)?r.getAcademicName():"") %>" size="100" name="academicName" maxlength="100" id="academicName" autocomplete="off">
					<p><fmt:message key="jsp.dspace-admin.researcher.form.academic-name.tip1"/></p>
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.sex"/>(*)</label></dt>
				<dd>
					<input type="radio" name="sex" id="sex" value="1" <%=((r==null&&userInfoMap.get("sex").equals("Male"))?"checked=\"checked\"":"") %> style="width: 50px;"/><div style="float: left; line-height: 30px; width: 100px;"><fmt:message key="jsp.dspace-admin.researcher.form.sex.male" /></div><input
					type="radio" name="sex" id="sex" value="0" <%=((r==null&&userInfoMap.get("sex").equals("Female"))?"checked=\"checked\"":"") %> style="width: 50px;"/><div style="float: left; line-height: 30px; width: 100px;"><fmt:message key="jsp.dspace-admin.researcher.form.sex.female" /></div>
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.title"/>(*)</label></dt>
				<dd>
					<input type="text" value="<%=((r!=null&&r.getTitle()!=null)?r.getTitle():"") %>" size="100" name="title" maxlength="100" id="title" autocomplete="off">
				</dd>
				
				<dt><label for="account_account_type_id"><fmt:message key="jsp.dspace-admin.researcher.form.unit"/>(*)</label></dt>
				<dd>
					<select id="unitId" name="unitId" class="form-control">
					<option selected="selected" value="-1"><fmt:message key="jsp.submit.start-lookup-submission.select.collection.defaultoption"/></option>
					<%
					Context c = UIUtil.obtainContext(request);
					Community[] subCommunity = null;
					subCommunity = PKUUtils.getSubcommunities(c, Community.findAllTop(c)[0].getID(), "ASC");
					for (int i = 0; i < subCommunity.length; i++) {
					%>
						<option value="<%=subCommunity[i].getID() %>"><%=subCommunity[i].getName() %></option>
					<%
					}
					%>
					</select>
				</dd>			
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.field"/>(*)</label></dt>
				<dd>
					<input type="text" value="<%=((r!=null&&r.getField()!=null)?r.getField():"") %>" size="100" name="field" maxlength="100" id="field" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.education"/></label></dt>
				<dd>
					<input type="text" value="<%=(r!=null?(r.getEducation()==null?"":r.getEducation()):userInfoMap.get("education")) %>" size="100" name="education" maxlength="100" id="education" autocomplete="off">
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.phone"/></label></dt>
				<dd>
					<input type="text" value="<%=(r!=null?(r.getPhone()==null?"":r.getPhone()):"") %>" size="100" name="phone" maxlength="100" id="phone" autocomplete="off">
				</dd>
				
				<dt><label for="account_subdomain">Email</label></dt>
				<dd id="subdomain">
					<input type="text" value="<%=(r!=null?(r.getEmail()==null?"":r.getEmail()):"") %>" size="100" name="email" maxlength="100" id="email" autocomplete="off">
				</dd>	
				
				<dt><label for="account_subdomain"><fmt:message key="jsp.dspace-admin.researcher.form.url"/></label></dt>
				<dd id="subdomain">
					<input type="text" value="<%=(r!=null?(r.getUrl()==null?"":r.getUrl()):"") %>" size="100" name="url" maxlength="100" id="url" autocomplete="off">
				</dd>		
			</dl>		
		</fieldset>
		
		<fieldset id="fieldset_orders">
			<legend><fmt:message key="jsp.dspace-admin.researcher.personalphoto" /></legend>
			
			<h2 id="signup_paypal"><fmt:message key="jsp.dspace-admin.researcher.personalphoto" /></h2>
			<% if(r!=null) {%>
			<dl>
				<dt><label for="account_paypal_email"><fmt:message key="jsp.dspace-admin.researcher.form.picture.has"/></label></dt>
				<dd>
					<%
						String image = r.getImage();
						if(StringUtils.isNotEmpty(image) && image.equals("calis-self")){
							String code = PKUUtils.encrypt(r.getUid(), "PkuLibIR");
							image = "<img src='" + request.getContextPath() + "/imageshow?spec=" + code + "' />";
							out.print(image);
						}
					%>
				</dd>
			</dl>
			<%} %>
			<dl>			
				<dt><label for="account_paypal_email"><fmt:message key="jsp.dspace-admin.researcher.form.picture"/></label></dt>
				<dd>
					<input name="image" type="file" size="50" accept="image/gif, image/jpeg, image/png"/>
					<p><fmt:message key="jsp.dspace-admin.researcher.form.picture.tip1"/></p>	
				</dd>
				
				<dt><label for="account_paypal_email"><fmt:message key="jsp.dspace-admin.researcher.form.picture.link"/></label></dt>
				<dd>
					<input type="text" value="http://" size="100" name="imageurl" maxlength="100" id="imageurl" autocomplete="off">
					<p><fmt:message key="jsp.dspace-admin.researcher.form.picture.tip2"/></p>	
				</dd>
			</dl>		
		</fieldset>
		
		<%
			if(isAdmin) {
		%>
		<fieldset id="fieldset_you">
			<legend><fmt:message key="jsp.dspace-admin.researcher.config" /></legend>
			
			<h2 id="signup_you"><fmt:message key="jsp.dspace-admin.researcher.config" /></h2>
			
			<dl>
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.flag"/>(*)</label></dt>
				<dd>
					<input type="radio" name="flag" id="flag" value="true" checked="checked" style="width: 50px;"/><div style="float: left; width: 100px;"><fmt:message key="jsp.dspace-admin.researcher.form.flag.yes"/></div><input
					type="radio" name="flag" id="flag" value="false" style="width: 50px;"/><div style="float: left; width: 100px;"><fmt:message key="jsp.dspace-admin.researcher.form.flag.no"/></div>
					<p><fmt:message key="jsp.dspace-admin.researcher.form.flag.tip"/></p>
				</dd>
				
				<dt><label for="account_store_name"><fmt:message key="jsp.dspace-admin.researcher.form.special"/>(*)</label></dt>
				<dd>
					<select name="special" id="special" onchange="go(this.value)">
					<option value="0"><fmt:message key="jsp.dspace-admin.researcher.form.special.mode1"/></option>
					<option value="1"><fmt:message key="jsp.dspace-admin.researcher.form.special.mode2"/></option>
					<option value="2"><fmt:message key="jsp.dspace-admin.researcher.form.special.mode3"/></option>
					</select>
					<p><fmt:message key="jsp.dspace-admin.researcher.form.special.tip"/></p>
				</dd>
			</dl>
		</fieldset>
		<%
			}
		%>
		
		<div id="form_footer">			
			<button type="submit" title="<fmt:message key="jsp.dspace-admin.researcher.submit"/>" id="btn_sign_up" class="button"><span><fmt:message key="jsp.dspace-admin.researcher.submit"/></span></button>					
		</div>		
	</form>
	<%
	}
	%>
</div>
<%
	if(r!=null){
%>
<script>
$("#unitId").get(0).value=<%=r.getUnitId()%>;
if(<%=r.getSex()%>){
	$("input[name='sex'][value=1]").attr("checked",true);
} else {
	$("input[name='sex'][value=0]").attr("checked",true);
}
if(<%=r.getFlag()%>){
	$("input[name='flag'][value=true]").attr("checked",true);
} else {
	$("input[name='flag'][value=false]").attr("checked",true);
}
$("#special").get(0).value='<%=r.getSpecial()%>';
</script>
<%
}
%>
</dspace:layout>