package fjs.cs.test;  

import org.hibernate.Session;  
import org.hibernate.SessionFactory;  
import org.hibernate.cfg.Configuration;  

public class HibernateTest {  
    public static void main(String[] args) {  
        try {  
            // Load cấu hình Hibernate  
            Configuration configuration = new Configuration();  
            configuration.configure("hibernate.cfg.xml");  
            
            // Tạo SessionFactory  
            SessionFactory sessionFactory = configuration.buildSessionFactory();  
            
            // Mở session thử nghiệm  
            Session session = sessionFactory.openSession();  
            
            System.out.println(">>> Hibernate kết nối thành công!");  
            
            // Đóng session và sessionFactory  
            session.close();  
            sessionFactory.close();  
        } catch (Exception e) {  
            System.err.println(">>> Lỗi kết nối Hibernate: " + e.getMessage());  
            e.printStackTrace();  
        }  
    }  
}

----
<!DOCTYPE hibernate-configuration PUBLIC  
    "-//Hibernate/Hibernate Configuration DTD 3.0//EN"  
    "http://hibernate.sourceforge.net/hibernate-configuration-3.0.dtd">  
<hibernate-configuration>  
    <session-factory>  
        <property name="hibernate.connection.driver_class">com.microsoft.sqlserver.jdbc.SQLServerDriver</property>  
        <property name="hibernate.connection.url">jdbc:sqlserver://localhost:1433;databaseName=MSTUSER</property>  
        <property name="hibernate.connection.username">your_user</property>  
        <property name="hibernate.connection.password">your_password</property>  
        <property name="hibernate.dialect">org.hibernate.dialect.SQLServerDialect</property>  
        <property name="hibernate.show_sql">true</property>  
        <property name="hibernate.hbm2ddl.auto">update</property>  
        <mapping resource="fjs/cs/mstuser.hbm.xml"/>  
    </session-factory>  
</hibernate-configuration>


----
<!DOCTYPE hibernate-mapping PUBLIC  
    "-//Hibernate/Hibernate Mapping DTD 3.0//EN"  
    "http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd">  
<hibernate-mapping>  
    <class name="fjs.cs.T001" table="MSTUSER">  
        <id name="userId" column="USER_ID">  
            <generator class="assigned"/>  
        </id>  
        <property name="password" column="PASSWORD"/>  
        <property name="psnCd" column="PSN_CD"/>  
        <property name="username" column="USERNAME"/>  
        <property name="deleteYmd" column="DELETE_YMD"/>  
    </class>  
</hibernate-mapping>


---

package fjs.cs;  

public class T001 {  
    private String userId;  
    private String password;  
    private String psnCd;  
    private String username;  
    private String deleteYmd;  

    // Getters và Setters  
    public String getUserId() { return userId; }  
    public void setUserId(String userId) { this.userId = userId; }  
    public String getPassword() { return password; }  
    public void setPassword(String password) { this.password = password; }  
    public String getPsnCd() { return psnCd; }  
    public void setPsnCd(String psnCd) { this.psnCd = psnCd; }  
    public String getUsername() { return username; }  
    public void setUsername(String username) { this.username = username; }  
    public String getDeleteYmd() { return deleteYmd; }  
    public void setDeleteYmd(String deleteYmd) { this.deleteYmd = deleteYmd; }  
}


----
package fjs.cs;  

public class T001Dto {  
    private String userId;  
    private String password;  
    private String psnCd;  
    private String username;  

    // Getters và Setters  
    public String getUserId() { return userId; }  
    public void setUserId(String userId) { this.userId = userId; }  
    public String getPassword() { return password; }  
    public void setPassword(String password) { this.password = password; }  
    public String getPsnCd() { return psnCd; }  
    public void setPsnCd(String psnCd) { this.psnCd = psnCd; }  
    public String getUsername() { return username; }  
    public void setUsername(String username) { this.username = username; }  
}



----
package fjs.cs;  

import org.hibernate.Session;  
import org.hibernate.SessionFactory;  
import org.hibernate.query.Query;  
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;  

public class T001Dao extends HibernateDaoSupport {  

    public T001Dto login(String userId, String password) {  
        Session session = getSession();  
        String hql = "FROM T001 WHERE userId = :userId AND password = :password AND deleteYmd IS NULL";  
        Query<T001> query = session.createQuery(hql, T001.class);  
        query.setParameter("userId", userId);  
        query.setParameter("password", password);  
        T001 user = query.uniqueResult();  

        if (user != null) {  
            T001Dto dto = new T001Dto();  
            dto.setUserId(user.getUserId());  
            dto.setPsnCd(user.getPsnCd());  
            dto.setUsername(user.getUsername());  
            return dto;  
        }  
        return null;  
    }  
}

---
package fjs.cs;  

public class T001Service {  
    private T001Dao t001Dao;  

    public void setT001Dao(T001Dao t001Dao) {  
        this.t001Dao = t001Dao;  
    }  

    public T001Dto login(String userId, String password) {  
        return t001Dao.login(userId, password);  
    }  
}

-----
package fjs.cs;  

import javax.servlet.http.HttpServletRequest;  
import javax.servlet.http.HttpServletResponse;  
import org.apache.struts.action.Action;  
import org.apache.struts.action.ActionForm;  
import org.apache.struts.action.ActionForward;  
import org.apache.struts.action.ActionMapping;  

public class T001Action extends Action {  
    private T001Service t001Service;  

    public void setT001Service(T001Service t001Service) {  
        this.t001Service = t001Service;  
    }  

    public ActionForward execute(ActionMapping mapping, ActionForm form,  
                                 HttpServletRequest request, HttpServletResponse response) {  
        T001Bean bean = (T001Bean) form;  
        T001Dto user = t001Service.login(bean.getUserId(), bean.getPassword());  

        if (user != null) {  
            request.getSession().setAttribute("psnCd", user.getPsnCd());  
            return mapping.findForward("success");  
        } else {  
            request.setAttribute("error", "Invalid username or password");  
            return mapping.findForward("failure");  
        }  
    }  
}
----app
<beans>  
    <bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">  
        <property name="configLocation" value="classpath:hibernate.cfg.xml"/>  
    </bean>  

    <bean id="t001Dao" class="fjs.cs.T001Dao">  
        <property name="sessionFactory" ref="sessionFactory"/>  
    </bean>  

    <bean id="t001Service" class="fjs.cs.T001Service">  
        <property name="t001Dao" ref="t001Dao"/>  
    </bean>  
</beans>

