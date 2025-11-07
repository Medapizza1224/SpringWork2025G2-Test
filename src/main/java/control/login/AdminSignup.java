package control.login;

import java.util.UUID;

import dao.DaoException;
import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class AdminSignup {

    public AdminSignupResult execute(String userName, String password, String securityCode) throws Failure {

        if (userName == null || userName.isBlank() || password == null || password.isBlank()) {
            throw new Failure("ID、パスワードは必須項目です。");
        }

        if (!"Hazelab".equals(securityCode)) {
            throw new Failure("セキュリティコードが正しくありません。");
        }

        try {
            UserDao userDao = new UserDao();

            // IDの重複チェック
            if (userDao.getOneByUserName(userName) != null) {
                throw new Failure("このIDは既に使用されています。");
            }

            UUID userId = UUID.randomUUID();

            // Userオブジェクトの生成
            String secretQuestion = "";
            String secretQuestionAnswer = "";
            String userStatus = "Admin";

            User newUser;
            try {
                newUser = new User(userId, userName, password, secretQuestion, secretQuestionAnswer, userStatus);
            } catch (Failure e) {
                // エンティティのバリデーションエラーをFailureとしてスロー
                throw new Failure("入力値が不正です: " + e.getMessage(), e);
            }

            userDao.createOne(newUser);

            AdminSignupResult result = new AdminSignupResult(newUser);
            return result;
        

        } catch (DaoException | Failure daoException) {
            throw new Failure("データベース処理中にエラーが発生しました。", daoException);
        }
    }
}