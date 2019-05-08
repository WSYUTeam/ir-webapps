package server;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

@WebServlet("/cadre")
public class CadreList extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.setCharacterEncoding("UTF-8");
		response.setContentType("text/html;charset=UTF-8");
		int pageSize = 12;
		int offset = 0;
		int unitId = 0;
		String name = "";

		try {
			pageSize = Integer.parseInt(request.getParameter("pageSize"));
		} catch (Exception e) {
			// TODO: handle exception
		}

		try {
			offset = Integer.parseInt(request.getParameter("offset"));
		} catch (Exception e) {
			// TODO: handle exception
		}

		try {
			unitId = Integer.parseInt(request.getParameter("unitId"));
		} catch (Exception e) {
			// TODO: handle exception
		}

		try {
			name = (request.getParameter("name"));
		} catch (Exception e) {
			// TODO: handle exception
		}

		String url = "jdbc:postgresql://218.199.144.229:5432/calisir";
		String username = "dspace";
		String password = "dspace";
		Connection connection = null;

		try {
			Class.forName("org.postgresql.Driver").newInstance();
		} catch (InstantiationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			connection = DriverManager.getConnection(url, username, password);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		PreparedStatement pStatement = null;
		ResultSet rs = null;
		ArrayList mylist = null;

		String sqls = "select *,metadatavalue.text_value from researcher left "
				+ "join metadatavalue on researcher.unit_id = metadatavalue.resource_id "
				+ "where metadatavalue.resource_type_id = 4 and metadata_field_id = 64"
				+ "and researcher.academic_name like '%骨干教师';";

		if (unitId != 0) {
			sqls = "select *,metadatavalue.text_value from researcher left "
					+ "join metadatavalue on researcher.unit_id = metadatavalue.resource_id "
					+ "where metadatavalue.resource_type_id = 4 and metadata_field_id = 64"
					+ "and researcher.academic_name like '%骨干教师'" + "and researcher.unit_id = '" + unitId + "'" + ";";
		}

		if (!name.equals("")) {
			sqls = "select *,metadatavalue.text_value from researcher left "
					+ "join metadatavalue on researcher.unit_id = metadatavalue.resource_id "
					+ "where metadatavalue.resource_type_id = 4 and metadata_field_id = 64"
					+ "and researcher.academic_name like '%骨干教师'" + "and researcher.name like '%" + name + "%';";
		}

		Map<String, String> uidlist = new HashMap<String, String>();
		uidlist.put("蔡红娟", "35d1b91dc3bf6cb2c6cd10e5aa6d9c46");
		uidlist.put("雷丹", "35d1b91dc3bf6cb283f5bce0177f95bc");
		uidlist.put("段丽娜", "35d1b91dc3bf6cb2dface763d1167aa3");
		uidlist.put("李硕", "f7f87c7cb3eac10eab09f9b6801ae69e");
		uidlist.put("石从继", "35d1b91dc3bf6cb29bd2ce2764ba1940");
		uidlist.put("张小菊", "bed2d71ce80b4851ca3adc267e76086a");
		uidlist.put("莫文婷", "4dcc32fc34b670c21123f6ca6d01d1ca");
		uidlist.put("凌平平", "bed2d71ce80b4851f603169b54523c68");
		uidlist.put("郑莹", "bed2d71ce80b485152967fa6730a1832");
		uidlist.put("黄颖", "35d1b91dc3bf6cb24849d3841183fe4e");
		uidlist.put("李林", "8ead5ac3f5d9f5528a12f204b5f94af2");
		uidlist.put("焦雨生", "3ee8f69f3cb31bdefe5dace95ca43732");
		uidlist.put("陈永蓉", "35d1b91dc3bf6cb223d6821cfd7771e8");
		uidlist.put("余林", "35d1b91dc3bf6cb2428804ed0627b4a6");
		uidlist.put("宋华", "35d1b91dc3bf6cb27258d33f48d5305e");
		uidlist.put("游娟", "35d1b91dc3bf6cb2302052cf7e285348");
		uidlist.put("肖巍", "35d1b91dc3bf6cb2769b138432617676");
		uidlist.put("李洁", "35d1b91dc3bf6cb2c5b2d01d549e8458");
		uidlist.put("姜娜", "55c3311c8c0457b796434cf36fc323c2");
		uidlist.put("余芳", "35d1b91dc3bf6cb277f41ffe2fcbf2f0");
		uidlist.put("朱祥和", "88902e85afe1ea310caa503f247c1291");
		uidlist.put("肖艳芬", "56dc6267fe0117ad2498fbad6534ecd3");
		uidlist.put("张瑾", "55c3311c8c0457b72873f3462ff3de83");
		uidlist.put("余婵娟", "bed2d71ce80b4851f39efb6960c00103");
		uidlist.put("杨娟", "09cab95069277bc4ee023f0ae52b240e");
		uidlist.put("杨旗", "361b27622fbc9ccb9d80b8301100f341");

		try {
			pStatement = connection.prepareStatement(sqls);
			rs = pStatement.executeQuery();
			mylist = new ArrayList();
			while (rs.next()) {
				// 拼接image图片
				String code = null;
				String image = rs.getString("image");
				String uname = rs.getString("name").toString();

				try {
					code = uidlist.get(uname);
				} catch (Exception e1) {
					e1.printStackTrace();
				}
				if (rs.getInt("special") != 0) {
					if (image.equals("calis-self")) {
						image = "<img src='" + request.getContextPath() + "/imageshow?spec=" + code + "' />";
					}
				} else if (rs.getBoolean("sex")) {
					image =

							"<img class='no-picture' src='" + request.getContextPath() + "/image/man.png' />";
				} else {
					image =

							"<img class='no-picture' src='" + request.getContextPath() + "/image/woman.png' />";
				}

				Map<String, Object> marster_list = new HashMap<String, Object>();
				marster_list.put("departmentId", "");
				marster_list.put("education", "");
				marster_list.put("email", "");
				marster_list.put("field", "");
				marster_list.put("image", image);
				marster_list.put("name", uname);
				marster_list.put("orcid", "");
				marster_list.put("phone", "");
				marster_list.put("researcherId", rs.getInt("researcher_id"));
				marster_list.put("resume", "");
				marster_list.put("sex", rs.getBoolean("sex"));
				marster_list.put("special", 0);
				marster_list.put("title", rs.getString("title"));
				marster_list.put("uid", code);
				marster_list.put("unitId", rs.getInt("unit_id"));
				marster_list.put("url", "");
				marster_list.put("visit", rs.getInt("visit"));

				JSONObject marster_jsont = JSONObject.fromObject(marster_list);
				mylist.add(marster_jsont);
			}
			connection.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		System.out.println();
		// 构造unitMap数据
		Map<String, Object> unitMap = new HashMap<String, Object>();
		unitMap.put("6", "经济管理学院");
		unitMap.put("12", "思想政治理论课部");
		unitMap.put("8", "新闻与法学学院");
		unitMap.put("2", "信息科学与工程学院");
		unitMap.put("10", "外国语学院");
		unitMap.put("11", "基础科学部");
		unitMap.put("4", "机电与自动化学院");
		unitMap.put("13", "直属、附属单位");
		unitMap.put("5", "城市建设学院");
		unitMap.put("9", "艺术设计学院");

		JSONObject unitMapjson = JSONObject.fromObject(unitMap);

		// 按页取数据
		List newlist = new ArrayList();
		if (mylist.size() >= 12) {
			if (pageSize + offset > mylist.size()) {
				newlist = mylist.subList(offset, mylist.size());
			} else {
				newlist = mylist.subList(offset, pageSize + offset);
			}

		} else {
			newlist = mylist;
		}

		JSONArray json = JSONArray.fromObject(newlist);
		// 构造json数据
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("total", mylist.size());
		params.put("unitMap", unitMapjson);
		params.put("offset", offset);
		params.put("pageSize", 12);
		params.put("researcherList", json);

		// java对象变成json对象
		JSONObject jsonObject = JSONObject.fromObject(params);

		// json对象转换成json字符串
		String jsonStr = jsonObject.toString();
		response.getWriter().print(jsonStr); // 将数据返回前台ajax
	}

}
