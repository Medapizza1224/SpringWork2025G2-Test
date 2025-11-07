<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>チェックイン方法の選択</title>
    <style>
        /* ページの基本設定 */
        html, body {
            height: 100%; /* 高さを画面全体に */
            margin: 0;
            /* ご指定のフォントを適用 */
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }
        body {
            display: flex;
            flex-direction: column; /* 要素を縦に並べる */
            justify-content: center; /* 全体を垂直方向の中央に */
            align-items: center;    /* 全体を水平方向の中央に */
        }
        h1 {
            margin-bottom: 30px; /* 見出しと選択肢の間のスペース */
        }
        /* 選択肢を囲むコンテナ */
        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 40px; /* 要素間のスペースを少し広げる */
            width: 100%;
        }
        /* リンクのスタイル */
        .choice-link {
            text-decoration: none;
            color: inherit;
        }
        /* 各選択肢のボックス */
        .choice-box {
            background-color: #f0f0f0;
            padding: 20px;
            border-radius: 5px;
            box-sizing: border-box; /* paddingを含んだサイズ計算にする */

            /* 横幅をビューポート（表示領域）の35%に設定 */
            width: 35vw;
            /* 高さをビューポート（表示領域）の70%に設定 */
            height: 70vh;

            /* ボックス内のコンテンツを中央に配置 */
            display: flex;
            flex-direction: column; /* アイテムを縦に並べる */
            justify-content: center; /* 垂直方向の中央揃え */
            align-items: center;    /* 水平方向の中央揃え */
            transition: transform 0.2s; /* ホバー時のアニメーション */
        }
        .choice-box:hover {
            transform: scale(1.02); /* マウスを乗せると少し拡大する */
        }
        /* 画像のスタイル */
        .choice-box img {
            /* 画像がボックスからはみ出ないようにし、サイズを調整 */
            max-width: 80%;
            height: auto;
        }
        /* テキストのスタイル */
        .choice-box p {
            margin-top: 25px; /* 画像とテキストの間のスペース */
            font-size: 1.8em; /* 文字サイズを調整 */
            font-weight: bold;
        }
    </style>
</head>
<body>

    <div class="container">
        <%-- 「予約済み」リンク --%>
        <a href="${pageContext.request.contextPath}/checkin-reserved" class="choice-link">
            <div class="choice-box">
                <img src="${pageContext.request.contextPath}/image/予約済み.png" alt="予約済み">
                <p>予約済み</p>
            </div>
        </a>

        <%-- 「予約していない」リンク --%>
        <a href="${pageContext.request.contextPath}/checkin-nonreserved" class="choice-link">
            <div class="choice-box">
                <img src="${pageContext.request.contextPath}/image/予約していない.png" alt="予約していない">
                <p>予約していない</p>
            </div>
        </a>
    </div>

</body>
</html>