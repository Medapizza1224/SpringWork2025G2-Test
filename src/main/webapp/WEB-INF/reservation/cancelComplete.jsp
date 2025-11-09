<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>予約キャンセル完了</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f0f0f0; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }*/
        .container { width: 393px; background: #fff; padding: 40px 20px; box-sizing: border-box; text-align: center; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .btn { margin-left: 60px; display: inline-block; margin-top: 30px; padding: 12px 40px; background-color: #000; color: #fff; text-decoration: none; border-radius: 25px; font-weight: 600;}
    </style>
</head>
<body>
    <div class="container">
        <h2>キャンセル手続きが完了しました</h2>
        <a href="${pageContext.request.contextPath}/reservation" class="btn">トップページへ戻る</a>
    </div>
</body>
</html>