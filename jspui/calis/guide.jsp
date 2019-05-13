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

<%@ page import="org.dspace.core.Context"%>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@ page import="java.util.Locale"%>

<%
	Context context = null;
	context = UIUtil.obtainContext(request);
	Locale locale = context.getCurrentLocale();
%>

<dspace:layout locbar="off" titlekey="jsp.layout.navbar-default.about" nocache="true">
		<div
			style="font-size: 16px;padding: 0 20px;line-height: 28px;">&nbsp; &nbsp; &nbsp;
			<fmt:message key="jsp.home.about" />
		</div>
		<h1 class="yx_font">
			<fmt:message key="jsp.help.guide.title" />
		</h1>
		<div id="guide" style="margin-top: 25px;">
			<ul>
				<li><a href="#"
					onclick="var popupwin = window.open('<%=request.getContextPath()%>/help/index_<%=(locale.getLanguage() == "en" ? "en" : "zh_CN")%>.html','dspacepopup','height=600,width=550,resizable,scrollbars');popupwin.focus();return false;"><fmt:message
							key="jsp.help.guide.manual" /> </a></li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.manual.txt" />
			</div>
			<!-- <ul>
				<li><a
					href="<%=request.getContextPath()%>/help/WSYU_IR_policy_trial.pdf"
					target="_blank"><fmt:message key="jsp.help.guide.open.policy" />
				</a></li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.open.policy.txt" />
			</div> -->
			<!--<ul>
				<li><a
					href="<%=request.getContextPath()%>/help/WSYU_IR_license_agreement.pdf"
					target="_blank"><fmt:message key="jsp.help.guide.license" /> </a>
				</li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.license.txt" />
			</div>-->
			<!--<ul>
				<li><a
					href="<%=request.getContextPath()%>/help/WSYU_IR_power_attorney.pdf"
					target="_blank"><fmt:message key="jsp.help.guide.attorney" />
				</a></li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.attorney.txt" />
			</div>-->
			<!-- <ul>
				<li><a
					href="<%=request.getContextPath()%>/help/WSYU_IR_submission.pdf"
					target="_blank"><fmt:message
							key="jsp.help.guide.process.submission" /> </a></li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.process.submission.txt" />
			</div> -->
			<!-- <ul>
				<li><a
					href="<%=request.getContextPath()%>/help/WSYU_IR_format_recommended.pdf"
					target="_blank"><fmt:message
							key="jsp.help.guide.format.recommended" /> </a></li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.format.recommended.txt" />
			</div>-->
			<ul>
				<li><a
					href="<%=request.getContextPath()%>/help/WSYU_IR_withdraw.pdf"
					target="_blank"><fmt:message
							key="jsp.help.guide.process.withdraw" /> </a></li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.process.withdraw.txt" />
			</div>
			<ul>
				<li><a
					href="<%=request.getContextPath()%>/help/WSYU_application_form.xlsx"
					target="_blank"><fmt:message
							key="jsp.help.guide.process.add.modify.withdraw.application.form" /> </a></li>
			</ul>
			<div style="margin-left: 40px;">
				<fmt:message key="jsp.help.guide.process.add.modify.withdraw.application.form.txt" />
			</div>
		</div>
		<br />
	</div>
	<br />
</dspace:layout>
