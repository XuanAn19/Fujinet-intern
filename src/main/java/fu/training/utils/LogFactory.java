package fu.training.utils;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


public class LogFactory {

	public static Logger getLogger() {
        return LogManager.getLogger(LogFactory.class);
    }
}
