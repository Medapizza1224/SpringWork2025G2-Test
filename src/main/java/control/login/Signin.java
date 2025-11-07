package control.login;

import dao.DaoException;
import dao.UserDao;
import dao.SeatManagementDao; // インポートを追加
import entity.User;
import entity.Reservation; // インポートを追加
import modelUtil.Failure;
import org.mindrot.jbcrypt.BCrypt;
import java.util.Optional; // インポートを追加

public class Signin {

  /**
   * ユーザー認証と有効な予約の検索を実行する。
   * @param userName ユーザー名
   * @param password パスワード
   * @return 認証されたユーザーと、有効な予約情報を含む結果オブジェクト
   * @throws Failure 認証失敗やDBエラーが発生した場合
   */
  public SigninResult execute(String userName, String password) throws Failure {

    // 入力値のバリデーション
    if (userName == null || userName.isEmpty() || password == null || password.isEmpty()) {
      throw new Failure("IDとパスワードを入力してください。");
    }

    try {
      // 1. DAOを使いユーザー認証を行う
      UserDao userDao = new UserDao();
      User user = userDao.getOneByUserName(userName);

      if (user == null || !BCrypt.checkpw(password, user.getUserPassword())) {
            throw new Failure("IDまたはパスワードが正しくありません。");
      }

      // 2. 認証成功後、有効な予約を検索する
      SeatManagementDao seatDao = new SeatManagementDao();
      Reservation activeReservation = seatDao.getActiveReservationByUserId(user.getUserId());

      // 3. ユーザー情報と予約情報(nullの可能性あり)を結果オブジェクトに詰めて返す
      // Optional.ofNullableは、引数がnullなら空のOptionalを、nullでなければ値を持つOptionalを生成します
      SigninResult result = new SigninResult(user, Optional.ofNullable(activeReservation));
      return result;

    } catch (DaoException daoException) {
      // DAO層で発生した例外をFailureにラップしてスローする
      throw new Failure("認証処理中にエラーが発生しました。" + daoException.getMessage(), daoException);
    }
  }
}