<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*"%>
<%@ page import="com.cs336.pkg.*"%>

<%

    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if the user is a manager   
    if (!session.getAttribute("role").equals("Customer")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String lineId = request.getParameter("reserve");
    LineSchedule sched = (LineSchedule) session.getAttribute("line: " + lineId);

    String tripType = request.getParameter("tripType") != null ? request.getParameter("tripType") : "oneway";
    String age = request.getParameter("age") != null ? request.getParameter("age") : "21";
    String disability = request.getParameter("disability") != null ? request.getParameter("disability") : "no";
    
    int multiplier = 1, discount = 0;
	if (tripType.equals("round")) {
		multiplier = 2;
	}
	
	if (disability.equals("yes")) {
		discount = 50;
	} else if (((int) Integer.valueOf(age)) >= 65) {
		discount = 35;
	} else if (((int) Integer.valueOf(age)) <= 12) {
		discount = 25;
	}
    
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        // SQL query to update all fields for an employee
        String updateQuery = "UPDATE Employee SET firstName = ?, lastName = ?, username = ?, password = ?, role = ? WHERE ssn = ?";
        ps = conn.prepareStatement(updateQuery);
        ps.setString(1, firstName);
        ps.setString(2, lastName);
        ps.setString(3, username);
        ps.setString(4, password); // Assuming password is hashed before being stored in the database
        ps.setString(5, role);
        ps.setString(6, ssn);

        int rowsUpdated = ps.executeUpdate();

        if (rowsUpdated > 0) {
            response.sendRedirect("managerWelcome.jsp?update=success");
        } else {
            response.sendRedirect("managerWelcome.jsp?update=failure");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("managerWelcome.jsp?update=error");
    } finally {
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
