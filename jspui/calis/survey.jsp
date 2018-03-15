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

<style type="text/css">

.question-content label {
    display: block;
    float: left;
    padding: 8px 0;
    width: 100%;
}

.table-square {
    border: 1px solid #D8D8D8;
    border-collapse: collapse;
    border-spacing: 0;
}
.table-square .odd {
    background: none repeat scroll 0 0 #F8F8F8;
}
.table-square th, .table-square td {
    border-bottom: 1px solid #D8D8D8;
    font-size: 12px;
    line-height: 18px;
    padding: 7px;
    text-align: center;
    vertical-align: middle;
}
.table-square td {
    width: 70px;
}
.table-square td {
    padding: 0;
    vertical-align: middle;
}
.table-square thead th, .table-square thead td {
    background: none repeat scroll 0 0 #6C6C6C;
    color: #FFFFFF;
}
</style>

<script type="text/javascript">
	function checkSubmit(){
		var flag = true;
		$$('#integrity')[0].value = true;
		var ss = "aid-001|aid-002|aid-003|aid-004|aid-005|qid-02|qid-03";
		var radios = ss.split("|");
		for(var i=0; i < radios.length; i++){
			var idxs = $$('input[type="radio"][name="' + radios[i] + '"]');
			var nodes=$A(idxs);
			nodes.each(function(node){
				if(node.checked){
					flag = true;
					throw $break;
				} else {
					flag = false;
				}
			});
			if(!flag) {
				$$('#integrity')[0].value = false;
				return;
			}
		}
	}
	
	if(<%=request.getAttribute("survey_flag")%>) {
		alert("感谢您参与我们的问卷调查！");
		window.close();
	}
</script>

