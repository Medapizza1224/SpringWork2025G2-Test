<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>チェックイン画面</title>
    <!-- QRコード読み取りライブラリ -->
    <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>

    <style>
      /* 全体のスタイル */
      body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        padding: 20px;
        background-color: #ffffff;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
      }
      
      /* 全体を囲むラッパー */
      .wrapper {
        display: flex;
        flex-direction: column; /* 要素を縦に並べる */
        align-items: center; /* 子要素を中央揃え (ボタンは後で個別指定) */
        width: 90%;
      }

      /* コンテナ (左右パネルを囲む) */
      .container {
        display: flex;
        justify-content: center;
        gap: 40px; /* 左右パネルの間隔 */
        width: 100%;
        margin-bottom: 30px; /* 下のボタンとの間隔 */
      }

      /* 左パネル */
      .left-panel {
        display: flex;
        flex-direction: column;
        justify-content: center; /* 内容を垂直方向に中央揃え */
        align-items: center;
        text-align: center;
        flex: 1; /* 幅を均等に分割 */
      }

      /* 右パネル */
      .right-panel {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        flex: 1; /* 幅を均等に分割 */
      }

      /* 説明用イラスト */
      .illustration-img {
        max-width: 100%;
        height: auto;
        margin-bottom: 20px;
      }

      /* 説明テキスト */
      .instruction {
        font-size: 16px;
        color: #333;
        margin: 0;
        line-height: 1.6;
      }

      /* 戻るボタン */
      .back-button {
        background-color: #e6e6e6; /* 薄いグレー */
        color: #333333;
        border: none;
        border-radius: 20px; /* 角を丸くする */
        padding: 10px 40px;
        font-size: 16px;
        cursor: pointer;
        transition: background-color 0.3s;
        /* ★変更点: ボタンを左寄せにする */
        align-self: flex-start;
      }

      .back-button:hover {
        background-color: #d4d4d4;
      }

      /* カメラ映像のコンテナ */
      #video-container {
        width: 90%;
        aspect-ratio: 1 / 1; /* 縦横比を1:1 (正方形) にする */
        border: 1px solid #cccccc;
        background-color: #f0f0f0;
        margin-bottom: 10px;
        position: relative;
      }

      #video {
        width: 100%;
        height: 100%;
        object-fit: cover; /* コンテナに合わせて映像をトリミング */
      }

      /* 出力メッセージ */
      #outputMessage {
        font-size: 14px;
        color: #555;
        height: 20px; /* メッセージの高さを確保 */
      }
    </style>
  </head>
  <body>
    <div class="wrapper">
      <div class="container">
        <!-- 左側 -->
        <div class="left-panel">
          <img src="${pageContext.request.contextPath}/image/QR読み取り.png" alt="QRコードを提示するイラスト" class="illustration-img" />
          <p class="instruction">
            予約サイトに表示されたQRコードを提示してください。
          </p>
        </div>

        <!-- 右側 -->
        <div class="right-panel">
          <div id="video-container">
            <video id="video" playsinline autoplay></video>
            <canvas id="canvas" style="display: none"></canvas>
          </div>
          <div id="outputMessage">カメラでQRコードをスキャンしてください...</div>

          <!-- データ送信フォーム -->
          <form id="checkinForm" action="checkin-reserved" method="post">
            <input type="hidden" id="qrDataInput" name="qrData" />
          </form>
        </div>
      </div>

      <!-- ★変更点: onclickの動作を、より確実なURL指定に変更 -->
      <button 
        type="button" 
        class="back-button" 
        onclick="location.href='${pageContext.request.contextPath}/'">
        戻る
      </button>
    </div>

    <script>
      const video = document.getElementById("video");
      const canvasElement = document.getElementById("canvas");
      const canvas = canvasElement.getContext("2d");
      const outputMessage = document.getElementById("outputMessage");
      const qrDataInput = document.getElementById("qrDataInput");
      const checkinForm = document.getElementById("checkinForm");
      let stream;

      // ユーザーのカメラにアクセス
      navigator.mediaDevices
        .getUserMedia({ video: { facingMode: "user" } })
        .then(function (s) {
          stream = s;
          video.srcObject = s;
          video.play();
          // 映像からQRコードを読み取る処理を毎フレーム実行
          requestAnimationFrame(tick);
        })
        .catch(function (err) {
          console.error("カメラへのアクセスに失敗しました: ", err);
          outputMessage.textContent =
            "カメラへのアクセスが許可されていません。";
        });

      function tick() {
        if (video.readyState === video.HAVE_ENOUGH_DATA) {
          canvasElement.height = video.videoHeight;
          canvasElement.width = video.videoWidth;
          canvas.drawImage(
            video,
            0,
            0,
            canvasElement.width,
            canvasElement.height
          );
          const imageData = canvas.getImageData(
            0,
            0,
            canvasElement.width,
            canvasElement.height
          );
          const code = jsQR(imageData.data, imageData.width, imageData.height, {
            inversionAttempts: "dontInvert",
          });

          if (code) {
            outputMessage.textContent = "QRコードを検出しました！";
            console.log("Found QR code", code.data);
            stream.getTracks().forEach((track) => track.stop());
            qrDataInput.value = code.data;
            checkinForm.submit();
          } else {
            requestAnimationFrame(tick);
          }
        } else {
          requestAnimationFrame(tick);
        }
      }
    </script>
  </body>
</html>