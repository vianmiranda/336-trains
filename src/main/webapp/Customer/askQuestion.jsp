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
    <title>Customer Welcome</title>
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

        .form-container {
            margin-top: 20px;
        }

        .form-container input, .form-container textarea {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .question-item, .answer-item {
            background-color: #fff;
            padding: 15px;
            border: 1px solid #ddd;
            margin-bottom: 10px;
            font-size: 16px;
        }

        .answer-item {
            background-color: #e8f5e9;
            padding: 10px;
            margin-top: 10px;
            border-left: 5px solid #4CAF50;
        }

        .search-container {
            margin-top: 20px;
            margin-bottom: 20px;
        }

        .search-container input[type="text"] {
            width: 260px;
            padding: 10px;
            font-size: 14px;
            border-radius: 4px;
            border: 1px solid #ccc;
            margin-right: 10px;
        }

        .search-container input[type="submit"] {
            padding: 10px 20px;
            font-size: 14px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .search-container input[type="submit"]:hover {
            background-color: #45a049;
        }

        .form-container textarea {
            font-size: 14px;
        }
        
       	.clear-button {
            padding: 8px 16px;
            background-color: #228c22;
            color: white;
            font-size: 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        
        .clear-button:hover {
            background-color: #228222;
        }
        
        .clear-button button {
            background-color: transparent;
		    background-repeat: no-repeat;
		    border: none;
		    cursor: pointer;
		    overflow: hidden;
		    outline: none;
            color: white;
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

        .question-text {
            font-size: 16px;
            margin-bottom: 8px;
        }

        .label-bold {
            font-weight: bold;
        }

    </style>
</head>
<body>

<% 
	String username = (String) session.getAttribute("username");

    if (session == null || username == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    
    if (!role.equals("Customer")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String errorMessage = null;
    List<String> questions = new ArrayList<>();
    List<String> answers = new ArrayList<>();
    List<String> questionUsernames = new ArrayList<>();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        String searchKeyword = request.getParameter("searchKeyword");
        String query = "SELECT q.questionText, a.answerText, c.username FROM Questions q " + 
                       "LEFT JOIN Answers a USING (questionId) " +
                       "JOIN Customer c USING (customerId) " +
                       "WHERE q.customerId = (SELECT customerId FROM Customer WHERE username = ?)";
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            query += " AND LOWER(q.questionText) LIKE LOWER(?)";
        }
        
        ps = conn.prepareStatement(query);
        ps.setString(1, username);
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            ps.setString(2, "%" + searchKeyword.toLowerCase() + "%");
        }
        
        rs = ps.executeQuery();

        while (rs.next()) {
            questions.add(rs.getString("questionText"));
            answers.add(rs.getString("answerText") != null ? rs.getString("answerText") : "");
            questionUsernames.add(rs.getString("username"));
        }

        String newQuestion = request.getParameter("newQuestion");
        if (newQuestion != null && !newQuestion.isEmpty()) {
            PreparedStatement ps2 = null;
            try {
                String insertQuestionQuery = "INSERT INTO Questions (customerId, questionText) " +
                                             "VALUES ((SELECT customerId FROM Customer WHERE username = ?), ?)";
                ps2 = conn.prepareStatement(insertQuestionQuery);
                ps2.setString(1, username);
                ps2.setString(2, newQuestion);
                ps2.executeUpdate();
                response.sendRedirect("customerWelcome.jsp");
            } catch (SQLException e) {
                errorMessage = "Error submitting your question: " + e.getMessage();
            } finally {
                if (ps2 != null) ps2.close();
            }
        }

    } catch (SQLException e) {
        errorMessage = "Error loading questions and answers: " + e.getMessage();
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
    <form class="clear-button" method="POST" action="customerWelcome.jsp">
    	<button name="clear">Clear And Go Back</button>
    </form>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
<% } %>

<div class="main-container">
    <div class="bottom-half">	        
		<h2>Speak to a Representative</h2>   
        <div class="form-container">
            <h3>Ask a New Question:</h3>
            <form method="POST" action="askQuestion.jsp">
                <textarea name="newQuestion" rows="4" placeholder="Write your question here" required></textarea><br>
                <input type="submit" value="Submit Question" />
            </form>
        </div>

		<details>
			<summary>View Previous Questions</summary>
	        <div class="search-container">
	            <form method="GET" action="askQuestion.jsp">
	                <input type="text" name="searchKeyword" placeholder="Search by question keyword" value="<%= (request.getParameter("searchKeyword") != null) ? request.getParameter("searchKeyword") : "" %>" />
	                <input type="submit" value="Search" />
	            </form>
	        </div>
	
	        <div class="question-section">
	            <% for (int i = 0; i < questions.size(); i++) { %>
	                <div class="question-item">
	                    <p><strong class="label-bold">Posted by:</strong> <%= questionUsernames.get(i) %></p>
	                    <h3 class="question-text">Q: <%= questions.get(i) %></h3>
	                    <p><strong class="label-bold">A:</strong> <%= (answers.get(i) != null && !answers.get(i).isEmpty()) ? answers.get(i) : "" %></p>
	                </div>
	            <% } %>
	        </div>
		</details>
    </div>
</div>

</body>
</html>
