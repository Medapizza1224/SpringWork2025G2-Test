<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList, java.util.List, entity.Reservation" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>チェックイン結果</title>
    <meta http-equiv="refresh" content="7; URL=${pageContext.request.contextPath}/checkin-home">
    <style>
        /* 全体のスタイル */
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            display: flex;
            justify-content: center; /* 水平方向中央 */
            align-items: center;   /* 垂直方向中央 */
            flex-direction: column;
            min-height: 100vh;
            margin: 0;
            background-color: #ffffff; /* 背景を白に */
            color: #333333;
        }

        /* コンテナ */
        .container {
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 40px; /* 各要素間のスペース */
        }
        
        /* ヘッダー（ロゴ部分） */
        .header {
            /* ロゴ画像の下に十分なマージンを確保 */
            margin-bottom: 20px;
        }

        /* ロゴ画像 */
        .logo-img {
            max-width: 250px; /* ロゴのサイズを適宜調整 */
            height: auto;
        }

        /* メッセージエリア */
        .message-area {
            line-height: 1.7;
        }

        /* メインメッセージ */
        .main-message {
            font-size: 24px; /* フォントサイズを調整 */
            font-weight: bold;
            margin: 10px;
        }

        /* 座席情報 */
        .seat-info {
            font-size: 22px; /* フォントサイズを調整 */
            font-weight: bold;
            margin-top: 50px;
        }
        
        /* 戻るボタン */
        .back-button {
            display: inline-block;
            padding: 12px 60px; /* パディングを調整 */
            font-size: 16px;
            color: #333333;
            background-color: #e6e6e6; /* 薄いグレー */
            border: none;
            border-radius: 30px; /* 角を丸くする */
            text-decoration: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .back-button:hover {
            background-color: #d4d4d4; /* ホバー時の色 */
        }

        /* エラーメッセージ用 */
        .error-message {
            color: #e74c3c;
            font-weight: bold;
            font-size: 18px;
        }

    </style>
</head>
<body>

    <%-- 
      ★★★ 修正点 ★★★
      座席番号をカンマ区切りの文字列に変換する処理。
      reservationオブジェクトから空でない座席番号をリストに追加し、
      String.joinで連結して変数 `seatString` に格納します。
    --%>
    <%
      List<String> seats = new ArrayList<>();
      if (request.getAttribute("reservation") != null) {
          Reservation res = (Reservation) request.getAttribute("reservation");
          // seat1からseat8までチェックし、空でなければリストに追加
          if (res.getSeat1() != null && !res.getSeat1().isEmpty()) seats.add(res.getSeat1());
          if (res.getSeat2() != null && !res.getSeat2().isEmpty()) seats.add(res.getSeat2());
          if (res.getSeat3() != null && !res.getSeat3().isEmpty()) seats.add(res.getSeat3());
          if (res.getSeat4() != null && !res.getSeat4().isEmpty()) seats.add(res.getSeat4());
          if (res.getSeat5() != null && !res.getSeat5().isEmpty()) seats.add(res.getSeat5());
          if (res.getSeat6() != null && !res.getSeat6().isEmpty()) seats.add(res.getSeat6());
          if (res.getSeat7() != null && !res.getSeat7().isEmpty()) seats.add(res.getSeat7());
          if (res.getSeat8() != null && !res.getSeat8().isEmpty()) seats.add(res.getSeat8());
      }
      // リストの要素をカンマで連結
      String seatString = String.join(",", seats);
      // JSTLで使えるようにリクエストスコープにセット
      pageContext.setAttribute("seatString", seatString);
    %>

    <div class="container">
        <!-- ヘッダー（ロゴ） -->
        <div class="header">
            <%-- ▼▼▼ 注意：この画像のパスは実際の環境に合わせて修正してください ▼▼▼ --%>
            <img src="${pageContext.request.contextPath}/image/logo.png" alt="東京学芸大学 大学生協食堂" class="logo-img"/>
        </div>

        <!-- メインコンテンツ -->
        <div>
            <%-- エラーメッセージがある場合 --%>
            <c:if test="${not empty errorMessage}">
                <p class="error-message">${errorMessage}</p>
            </c:if>

            <%-- 成功メッセージがある場合 --%>
            <c:if test="${not empty successMessage}">
                <div class="message-area">
                    <p class="main-message">チェックインが完了しました。</p>
                    <p class="main-message">座席へお進みください。</p>
                </div>
                
                <div class="seat-info">
                    <%-- ★★★ 修正点：カンマ区切りで座席を表示 ★★★ --%>
                    <p>座席：${seatString}</p>
                </div>
            </c:if>
        </div>

        <!-- ボタン -->
        <a href="${pageContext.request.contextPath}/checkin-home" class="back-button">戻る</a>
    </div>

</body>
</html>