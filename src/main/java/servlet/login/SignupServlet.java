package servlet.login;

import java.io.IOException;

import control.login.Signin;
import control.login.SigninResult;
import control.login.Signup;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import modelUtil.Failure;

@WebServlet(value = { "/signup" })
public class SignupServlet extends HttpServlet {

  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 新規登録ページを表示
        req.getRequestDispatcher("/WEB-INF/login/signup.jsp").forward(req, resp);
    }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

    req.setCharacterEncoding("UTF-8");

    String id = req.getParameter("id").trim();
    String password = req.getParameter("password");

    try {
            // 1. 新規登録処理を実行
            Signup signupControl = new Signup();
            signupControl.execute(id, password);

            // 2. 登録した情報でログイン処理を行い、完全なUserオブジェクトを取得する
            Signin signinControl = new Signin();
            SigninResult signinResult = signinControl.execute(id, password);
            User loginUser = signinResult.user();

            // 3. セッションを取得
            HttpSession session = req.getSession();

            // 4. ★★★ 修正箇所 ★★★
            // Userオブジェクトをセッションに保存する
            session.setAttribute("loginUser", loginUser);

            // 5. リダイレクト後のページで表示したいメッセージをセッションに保存
            session.setAttribute("successMessage", "新規登録が完了しました。");

            // 6. 予約サイトにリダイレクト
            resp.sendRedirect(req.getContextPath() + "/reservation");
        } catch (Failure failure) {

            failure.printStackTrace();
            req.setAttribute("error", failure.getMessage());
            
            // 新規登録ページ
            req.getRequestDispatcher("/WEB-INF/login/signup.jsp").forward(req, resp);
        }

  }

}