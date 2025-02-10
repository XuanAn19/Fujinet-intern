package fu.training.utils;


import java.util.Date;

import java.text.ParseException;
import java.text.SimpleDateFormat;



public class DateUtils {
  public static Date convertStringToDate(String dateString)
      throws ParseException {
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    Date date = formatter.parse(dateString);
    return date;
  }


  public static java.sql.Date convertJavaDateToSqlDate(Date javaDate) {
    java.sql.Date sqlDate = new java.sql.Date(javaDate.getTime());
    return sqlDate;
  }

}
