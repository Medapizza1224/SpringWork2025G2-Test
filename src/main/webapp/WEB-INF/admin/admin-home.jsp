<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理者画面</title>
    
    <style>
        /* ========== 基本/共通スタイル (style-admin.css) ========== */
        :root {
          --light-gray: #f8f9fa;
          --gray: #6c757d;
          --border-color: #dee2e6;
          --nav-bg: #ffffff;
          --body-bg: #f4f7f6;
          --nav-active-bg: #e9ecef;
        }

        * {
          box-sizing: border-box;
          margin: 0;
          padding: 0;
        }

        html, body {
          height: 100%;
        }

        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
          background-color: var(--body-bg);
          color: #333;
        }

        .admin-container {
          display: flex;
          min-height: 100vh;
        }

        /* --- 左側ナビゲーションバー --- */
        .admin-nav {
          width: 240px;
          flex-shrink: 0;
          background-color: var(--nav-bg);
          border-right: 1px solid var(--border-color);
          padding: 20px 0;
          display: flex;
          flex-direction: column;
        }

        .admin-nav .logo {
          padding: 0 20px 20px 20px;
          border-bottom: 1px solid var(--border-color);
          margin-bottom: 10px;
        }
        .admin-nav .logo img { max-width: 100%; height: auto; }
        .admin-nav ul { list-style-type: none; padding: 0 10px; }

        .admin-nav .nav-link {
          display: flex;
          align-items: center;
          gap: 15px;
          padding: 12px 15px;
          text-decoration: none;
          color: #343a40;
          font-weight: 500;
          border-radius: 6px;
          margin-bottom: 4px;
          transition: background-color 0.2s, color 0.2s;
        }
        .admin-nav .nav-link:hover { background-color: var(--nav-active-bg); }
        .admin-nav .nav-link.active { background-color: var(--light-gray); font-weight: 600; }
        .nav-icon { width: 20px; height: 20px; }

        /* --- 右側メインコンテンツ --- */
        .admin-main {
          flex-grow: 1;
          padding: 24px 32px;
          overflow-y: auto;
        }

        .main-section {
          background-color: #fff;
          border-radius: 8px;
          padding: 24px;
          margin-bottom: 24px;
          box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        .main-section > h2 { font-size: 22px; margin-bottom: 20px; font-weight: 600; }
        .hidden { display: none; }

        /* --- メッセージ表示 --- */
        .message { padding: 12px; margin-bottom: 15px; border-radius: 4px; border: 1px solid transparent; }
        .message.error { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
        .message.success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
        
        /* --- テーブル --- */
        table { width: 100%; border-collapse: collapse; font-size: 14px; }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        thead th { background-color: var(--light-gray); color: var(--gray); font-weight: 600; text-transform: uppercase; }
        tbody tr:hover { background-color: #f8f9fa; }
        tbody tr:last-child td { border-bottom: none; }

        /* --- フォームとボタン --- */
        form button, button[type="submit"] {
            margin-top: 15px;
            padding: 10px 20px;
            border: none;
            background-color: #007bff;
            color: white;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            transition: background-color 0.2s;
        }
        form button:hover, button[type="submit"]:hover { background-color: #0056b3; }

        /* ========== フローチャート風ホーム画面スタイル ========== */
        .flowchart-container {
          display: flex;
          flex-direction: column;
          align-items: flex-start;
          gap: 15px;
          padding: 20px 0;
          width: 100%;
        }
        .flow-block {
          display: grid;
          grid-template-columns: 170px 1fr;
          align-items: center;
          column-gap: 100px;
          width: 95%;
          min-height: 180px;
          margin-left: 100px;
        }
        .flow-main-button {
          grid-column: 1 / 2;
          width: 200px;
          height: 150px;
          display: flex;
          justify-content: center;
          align-items: center;
          border-radius: 8px;
          color: white;
          font-size: 1.25rem;
          font-weight: bold;
          text-decoration: none;
          box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
          transition: transform 0.2s, box-shadow 0.2s;
        }
        .flow-main-button:hover {
          transform: translateY(-3px);
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
        }
        .bg-blue { background-color: #34b1eb; }
        .bg-orange { background-color: #f7a42b; }
        .bg-green { background-color: #00c853; }

        .flow-arrow {
          width: 0; height: 0;
          border-left: 30px solid transparent;
          border-right: 30px solid transparent;
          border-top: 30px solid #d8d8d8;
          margin-left: 170px;
        }
        .flow-sub-container {
          grid-column: 2 / 3;
          display: flex;
          flex-direction: column;
          gap: 20px;
        }
        .flow-sub-row {
          display: flex;
          align-items: center;
          flex-wrap: wrap;
          gap: 20px 40px;
        }
        .flow-sub-button {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 10px 20px;
          background-color: #ffffff;
          border: 1px solid #dee2e6;
          border-radius: 6px;
          box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
          text-decoration: none;
          color: #495057;
          font-weight: 500;
          font-size: 1rem;
          transition: background-color 0.2s, box-shadow 0.2s;
        }
        .flow-sub-button:hover {
          background-color: #f8f9fa;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
        }
        .flow-icon { width: 22px; height: 22px; }

        /* ========== 座席状況画面の専用スタイル ========== */
        .seat-grid-container { background-color: white; padding: 10px; border: 1px solid #ddd; border-radius: 8px; overflow-x: auto; }
        .seat-grid { display: grid; grid-template-columns: repeat(20, 1fr); gap: 5px; min-width: 700px; }
        .seat-cell { width: 30px; height: 30px; border: 1px solid #ccc; border-radius: 4px; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold; }

        /* --- ステータスごとのスタイル --- */
        .seat-cell.available { background-color: #ffffff; }
        .seat-cell.status-reserved { background-color: #e9ecef; color: #868e96; border-color: #ced4da; } /* 予約済み: 灰色 */
        .seat-cell.status-checked-in { background-color: #d4edda; color: #155724; border-color: #c3e6cb; } /* チェックイン: 緑 */
        .seat-cell.status-provisional { background-color: #fff3cd; color: #856404; border-color: #ffeeba; } /* 仮予約: 黄色 */

        /* --- 時間選択ボタンのスタイル --- */
        .time-selector { padding: 16px; background: #f8f9fa; border-radius: 8px; }
        .time-selector-header { display: flex; align-items: center; gap: 8px; font-weight: bold; margin-bottom: 10px; }
        .time-grid-container { display: grid; grid-template-columns: repeat(auto-fill, minmax(50px, 1fr)); gap: 8px; }
        .time-button { display: block; padding: 8px; border: 1px solid #dee2e6; border-radius: 4px; text-align: center; cursor: pointer; background: white; font-size: 12px; text-decoration: none; color: #212529; }
        .time-button:hover { background-color: #f1f3f5; }
        .time-button.active { background-color: #0d6efd; color: white; border-color: #0d6efd; font-weight: bold; }
        /* --- ログアウトフォームのスタイル --- */
        .logout-form {
        margin-top: auto; /* この指定でフォームが最下部に配置される */
        padding: 20px;    /* 周囲の余白を調整 */
        }

        .logout-form button {
        width: 100%;
        margin-top: 0; /* 上の汎用スタイルをリセット */
        background-color: #6c757d; /* ログアウトボタンの色を変更 */
        }

        .logout-form button:hover {
        background-color: #5a6268;
        }
    </style>
</head>
<body>

<div class="admin-container">
    <!-- 左側ナビゲーション -->
    <nav class="admin-nav">
        <div class="logo">
            <a href="${pageContext.request.contextPath}/admin">
                <img src="${pageContext.request.contextPath}/image/logo.png" alt="ロゴ">
            </a>
        </div>
        <ul>
            <li><a href="#home-section" class="nav-link"><img src="${pageContext.request.contextPath}/image/home.png" alt="ホーム" class="nav-icon">ホーム</a></li>
            <li><a href="#seat-status-section" class="nav-link"><img src="${pageContext.request.contextPath}/image/seat-reservation.png" alt="座席状況" class="nav-icon">座席状況</a></li>
            <li><a href="#reservation-section" class="nav-link"><img src="${pageContext.request.contextPath}/image/reservation-info.png" alt="予約状況" class="nav-icon">予約状況</a></li>
            <li><a href="#user-section" class="nav-link"><img src="${pageContext.request.contextPath}/image/user.png" alt="ユーザー管理" class="nav-icon">ユーザー</a></li>
            <!--<li><a href="#admin-section" class="nav-link"><img src="${pageContext.request.contextPath}/image/admin.png" alt="管理者管理" class="nav-icon">管理者</a></li>-->
            <li><a href="#setting-section" class="nav-link"><img src="${pageContext.request.contextPath}/image/setting.png" alt="設定" class="nav-icon">設定</a></li>
        </ul>
        <form class="logout-form" action="${pageContext.request.contextPath}/admin-logout" method="post">
            <button type="submit">ログアウト</button>
        </form>
    </nav>

    <!-- 右側メインコンテンツ -->
    <main class="admin-main">
        <section id="home-section" class="main-section">
            <h2>ホーム</h2>
            <c:if test="${not empty requestScope.error}"><div class="message error">エラー：${fn:escapeXml(requestScope.error)}</div></c:if>
            <c:if test="${not empty requestScope.success}"><div class="message success">${fn:escapeXml(requestScope.success)}</div></c:if>
            
            <div class="flowchart-container">

                <!-- 予約・座席管理ブロック -->
                <div class="flow-block">
                    <a href="#reservation-section" class="flow-main-button bg-orange">予約・座席管理</a>
                    <div class="flow-sub-container">
                        <div class="flow-sub-row">
                            <a href="#seat-status-section" class="flow-sub-button">
                                <img src="${pageContext.request.contextPath}/image/seat-reservation.png" alt="座席状況" class="flow-icon">
                                <span>座席状況の確認</span>
                            </a>
                            <a href="#reservation-section" class="flow-sub-button">
                                <img src="${pageContext.request.contextPath}/image/reservation-info.png" alt="予約状況" class="flow-icon">
                                <span>全予約の確認</span>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="flow-arrow"></div>

                <!-- 顧客管理ブロック -->
                <div class="flow-block">
                    <a href="#user-section" class="flow-main-button bg-blue">顧客管理</a>
                    <div class="flow-sub-container">
                        <div class="flow-sub-row">
                             <a href="#user-section" class="flow-sub-button">
                                <img src="${pageContext.request.contextPath}/image/user.png" alt="ユーザー" class="flow-icon">
                                <span>ユーザー一覧</span>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="flow-arrow"></div>

                <!-- システム管理ブロック -->
                <div class="flow-block">
                    <a href="#admin-section" class="flow-main-button bg-green">システム管理</a>
                     <div class="flow-sub-container">
                        <div class="flow-sub-row">
                            <!--<a href="#admin-section" class="flow-sub-button">
                                <img src="${pageContext.request.contextPath}/image/admin.png" alt="管理者" class="flow-icon">
                                <span>管理者一覧</span>
                            </a>-->
                            <a href="#setting-section" class="flow-sub-button">
                                <img src="${pageContext.request.contextPath}/image/setting.png" alt="設定" class="flow-icon">
                                <span>設定</span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section id="seat-status-section" class="main-section hidden">
            <h2>座席状況</h2>
            <div style="display: flex; flex-wrap: wrap; gap: 20px;">
                <div class="time-selector" style="flex: 1; min-width: 300px;">
                    <div class="time-selector-header">
                        <span id="selected-date">${fn:escapeXml(requestScope.currentDate)}</span>
                    </div>
                    <div class="time-grid-container">
                        <c:forEach begin="0" end="23" var="h">
                            <c:forEach begin="0" end="50" step="10" var="m">
                                <c:set var="timeValue"><c:if test="${h<10}">0</c:if>${h}:<c:if test="${m<10}">0</c:if>${m}</c:set>
                                <c:set var="activeClass" value="${requestScope.selectedTime eq timeValue ? ' active' : ''}" />
                                <a href="${pageContext.request.contextPath}/admin?date=${requestScope.currentDate}&time=${timeValue}#seat-status-section" 
                                   class="time-button${activeClass}">
                                   ${timeValue}
                                </a>
                            </c:forEach>
                        </c:forEach>
                    </div>
                </div>
                <div style="flex: 2; min-width: 400px;">
                     <div class="time-selector-header">
                        <span id="display-time" style="font-size: 24px; font-weight: bold;">
                            <c:out value="${not empty requestScope.selectedTime ? requestScope.selectedTime : '--:--'}" />
                        </span>
                    </div>
                    <div class="seat-grid-container">
                        <div class="seat-grid">
                            <c:forEach begin="1" end="21" var="row">
                                <c:forEach var="col" items="${['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T']}">
                                    <c:set var="seatName" value="${col}${row}"/>
                                    <c:set var="status" value="${requestScope.seatStatusMap[seatName]}"/>
                                    <c:choose>
                                        <c:when test="${status eq '予約済み'}"><div class="seat-cell status-reserved" title="${seatName}: 予約済み">×</div></c:when>
                                        <c:when test="${status eq 'チェックイン済み'}"><div class="seat-cell status-checked-in" title="${seatName}: チェックイン済み">✓</div></c:when>
                                        <c:when test="${status eq '仮予約'}"><div class="seat-cell status-provisional" title="${seatName}: 仮予約">仮</div></c:when>
                                        <c:otherwise><div class="seat-cell available" title="${seatName}: 空席"></div></c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section id="reservation-section" class="main-section hidden">
            <h2>予約状況</h2>
            <c:choose>
                <c:when test="${not empty requestScope.reservationDtoList}">
                    <table>
                        <thead>
                            <tr><th>予約番号</th><th>ユーザーID</th><th>人数</th><th>予約日</th><th>予約時間</th><th>予約座席</th><th>ステータス</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="dto" items="${requestScope.reservationDtoList}">
                                <tr>
                                    <td>${fn:escapeXml(fn:substring(dto.reservationId, 0, 8))}...</td>
                                    <td>${fn:escapeXml(fn:substring(dto.userId, 0, 8))}...</td>
                                    <td>${fn:escapeXml(dto.numberOfPeople)}名</td>
                                    <td><fmt:formatDate value="${dto.reservationDateAsDate}" type="DATE" pattern="yyyy/MM/dd"/></td>
                                    <td><fmt:formatDate value="${dto.startTimeAsDate}" type="TIME" pattern="HH:mm"/> ~ <fmt:formatDate value="${dto.endTimeAsDate}" type="TIME" pattern="HH:mm"/></td>
                                    <td>${fn:escapeXml(dto.seatsAsString)}</td>
                                    <td>${fn:escapeXml(dto.reservationStatus)}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise><p>表示する予約がありません。</p></c:otherwise>
            </c:choose>
        </section>
        
        <section id="user-section" class="main-section hidden">
            <h2>ユーザー</h2>
            <c:choose>
                <c:when test="${not empty requestScope.userList}">
                    <table>
                        <thead>
                            <tr><th>ユーザーID</th><th>ユーザー名</th><th>ステータス</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="user" items="${requestScope.userList}">
                                <tr>
                                    <td>${fn:escapeXml(user.userId)}</td>
                                    <td>${fn:escapeXml(user.userName)}</td>
                                    <td>${fn:escapeXml(user.userStatus)}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise><p>表示するユーザーがいません。</p></c:otherwise>
            </c:choose>
        </section>

        <!--
        <section id="admin-section" class="main-section hidden">
            <h2>管理者</h2>
             <c:choose>
                <c:when test="${not empty requestScope.adminList}">
                     <table>
                        <thead>
                            <tr><th>管理者ID</th><th>管理者名</th><th>ステータス</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="admin" items="${requestScope.adminList}">
                                <tr>
                                    <td>${fn:escapeXml(admin.adminId)}</td>
                                    <td>${fn:escapeXml(admin.adminName)}</td>
                                    <td>${fn:escapeXml(admin.adminStatus)}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise><p>表示する管理者がいません。</p></c:otherwise>
            </c:choose>
        </section>-->
        
        <section id="setting-section" class="main-section hidden">
            <h2>設定</h2>
        </section>
    </main>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const navLinks = document.querySelectorAll('.admin-nav .nav-link');
    const sections = document.querySelectorAll('.admin-main .main-section');
    const flowchartLinks = document.querySelectorAll('.flowchart-container a');

    // 最初に表示するセクションを決定（URLのハッシュがあればそれを優先）
    const initialHash = window.location.hash || '#home-section';

    // 指定されたIDのセクションを表示し、ナビゲーションの状態を更新する関数
    function updateActiveState(targetId) {
        sections.forEach(section => {
            section.classList.add('hidden');
        });
        const targetSection = document.querySelector(targetId);
        if (targetSection) {
            targetSection.classList.remove('hidden');
        }

        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === targetId) {
                link.classList.add('active');
            }
        });
    }

    // 初期表示
    updateActiveState(initialHash);

    // 各ナビゲーションリンクにクリックイベントを設定
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            updateActiveState(targetId);
            // URLのハッシュを更新してブラウザ履歴に保存
            history.pushState(null, null, targetId); 
        });
    });

    // フローチャート内のリンクにクリックイベントを設定
    if (flowchartLinks.length > 0) {
        flowchartLinks.forEach(link => {
            link.addEventListener('click', (event) => {
                event.preventDefault();
                const targetId = link.getAttribute('href');
                if (targetId && targetId.startsWith('#')) {
                    // 対応するナビゲーションリンクを探してクリックイベントを発火させる
                    const navLinkToClick = document.querySelector(`.admin-nav .nav-link[href="${targetId}"]`);
                    if (navLinkToClick) {
                        navLinkToClick.click();
                    }
                }
            });
        });
    }
});
</script>
</body>
</html>