<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalTime, java.time.Duration" %>
<%@ page import="java.time.ZonedDateTime, java.time.ZoneId, java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    ZonedDateTime nowJst = ZonedDateTime.now(ZoneId.of("Asia/Tokyo"));
    String currentTimeJst = nowJst.format(DateTimeFormatter.ofPattern("HH:mm"));
    pageContext.setAttribute("currentTimeJst", currentTimeJst);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>予約確認・変更</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
      /* --- 共通スタイル --- */
      body { margin: 0; font-family: 'Inter', sans-serif; background-color: #e0e0e0; display: flex; justify-content: center; }
      .container { box-sizing: border-box; position: relative; width: 393px; height: 852px; background: #ffffff; border: 1px solid #ccc; overflow-y: auto; }
      .header { width: 100%; height: 60px; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; box-sizing: border-box; background-color: #fff; }
      .menu-icon .line { width: 25px; height: 2px; background-color: #000; margin: 6px 0; }
      .logo { font-weight: bold; text-align: center; }
      .user-icon { font-size: 24px; }
      
      /* --- タブと背景 --- */
      .content-background { position: absolute; width: 100%; height: calc(100% - 120px); left: 0; top: 120px; transition: background-color: 0.3s ease; }
      .tabs { position: absolute; width: calc(100% - 30px); left: 15px; top: 130px; display: flex; height: 65px; z-index: 5; }
      .tab { flex: 1; display: flex; flex-direction: column; justify-content: center; align-items: center; gap: 8px; font-size: 10px; font-weight: 700; border-radius: 5px 5px 0 0; box-sizing: border-box; cursor: pointer; border: 1px solid transparent; }
      .tab-link { color: inherit; text-decoration: none; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 100%; height: 100%; justify-content: center;}
      .tab.active.qr-active { background: #ffffff; color: #0070c0; }
      .tab.inactive.qr-active { background: rgba(255, 255, 255, 0.4); color: #000000; border-color: #e7f9ff; }
      .tab.active.change-active { background: #ffffff; color: #00b050; }
      .tab.inactive.change-active { background: rgba(255, 255, 255, 0.4); color: #000000; border-color: #e8fae2; }
      .tab.active.cancel-active { background: #ffffff; color: #c00000; }
      .tab.inactive.cancel-active { background: rgba(255, 255, 255, 0.4); color: #000000; border-color: #fff2f2; }
      .view-container { position: absolute; width: calc(100% - 30px); left: 15px; top: 195px; height: auto; padding-bottom: 20px; }
      .main-card { background: #ffffff; border-radius: 0 0 5px 5px; box-sizing: border-box; }
      
      /* --- QRビュー & キャンセルビュー スタイル --- */
      .submit-btn-container { text-align: center; margin-top: 30px; }
      .submit-btn { width: 250px; height: 45px; color: #ffffff; font-size: 20px; font-weight: 700; border: none; border-radius: 50px; cursor: pointer; }
      .confirmation-area { text-align: center; }
      .confirmation-item { padding: 15px 0; border-bottom: 1px solid #eee; text-align: left; }
      .confirmation-item:last-of-type { border-bottom: none; }
      .confirmation-item .item-label { font-size: 13px; color: #888; margin-bottom: 8px; }
      .confirmation-item .item-value { font-size: 20px; font-weight: bold; color: #333; }

      /* --- ▼▼▼ 変更ビューのスタイル ▼▼▼ --- */
      .change-view-outer-card { padding: 0 !important; }
      .change-view-title { padding: 20px 20px 0; font-weight: 700; font-size: 20px; color: #000000; margin: 0; }
      .change-view-content-background { background: #F5F5F5; border-radius: 0 0 5px 5px; padding: 20px; box-sizing: border-box; margin-top: 20px; }
      .form-card { padding: 25px; background: #FFFFFF; border-radius: 10px; box-sizing: border-box; }
      .info-box { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); margin-bottom: 20px; }
      .action-button { background-color: #00b050; color: #fff; padding: 12px 25px; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; }
      .action-button:disabled { background-color: #ccc; cursor: not-allowed; }
      .step-bar { display: flex; align-items: center; justify-content: space-between; height: 30px; margin: 20px 0; }
      .step { position: relative; display: flex; flex-direction: column; align-items: center; flex: 1; }
      .step-label { position: absolute; top: 25px; font-weight: 600; font-size: 8px; color: #000000; width: 40px; text-align: center; }
      .section { padding: 20px 0; border-bottom: 1px solid #CCCCCC; }
      .section:last-of-type { border-bottom: none; }
      .row-flex { display: flex; justify-content: space-between; align-items: center; }
      .item-label-group { display: flex; align-items: center; gap: 10px; }
      .item-label-group .icon { font-size: 24px; }
      .item-label-group .label-text { font-size: 12px; color: #888888; font-weight: 600; }
      .counter { display: flex; align-items: center; }
      .counter button { width: 30px; height: 30px; border-radius: 50%; border: 1px solid #000; background-color: #fff; cursor: pointer; }
      #count { font-size: 20px; padding: 0 20px; }
      .time-value-display { font-weight: 600; font-size: 14px; }
      .grid-container { display: flex; gap: 10px; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); }
      .hour-labels { width: 50px; }
      .hour-label { height: 48px; display: flex; align-items: center; justify-content: flex-end; font-size: 15px; color: #555; }
      .time-grid { flex-grow: 1; display: grid; grid-template-columns: repeat(6, 1fr); gap: 8px; }
      .time-button { padding: 15px 5px; border: 1px solid #ddd; text-align: center; cursor: pointer; background-color: white; border-radius: 6px; font-size: 14px; }
      .time-button.selected-start { background-color: #1abc9c; color: white; border-color: #1abc9c; }
      .time-button.selected-end { background-color: #e74c3c; color: white; border-color: #e74c3c; }
      .time-button.selected-range { background-color: #3498db; color: white; border-color: #3498db; }
      .time-button.past-time {
          background-color: #f0f0f0;
          color: #ccc;
          cursor: not-allowed;
          border-color: #e0e0e0;
      }
      .seat-grid-container { background-color: white; padding: 10px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); overflow-x: auto; }
      .seat-grid { display: grid; grid-template-columns: 30px repeat(4, 1fr) 10px repeat(3, 1fr) 10px repeat(3, 1fr) 10px repeat(6, 1fr) 10px repeat(4, 1fr) 30px; gap: 1px; min-width: 850px; }
      .row-label { text-align: right; padding-right: 5px; font-size: 10px; color: #888; height: 25px; display: flex; align-items: center; justify-content: flex-end; }
      .seat-cell { width: 25px; height: 25px; border-radius: 4px; cursor: pointer; display: flex; align-items: center; justify-content: center; margin: 2px; font-size: 14px; }
      .available { border: 2px solid #3498db; background-color: #e9f2ff; color: #3498db; }
      .selected { border: 2px solid #2ecc71; background-color: #d6f5d6; color: #2ecc71; }
      .occupied { border: 2px solid #e74c3c; background-color: #fadde1; color: #e74c3c; cursor: not-allowed; }
      .step-icon { width: 24px; height: 24px; border-radius: 50%; border: 1px solid #000; background-color: #F5F5F5; z-index: 2; display: flex; justify-content: center; align-items: center; position: relative; }
      .step-icon img { width: 16px; height: 16px; }
      .step:not(:last-child)::after { content: ''; position: absolute; left: 50%; top: 12px; width: 100%; height: 1px; background-color: #000; z-index: 1; }
      .step.active-step .step-icon { background-color: #00b050; color: white; border-color: #00b050; }
      .step.active-step .step-icon::before { content: '✓'; font-size: 14px; text-align: center; line-height: 24px; }
      .step.active-step .step-icon img { display: none; }
      /* --- ▲▲▲ 変更ビューのスタイルここまで ▲▲▲ --- */
    </style>
</head>
<body>
<%-- JSTL変数設定 --%>
<c:set var="view" value="${not empty requestScope.view ? requestScope.view : 'qr'}" />
<c:set var="changeStep" value="${not empty requestScope.changeStep ? requestScope.changeStep : 'main'}" />
<c:set var="isQrView" value="${view == 'qr'}" />
<c:set var="isChangeView" value="${view == 'change'}" />
<c:set var="isCancelView" value="${view == 'cancelConfirm'}" />
<c:set var="currentNumberPeople" value="${not empty sessionScope.change_numberPeople ? sessionScope.change_numberPeople : '1'}" />
<c:set var="currentStartTime" value="${not empty sessionScope.change_startTime ? sessionScope.change_startTime : ''}" />
<c:set var="currentEndTime" value="${not empty sessionScope.change_endTime ? sessionScope.change_endTime : ''}" />
<c:set var="currentSelectedSeats" value="${not empty sessionScope.change_selectedSeats ? sessionScope.change_selectedSeats : ''}" />

<div class="container">
    <header>
        <div class="menu-icon"><div class="line"></div><div class="line"></div><div class="line"></div></div>
        <img src="${pageContext.request.contextPath}/image/logo.png" alt="ロゴ" style="width: 200px; height: auto;">
        <div class="user-icon">👤</div>
    </header>

    <div class="content-background" style="background-color: ${isQrView ? '#E7F5FF' : (isChangeView ? '#E8FAE2' : '#FFF2F2')};"></div>

    <div class="tabs">
        <div class="tab ${isQrView ? 'active qr-active' : 'inactive qr-active'}">
            <a href="${pageContext.request.contextPath}/reservation-modify" class="tab-link">
              <span>📊</span> <span>QRコード</span>
            </a>
        </div>
        <div class="tab ${isChangeView ? 'active change-active' : 'inactive change-active'}">
           <a href="javascript:document.getElementById('changeTabForm').submit();" class="tab-link">
              <span>📄</span> <span>変更</span>
           </a>
        </div>
        <div class="tab ${isCancelView ? 'active cancel-active' : 'inactive cancel-active'}">
            <a href="javascript:document.getElementById('cancelTabForm').submit();" class="tab-link">
              <span>📅</span> <span>キャンセル</span>
            </a>
        </div>
    </div>
    
    <%-- タブクリック用フォーム --%>
    <form id="changeTabForm" action="${pageContext.request.contextPath}/reservation-modify" method="post" style="display: none;"><input type="hidden" name="step" value="showChangeView"></form>
    <form id="cancelTabForm" action="${pageContext.request.contextPath}/reservation-modify" method="post" style="display: none;"><input type="hidden" name="step" value="showCancelConfirm"></form>

    <div class="view-container">
        <c:if test="${not empty errorMessage}">
            <div style="color: red; text-align: center; background: #ffebee; padding: 10px; border-radius: 5px; margin-bottom: 15px;">${errorMessage}</div>
        </c:if>

        <c:choose>
            <%-- ======================= QRコード表示ビュー ======================= --%>
            <c:when test="${view == 'qr'}">
                <div class="main-card" style="padding: 30px 25px; text-align: center;">
                    <img src="data:image/png;base64,${sessionScope.qrCodeBase64}" alt="予約QRコード" style="width: 204px; height: 204px; margin: 0 auto;"/>
                    <p style="margin-top: 25px; font-size: 12px; color: #555; line-height: 1.5;">
                        予約は完了済みです。<br />
                        予約時間までに自動チェックイン機に、QRコードをスキャンしてください。
                    </p>
                    <%-- QRコード詳細カード --%>
                    <div width: 300px; left: 50%; transform: translateX(-50%); bottom: 70px; background: #ffffff; box-shadow: 0px 0px 20px rgba(0, 0, 0, 0.15); border-radius: 10px;">
                        <div style="background: #0070c0; color: #ffffff; padding: 4px 15px 18px; border-radius: 10px 10px 0 0; display: flex; align-items: center;">
                            <div style="flex-grow: 1;">
                                <div style="font-size: 6px; font-weight: 600;">予約番号</div>
                                <div style="font-size: 14px; font-weight: 600; word-break: break-all;">${reservationId}</div>
                            </div>
                        </div>
                        <div style="padding: 22px 20px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; font-weight: 600; color: #000;">
                                <span style="font-size: 20px;">${startTime}</span>
                                <% 
                                long durationInMinutes = 0; 
                                try {
                                    String startStr = (String) request.getAttribute("startTime");
                                    String endStr = (String) request.getAttribute("endTime");
                                    if (startStr != null && endStr != null) {
                                        durationInMinutes = Duration.between(LocalTime.parse(startStr), LocalTime.parse(endStr)).toMinutes();
                                    }
                                } catch (Exception e) {}
                                %>
                                <span style="font-size: 14px;"><%= durationInMinutes %>min</span>
                                <span style="font-size: 20px;">${endTime}</span>
                            </div>
                            <div style="border-top: 1px dashed #aaaaaa; margin: 22px 0;"></div>
                            <div style="display: flex; justify-content: flex-start; padding: 0 20px; gap: 60px;">
                                <div>
                                    <div style="font-size: 10px; font-weight: 600; color: #888888; margin-bottom: 2px;">人数</div>
                                    <div style="font-size: 16px; font-weight: 600; color: #000000;">${numberPeople}</div>
                                </div>
                                <div>
                                    <div style="font-size: 10px; font-weight: 600; color: #888888; margin-bottom: 2px;">座席番号</div>
                                    <div style="font-size: 16px; font-weight: 600; color: #000000;">${selectedSeats}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:when>

            <%-- ======================= 予約変更ビュー ======================= --%>
            <c:when test="${view == 'change'}">
                <div class="main-card change-view-outer-card">
                    <form method="post" action="${pageContext.request.contextPath}/reservation-modify" id="changeFlowForm">
                        <input type="hidden" name="numberPeople" id="numberPeople" value="${currentNumberPeople}">
                        <input type="hidden" name="startTime" id="startTime" value="${currentStartTime}">
                        <input type="hidden" name="endTime" id="endTime" value="${currentEndTime}">
                        <input type="hidden" name="selectedSeats" id="selectedSeats" value="${currentSelectedSeats}">
                        <input type="hidden" name="step" id="next_step" value="">

                        <c:choose>
                            <c:when test="${changeStep == 'time'}">
                                <h2 class="change-view-title">時間選択</h2>
                                <div class="change-view-content-background">
                                    <div class="info-box">
                                        <div id="time-display-container" style="font-weight: bold; font-size: 18px; text-align: center;">
                                            <span class="selected-time-value selected-time-start"></span> ~ <span class="selected-time-value selected-time-end"></span>
                                        </div>
                                        <p id="hint-text" class="hint-text" style="text-align: center; font-size: 14px; margin-top: 10px;"></p>
                                    </div>
                                    <div class="grid-container">
                                        <div class="hour-labels">
                                            <c:forEach begin="8" end="24" var="hour"><div class="hour-label">${hour}時</div></c:forEach>
                                        </div>
                                        <div class="time-grid">
                                            <c:forEach begin="8" end="24" var="h">
                                                <c:forEach begin="0" end="50" step="10" var="m">
                                                    <c:set var="timeValue"><c:if test="${h<10}">0</c:if>${h}:<c:if test="${m<10}">0</c:if>${m}</c:set>
                                                    <div class="time-button" onclick="window.selectTime(this)">${timeValue}</div>
                                                </c:forEach>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <div class="submit-btn-container">
                                        <button type="button" id="timeConfirmBtn" class="action-button" disabled onclick="document.getElementById('next_step').value='goToSeat'; this.form.submit();">時間を確定して座席選択へ</button>
                                    </div>
                                </div>
                            </c:when>

                            <%-- 変更フロー：座席選択ステップ --%>
                            <c:when test="${changeStep == 'seat'}">
                                <h2 class="change-view-title">座席選択</h2>
                                <div class="change-view-content-background">
                                    <div class="info-box">
                                        <p>予約人数: <strong>${sessionScope.change_numberPeople}名</strong></p>
                                        選択中: (<span id="selected-count">0</span>/<span id="required-count">${sessionScope.change_numberPeople}</span>)
                                        <div id="selected-seats-display" style="font-weight: bold; margin-top: 5px;">座席未選択</div>
                                    </div>
                                    <div class="seat-grid-container">
                                        <div class="seat-grid" id="seatGrid">
                                            <c:forEach var="rowLabel" items="${['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U']}">
                                                <div class="row-label">${rowLabel}</div>
                                                <c:forEach begin="1" end="21" var="col">
                                                    <c:set var="seatName" value="${rowLabel}${col}"/>
                                                    <c:set var="isOccupied" value="${fn:contains(reservedSeats, seatName)}"/>
                                                    <div class="seat-cell ${isOccupied ? 'occupied' : 'available'}" data-name="${seatName}" onclick="toggleSeat(this)">
                                                        <c:if test="${isOccupied}">×</c:if>
                                                    </div>
                                                </c:forEach>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <div class="submit-btn-container">
                                        <button type="button" id="seatConfirmBtn" class="action-button" disabled onclick="document.getElementById('next_step').value='provisionalChange'; this.form.submit();">変更内容の確認へ</button>
                                    </div>
                                </div>
                            </c:when>
                            
                            <%-- 変更フロー：メイン/確認ステップ --%>
                            <c:otherwise> 
                                <h2 class="change-view-title">${not empty showConfirmChange ? '変更内容の確認' : '予約の変更'}</h2>
                                <div class="change-view-content-background">
                                    <c:set var="isPeopleDone" value="${true}" />
                                    <c:set var="isTimeDone" value="${not empty currentStartTime}" />
                                    <c:set var="isSeatDone" value="${not empty currentSelectedSeats}" />
                                    <c:set var="isConfirmDone" value="${not empty showConfirmChange}" />
                                    <div class="step-bar">
                                        <div class="step ${isPeopleDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/人数.svg" alt="人数"></div><span class="step-label">人数</span></div>
                                        <div class="step ${isTimeDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/時間.svg" alt="時間"></div><span class="step-label">時間</span></div>
                                        <div class="step ${isSeatDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/座席選択.png" alt="座席"></div><span class="step-label">座席指定</span></div>
                                        <div class="step ${isConfirmDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/確認.svg" alt="確認"></div><span class="step-label">確認</span></div>
                                        <div class="step"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/完了.svg" alt="完了"></div><span class="step-label">完了</span></div>
                                    </div>
                                    
                                    <div class="form-card">
                                        <div id="input-mode-area" style="${not empty showConfirmChange ? 'display: none;' : ''}">
                                            <div class="section">
                                                <div class="row-flex">
                                                    <div class="item-label-group"><span class="icon"><img src="${pageContext.request.contextPath}/image/人①.svg" alt="人数" height="30"></span><span class="label-text">人数</span></div>
                                                    <div class="counter">
                                                        <button type="button" id="decreaseBtn">－</button>
                                                        <span id="count">${currentNumberPeople}</span>
                                                        <button type="button" id="increaseBtn">＋</button>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="section">
                                                <div class="row-flex">
                                                    <div class="item-label-group"><span class="icon"><img src="${pageContext.request.contextPath}/image/時間.svg" alt="時間" height="30"></span><span class="label-text">時間</span></div>
                                                    <div class="time-value-display">
                                                        <c:out value="${not empty currentStartTime ? currentStartTime : '未選択'}" />
                                                        <c:if test="${not empty currentStartTime}"> 〜 <c:out value="${currentEndTime}" /></c:if>
                                                    </div>
                                                    <button type="button" class="action-button" onclick="goToChangeStep('goToTime')">${not empty currentStartTime ? '時間変更' : '時間選択'}</button>
                                                </div>
                                            </div>
                                            <div class="section">
                                                <div class="row-flex">
                                                    <div class="item-label-group"><span class="icon"><img src="${pageContext.request.contextPath}/image/座席選択.png" alt="座席" height="30"></span><span class="label-text">座席</span></div>
                                                    <div class="time-value-display">${not empty currentSelectedSeats ? fn:replace(currentSelectedSeats, ',', ', ') : '未選択'}</div>
                                                    <button type="button" class="action-button" id="seatSelectButton" onclick="goToChangeStep('goToSeat')">${not empty currentSelectedSeats ? '座席変更' : '座席選択'}</button>
                                                </div>
                                            </div>
                                        </div>

                                        <div id="confirm-mode-area" style="${not empty showConfirmChange ? '' : 'display: none;'}">
                                            <div class="confirmation-item"><div class="item-label">人数</div><div class="item-value">${sessionScope.change_numberPeople}名</div></div>
                                            <div class="confirmation-item"><div class="item-label">時間</div><div class="item-value">${sessionScope.change_startTime} 〜 ${sessionScope.change_endTime}</div></div>
                                            <div class="confirmation-item"><div class="item-label">座席</div><div class="item-value">${fn:replace(sessionScope.change_selectedSeats, ',', ', ')}</div></div>
                                        </div>

                                        <div class="submit-btn-container">
                                            <c:choose>
                                                <c:when test="${not empty showConfirmChange}">
                                                    <button type="button" id="finalConfirmButton" class="action-button" style="width: auto;">変更を確定する</button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button" id="goToConfirmButton" class="action-button" style="width: auto;" disabled>内容を確認する</button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </form>
                </div>
            </c:when>
            
            <%-- ======================= 予約キャンセルビュー ======================= --%>
            <c:when test="${view == 'cancelConfirm'}">
                <div class="main-card confirmation-area" style="padding: 30px 25px;">
                    <h3 style="margin-top:0;">予約のキャンセル</h3>
                    <p>本当にこの予約をキャンセルしますか？<br>この操作は元に戻せません。</p>
                    <div class="confirmation-item"><div class="item-label">時間</div><div class="item-value">${startTime} 〜 ${endTime}</div></div>
                    <div class="confirmation-item"><div class="item-label">人数</div><div class="item-value">${numberPeople}名</div></div>
                    <div class="confirmation-item"><div class="item-label">座席</div><div class="item-value">${selectedSeats}</div></div>
                    <div class="submit-btn-container">
                        <form action="${pageContext.request.contextPath}/reservation-modify" method="post">
                             <input type="hidden" name="step" value="executeCancel">
                             <button type="submit" class="submit-btn" style="background: #c00000;">はい、キャンセルします</button>
                        </form>
                    </div>
                </div>
            </c:when>
        </c:choose>
    </div>
    
</div>



<script>
    // =================================================================
    // ▼▼▼ 最終修正版・デバッグ機能付きJavaScript ▼▼▼
    // =================================================================

    /**
     * [デバッグ用] キャッチされなかったグローバルなエラーを捕捉します。
     */
    window.onerror = function(message, source, lineno, colno, error) {
        console.error("[FATAL ERROR] Uncaught exception:", {
            message: message,
            source: source,
            lineno: lineno,
            colno: colno,
            error: error
        });
        return false; // trueにするとエラーがコンソールに表示されなくなります
    };
    
    /**
     * [デバッグ用] 要素取得を安全に行うラッパー関数
     */
    function getElementByIdSafe(id, functionName) {
        const element = document.getElementById(id);
        if (!element) {
            console.warn(`[DEBUG] In ${functionName}, element with ID '${id}' was not found. This may be expected depending on the current view.`);
        }
        return element;
    }

    // onclick属性から呼び出せるように、これらの関数はグローバルスコープに定義します
    function goToChangeStep(stepName) {
        console.log(`[DEBUG] goToChangeStep called with step: '${stepName}'`);
        try {
            getElementByIdSafe('next_step', 'goToChangeStep').value = stepName;
            const countEl = getElementByIdSafe('count', 'goToChangeStep');
            if (countEl) { // mainビューにのみ存在するため、存在チェックを追加
                 getElementByIdSafe('numberPeople', 'goToChangeStep').value = countEl.innerText;
            }
            getElementByIdSafe('changeFlowForm', 'goToChangeStep').submit();
        } catch (e) {
            console.error('[ERROR] in goToChangeStep function:', e);
        }
    }
    // windowオブジェクトに明示的にアタッチして、呼び出しを確実にします
    window.goToChangeStep = goToChangeStep;
    
    // --- メインの処理は、DOMが完全に読み込まれてから実行します ---
    document.addEventListener('DOMContentLoaded', function() {
        console.log('[DEBUG] DOMContentLoaded event fired. Initializing scripts...');
        
        // [修正点] DOM読み込み後に時刻を取得することで、undefinedになるのを防ぎます
        const currentTime = document.body.dataset.currentTime;
        console.log(`[DEBUG] Current time read from data attribute: '${currentTime}'`);

        const isChangeView = "${isChangeView}" === "true";
        if (isChangeView) {
            const changeStepParam = "${changeStep}";
            const showConfirmChangeParam = "${not empty showConfirmChange}" === "true";
            console.log(`[DEBUG] Initializing ChangeView. Step: ${changeStepParam}, ConfirmMode: ${showConfirmChangeParam}`);

            if (changeStepParam === 'main' || showConfirmChangeParam) {
                initializeMainChangeScreen();
            } else if (changeStepParam === 'time') {
                // currentTimeを引数として渡します
                initializeTimeScreen(currentTime); 
            } else if (changeStepParam === 'seat') {
                initializeSeatChangeScreen();
            }
        } else {
             console.log('[DEBUG] Not in ChangeView. No specific initialization needed.');
        }
    });

    // --- 各ビューの初期化関数 ---

    function initializeMainChangeScreen() {
        console.log('[DEBUG] Initializing MainChangeScreen...');
        try {
            const goToConfirmButton = getElementByIdSafe('goToConfirmButton', 'initializeMainChangeScreen');
            const numberPeopleInput = getElementByIdSafe("numberPeople", 'initializeMainChangeScreen');
            const decreaseBtn = getElementByIdSafe('decreaseBtn', 'initializeMainChangeScreen');
            const increaseBtn = getElementByIdSafe('increaseBtn', 'initializeMainChangeScreen');

            if (goToConfirmButton && numberPeopleInput && decreaseBtn && increaseBtn) {
                const updatePeopleCount = (newCount) => {
                    numberPeopleInput.value = newCount;
                    getElementByIdSafe('next_step', 'updatePeopleCount').value = 'goToTime'; 
                    getElementByIdSafe('startTime', 'updatePeopleCount').value = '';
                    getElementByIdSafe('endTime', 'updatePeopleCount').value = '';
                    getElementByIdSafe('selectedSeats', 'updatePeopleCount').value = '';
                    getElementByIdSafe('changeFlowForm', 'updatePeopleCount').submit();
                }
                increaseBtn.onclick = () => updatePeopleCount(parseInt(numberPeopleInput.value, 10) + 1);
                decreaseBtn.onclick = () => {
                    const currentCount = parseInt(numberPeopleInput.value, 10);
                    if (currentCount > 1) { updatePeopleCount(currentCount - 1); }
                };
                
                const checkGoToConfirmButtonState = () => {
                    const timeIsSelected = getElementByIdSafe('startTime', 'checkGoToConfirmButtonState').value !== "";
                    const seatsAreSelected = getElementByIdSafe('selectedSeats', 'checkGoToConfirmButtonState').value !== "";
                    getElementByIdSafe('seatSelectButton', 'checkGoToConfirmButtonState').disabled = !timeIsSelected;
                    goToConfirmButton.disabled = !(timeIsSelected && seatsAreSelected);
                }
                goToConfirmButton.onclick = () => {
                    getElementByIdSafe('next_step', 'goToConfirmButton.onclick').value = 'provisionalChange';
                    getElementByIdSafe('changeFlowForm', 'goToConfirmButton.onclick').submit();
                };
                checkGoToConfirmButtonState();
            }

            const finalConfirmButton = getElementByIdSafe('finalConfirmButton', 'initializeMainChangeScreen');
            if (finalConfirmButton) {
                finalConfirmButton.onclick = () => {
                    getElementByIdSafe('next_step', 'finalConfirmButton.onclick').value = 'executeChange';
                    getElementByIdSafe('changeFlowForm', 'finalConfirmButton.onclick').submit();
                };
            }
        } catch (e) {
            console.error('[ERROR] in initializeMainChangeScreen:', e);
        }
    }
    
    function initializeTimeScreen(currentTime) {
        console.log('[DEBUG] Initializing TimeScreen...');
        try {
            const startDisplay = document.querySelector('.selected-time-start');
            const endDisplay = document.querySelector('.selected-time-end');
            const confirmBtn = getElementByIdSafe('timeConfirmBtn', 'initializeTimeScreen');
            const hintText = getElementByIdSafe('hint-text', 'initializeTimeScreen');
            if(!startDisplay || !endDisplay || !confirmBtn || !hintText) {
                console.error("[ERROR] Could not find all required elements for TimeScreen."); return;
            }

            let selectedStartTime = null;
            let selectedEndTime = null;

            // [修正点] currentTimeが有効かチェックしてからsplitを実行します
            if (currentTime && typeof currentTime === 'string' && currentTime.includes(':')) {
                const [currentHour, currentMinute] = currentTime.split(':').map(Number);
                const currentTimeNumeric = currentHour * 100 + currentMinute;
                document.querySelectorAll('.time-button').forEach(button => {
                    const buttonTime = button.textContent.trim();
                    if (!buttonTime) return;
                    const buttonNumericTime = parseInt(buttonTime.replace(':', ''), 10);
                    if (buttonNumericTime < currentTimeNumeric) {
                        button.disabled = true;
                        button.classList.add('past-time');
                        button.onclick = null;
                    }
                });
            } else {
                 console.warn("[WARN] currentTime value is invalid or missing. Past time slots will not be disabled.", currentTime);
            }

            // [修正点] windowオブジェクトに直接関数を定義して、onclickから確実に見つけられるようにします
            window.selectTime = function (button) {
                if (button.disabled) return;
                const clickedTime = button.textContent.trim();

                if (!selectedStartTime || (selectedStartTime && selectedEndTime)) {
                    selectedStartTime = clickedTime; selectedEndTime = null;
                } else {
                    selectedEndTime = clickedTime;
                    const startTimeNumeric = parseInt(selectedStartTime.replace(':', ''), 10);
                    const endTimeNumeric = parseInt(selectedEndTime.replace(':', ''), 10);
                    if (startTimeNumeric > endTimeNumeric) {
                        [selectedStartTime, selectedEndTime] = [selectedEndTime, selectedStartTime];
                    }
                }
                updateTimeUI();
            }

            const updateTimeUI = () => {
                startDisplay.textContent = selectedStartTime || '開始時間';
                endDisplay.textContent = selectedEndTime || '終了時間';
                hintText.textContent = !selectedStartTime ? '開始時間を選択してください。' : !selectedEndTime ? '終了時間を選択してください。' : 'よろしければ下のボタンを押してください。';
                getElementByIdSafe('startTime', 'updateTimeUI').value = selectedStartTime || '';
                getElementByIdSafe('endTime', 'updateTimeUI').value = selectedEndTime || '';
                
                const startTimeNumeric = selectedStartTime ? parseInt(selectedStartTime.replace(':', ''), 10) : null;
                const endTimeNumeric = selectedEndTime ? parseInt(selectedEndTime.replace(':', ''), 10) : null;

                document.querySelectorAll('.time-button').forEach(btn => {
                    if (btn.classList.contains('past-time')) return;
                    btn.classList.remove('selected-start', 'selected-end', 'selected-range');
                    const btnTime = btn.textContent.trim();
                    const btnNum = parseInt(btnTime.replace(':', ''), 10);
                    if (btnTime === selectedStartTime) btn.classList.add('selected-start');
                    else if (btnTime === selectedEndTime) btn.classList.add('selected-end');
                    else if (startTimeNumeric && endTimeNumeric && btnNum > startTimeNumeric && btnNum < endTimeNumeric) btn.classList.add('selected-range');
                });
                
                confirmBtn.disabled = !(selectedStartTime && selectedEndTime);
            }
            updateTimeUI();
        } catch (e) {
            console.error('[ERROR] in initializeTimeScreen:', e);
        }
    }

    function initializeSeatChangeScreen() {
        console.log('[DEBUG] Initializing SeatChangeScreen...');
        try {
            const requiredCountEl = getElementByIdSafe('required-count', 'initializeSeatChangeScreen');
            if (!requiredCountEl) return;
            const requiredCount = parseInt(requiredCountEl.textContent, 10);
            const selectedSeatsInput = getElementByIdSafe('selectedSeats', 'initializeSeatChangeScreen');
            const initialSeats = selectedSeatsInput.value ? selectedSeatsInput.value.split(',') : [];
            const selectedSeats = new Set(initialSeats);

            const confirmBtn = getElementByIdSafe('seatConfirmBtn', 'initializeSeatChangeScreen');
            const selectedSeatsDisplay = getElementByIdSafe('selected-seats-display', 'initializeSeatChangeScreen');
            const selectedCountSpan = getElementByIdSafe('selected-count', 'initializeSeatChangeScreen');
            
            window.toggleSeat = function (seatElement) {
                const seatName = seatElement.dataset.name;
                if (seatElement.classList.contains('occupied')) return;
                if (selectedSeats.has(seatName)) { selectedSeats.delete(seatName); }
                else if (selectedSeats.size < requiredCount) { selectedSeats.add(seatName); }
                updateSeatUI();
            }

            const updateSeatUI = () => {
                document.querySelectorAll('.seat-cell').forEach(cell => {
                    if (cell.classList.contains('occupied')) return;
                    cell.classList.toggle('selected', selectedSeats.has(cell.dataset.name));
                    cell.classList.toggle('available', !selectedSeats.has(cell.dataset.name));
                });
                const selectedArray = Array.from(selectedSeats).sort();
                selectedSeatsInput.value = selectedArray.join(',');
                selectedSeatsDisplay.textContent = selectedArray.length > 0 ? selectedArray.join(', ') : '座席未選択';
                selectedCountSpan.textContent = selectedArray.length;
                confirmBtn.disabled = (selectedSeats.size !== requiredCount);
            }
            updateSeatUI();
        } catch(e) {
            console.error('[ERROR] in initializeSeatChangeScreen:', e);
        }
    }

/*
    const currentTime = "<%= currentTimeJst %>";

    document.addEventListener('DOMContentLoaded', function() {
        const isChangeView = "${isChangeView}";
        
        if (isChangeView) {
            const changeStepParam = "${changeStep}";
            const showConfirmChangeParam = "${not empty showConfirmChange}";

            if (changeStepParam === 'main' || showConfirmChangeParam) {
                initializeMainChangeScreen();
            } else if (changeStepParam === 'time') {
                initializeTimeScreen();
            } else if (changeStepParam === 'seat') {
                initializeSeatChangeScreen();
            }
        }
    });

    function initializeMainChangeScreen() {
        const goToConfirmButton = document.getElementById('goToConfirmButton');
        if (goToConfirmButton) {
            const numberPeopleInput = document.getElementById("numberPeople");
            const decreaseBtn = document.getElementById('decreaseBtn');
            const increaseBtn = document.getElementById('increaseBtn');
            function updatePeopleCount(newCount) {
                document.getElementById('numberPeople').value = newCount;
                document.getElementById('next_step').value = 'goToTime'; 
                document.getElementById('startTime').value = '';
                document.getElementById('endTime').value = '';
                document.getElementById('selectedSeats').value = '';
                document.getElementById('changeFlowForm').submit();
            }
            increaseBtn.onclick = () => { updatePeopleCount(parseInt(numberPeopleInput.value) + 1); };
            decreaseBtn.onclick = () => {
                const currentCount = parseInt(numberPeopleInput.value);
                if (currentCount > 1) { updatePeopleCount(currentCount - 1); }
            };
            function checkGoToConfirmButtonState() {
                const timeIsSelected = document.getElementById('startTime').value !== "";
                const seatsAreSelected = document.getElementById('selectedSeats').value !== "";
                document.getElementById('seatSelectButton').disabled = !timeIsSelected;
                goToConfirmButton.disabled = !(timeIsSelected && seatsAreSelected);
            }
            goToConfirmButton.onclick = () => {
                document.getElementById('next_step').value = 'provisionalChange';
                document.getElementById('changeFlowForm').submit();
            };
            checkGoToConfirmButtonState();
        }
        const finalConfirmButton = document.getElementById('finalConfirmButton');
        if (finalConfirmButton) {
            finalConfirmButton.onclick = () => {
                document.getElementById('next_step').value = 'executeChange';
                document.getElementById('changeFlowForm').submit();
            };
        }
    }
    
    // =================================================================
    // ▼▼▼ ここからが修正された時間選択のロジックです ▼▼▼
    // =================================================================
    function initializeTimeScreen() {
        const startDisplay = document.querySelector('.selected-time-start');
        const endDisplay = document.querySelector('.selected-time-end');
        const confirmBtn = document.getElementById('timeConfirmBtn');
        const hintText = document.getElementById('hint-text');

        let selectedStartTime = null;
        let selectedEndTime = null;

        // --- 過去の時間を無効化する処理 ---
        const [currentHour, currentMinute] = currentTime.split(':').map(Number);
        const currentTimeNumeric = currentHour * 100 + currentMinute;
        
        document.querySelectorAll('.time-button').forEach(button => {
            const buttonTime = button.textContent.trim();
            const buttonNumericTime = parseInt(buttonTime.replace(':', ''));
            if (buttonNumericTime < currentTimeNumeric) {
                button.disabled = true;
                button.classList.add('past-time');
                button.onclick = null;
            }
        });

        // --- 時間選択のメイン関数 ---
        window.selectTime = function (button) {
            if (button.disabled) return;
            
            const clickedTime = button.textContent.trim();

            if (!selectedStartTime || (selectedStartTime && selectedEndTime)) {
                // 1回目のクリック、または3回目のクリック（リセットして新しい開始時間を選択）
                selectedStartTime = clickedTime;
                selectedEndTime = null;
            } else {
                // 2回目のクリック（終了時間を選択）
                selectedEndTime = clickedTime;
                
                // 開始時刻と終了時刻を比較し、必要なら入れ替える
                const startTimeNumeric = parseInt(selectedStartTime.replace(':', ''));
                const endTimeNumeric = parseInt(selectedEndTime.replace(':', ''));
                if (startTimeNumeric > endTimeNumeric) {
                    [selectedStartTime, selectedEndTime] = [selectedEndTime, selectedStartTime];
                }
            }
            updateTimeUI();
        }

        // --- UI（表示）を更新する関数 ---
        function updateTimeUI() {
            // 上部の時刻表示を更新
            startDisplay.textContent = selectedStartTime || '開始時間';
            endDisplay.textContent = selectedEndTime || '終了時間';

            // ヒントテキストを更新
            if (!selectedStartTime) {
                hintText.textContent = '開始時間を選択してください。';
            } else if (!selectedEndTime) {
                hintText.textContent = '終了時間を選択してください。';
            } else {
                hintText.textContent = 'よろしければ下のボタンを押してください。';
            }
            
            // formの隠しフィールドを更新
            document.getElementById('startTime').value = selectedStartTime || '';
            document.getElementById('endTime').value = selectedEndTime || '';
            
            const startTimeNumeric = selectedStartTime ? parseInt(selectedStartTime.replace(':', '')) : null;
            const endTimeNumeric = selectedEndTime ? parseInt(selectedEndTime.replace(':', '')) : null;

            // 全ての時間ボタンのスタイルを更新
            document.querySelectorAll('.time-button').forEach(btn => {
                if (btn.classList.contains('past-time')) return;
                
                btn.classList.remove('selected-start', 'selected-end', 'selected-range');
                const btnTime = btn.textContent.trim();
                const btnNum = parseInt(btnTime.replace(':', ''));
                
                if (btnTime === selectedStartTime) {
                    btn.classList.add('selected-start'); // 開始時間
                } else if (btnTime === selectedEndTime) {
                    btn.classList.add('selected-end'); // 終了時間
                } else if (startTimeNumeric && endTimeNumeric && btnNum > startTimeNumeric && btnNum < endTimeNumeric) {
                    btn.classList.add('selected-range'); // 間の時間
                }
            });
            
            // 確定ボタンの状態を更新（開始と終了の両方が選択されている場合のみ有効）
            confirmBtn.disabled = !(selectedStartTime && selectedEndTime);
        }
        
        // 初期表示をセットアップ
        updateTimeUI();
    }
    // =================================================================
    // ▲▲▲ 修正された時間選択のロジックはここまでです ▲▲▲
    // =================================================================

    function initializeSeatChangeScreen() {
        const requiredCount = parseInt(document.getElementById('required-count').textContent);
        const selectedSeatsInput = document.getElementById('selectedSeats');
        const initialSeats = selectedSeatsInput.value ? selectedSeatsInput.value.split(',') : [];
        const selectedSeats = new Set(initialSeats);

        const confirmBtn = document.getElementById('seatConfirmBtn');
        const selectedSeatsDisplay = document.getElementById('selected-seats-display');
        const selectedCountSpan = document.getElementById('selected-count');
        
        window.toggleSeat = function (seatElement) {
            const seatName = seatElement.dataset.name;
            if (seatElement.classList.contains('occupied')) return;
            
            if (selectedSeats.has(seatName)) {
                selectedSeats.delete(seatName);
            } else {
                if (selectedSeats.size < requiredCount) {
                    selectedSeats.add(seatName);
                }
            }
            updateSeatUI();
        }

        function updateSeatUI() {
            document.querySelectorAll('.seat-cell').forEach(cell => {
                if (cell.classList.contains('occupied')) return;
                
                if (selectedSeats.has(cell.dataset.name)) {
                    cell.classList.add('selected');
                    cell.classList.remove('available');
                } else {
                    cell.classList.remove('selected');
                    cell.classList.add('available');
                }
            });
            const selectedArray = Array.from(selectedSeats).sort();
            selectedSeatsInput.value = selectedArray.join(',');
            selectedSeatsDisplay.textContent = selectedArray.length > 0 ? selectedArray.join(', ') : '座席未選択';
            selectedCountSpan.textContent = selectedArray.length;
            confirmBtn.disabled = (selectedSeats.size !== requiredCount);
        }
        updateSeatUI();
    }

    function goToChangeStep(stepName) {
        document.getElementById('next_step').value = stepName;
        document.getElementById('numberPeople').value = document.getElementById('count').innerText;
        document.getElementById('changeFlowForm').submit();
    }*/
</script>
</body>
</html>