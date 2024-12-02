<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<%
    // Set cache control headers to prevent caching of the page
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <title>View Schedules</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f9;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .header {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header .username {
            color: black;
            font-size: 20px;
            font-weight: bold;
        }

        .main-container {
            display: flex;
            flex-direction: column;
            height: 100%;
            padding: 20px;
            flex-grow: 1;
        }

        .top-half {
            flex: 6;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            align-items: center;
            height: 100vh;
            overflow-y: visible;
        }

        .bottom-half {
            flex: 1;
            overflow-y: visible;
            margin-top: 20px;
			display: block;
			margin: auto;
		    justify-content: center;
		    align-items: center;
        }

        .logout-button {
            padding: 8px 16px;
            background-color: #f44336;
            color: white;
            font-size: 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        
        .logout-button:hover {
            background-color: #d32f2f;
        }
        
        .table-container {
        	width: 100%;
            align-items: center;
            text-align: center;
        }
               
        .reservation-table {
            width: 100%;
            border-collapse: collapse;
        }

        .reservation-table th, .employee-table td {
            border: 1px solid #ddd;
            padding: 8px;
        }

        .reservation-table th {
            background-color: #4CAF50;
            color: white;
        }

        .reservation-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .reservation-table tr:hover {
            background-color: #f1f1f1;
        }

        .label-bold {
            font-weight: bold;
        }

    </style>
</head>
<body>

<% 
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    
    if (!role.equals("Customer")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    String errorMessage = null;
    List<Station> uniqueStations = new ArrayList<>();
    Map<Integer, LineSchedule> scheduleRes = new HashMap<>();
    
    String originStationId = request.getParameter("origin");
    String destinationStationId = request.getParameter("destination");
    String reservationDate = request.getParameter("reservationDate");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        String query = "SELECT DISTINCT s.stationId, s.name, s.city, s.state FROM Stop " + 
                       "JOIN Station s ON Stop.stopStation = s.stationId";
        
        ps = conn.prepareStatement(query);
        rs = ps.executeQuery();

        while (rs.next()) {        	
        	uniqueStations.add(new Station(rs.getInt("stationId"), rs.getString("name"),rs.getString("city"), rs.getString("state")));
        }
        // Collections.sort(uniqueStations, (a, b) -> Integer.compare(a.getStationId(), b.getStationId()));
        
        String query2 = "SELECT tl.lineId AS LineId, tl.lineName AS LineName, s1.stationId AS OriginStationId, s1.name AS OriginStationName, s1.city AS OriginCity, s1.state AS OriginState, stop1.departureDateTime AS DepartureDateTime, " +
        				"s2.stationId AS DestinationStationId, s2.name AS DestinationStationName, s2.city AS DestinationCity, s2.state AS DestinationState, stop2.arrivalDateTime AS ArrivalDateTime, tl.fare AS Fare " +
		        		"FROM Station s1 " +
		        		"JOIN Stop stop1 ON s1.stationId = stop1.stopStation " +
		        		"JOIN TransitLine tl ON stop1.stopLine = tl.lineId " +
		        		"JOIN Stop stop2 ON tl.lineId = stop2.stopLine " +
		        		"JOIN Station s2 ON stop2.stopStation = s2.stationId " +
		        		"WHERE s1.stationId = ? AND s2.stationId = ? AND CAST(stop1.departureDateTime AS DATE) = ? AND stop1.departureDateTime < stop2.arrivalDateTime";
        
        PreparedStatement ps2 = conn.prepareStatement(query2);
        ps2.setString(1, originStationId);
        ps2.setString(2, destinationStationId);
        ps2.setString(3, reservationDate);
        ResultSet rs2 = ps2.executeQuery();
        
        while (rs2.next()) {
        	int lineId = rs2.getInt("LineId");
        	scheduleRes.put(lineId, new LineSchedule(lineId, rs2.getString("LineName"), 
        			rs2.getInt("OriginStationId"), rs2.getString("OriginStationName"), rs2.getString("OriginCity"), rs2.getString("OriginState"), rs2.getString("DepartureDateTime"), 
        			rs2.getInt("DestinationStationId"), rs2.getString("DestinationStationName"), rs2.getString("DestinationCity"), rs2.getString("DestinationState"), rs2.getString("ArrivalDateTime"), 
        			rs2.getFloat("Fare")));
        }
        
        String query3 = "SELECT tl.lineId AS LineId, s.stationId AS StationId, s.name AS StationName, s.city AS StationCity, s.state AS StationState, stop.arrivalDateTime AS ArrivalDateTime, stop.departureDateTime AS DepartureDateTime " + 
		        		"FROM TransitLine tl " +
		        		"JOIN Stop stop ON tl.lineId = stop.stopLine " +
		        		"JOIN Station s ON stop.stopStation = s.stationId " +
		        		"ORDER BY stop.departureDateTime ASC";
        
        PreparedStatement ps3 = conn.prepareStatement(query3);
        ResultSet rs3 = ps3.executeQuery();
        
        while (rs3.next()) {
        	int lineId = rs3.getInt("LineId");
        	if (scheduleRes.containsKey(lineId)) {
        		scheduleRes.get(lineId).addStop(rs3.getInt("StationId"), rs3.getString("StationName"), rs3.getString("StationCity"), rs3.getString("StationState"), rs3.getString("ArrivalDateTime"), rs3.getString("DepartureDateTime"));
        	}
        }
    } catch (SQLException e) {
        errorMessage = "Error loading stations: " + e.getMessage();
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

<div class="header">
    <div class="username">Hello, <%= username %>!</div>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
<% } %>

<div class="main-container">
    <div class="top-half">
		<!--  book reservations  -->
		<h3>View Alternate Schedules</h3>
		<form method="POST" action="viewSchedules.jsp" style="display: inline">
			<label>Origin: </label>
			<select name="origin" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"
					<%= station.getStationId() == Integer.valueOf(originStationId) ? "selected" : "" %>>
						<%= station.toString() %>
					</option>
				<% } %>
			</select>
			
			<label>Destination: </label>
			<select name="destination" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"
					<%= station.getStationId() == Integer.valueOf(destinationStationId) ? "selected" : "" %>>
						<%= station.toString() %>
					</option>
				<% } %>
			</select>
			
			<label>Date of Departure: </label>	            
            <input type="date" name="reservationDate" required value="<%= reservationDate %>">
			
			<button type="submit">View Schedules</button>
		</form>
		
		<div class="table-container">
		<h3>Book Reservation</h3>
		<table class="reservation-table">
        <thead>
            <tr>
                <th>Transit Line</th>
                <th>Origin</th>
                <th>Departure Time</th>
                <th>Destination</th>
                <th>Arrival Time</th>
                <th>Path</th>
                <th>Fare</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <%            
            for (Integer lineId : scheduleRes.keySet()) { 
            	LineSchedule sched = scheduleRes.get(lineId);
            %>
                <tr>
                    <td><%= sched.getLineName() %></td>
                    <td><%= sched.getOrigin() %></td>
                    <td><%= sched.getDepartureDateTime() %></td>
                    <td><%= sched.getDestination() %></td>
                    <td><%= sched.getArrivalDateTime() %></td>
                    <td>
                    	<details>
                    		<summary>View Stops</summary>
                    		<table>
                    		<thead>
                    			<tr>
                    				<th>Station</th>
                    				<th>Arrival Time</th>
                    				<th>Departure Time</th>
                    				<th>Estimated Fare</th>
                    			</tr>
                    		</thead>
                    		<tbody>
                    			<%
                    			List<Object[]> lineStops = sched.getStops();
                    			for (int ii = 0; ii < lineStops.size(); ii++) {
                    				Object[] stop = lineStops.get(ii);
                    				String stationName = stop[0].toString();
                    				String arrivalTime = (String) stop[1], departureTime = (String) stop[2];
                    				String color = (String) stop[3];
                    				boolean bold = (boolean) stop[4];
                    				
                    				float estimatedFare = sched.getEstimatedFare(ii);
                    				String estFareStr = String.format("$%.2f", estimatedFare);
                    				if (estimatedFare == -1) estFareStr = "N/A";
                    				
                    				if (bold) {
                    					stationName = "<b>" + stationName + "</b>";
                    					arrivalTime = "<b>" + arrivalTime + "</b>";
                    					departureTime = "<b>" + departureTime + "</b>";
                    					estFareStr = "<b>" + estFareStr + "</b>";
                    				}
                    			%>
	                    			<tr>
	                    				<td style="color:<%= color %>"><%= stationName %></td>
	                    				<td style="color:<%= color %>"><%= arrivalTime %></td>
	                    				<td style="color:<%= color %>"><%= departureTime %></td>
	                    				<td style="color:<%= color %>"><%= estFareStr %></td>
	                    			</tr>
	                    		<% } %>
                    		</tbody>
                    		</table>
                    	</details>
                    </td>
                    <td>$<%= String.format("%.02f", sched.getEstimatedFare()) %></td>
                    <td>
						some action
                    </td>
                </tr>
            <% } %>
        </tbody>      
	    </table>
        <% if (scheduleRes.isEmpty()) { %>
        <p style="color: red">No valid schedules.</p>            
        <% } %>
        </div>
    </div>
 

    <div class="bottom-half">	        
		<form method="POST" action="askQuestion.jsp" style="display: inline">
			<button type="submit" class="viewQuestions">Speak with a Representative</button>
		</form>
    </div>
</div>

</body>
</html>