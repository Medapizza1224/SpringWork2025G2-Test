package dao;

public class jdbcDriver {
     static void load() {
    try {
      // この行がないと、ビルド時のclasspathにConnector/Jが乗らなくなってしまう。
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (Exception exception) {
      throw new RuntimeException(exception);
    }
  }
}
