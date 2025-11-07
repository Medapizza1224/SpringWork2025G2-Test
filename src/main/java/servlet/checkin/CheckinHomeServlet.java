package servlet.checkin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * チェックインの初期画面を表示するためのサーブレット
 */
@WebServlet("/checkin-home") // このURLでサーブレットが呼び出される
public class CheckinHomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // WEB-INF内にあるJSPファイルに処理をフォワードする
        request.getRequestDispatcher("/WEB-INF/checkin/checkin-home.jsp").forward(request, response);
    }
}