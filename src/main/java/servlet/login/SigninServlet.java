package servlet.login;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.EnumMap;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import control.login.Signin;
import control.login.SigninResult;
import entity.Reservation;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import modelUtil.Failure;

@WebServlet(value = { "", "/signin" })
public class SigninServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
        // ログインページの表示
        request.getRequestDispatcher("/WEB-INF/login/signin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String userName = request.getParameter("id");
        String password = request.getParameter("password");
        
        Signin signinControl = new Signin();
        
        try {
            // 1. コントロールを呼び出し、ビジネスロジックを実行
            SigninResult result = signinControl.execute(userName, password);
            
            // 2. ログインユーザー情報をセッションに保存
            HttpSession session = request.getSession(true);
            session.setAttribute("loginUser", result.user());
            
            // 3. 結果オブジェクト内の予約情報の有無で、リダイレクト先を決定
            if (result.activeReservation().isPresent()) {
                // 有効な予約がある場合 -> 予約完了画面へリダイレクト
                Reservation activeReservation = result.activeReservation().get();
                
                setupSessionForConfirmedPage(session, activeReservation);
                
                response.sendRedirect(request.getContextPath() + "/reservation-confirmed");
                
            } else {
                // 有効な予約がない場合 -> 新規予約画面へリダイレクト
                response.sendRedirect(request.getContextPath() + "/reservation");
            }

        } catch (Failure f) {
            // 認証失敗などのビジネスエラーの場合
            request.setAttribute("error", f.getMessage());
            request.setAttribute("lastInputId", userName);
            request.getRequestDispatcher("/WEB-INF/login/signin.jsp").forward(request, response);
        }
    }
    
    /**
     * 予約完了画面表示のために、セッションに必要な情報を設定するヘルパーメソッド。
     * @param session HttpSessionオブジェクト
     * @param reservation 表示対象の予約情報
     */
    private void setupSessionForConfirmedPage(HttpSession session, Reservation reservation) {
        String reservationIdStr = reservation.getReservationId().toString();
        String qrCodeBase64 = generateQrCode(reservationIdStr);
        
        session.setAttribute("qrCodeBase64", qrCodeBase64);
        session.setAttribute("reservationId", reservationIdStr);
        session.setAttribute("numberPeople", String.valueOf(reservation.getNumberOfPeople()));
        session.setAttribute("reservationDate", reservation.getReservationDate().toString());
        session.setAttribute("startTime", reservation.getStartTime().toString());
        session.setAttribute("endTime", reservation.getEndTime().toString());
        
        // 予約エンティティから座席情報をカンマ区切りの文字列に変換
        String selectedSeats = Stream.of(
            reservation.getSeat1(), reservation.getSeat2(), reservation.getSeat3(), 
            reservation.getSeat4(), reservation.getSeat5(), reservation.getSeat6(), 
            reservation.getSeat7(), reservation.getSeat8())
            .filter(s -> s != null && !s.isEmpty())
            .collect(Collectors.joining(","));
        session.setAttribute("selectedSeats", selectedSeats);
    }

    /**
     * 与えられた文字列データからQRコードの画像を生成し、Base64形式の文字列として返す。
     * (このメソッドは変更なし)
     */
    private String generateQrCode(String data) {
        try {
            Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
            hints.put(EncodeHintType.MARGIN, 2);
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(data, BarcodeFormat.QR_CODE, 250, 250, hints);
            ByteArrayOutputStream pngOutputStream = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", pngOutputStream);
            byte[] pngData = pngOutputStream.toByteArray();
            return Base64.getEncoder().encodeToString(pngData);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}