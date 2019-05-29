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

import org.dspace.core.ConfigurationManager;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import tool.PKUUtils;

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

//		数据库配置参数获取
		String driverClassName = ConfigurationManager.getProperty("db.driver");
		String url = ConfigurationManager.getProperty("db.url");
		String username = ConfigurationManager.getProperty("db.username");
		String password = ConfigurationManager.getProperty("db.password");
		Connection connection = null;
		
		

		try {
			Class.forName(driverClassName).newInstance();
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

		try {
			pStatement = connection.prepareStatement(sqls);
			rs = pStatement.executeQuery();
			mylist = new ArrayList();
			while (rs.next()) {
				// 拼接image图片
				String code = rs.getString("uid");
				String image = rs.getString("image");
				String uname = rs.getString("name").toString();

				try {
					code = PKUUtils.encrypt(code, "PkuLibIR");
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
