package fu.training.utils;

import java.sql.Connection;

public class test {
	public static void main(String[] args) {
		Connection con = DBUtils.getConnectionn();
		if(con == null) {
			System.out.println("that bai");
		}else {
			System.out.println("thanh con");
		}
		
	}
}
