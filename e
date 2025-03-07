<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!-- Cấu hình DataSource (SQL Server) -->
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
        <property name="driverClassName" value="com.microsoft.sqlserver.jdbc.SQLServerDriver"/>
        <property name="url" value="jdbc:sqlserver://localhost:1433;databaseName=YourDB"/>
        <property name="username" value="sa"/>
        <property name="password" value="yourpassword"/>
    </bean>

    <!-- Cấu hình SessionFactory (Hibernate) -->
    <bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <property name="mappingResources">
            <list>
                <value>fjs/cs/mstuser.hbm.xml</value>
            </list>
        </property>
        <property name="hibernateProperties">
            <props>
                <prop key="hibernate.dialect">org.hibernate.dialect.SQLServerDialect</prop>
                <prop key="hibernate.show_sql">true</prop>
                <prop key="hibernate.hbm2ddl.auto">update</prop>
            </props>
        </property>
    </bean>

    <!-- Cấu hình Transaction Manager -->
    <bean id="transactionManager" class="org.springframework.orm.hibernate3.HibernateTransactionManager">
        <property name="sessionFactory" ref="sessionFactory"/>
    </bean>

    <!-- Cấu hình DAO -->
    <bean id="T001Dao" class="fjs.cs.T001Dao">
        <property name="sessionFactory" ref="sessionFactory"/>
    </bean>

    <!-- Cấu hình Service -->
    <bean id="T001Service" class="fjs.cs.T001Service">
        <property name="T001Dao" ref="T001Dao"/>
    </bean>

    <!-- Cấu hình Struts Action -->
    <bean name="/T001Action" class="fjs.cs.T001Action">
        <property name="T001Service" ref="T001Service"/>
    </bean>

</beans>




<form-beans>
    <form-bean name="T001Form" type="fjs.cs.T001Form"/>
</form-beans>

<action-mappings>
    <action path="/T001Action" type="org.springframework.web.struts.DelegatingActionProxy" 
            name="T001Form" scope="request" validate="false">
        <forward name="success" path="/WEB-INF/jsp/T001.jsp"/>
    </action>
</action-mappings>



package fjs.cs;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.transaction.annotation.Transactional;

public class T001Dao {

    private SessionFactory sessionFactory;

    public void setSessionFactory(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }

    @Transactional
    public boolean checkUser(String username, String password) {
        Session session = sessionFactory.getCurrentSession();
        Long count = (Long) session.createQuery("SELECT COUNT(*) FROM mstuser WHERE username = :username AND password = :password")
                                   .setParameter("username", username)
                                   .setParameter("password", password)
                                   .uniqueResult();
        return count != null && count > 0;
    }
}



package fjs.cs;

import org.springframework.transaction.annotation.Transactional;

public class T001Service {

    private T001Dao T001Dao;

    public void setT001Dao(T001Dao T001Dao) {
        this.T001Dao = T001Dao;
    }

    @Transactional
    public boolean validateUser(String username, String password) {
        return T001Dao.checkUser(username, password);
    }
}


package fjs.cs;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.springframework.transaction.annotation.Transactional;

public class T001Action extends Action {
    
    private T001Service T001Service;

    public void setT001Service(T001Service T001Service) {
        this.T001Service = T001Service;
    }

    @Transactional
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                 HttpServletRequest request, HttpServletResponse response) {
        T001Form loginForm = (T001Form) form;
        
        boolean isValidUser = T001Service.validateUser(loginForm.getUsername(), loginForm.getPassword());
        
        if (isValidUser) {
            return mapping.findForward("success");
        } else {
            request.setAttribute("error", "Invalid username or password");
            return mapping.findForward("error");
        }
    }
}
