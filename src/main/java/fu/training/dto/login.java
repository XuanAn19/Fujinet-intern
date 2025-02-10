package fu.training.dto;

public class login {
	String USERID;
	String PASSWORD;
	public String getUSERID() {
		return USERID;
	}
	public void setUSERID(String uSERID) {
		USERID = uSERID;
	}
	public String getPASSWORD() {
		return PASSWORD;
	}
	public void setPASSWORD(String pASSWORD) {
		PASSWORD = pASSWORD;
	}
	public login(String uSERID, String pASSWORD) {
		super();
		USERID = uSERID;
		PASSWORD = pASSWORD;
	}
	
	
}
