package control.login;

import java.util.UUID;

import dao.DaoException;
import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class Signup {

    public SignupResult execute(String userName, String password) throws Failure {

        if (userName == null || userName.isBlank() || password == null || password.isBlank()) {
            throw new Failure("ID、パスワードは必須項目です。");
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
            String userStatus = "Guest";

            User newUser = new User(userId, userName, password, secretQuestion, secretQuestionAnswer, userStatus);

            userDao.createOne(newUser);

            SignupResult result = new SignupResult(newUser);
            return result;
        

        } catch (DaoException daoException) {
            throw new Failure("データベース処理中にエラーが発生しました。", daoException);
        }
    }
}