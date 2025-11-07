<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>エラー</title>
</head>
<body>
    <h1>エラーが発生しました</h1>
    <p>
        <%
            String errorMessage = request.getParameter("message");
            if (errorMessage != null && !errorMessage.isEmpty()) {
                out.println(errorMessage);
            } else {
                out.println("予期せぬエラーが発生しました。");
            }
        %>
    </p>
    <p><a href="<%= request.getContextPath() %>/register/returnsearch">検索画面に戻る</a></p>
</body>
</html>