<dspace:layout navbar="off" locbar="off"
	titlekey="jsp.survey.title" nocache="true">
	<div id="bodyPan">
	<form id="calis_survey" action="<%=request.getContextPath()%>/survey" method="post" onsubmit="checkSubmit()">
	<div class="survey-hd">
		<h1>北京大学机构知识库新版页面反馈</h1>
		<div>&nbsp;</div>
		<div>
			<span
				style="FONT-FAMILY: 宋体; COLOR: #404040; FONT-SIZE: 12pt; mso-ascii-font-family: Tahoma; mso-hansi-font-family: Tahoma; mso-bidi-font-family: Tahoma; mso-font-kerning: 0pt; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA"><strong>亲爱的用户：</strong>
			</span><span lang="EN-US"
				style="FONT-FAMILY: 'Tahoma', 'sans-serif'; COLOR: #404040; FONT-SIZE: 12pt; mso-font-kerning: 0pt; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA; mso-fareast-font-family: 宋体"><br>
			</span><span
				style="FONT-FAMILY: 宋体; COLOR: #404040; FONT-SIZE: 12pt; mso-ascii-font-family: Tahoma; mso-hansi-font-family: Tahoma; mso-bidi-font-family: Tahoma; mso-font-kerning: 0pt; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA"><strong>您对北京大学机构知识库新首页有任何建议，或使用中遇到问题，请在本问卷反馈。</strong>
			</span><span lang="EN-US"
				style="FONT-FAMILY: 'Tahoma', 'sans-serif'; COLOR: #404040; FONT-SIZE: 12pt; mso-font-kerning: 0pt; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA; mso-fareast-font-family: 宋体"><br>
			</span>
		</div>
	</div>
	<div style="padding: 20px;">
		<input type="hidden" name="integrity" id="integrity" value="true" />
		<div dataset="" data="" class="question-item" id="question_01">
			<div>
				<strong><font style="font-size: 12.0pt;">一、对北京大学机构知识库新版首页的以下各个方面，您的满意程度如何？（横向单选）</font>
				</strong>
			</div>
			<div class="question-content">
				<table class="table-square">
					<thead>
						<tr>
							<th></th>
							<th>非常不满意</th>
							<th>比较不满意</th>
							<th>一般</th>
							<th>比较满意</th>
							<th>非常满意</th>
						</tr>
					</thead>
					<tbody>
						<tr class="odd">
							<th style="text-align: right;">页面打开快速</th>
							<th><label> <input type="radio"
									value="001:175539" name="aid-001"> </label></th>
							<th><label> <input type="radio"
									value="001:175540" name="aid-001"> </label></th>
							<th><label> <input type="radio"
									value="001:175541" name="aid-001"> </label></th>
							<th><label> <input type="radio"
									value="001:175542" name="aid-001"> </label></th>
							<th><label> <input type="radio"
									value="001:175543" name="aid-001"> </label></th>
						</tr>
						<tr>
							<th style="text-align: right;">界面设计美观</th>
							<th><label> <input type="radio"
									value="002:175539" name="aid-002"> </label></th>
							<th><label> <input type="radio"
									value="002:175540" name="aid-002"> </label></th>
							<th><label> <input type="radio"
									value="002:175541" name="aid-002"> </label></th>
							<th><label> <input type="radio"
									value="002:175542" name="aid-002"> </label></th>
							<th><label> <input type="radio"
									value="002:175543" name="aid-002"> </label></th>
						</tr>
						<tr class="odd">
							<th style="text-align: right;">排版展现合理</th>
							<th><label> <input type="radio"
									value="003:175539" name="aid-003"> </label></th>
							<th><label> <input type="radio"
									value="003:175540" name="aid-003"> </label></th>
							<th><label> <input type="radio"
									value="003:175541" name="aid-003"> </label></th>
							<th><label> <input type="radio"
									value="003:175542" name="aid-003"> </label></th>
							<th><label> <input type="radio"
									value="003:175543" name="aid-003"> </label></th>
						</tr>
						<tr>
							<th style="text-align: right;">信息分类很方便操作</th>
							<th><label> <input type="radio"
									value="004:175539" name="aid-004"> </label></th>
							<th><label> <input type="radio"
									value="004:175540" name="aid-004"> </label></th>
							<th><label> <input type="radio"
									value="004:175541" name="aid-004"> </label></th>
							<th><label> <input type="radio"
									value="004:175542" name="aid-004"> </label></th>
							<th><label> <input type="radio"
									value="004:175543" name="aid-004"> </label></th>
						</tr>
						<tr class="odd">
							<th style="text-align: right;">资料信息展示清晰</th>
							<th><label> <input type="radio"
									value="005:175539" name="aid-005"> </label></th>
							<th><label> <input type="radio"
									value="005:175540" name="aid-005"> </label></th>
							<th><label> <input type="radio"
									value="005:175541" name="aid-005"> </label></th>
							<th><label> <input type="radio"
									value="005:175542" name="aid-005"> </label></th>
							<th><label> <input type="radio"
									value="005:175543" name="aid-005"> </label></th>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div dataset="" data="" class="question-item" id="question_02">
			<div>
				<font style="font-size: 12.0pt;"><strong>二、您使用北京大学机构知识库新版页面的过程中，总体的满意程度如何？（单选）</strong>
				</font>
			</div>
			<div class="question-content col-1 type-1 ">
				<div>
					<label id="question_"> <input type="radio" value="175544"
						id="aid-006" name="qid-02"> 非常不满意 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175545"
						id="aid-007" name="qid-02"> 比较不满意 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175546"
						id="aid-008" name="qid-02"> 一般 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175547"
						id="aid-009" name="qid-02"> 比较满意 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175548"
						id="aid-010" name="qid-02"> 非常满意 </label>
				</div>
			</div>
		</div>

		<div dataset="" data="" class="question-item" id="question_03">
			<div>
				<font style="font-size: 12.0pt;"><strong>三、您的身份是？（单选）</strong>
				</font>
			</div>
			<div class="question-content col-1 type-1 ">
				<div>
					<label id="question_"> <input type="radio" value="175549"
						id="aid-011" name="qid-03"> 研究人员 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175550"
						id="aid-012" name="qid-03"> 教师 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175551"
						id="aid-013" name="qid-03"> 博士研究生 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175552"
						id="aid-014" name="qid-03"> 研究生 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175553"
						id="aid-015" name="qid-03"> 本科生 </label>
				</div>
				<div>
					<label id="question_"> <input type="radio" value="175554"
						id="aid-016" name="qid-03"> 其他 </label>
				</div>
			</div>
		</div>

		<div dataset="" data="" class="question-item" id="question_04">
			<div>
				<font style="font-size: 12.0pt;"><strong>四、您常用的联系电话是？（请填写）</strong>
				</font>
			</div>
			<div class="msg">
				<span class="tips naked">请尽量填写，如有需要我们会及时联系您和给您回复。</span>
			</div>
			<div class="question-content">
				<input type="text" value="" name="qid-04"
					class="text-input J_InputText" id="textarea1">
				<div style="display: none;" class="msg">
					<p class="attention">最多可输入140个字符</p>
				</div>
				<div style="display: none;" class="msg">
					<p class="error">
						您输入的信息超过<span></span> 个字符
					</p>
				</div>
			</div>
		</div>

		<div dataset="" data="" class="question-item" id="question_05">
			<div>
				<font style="font-size: 12.0pt;"><strong>五、您的姓名是？（请填写）</strong>
				</font>
			</div>
			<div class="msg">
				<span class="tips naked">请尽量填写，如有需要我们会及时联系您和给您回复。</span>
			</div>
			<div class="question-content">
				<input type="text" value="" name="qid-05"
					class="text-input J_InputText" id="textarea1">
				<div style="display: none;" class="msg">
					<p class="attention">最多可输入140个字符</p>
				</div>
				<div style="display: none;" class="msg">
					<p class="error">
						您输入的信息超过<span></span> 个字符
					</p>
				</div>
			</div>
		</div>
	</div>
	<div class="survey-ft">
		<div class="pagenav-bottom">
			<button type="submit" class="long-btn" id="submitForm">提交问卷</button>
		</div>
	</div>
	</form>
	</div>
	<br/>
</dspace:layout>
