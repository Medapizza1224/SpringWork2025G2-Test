<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 予約なし（非会員）向けのページのため、ログインチェックは不要 --%>
<%@ page import="java.time.ZonedDateTime, java.time.ZoneId, java.time.format.DateTimeFormatter" %>
<%
    // ブラウザのキャッシュを無効にし、常に最新のページが表示されるようにする
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.

    // 日本標準時（JST）の現在時刻を "HH:mm" 形式で取得
    ZonedDateTime nowJst = ZonedDateTime.now(ZoneId.of("Asia/Tokyo"));
    String currentTimeJst = nowJst.format(DateTimeFormatter.ofPattern("HH:mm"));
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>新規予約 - 東京学芸大学 大学生協食堂</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body { margin: 0; font-family: 'Inter', sans-serif; background-color: #e0e0e0; display: flex; justify-content: center; }
        .phone-wrapper { position: relative; width: 393px; height: 852px; background: #FFFFFF; border: 1px solid #FFFFFF; overflow: auto; box-sizing: border-box; }
        header { width: 100%; height: 60px; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; box-sizing: border-box; background-color: #fff; }
        .menu-icon, .user-icon { font-size: 24px; }
        .logo { font-weight: bold; text-align: center; }
        .title { padding: 20px 20px 0; font-weight: 700; font-size: 20px; color: #000000; }
        .content-background { background: #F5F5F5; border-radius: 20px 20px 0px 0px; padding: 20px; box-sizing: border-box; margin-top: 20px; }
        .form-card { padding: 25px; background: #FFFFFF; border-radius: 10px; box-sizing: border-box; }
        .info-box { background-color: white; padding: 20px; border-radius: 8px; /*box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);*/ margin-bottom: 20px; }
        .submit-button-container { text-align: center; margin-top: 30px; }
        .action-button { background-color: #000; color: #fff; padding: 12px 25px; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; }
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
        .confirmation-item { padding: 15px 0; border-bottom: 1px solid #eee; text-align: left; }
        .confirmation-item .item-label { font-size: 13px; color: #888; margin-bottom: 8px; }
        .confirmation-item .item-content { display: flex; align-items: center; gap: 12px; }
        .confirmation-item .item-value { font-size: 20px; font-weight: bold; }
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
        .seat-grid-container { background-color: white; padding: 10px; border-radius: 8px; /*box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);*/ overflow-x: auto; }
        .seat-grid { display: grid; grid-template-columns: 30px repeat(4, 1fr) 10px repeat(3, 1fr) 10px repeat(3, 1fr) 10px repeat(6, 1fr) 10px repeat(4, 1fr) 30px; gap: 1px; min-width: 850px; }
        .row-label { text-align: right; padding-right: 5px; font-size: 10px; color: #888; height: 25px; display: flex; align-items: center; justify-content: flex-end; }
        .seat-cell { width: 25px; height: 25px; border-radius: 4px; cursor: pointer; display: flex; align-items: center; justify-content: center; margin: 2px; font-size: 14px; }
        .available { border: 2px solid #3498db; background-color: #e9f2ff; color: #3498db; }
        .selected { border: 2px solid #2ecc71; background-color: #d6f5d6; color: #2ecc71; }
        .occupied { border: 2px solid #e74c3c; background-color: #fadde1; color: #e74c3c; cursor: not-allowed; }
        .col-label { text-align: center; font-size: 10px; font-weight: bold; color: #555; }
        .step-icon { width: 24px; height: 24px; border-radius: 50%; border: 1px solid #000; background-color: #F5F5F5; z-index: 2; display: flex; justify-content: center; align-items: center; position: relative; }
        .step-icon img { width: 16px; height: 16px; }
        .step:not(:last-child)::after { content: ''; position: absolute; left: 50%; top: 12px; width: 100%; height: 1px; background-color: #000; z-index: 1; }
        .step.active-step .step-icon { background-color: #000000; color: white; border-color: #000000; }
        .step.active-step .step-icon::before { content: '✓'; font-size: 14px; text-align: center; line-height: 24px; }
        .step.active-step .step-icon img { display: none; }
                .content-background { height: 682px; background: #F5F5F5; border-radius: 20px 20px 0px 0px; padding: 20px; box-sizing: border-box; margin-top: 20px;  }
        .form-card { padding: 25px; background: #FFFFFF; border-radius: 10px; box-sizing: border-box; }
        .info-box { border-radius: 25px 25px 0 0;*/ background-color: white; width: 350px; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .submit-button-container { text-align: center; margin-top: 30px; height: 70px; background-color: white;}
        .action-button { background-color: #000; color: #fff; padding: 12px 25px; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; }
        .action-button:disabled { background-color: #ccc; cursor: not-allowed; }
        .step-bar { display: flex; align-items: center; justify-content: space-between; height: 30px; margin: 20px 0 35px; }
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
        .confirmation-item { padding: 15px 0; border-bottom: 1px solid #eee; text-align: left; }
        .confirmation-item .item-label { font-size: 13px; color: #888; margin-bottom: 8px; }
        .confirmation-item .item-content { display: flex; align-items: center; gap: 12px; }
        .confirmation-item .item-value { font-size: 20px; font-weight: bold; }
        .grid-container { display: flex; gap: 10px; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); }
        .hour-labels { width: 50px; }
        .hour-label { height: 48px; display: flex; align-items: center; justify-content: flex-end; font-size: 12px; color: #555; font-weight: bold;}
        .time-grid { flex-grow: 1; display: grid; grid-template-columns: repeat(6, 1fr); gap: 8px; }
        .time-button {
            padding: 6px 5px;
            border: 1px solid #ddd;
            cursor: pointer;
            background-color: white;
            border-radius: 5px;
            font-size: 12px;
            display: flex;           /* ← 追加: Flexboxコンテナにする */
            align-items: center;     /* ← 追加: 垂直方向の中央揃え */
            justify-content: center; /* ← 追加: 水平方向の中央揃え */
            color: #0070C0;
        }
        .time-button.selected-start { background-color: #0070C0; color: white; border-color: #0070C0; }
        .time-button.selected-end { background-color: #0070C0;  color: white; border-color: #0070C0; }
        .time-button.selected-range { background-color: #9ADDF8; color: #0070C0; border-color: #9ADDF8; }
        .time-button.past-time { background-color: #f0f0f0; color: #ccc; cursor: not-allowed; border-color: #e0e0e0; }
        .seat-grid-container { width: 380px; height:300px; background-color: white; padding: 5px; border-radius: 8px; overflow-x: hidden; overflow-y: hidden;}
        .seat-grid { width: 920px; overflow-x: hidden; overflow-y:hidden; transform: scale(0.4); transform-origin: top left; display: grid; grid-template-columns: 30px repeat(4, 1fr) 10px repeat(3, 1fr) 10px repeat(3, 1fr) 10px repeat(6, 1fr) 10px repeat(4, 1fr) 30px; gap: 1px; }
        .row-label { text-align: right; padding-right: 5px; font-size: 10px; color: #888; height: 25px; display: flex; align-items: center; justify-content: flex-end; }
        .seat-cell { width: 25px; height: 25px; border-radius: 4px; cursor: pointer; display: flex; align-items: center; justify-content: center; margin: 2px; font-size: 14px; }
        .available { border: 2px solid #3498db; background-color: #e9f2ff; color: #3498db; }
        .selected { border: 2px solid #2ecc71; background-color: #d6f5d6; color: #2ecc71; }
        .occupied { border: 2px solid #e74c3c; background-color: #fadde1; color: #e74c3c; cursor: not-allowed; }
        .col-label { text-align: center; font-size: 10px; font-weight: bold; color: #555; }
        .step-icon { width: 24px; height: 24px; border-radius: 50%; border: 1px solid #000; background-color: #F5F5F5; z-index: 2; display: flex; justify-content: center; align-items: center; position: relative; }
        .step-icon img { width: 16px; height: 16px; }
        .step:not(:last-child)::after { content: ''; position: absolute; left: 50%; top: 12px; width: 100%; height: 1px; background-color: #000; z-index: 1; }
        .step.active-step .step-icon { background-color: #000000; color: white; border-color: #000000; }
        .step.active-step .step-icon::before { content: '✓'; font-size: 14px; text-align: center; line-height: 24px; }
        .step.active-step .step-icon img { display: none; }
        /* 既存の .seat-cell の定義の下あたりに追加 */
.seat-cell.non-existent {
    background-color: #f0f0f0;
    border: 2px solid #e0e0e0;
    color: #ccc;
    cursor: default;
}
.col-label {
    grid-column: span 1;
    text-align: center;
    font-size: 14px;
    font-weight: bold;
    color: #333;
    display: flex;
    align-items: center;
    justify-content: center;
}
.aisle {
    grid-column: span 1;
}
    </style>
</head>
<body>
<c:set var="step" value="${not empty requestScope.step ? requestScope.step : 'main'}"/>
<c:set var="currentNumberPeople" value="${not empty sessionScope.numberPeople ? sessionScope.numberPeople : '1'}" />
<c:set var="currentStartTime" value="${not empty sessionScope.startTime ? sessionScope.startTime : ''}" />
<c:set var="currentEndTime" value="${not empty sessionScope.endTime ? sessionScope.endTime : ''}" />
<c:set var="currentSelectedSeats" value="${not empty sessionScope.selectedSeats ? sessionScope.selectedSeats : ''}" />

<div class="phone-wrapper">
    <header>
        <img src="${pageContext.request.contextPath}/image/logo.png" alt="ロゴ" style="width: 200px; height: auto; margin-left: 80px">
    </header>

    <form method="post" action="${pageContext.request.contextPath}/checkin-nonreserved" id="reservationForm">
        <input type="hidden" name="numberPeople" id="numberPeople" value="${currentNumberPeople}">
        <input type="hidden" name="startTime" id="startTime" value="${currentStartTime}">
        <input type="hidden" name="endTime" id="endTime" value="${currentEndTime}">
        <input type="hidden" name="selectedSeats" id="selectedSeats" value="${currentSelectedSeats}">
        <input type="hidden" name="step" id="next_step" value="">

        <c:choose><%--
            <c:when test="${step == 'time'}">
                <h2 class="title">時間選択</h2>
                <div class="info-box">
                    <div id="time-display-container" style="font-weight: bold; font-size: 18px; text-align: center;">
                        <span class="selected-time-value selected-time-start"></span> ~ <span class="selected-time-value selected-time-end"></span>
                    </div>
                    <p id="hint-text" class="hint-text" style="text-align: center; font-size: 14px; margin-top: 10px;"></p>
                </div>
                <div class="grid-container">
                    <div class="hour-labels">
                        <c:forEach begin="8" end="18" var="hour"><div class="hour-label">${hour}時</div></c:forEach>
                    </div>
                    <div class="time-grid">
                        <c:forEach begin="8" end="18" var="h">
                            <c:forEach begin="0" end="50" step="10" var="m">
                                <c:set var="timeValue"><c:if test="${h<10}">0</c:if>${h}:<c:if test="${m<10}">0</c:if>${m}</c:set>
                                <div class="time-button" onclick="selectTime(this)">${timeValue}</div>
                            </c:forEach>
                        </c:forEach>
                    </div>
                </div>
                <div class="submit-button-container">
                    <button type="button" id="timeConfirmBtn" class="action-button" disabled onclick="document.getElementById('next_step').value='seat'; this.form.submit();">時間を確定して座席選択へ</button>
                </div>
            </c:when>

            <c:when test="${step == 'seat'}">
                <h2 class="title">座席選択</h2>
                <div class="info-box">
                    <p>予約人数: <strong>${sessionScope.numberPeople}名</strong></p>
                    選択中: (<span id="selected-count">0</span>/<span id="required-count">${sessionScope.numberPeople}</span>)
                    <div id="selected-seats-display" style="font-weight: bold; margin-top: 5px;">座席未選択</div>
                </div>
                <div class="seat-grid-container">
                    <div class="seat-grid" id="seatGrid">
                        <c:forEach var="rowLabel" items="${['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U']}">
                             <div class="row-label">${rowLabel}</div>
                             <c:forEach begin="1" end="21" var="col">
                                 <c:set var="seatName" value="${rowLabel}${col}"/>
                                 <c:set var="isOccupied" value="${fn:contains(reservedSeats, seatName)}"/>
                                 <c:choose>
                                     <c:when test="${isOccupied}">
                                         <div class="seat-cell occupied" data-name="${seatName}">×</div>
                                     </c:when>
                                     <c:otherwise>
                                         <div class="seat-cell available" data-name="${seatName}" onclick="toggleSeat(this)"></div>
                                     </c:otherwise>
                                 </c:choose>
                             </c:forEach>
                        </c:forEach>
                    </div>
                </div>
                <div class="submit-button-container">
                    <button type="button" id="seatConfirmBtn" class="action-button" disabled onclick="document.getElementById('next_step').value='provisional'; this.form.submit();">予約内容の確認へ</button>
                </div>
            </c:when>--%>

            <c:when test="${step == 'time'}">
                <h2 class="title">時間選択</h2>
                <div class="info-box">
                    <div id="time-display-container" style="font-weight: bold; font-size: 18px; text-align: center;">
                        <span class="selected-time-value selected-time-start"></span> ~ <span class="selected-time-value selected-time-end"></span>
                    </div>
                    <p id="hint-text" class="hint-text" style="text-align: center; font-size: 14px; margin-top: 10px;"></p>
                </div>
                <div class="grid-container">
                    <div class="hour-labels">
                        <c:forEach begin="0" end="23" var="hour"><div class="hour-label">${hour}時</div></c:forEach>
                    </div>
                    <div class="time-grid">
                        <c:forEach begin="0" end="23" var="h">
                            <c:forEach begin="0" end="50" step="10" var="m">
                                <c:set var="timeValue"><c:if test="${h<10}">0</c:if>${h}:<c:if test="${m<10}">0</c:if>${m}</c:set>
                                <div class="time-button" onclick="selectTime(this)">${timeValue}</div>
                            </c:forEach>
                        </c:forEach>
                    </div>
                </div>
                <div class="submit-button-container">
                    <button type="button" id="timeConfirmBtn" class="action-button" disabled onclick="document.getElementById('next_step').value='seat'; this.form.submit();">時間を確定して座席選択へ</button>
                </div>
            </c:when>

            <%-- ========================== ▼▼▼ このブロックを差し替え ▼▼▼ ========================== --%>
            <c:when test="${step == 'seat'}">
                <h2 class="title">座席選択</h2>
                <div class="info-box">
                    <p>予約人数: <strong>${sessionScope.numberPeople}名</strong></p>
                    選択中: (<span id="selected-count">0</span>/<span id="required-count">${sessionScope.numberPeople}</span>)
                    <div id="selected-seats-display" style="font-weight: bold; margin-top: 5px;">座席未選択</div>
                </div>

                <%-- 存在しない座席のリスト --%>
                <c:set var="nonExistentSeats" value=",B3,D3,H3,J3,L3,P3,R3,T3,B4,D4,F4,H4,J4,L4,N4,P4,R4,T4,A5,B5,C5,D5,F5,G5,H5,J5,L5,M5,O5,P5,Q5,R5,S5,T5,B6,D6,F6,G6,H6,J6,L6,N6,P6,R6,T6,B7,D7,F7,G7,H7,J7,L7,M7,O7,P7,R7,T7,B8,D8,F8,G8,H8,J8,L8,N8,P8,R8,T8,B9,D9,F9,G9,H9,J9,L9,M9,O9,P9,R9,T9,B10,D10,F10,G10,H10,J10,L10,N10,P10,R10,T10,A11,B11,C11,D11,F11,G11,H11,J11,L11,M11,O11,P11,Q11,R11,S11,T11,A12,B12,C12,D12,F12,G12,H12,J12,L12,N12,P12,R12,T12,A13,B13,D13,F13,G13,H13,J13,L13,M13,O13,P13,R13,T13,B14,D14,F14,G14,H14,J14,L14,N14,P14,R14,T14,B15,D15,F15,H15,J15,L15,M15,O15,P15,R15,T15,B16,D16,F16,H16,J16,L16,N16,P16,R16,T16,A17,B17,D17,F17,H17,J17,L17,M17,O17,P17,R17,T17,A18,B18,D18,F18,H18,J18,L18,N18,P18,R18,T18,A19,C19,E19,G19,I19,K19,M19,N19,O19,P19,Q19,R19,S19,T19,B20,D20,E20,G20,I20,K20,M20,O20,Q20,S20,B21,D21,E21,G21,I21,K21,M21,O21,Q21,S21," />

                <div class="seat-grid-container">
                    <div class="seat-grid" id="seatGrid">
                        
                        <%-- 座席列ヘッダー (A, B, C...) --%>
                        <div class="col-label"></div> <%-- 行番号用の空白 --%>
                        <c:forEach items="${['A','B','C','D']}" var="col"><div class="col-label">${col}</div></c:forEach>
                        <div class="aisle"></div>
                        <c:forEach items="${['E','F','G']}" var="col"><div class="col-label">${col}</div></c:forEach>
                        <div class="aisle"></div>
                        <c:forEach items="${['H','I','J']}" var="col"><div class="col-label">${col}</div></c:forEach>
                        <div class="aisle"></div>
                        <c:forEach items="${['K','L','M']}" var="col"><div class="col-label">${col}</div></c:forEach>
                        <div class="aisle"></div>
                        <c:forEach items="${['N','O','P']}" var="col"><div class="col-label">${col}</div></c:forEach>
                        <div class="aisle"></div>
                        <c:forEach items="${['Q','R','S','T']}" var="col"><div class="col-label">${col}</div></c:forEach>
                        
                        <%-- 座席本体 (1〜21行) --%>
                        <c:forEach begin="1" end="21" var="row">
                            <div class="row-label">${row}</div>

                            <%-- A-D列 --%>
                            <c:forEach items="${['A','B','C','D']}" var="col">
                                <c:set var="seatName" value="${col}${row}"/>
                                <c:choose>
                                    <c:when test="${fn:contains(nonExistentSeats, ','.concat(seatName).concat(','))}">
                                        <div class="seat-cell non-existent">×</div>
                                    </c:when>
                                    <c:when test="${fn:contains(reservedSeats, seatName)}">
                                        <div class="seat-cell occupied" data-name="${seatName}">×</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="seat-cell available" data-name="${seatName}" onclick="toggleSeat(this)">○</div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                            
                            <div class="aisle"></div> <%-- 通路 --%>

                            <%-- E-G列 --%>
                            <c:forEach items="${['E','F','G']}" var="col">
                                <c:set var="seatName" value="${col}${row}"/>
                                <c:choose>
                                    <c:when test="${fn:contains(nonExistentSeats, ','.concat(seatName).concat(','))}">
                                        <div class="seat-cell non-existent">×</div>
                                    </c:when>
                                    <c:when test="${fn:contains(reservedSeats, seatName)}">
                                        <div class="seat-cell occupied" data-name="${seatName}">×</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="seat-cell available" data-name="${seatName}" onclick="toggleSeat(this)">○</div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <div class="aisle"></div> <%-- 通路 --%>

                            <%-- H-J列 --%>
                            <c:forEach items="${['H','I','J']}" var="col">
                                <c:set var="seatName" value="${col}${row}"/>
                                <c:choose>
                                    <c:when test="${fn:contains(nonExistentSeats, ','.concat(seatName).concat(','))}">
                                        <div class="seat-cell non-existent">×</div>
                                    </c:when>
                                    <c:when test="${fn:contains(reservedSeats, seatName)}">
                                        <div class="seat-cell occupied" data-name="${seatName}">×</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="seat-cell available" data-name="${seatName}" onclick="toggleSeat(this)">○</div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <div class="aisle"></div> <%-- 通路 --%>

                            <%-- K-M列 --%>
                            <c:forEach items="${['K','L','M']}" var="col">
                                <c:set var="seatName" value="${col}${row}"/>
                                <c:choose>
                                    <c:when test="${fn:contains(nonExistentSeats, ','.concat(seatName).concat(','))}">
                                        <div class="seat-cell non-existent">×</div>
                                    </c:when>
                                    <c:when test="${fn:contains(reservedSeats, seatName)}">
                                        <div class="seat-cell occupied" data-name="${seatName}">×</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="seat-cell available" data-name="${seatName}" onclick="toggleSeat(this)">○</div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <div class="aisle"></div> <%-- 通路 --%>

                            <%-- N-P列 --%>
                            <c:forEach items="${['N','O','P']}" var="col">
                                <c:set var="seatName" value="${col}${row}"/>
                                <c:choose>
                                    <c:when test="${fn:contains(nonExistentSeats, ','.concat(seatName).concat(','))}">
                                        <div class="seat-cell non-existent">×</div>
                                    </c:when>
                                    <c:when test="${fn:contains(reservedSeats, seatName)}">
                                        <div class="seat-cell occupied" data-name="${seatName}">×</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="seat-cell available" data-name="${seatName}" onclick="toggleSeat(this)">○</div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <div class="aisle"></div> <%-- 通路 --%>

                            <%-- Q-T列 --%>
                            <c:forEach items="${['Q','R','S','T']}" var="col">
                                <c:set var="seatName" value="${col}${row}"/>
                                <c:choose>
                                    <c:when test="${fn:contains(nonExistentSeats, ','.concat(seatName).concat(','))}">
                                        <div class="seat-cell non-existent">×</div>
                                    </c:when>
                                    <c:when test="${fn:contains(reservedSeats, seatName)}">
                                        <div class="seat-cell occupied" data-name="${seatName}">×</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="seat-cell available" data-name="${seatName}" onclick="toggleSeat(this)">○</div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:forEach>
                    </div>
                </div>
                <div class="submit-button-container">
                    <button type="button" id="seatConfirmBtn" class="action-button" disabled onclick="document.getElementById('next_step').value='provisional'; this.form.submit();">予約内容の確認へ</button>
                </div>
            </c:when>
            
            <c:otherwise> 
                <h2 class="title">${showConfirm ? '予約内容の確認' : '新規予約'}</h2>
                <div class="content-background">
                    <c:set var="isPeopleDone" value="${true}" />
                    <c:set var="isTimeDone" value="${not empty currentStartTime}" />
                    <c:set var="isSeatDone" value="${not empty currentSelectedSeats}" />
                    <c:set var="isConfirmDone" value="${showConfirm}" />
                    <c:set var="isCompletionDone" value="${false}" />

                    <div class="step-bar">
                        <div class="step ${isPeopleDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/人数.svg" alt="人数"></div><span class="step-label">人数</span></div>
                        <div class="step ${isTimeDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/時間.svg" alt="時間"></div><span class="step-label">時間</span></div>
                        <div class="step ${isSeatDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/座席選択.png" alt="座席"></div><span class="step-label">座席指定</span></div>
                        <div class="step ${isConfirmDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/確認.svg" alt="確認"></div><span class="step-label">確認</span></div>
                        <div class="step ${isCompletionDone ? 'active-step' : ''}"><div class="step-icon"><img src="${pageContext.request.contextPath}/image/完了.svg" alt="完了"></div><span class="step-label">完了</span></div>
                    </div>
                    
                    <div class="form-card">
                         <c:if test="${not empty errorMessage}">
                            <div style="color: red; text-align: center; margin-bottom: 15px;">${errorMessage}</div>
                         </c:if>

                        <div id="input-mode-area" style="${showConfirm ? 'display: none;' : ''}">
                            <div class="section">
                                <div class="row-flex">
                                    <div class="item-label-group"><span class="icon"><img src="${pageContext.request.contextPath}/image/人①.svg" alt="人数" height="30"></span></span><span class="label-text">人数</span></div>
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
                                        <c:choose>
                                            <c:when test="${not empty currentStartTime}">${currentStartTime} 〜 ${currentEndTime}</c:when>
                                            <c:otherwise>未選択</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <button type="button" class="action-button" onclick="goToStep('time')">${not empty currentStartTime ? '時間変更' : '時間選択'}</button>
                                </div>
                            </div>
                            <div class="section">
                                <div class="row-flex">
                                    <div class="item-label-group"><span class="icon"><img src="${pageContext.request.contextPath}/image/座席選択.png" alt="座席" height="30"></span></span><span class="label-text">座席</span></div>
                                    <div class="time-value-display" id="main-selected-seats-display">${not empty currentSelectedSeats ? fn:replace(currentSelectedSeats, ',', ', ') : '未選択'}</div>
                                    <button type="button" class="action-button" id="seatSelectButton" onclick="goToStep('seat')">${not empty currentSelectedSeats ? '座席変更' : '座席選択'}</button>
                                </div>
                            </div>
                        </div>

                        <div id="confirm-mode-area" style="${showConfirm ? '' : 'display: none;'}">
                            <c:if test="${showConfirm}">
                                <div class="confirmation-item"><div class="item-label">人数</div><div class="item-value">${sessionScope.numberPeople}名</div></div>
                                <div class="confirmation-item"><div class="item-label">時間</div><div class="item-value">${sessionScope.startTime} 〜 ${sessionScope.endTime}</div></div>
                                <div class="confirmation-item"><div class="item-label">座席</div><div class="item-value">${fn:replace(sessionScope.selectedSeats, ',', ', ')}</div></div>
                            </c:if>
                        </div>

                        <div class="submit-button-container">
                            <c:choose>
                                <c:when test="${showConfirm}">
                                    <button type="button" id="finalConfirmButton" class="action-button">予約を確定する</button>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" id="goToConfirmButton" class="action-button" disabled>内容を確認する</button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </form>
</div>

<!-- ▼▼▼ 変更箇所 START ▼▼▼ -->
<script>
    const currentTime = "<%= currentTimeJst %>";
    const form = document.getElementById('reservationForm');
    const stepParam = "${step}";

    // どの画面でも共通の処理や変数をここに記述

    // stepの値に応じて各画面の初期化関数を呼び出す
    if (stepParam === 'main' || "${showConfirm}") {
        initializeMainScreen();
    } else if (stepParam === 'time') {
        initializeTimeScreen();
    } else if (stepParam === 'seat') {
        initializeSeatScreen();
    }

    /**
     * メイン画面（人数・時間・座席のサマリー表示）の初期化とイベント設定
     */
    function initializeMainScreen() {
        const goToConfirmButton = document.getElementById('goToConfirmButton');
        if (goToConfirmButton) {
            const numberPeopleInput = document.getElementById("numberPeople");
            const decreaseBtn = document.getElementById('decreaseBtn');
            const increaseBtn = document.getElementById('increaseBtn');
            
            // 人数変更時の処理
            function updatePeopleCount(newCount) {
                // 人数が変わったらセッション情報を更新し、時間選択からやり直させる
                document.getElementById('numberPeople').value = newCount;
                document.getElementById('next_step').value = 'time'; 
                // 人数変更時は時間と座席の選択をリセットするため、値をクリアする
                document.getElementById('startTime').value = '';
                document.getElementById('endTime').value = '';
                document.getElementById('selectedSeats').value = '';
                form.submit();
            }
            
            increaseBtn.onclick = () => { updatePeopleCount(parseInt(numberPeopleInput.value) + 1); };
            decreaseBtn.onclick = () => {
                const currentCount = parseInt(numberPeopleInput.value);
                if (currentCount > 1) {
                    updatePeopleCount(currentCount - 1);
                }
            };

            // 「内容を確認する」ボタンの状態をチェック
            function checkGoToConfirmButtonState() {
                const timeIsSelected = document.getElementById('startTime').value !== "";
                const seatsAreSelected = document.getElementById('selectedSeats').value !== "";
                // 時間が選択されていないと座席選択ボタンは押せない
                document.getElementById('seatSelectButton').disabled = !timeIsSelected;
                // 時間と座席の両方が選択されていないと確認ボタンは押せない
                goToConfirmButton.disabled = !(timeIsSelected && seatsAreSelected);
            }
            
            // 確認ボタンのクリックイベント
            goToConfirmButton.onclick = function() {
                document.getElementById('next_step').value = 'provisional';
                form.submit();
            };
            
            checkGoToConfirmButtonState();
        }

        const finalConfirmButton = document.getElementById('finalConfirmButton');
        if (finalConfirmButton) {
            // 予約確定ボタンのクリックイベント
            finalConfirmButton.onclick = function() {
                document.getElementById('next_step').value = 'confirm';
                form.submit();
            };
        }
    }
    
    /**
     * 時間選択画面の初期化と操作に関する処理
     */
    function initializeTimeScreen() {
        const startDisplay = document.querySelector('.selected-time-start');
        const endDisplay = document.querySelector('.selected-time-end');
        const confirmBtn = document.getElementById('timeConfirmBtn');
        const hintText = document.getElementById('hint-text');

        // 1. JSPから渡された現在時刻を基に、固定の開始時刻を決定
        const [currentHour, currentMinute] = currentTime.split(':').map(Number);
        const startMinuteOfCurrentSlot = Math.floor(currentMinute / 10) * 10;
        
        // 開始時刻を "HH:mm" 形式の文字列で作成
        const fixedStartTime = 
            String(currentHour).padStart(2, '0') + ':' + 
            String(startMinuteOfCurrentSlot).padStart(2, '0');
        // 比較のために数値形式にも変換 (例: "12:10" -> 1210)
        const fixedStartTimeNumeric = parseInt(fixedStartTime.replace(':', ''));

        // ユーザーが選択する終了時刻を保持する変数
        let selectedEndTime = null;

        // 2. ヒントテキストを「終了時間を選択」に更新
        hintText.textContent = '終了時間を選択してください。';

        // 3. 開始時刻より前の時間ボタンをすべて無効化
        document.querySelectorAll('.time-button').forEach(button => {
            const buttonTime = button.textContent.trim();
            const buttonNumericTime = parseInt(buttonTime.replace(':', ''));
            if (buttonNumericTime < fixedStartTimeNumeric) {
                button.disabled = true;
                button.classList.add('past-time');
                button.onclick = null; // クリックイベントを削除
            }
        });
        
        // 4. 時間ボタンがクリックされたときの処理をグローバル関数として定義
        window.selectTime = function (button) {
            // 無効化されたボタンは無視
            if (button.disabled) return;
            
            const clickedTime = button.textContent.trim();
            const clickedTimeNumeric = parseInt(clickedTime.replace(':', ''));

            // クリックされた時間が、固定の開始時間よりも後であれば、それを終了時間として設定
            if (clickedTimeNumeric > fixedStartTimeNumeric) {
                selectedEndTime = clickedTime;
            } else {
                // 開始時間と同じか、それより前がクリックされた場合は、終了時間の選択を解除
                selectedEndTime = null;
            }
            // UIを最新の状態に更新
            updateTimeUI();
        }

        // 5. 画面表示を更新するための関数
        function updateTimeUI() {
            // 常に固定の開始時刻を表示
            startDisplay.textContent = fixedStartTime;
            // 終了時刻が選択されていれば表示し、なければプレースホルダーを表示
            endDisplay.textContent = selectedEndTime || '終了時間';
            
            // formのhiddenフィールドに値を設定
            document.getElementById('startTime').value = fixedStartTime;
            document.getElementById('endTime').value = selectedEndTime || '';
            
            const endTimeNumeric = selectedEndTime ? parseInt(selectedEndTime.replace(':', '')) : null;

            // すべての時間ボタンの見た目を更新
            document.querySelectorAll('.time-button').forEach(btn => {
                if (btn.classList.contains('past-time')) return; // 過去時間は無視
                
                // まず全てのスタイルをリセット
                btn.classList.remove('selected-start', 'selected-end', 'selected-range');
                const btnTime = btn.textContent.trim();
                const btnNum = parseInt(btnTime.replace(':', ''));
                
                // 状態に応じてスタイルを適用
                if (btnTime === fixedStartTime) {
                    btn.classList.add('selected-start'); // 開始時刻
                } else if (btnTime === selectedEndTime) {
                    btn.classList.add('selected-end');   // 終了時刻
                } else if (endTimeNumeric && btnNum > fixedStartTimeNumeric && btnNum < endTimeNumeric) {
                    btn.classList.add('selected-range'); // 開始と終了の間
                }
            });
            
            // 終了時刻が選択されている場合のみ、確定ボタンを有効化
            confirmBtn.disabled = !selectedEndTime;
        }

        // 6. ページ読み込み時に一度UIを初期表示
        updateTimeUI();
    }

    /**
     * 座席選択画面の初期化と操作に関する処理
     */
    function initializeSeatScreen() {
        const requiredCount = parseInt(document.getElementById('required-count').textContent);
        const selectedSeatsInput = document.getElementById('selectedSeats');
        // 以前に選択した座席があれば復元
        const initialSeats = selectedSeatsInput.value ? selectedSeatsInput.value.split(',') : [];
        const selectedSeats = new Set(initialSeats);

        const confirmBtn = document.getElementById('seatConfirmBtn');
        const selectedSeatsDisplay = document.getElementById('selected-seats-display');
        const selectedCountSpan = document.getElementById('selected-count');
        
        // 座席クリック時の処理をグローバル関数として定義
        window.toggleSeat = function (seatElement) {
            const seatName = seatElement.dataset.name;
            if (selectedSeats.has(seatName)) {
                selectedSeats.delete(seatName);
            } else {
                if (selectedSeats.size < requiredCount) {
                    selectedSeats.add(seatName);
                }
            }
            updateSeatUI();
        }

        // 座席表示を更新する関数
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
        // 初期表示を更新
        updateSeatUI();
    }

    /**
     * 指定されたステップの画面に遷移する
     * @param {string} stepName - 遷移先のステップ名 ('time', 'seat' など)
     */
    function goToStep(stepName) {
        document.getElementById('next_step').value = stepName;
        // 人数情報は常に最新のものをフォームに設定
        document.getElementById('numberPeople').value = document.getElementById('count').innerText;
        form.submit();
    }
</script>
<!-- ▲▲▲ 変更箇所 END ▲▲▲ -->

</body>
</html>