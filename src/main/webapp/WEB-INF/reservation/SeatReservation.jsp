<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.ZonedDateTime, java.time.ZoneId, java.time.format.DateTimeFormatter" %>
<%
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
        header {
            position: relative; /* 子要素の絶対配置の基準にする */
            display: flex;
            align-items: center; /* アイテムを垂直方向に中央揃え */
            justify-content: space-between; /* 両端に配置 */
            padding: 10px; /*よしなに調整*/
            border-bottom: 1px solid #ccc; /*分かりやすくするため*/
        }
        .phone-wrapper { position: relative; width: 393px; height: 852px; background: #FFFFFF; border: 1px solid #FFFFFF; overflow: auto; box-sizing: border-box; }
        .menu-icon, .user-icon { font-size: 24px; }
        .logo { font-weight: bold; text-align: center; }
        .title { padding: 20px 20px 0; font-weight: 700; font-size: 20px; color: #000000; }
        .content-background { background: #F5F5F5; border-radius: 20px 20px 0px 0px; padding: 20px; box-sizing: border-box; margin-top: 20px; }
        .form-card { padding: 25px; background: #FFFFFF; border-radius: 10px; box-sizing: border-box; }
        .info-box { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); margin-bottom: 20px; }
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
        .seat-grid-container { background-color: white; padding: 10px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); overflow-x: auto; }
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
        <div class="menu-icon"></div>
        <img src="${pageContext.request.contextPath}/image/logo.png" alt="ロゴ" style="width: 200px; height: auto;">
        <div class="user-icon" onclick="location.href='${pageContext.request.contextPath}/logout';" style="cursor: pointer;">
            <img src="${pageContext.request.contextPath}/image/ログアウト.png" alt="ログアウト" style="height: 50px; width: auto; display: block;">
        </div>
    </header>

    <%-- サーブレットから渡されたformActionをJSTL変数に設定。なければデフォルト値（/reservation）を設定 --%>
    <c:set var="formActionUrl" value="${pageContext.request.contextPath}${not empty formAction ? formAction : '/reservation'}" />

    <form method="post" action="${formActionUrl}" id="reservationForm">
        <input type="hidden" name="numberPeople" id="numberPeople" value="${currentNumberPeople}">
        <input type="hidden" name="startTime" id="startTime" value="${currentStartTime}">
        <input type="hidden" name="endTime" id="endTime" value="${currentEndTime}">
        <input type="hidden" name="selectedSeats" id="selectedSeats" value="${currentSelectedSeats}">
        <input type="hidden" name="step" id="next_step" value="">

        <c:choose>
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

<%-- ========================== ここから下が修正箇所 ========================== --%>
<script>
    const currentTime = "<%= currentTimeJst %>";
    const form = document.getElementById('reservationForm');
    const stepParam = "${step}";

    if (stepParam === 'main' || "${showConfirm}") {
        initializeMainScreen();
    } else if (stepParam === 'time') {
        initializeTimeScreen();
    } else if (stepParam === 'seat') {
        initializeSeatScreen();
    }

    function initializeMainScreen() {
        const goToConfirmButton = document.getElementById('goToConfirmButton');
        if (goToConfirmButton) {
            const numberPeopleInput = document.getElementById("numberPeople");
            const decreaseBtn = document.getElementById('decreaseBtn');
            const increaseBtn = document.getElementById('increaseBtn');
            
            function updatePeopleCount(newCount) {
                document.getElementById('numberPeople').value = newCount;
                document.getElementById('next_step').value = 'time'; 
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

            function checkGoToConfirmButtonState() {
                const timeIsSelected = document.getElementById('startTime').value !== "";
                const seatsAreSelected = document.getElementById('selectedSeats').value !== "";
                document.getElementById('seatSelectButton').disabled = !timeIsSelected;
                goToConfirmButton.disabled = !(timeIsSelected && seatsAreSelected);
            }
            
            goToConfirmButton.onclick = function() {
                document.getElementById('next_step').value = 'provisional';
                form.submit();
            };
            
            checkGoToConfirmButtonState();
        }

        const finalConfirmButton = document.getElementById('finalConfirmButton');
        if (finalConfirmButton) {
            finalConfirmButton.onclick = function() {
                document.getElementById('next_step').value = 'confirm';
                form.submit();
            };
        }
    }
    
    // ▼▼▼▼▼▼▼▼▼ この関数を差し替え ▼▼▼▼▼▼▼▼▼
    function initializeTimeScreen() {
        const startDisplay = document.querySelector('.selected-time-start');
        const endDisplay = document.querySelector('.selected-time-end');
        const confirmBtn = document.getElementById('timeConfirmBtn');
        const hintText = document.getElementById('hint-text');

        let selectedStartTime = null;
        let selectedEndTime = null;

        // 過去の時間を無効化する
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

        window.selectTime = function (button) {
            if (button.disabled) return;
            
            const clickedTime = button.textContent.trim();

            if (!selectedStartTime || (selectedStartTime && selectedEndTime)) {
                // 1回目のクリック、または3回目のクリック（リセット）
                selectedStartTime = clickedTime;
                selectedEndTime = null;
            } else {
                // 2回目のクリック
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

            // 全ボタンのスタイルをリセット
            document.querySelectorAll('.time-button').forEach(btn => {
                if (btn.classList.contains('past-time')) return;
                
                btn.classList.remove('selected-start', 'selected-end', 'selected-range');
                const btnTime = btn.textContent.trim();
                const btnNum = parseInt(btnTime.replace(':', ''));
                
                if (btnTime === selectedStartTime) {
                    btn.classList.add('selected-start');
                } else if (btnTime === selectedEndTime) {
                    btn.classList.add('selected-end');
                } else if (startTimeNumeric && endTimeNumeric && btnNum > startTimeNumeric && btnNum < endTimeNumeric) {
                    btn.classList.add('selected-range');
                }
            });
            
            // 確定ボタンの状態を更新（開始と終了の両方が選択されている場合のみ有効）
            confirmBtn.disabled = !(selectedStartTime && selectedEndTime);
        }
        
        // 初期表示
        updateTimeUI();
    }
    // ▲▲▲▲▲▲▲▲▲ この関数を差し替え ▲▲▲▲▲▲▲▲▲

    function initializeSeatScreen() {
        const requiredCount = parseInt(document.getElementById('required-count').textContent);
        const selectedSeatsInput = document.getElementById('selectedSeats');
        const initialSeats = selectedSeatsInput.value ? selectedSeatsInput.value.split(',') : [];
        const selectedSeats = new Set(initialSeats);

        const confirmBtn = document.getElementById('seatConfirmBtn');
        const selectedSeatsDisplay = document.getElementById('selected-seats-display');
        const selectedCountSpan = document.getElementById('selected-count');
        
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

    function goToStep(stepName) {
        document.getElementById('next_step').value = stepName;
        document.getElementById('numberPeople').value = document.getElementById('count').innerText;
        form.submit();
    }
</script>
<%-- ========================== ここまでが修正箇所 ========================== --%>
</body>
</html>