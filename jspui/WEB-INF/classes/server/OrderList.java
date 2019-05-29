package server;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.dspace.core.ConfigurationManager;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import tool.PKUUtils;

@WebServlet("/order")
public class OrderList extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.setCharacterEncoding("UTF-8");
		response.setContentType("text/html;charset=UTF-8");

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

		String sqls = "select researcher.researcher_id,researcher.uid, researcher.name,researcher.image,researcher.special,researcher.sex,researcher.unit_id,count(*) works from researcher  ,metadatavalue " + 
        		" where researcher.name=metadatavalue.text_value  and  metadata_field_id=3 " + 
        		" group by researcher.name,researcher.uid,researcher.image,researcher.unit_id,researcher.special,researcher.sex,researcher.researcher_id " + 
        		" order by works desc limit 10;";
		
		//院系关系
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
		try {
			pStatement = connection.prepareStatement(sqls);
			rs = pStatement.executeQuery();
			mylist = new ArrayList();
			while (rs.next()) {
				// 拼接image图片
				String code = rs.getString("uid");
				String image = rs.getString("image");
				String uname = rs.getString("name").toString();
				String unit_name = null;

				try {
					code = PKUUtils.encrypt(code, "PkuLibIR");
				} catch (Exception e1) {
					e1.printStackTrace();
				}
				
				if (rs.getInt("special") != 0) {
					if (image.equals("calis-self")) {
						image = request.getContextPath() + "/imageshow?spec=" + code;
					}
				} else if (rs.getBoolean("sex")) {
					image =request.getContextPath() + "/calis/images/man.png";
				} else {
					image =request.getContextPath() + "/calis/images/woman.png'";
				}

				Map<String, Object> parlist = new HashMap<String, Object>();
				
				try {
					String unid_id = Integer.toString(rs.getInt("unit_id"));
					unit_name = (String) unitMap.get(unid_id);
				} catch (Exception e1) {
					e1.printStackTrace();
				}
				
				parlist.put("image", image);
				parlist.put("name", uname);
				parlist.put("researcherId", rs.getInt("researcher_id"));
				parlist.put("uid", code);
				parlist.put("unitId", unit_name);

				JSONObject jsont = JSONObject.fromObject(parlist);
				mylist.add(jsont);
			}
			connection.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		// 构造unitMap数据





		JSONArray json = JSONArray.fromObject(mylist);
		// 构造json数据
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("researcherList", json);

		// java对象变成json对象
		JSONObject jsonObject = JSONObject.fromObject(params);

		// json对象转换成json字符串
//		String jsonStr = jsonObject.toString();
		response.getWriter().print(jsonObject); // 将数据返回前台ajax
	}

}
