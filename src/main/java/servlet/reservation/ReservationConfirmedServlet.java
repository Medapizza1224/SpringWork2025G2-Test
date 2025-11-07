package servlet.reservation;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/reservation-confirmed")
public class ReservationConfirmedServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);

        // セッションまたは予約IDがなければトップページへ
        if (session == null || session.getAttribute("reservationId") == null) {
            response.sendRedirect("reservation");
            return;
        }

        // 表示担当のサーブレットにリダイレクトする
        // セッションを維持することで、ユーザーは変更・キャンセル操作を続けられる
        response.sendRedirect(request.getContextPath() + "/reservation-modify");
    }
}