<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*"%>
<%@ page import="com.cs336.pkg.*"%>

<%
    // Check if the session is valid and the user is a manager
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    if (!"Manager".equals(session.getAttribute("role"))) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String month = request.getParameter("month");
    String year = request.getParameter("year");
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        // SQL query to get the sales report data for the given month and year
        String query = "SELECT t.lineName AS 'Line Name', " +
                       "COUNT(r.reservationNo) AS 'Total Reservations', " +
                       "SUM(t.fare) AS 'Total Revenue' " +
                       "FROM Reservation r " +
                       "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                       "WHERE MONTH(r.reservationDateTime) = ? AND YEAR(r.reservationDateTime) = ? " +
                       "GROUP BY t.lineName";
        
        ps = conn.prepareStatement(query);
        ps.setInt(1, Integer.parseInt(month));
        ps.setInt(2, Integer.parseInt(year));
        rs = ps.executeQuery();

        // Display results in a table format
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head><title>Sales Report</title></head>");
        out.println("<body>");
        out.println("<h2>Sales Report for " + new java.text.DateFormatSymbols().getMonths()[Integer.parseInt(month) - 1] + " " + year + "</h2>");
        out.println("<table border='1'>");
        out.println("<thead>");
        out.println("<tr>");
        out.println("<th>Line Name</th>");
        out.println("<th>Total Reservations</th>");
        out.println("<th>Total Revenue</th>");
        out.println("</tr>");
        out.println("</thead>");
        out.println("<tbody>");

        while (rs.next()) {
            String lineName = rs.getString("Line Name");
            int totalReservations = rs.getInt("Total Reservations");
            double totalRevenue = rs.getDouble("Total Revenue");

            out.println("<tr>");
            out.println("<td>" + lineName + "</td>");
            out.println("<td>" + totalReservations + "</td>");
            out.println("<td>" + String.format("$%.2f", totalRevenue) + "</td>");
            out.println("</tr>");
        }
        
        out.println("</tbody>");
        out.println("</table>");
        out.println("<br><a href='managerWelcome.jsp'>Back to Dashboard</a>");
        out.println("</body>");
        out.println("</html>");

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<p>Error: Unable to retrieve sales report data. Please try again later.</p>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
