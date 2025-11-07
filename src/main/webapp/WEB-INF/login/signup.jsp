<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>新規登録</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style-signup.css">
    <style>
        html,
        body {
            height: 100%;
            margin: 0;
            padding: 0;
            /* 日本語表示に適したフォントを指定 */
            font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
            background-color: #fff;
            /* 背景は白 */
            color: #333;
            /* 基本の文字色 */
        }

        body {
            /* Flexboxを使ってコンテンツを上下左右中央に配置 */
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-logo {
            /* ロゴのサイズは実際の画像に合わせて調整してください */
            max-width: 180px;
            margin-bottom: 24px;
        }

        /* --- タイトル「ログイン」 --- */
        .signup-title {
            font-size: 22px;
            font-weight: bold;
            margin-top: 40px;
            margin-bottom: 32px;
        }

        /* --- フォーム内の各入力欄のグループ --- */
        .form-group {
            margin-bottom: 20px;
            text-align: left;
            /* ラベルを左寄せにする */
        }

        /* --- ラベル（ログインID, パスワード） --- */
        .form-label {
            display: block;
            /* 入力欄の上に表示させる */
            font-size: 14px;
            color: #555;
            margin-bottom: 8px;
            /* 入力欄との隙間 */
        }

        /* --- 入力欄（テキストボックス、パスワード） --- */
        .form-control {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 6px;
            /* 少し角を丸くする */
            box-sizing: border-box;
            /* paddingを含めて幅を100%にする */
        }

        /* --- ログインボタン --- */
        .btn-login {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            font-weight: bold;
            color: #fff;
            /* 文字色は白 */
            background-color: #000;
            /* 背景色は黒 */
            border: none;
            border-radius: 50px;
            /* 角を丸くしてカプセル型に */
            cursor: pointer;
            transition: opacity 0.2s ease;
            /* ホバー時のアニメーション */
            margin-top: 40px;
            /* 上の要素との隙間 */
        }

        /* ボタンにカーソルを乗せた時の効果 */
        .btn-login:hover {
            opacity: 0.8;
        }


        /* --- エラーメッセージのスタイル --- */
        .error-message {
            color: #d9534f;
            background-color: #f2dede;
            border: 1px solid #ebccd1;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .new-user {
            font-size: 14px;
            text-align: left;
        }

        /* --- 成功メッセージのスタイル --- */
        .success-message {
            color: #155724;
            /* 文字色 */
            background-color: #d4edda;
            /* 背景色 */
            border: 1px solid #c3e6cb;
            /* 枠線 */
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        /* --- 入力欄の下に表示する注釈テキスト --- */
        .form-text {
            display: block;
            /* 改行して表示 */
            margin-top: 5px;
            /* 上の入力欄との隙間 */
            font-size: 13px;
            color: #6c757d;
            /* 少し薄いグレー */
        }

        /* --- 登録成功後に表示されるリンクのスタイル --- */
        .form-footer-link {
            margin-top: 20px;
            font-size: 14px;
        }

        .form-footer-link a {
            color: #007bff;
            text-decoration: none;
        }

        .form-footer-link a:hover {
            text-decoration: underline;
        }

        .signup-container {
            width: 100%;
            max-width: 360px;
            /* フォームの最大幅 */
            padding: 20px;
            box-sizing: border-box;
            /* paddingを含めて幅を計算 */
            text-align: center;
        }
    </style>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

    <div class="signup-container">
        <img src="${pageContext.request.contextPath}/image/logo.png" alt="ロゴ" style="width: 200px; height: auto;">

        <h1 class="signup-title">新規登録</h1>

        <%-- エラーメッセージ --%>
        <c:if test="${not empty requestScope.error}">
            <div class="error-message">エラー：${fn:escapeXml(requestScope.error)}</div>
        </c:if>
        
        <%-- 成功メッセージ --%>
        <c:if test="${not empty requestScope.success}">
            <div class="success-message">${fn:escapeXml(requestScope.success)}</div>
            <div class="form-footer-link">
                <a href="${pageContext.request.contextPath}/reservation">ログインページへ</a>
            </div>
        </c:if>

        <%-- 新規登録フォーム --%>
        <c:if test="${empty requestScope.success}">
            <form action="${pageContext.request.contextPath}/signup" method="post" class="login-form">
                
                <div class="form-group">
                    <label for="id" class="form-label">ユーザー名</label>
                    <input type="text" id="id" name="id" class="form-control" value="${fn:escapeXml(requestScope.lastInput.id)}" required>
                    <small class="form-text">8文字以上、半角英数字ハイフンのみ</small>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">パスワード</label>
                    <input type="password" id="password" name="password" class="form-control" required>
                    <small class="form-text">64文字以下</small>
                </div>
                
                <button type="submit" class="btn-login">登録</button>
            </form>
        </c:if>

    </div>
</body>
</html>