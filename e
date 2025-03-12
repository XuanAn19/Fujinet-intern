<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
                           http://www.springframework.org/schema/tx
                           http://www.springframework.org/schema/tx/spring-tx-2.5.xsd">

    <!-- ✅ Khai báo Transaction Manager -->
    <bean id="transactionManager" class="org.springframework.orm.hibernate3.HibernateTransactionManager">
        <property name="sessionFactory" ref="sessionFactory"/>
    </bean>

    <!-- ✅ Kích hoạt annotation @Transactional -->
    <tx:annotation-driven transaction-manager="transactionManager"/>

</beans>





<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
           http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">

    <!-- ✅ DataSource: Kết nối database -->
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
        <property name="driverClassName" value="com.microsoft.sqlserver.jdbc.SQLServerDriver"/>
        <property name="url" value="jdbc:sqlserver://localhost:1433;databaseName=YourDatabase"/>
        <property name="username" value="your_user"/>
        <property name="password" value="your_password"/>
    </bean>

    <!-- ✅ Hibernate SessionFactory -->
    <bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <property name="mappingResources">
            <list>
                <value>fjs/cs/mstuser.hbm.xml</value>
                <value>fjs/cs/T002.hbm.xml</value>
                <!-- Thêm các file mapping khác nếu có -->
            </list>
        </property>
        <property name="hibernateProperties">
            <props>
                <prop key="hibernate.dialect">org.hibernate.dialect.SQLServerDialect</prop>
                <prop key="hibernate.show_sql">true</prop>
                <prop key="hibernate.format_sql">true</prop>
                <prop key="hibernate.jdbc.batch_size">20</prop>
            </props>
        </property>
    </bean>

    <!-- ✅ Transaction Manager -->
    <bean id="transactionManager" class="org.springframework.orm.hibernate3.HibernateTransactionManager">
        <property name="sessionFactory" ref="sessionFactory"/>
    </bean>

    <!-- ✅ Tự động quản lý Transaction -->
    <bean class="org.springframework.transaction.interceptor.TransactionProxyFactoryBean">
        <property name="transactionManager" ref="transactionManager"/>
        <property name="target" ref="t002Service"/>
        <property name="transactionAttributes">
            <props>
                <prop key="save*">PROPAGATION_REQUIRED</prop>
                <prop key="delete*">PROPAGATION_REQUIRED</prop>
                <prop key="update*">PROPAGATION_REQUIRED</prop>
                <prop key="find*">PROPAGATION_SUPPORTS, readOnly</prop>
            </props>
        </property>
    </bean>
</beans>



public void softDeleteCustomers(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    Transaction transaction = null;
    try (Session session = SessionFactoryUtils.getSession(sessionFactory, true)) {
        transaction = session.beginTransaction();

        // Lấy CriteriaBuilder từ Session
        CriteriaBuilder cb = session.getCriteriaBuilder();
        CriteriaUpdate<T002> update = cb.createCriteriaUpdate(T002.class);
        Root<T002> root = update.from(T002.class);

        // Cập nhật cột deleteYMD bằng ngày hiện tại
        update.set(root.get("deleteYMD"), LocalDate.now());
        update.where(root.get("customerId").in(ids)); // Điều kiện WHERE IN (ids)

        // Thực thi truy vấn cập nhật
        session.createQuery(update).executeUpdate();

        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) {
            transaction.rollback();
        }
        e.printStackTrace();
    }
}
------
public void softDeleteCustomers(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    Transaction transaction = null;
    try (Session session = SessionFactoryUtils.getSession(sessionFactory, true)) {
        transaction = session.beginTransaction();

        // Tạo câu lệnh SQL cập nhật deleteYMD = ngày hiện tại
        String sql = "UPDATE MSTCUSTOMER SET deleteYMD = GETDATE() WHERE CUSTOMER_ID IN (:ids)";

        Query query = session.createNativeQuery(sql);
        query.setParameter("ids", ids);
        query.executeUpdate();

        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) {
            transaction.rollback();
        }
        e.printStackTrace();
    }
}
-----
public void softDeleteCustomers(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    String sql = "UPDATE MSTCUSTOMER SET deleteYMD = GETDATE() WHERE CUSTOMER_ID IN (" +
                 ids.stream().map(id -> "?").collect(Collectors.joining(",")) + ")";

    try (Connection conn = sessionFactory.getSessionFactoryOptions().getServiceRegistry()
                .getService(ConnectionProvider.class).getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        for (int i = 0; i < ids.size(); i++) {
            stmt.setLong(i + 1, ids.get(i));
        }

        stmt.executeUpdate();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
----Hobernate 5+
public void softDeleteCustomers(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    Transaction transaction = null;
    try (Session session = sessionFactory.openSession()) {
        transaction = session.beginTransaction();
        
        CriteriaBuilder cb = session.getCriteriaBuilder();
        CriteriaUpdate<T002> update = cb.createCriteriaUpdate(T002.class);
        Root<T002> root = update.from(T002.class);

        // Cập nhật cột deleteYMD = ngày hiện tại
        update.set(root.get("deleteYMD"), LocalDate.now());
        update.where(root.get("id").in(ids));

        // Thực thi cập nhật
        session.createQuery(update).executeUpdate();

        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) {
            transaction.rollback();
        }
        e.printStackTrace();
    }
}
----Hibernate 4+
public void softDeleteCustomers(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    Transaction transaction = null;
    try (Session session = sessionFactory.openSession()) {
        transaction = session.beginTransaction();

        String hql = "UPDATE T002 SET deleteYMD = :deleteDate WHERE id IN (:ids)";
        Query query = session.createQuery(hql);
        query.setParameter("deleteDate", LocalDate.now());
        query.setParameterList("ids", ids);

        query.executeUpdate();
        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) {
            transaction.rollback();
        }
        e.printStackTrace();
    }
}
---hibernate 3.
public void softDeleteCustomers(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    Session session = null;
    Transaction transaction = null;
    try {
        session = sessionFactory.openSession();
        transaction = session.beginTransaction();

        // Tạo đối tượng Criteria để cập nhật deleteYMD
        Criteria criteria = session.createCriteria(T002.class);
        criteria.add(Restrictions.in("id", ids));

        List<T002> customers = criteria.list();
        for (T002 customer : customers) {
            customer.setDeleteYMD(new Date());  // Đặt ngày xóa mềm
            session.update(customer);
        }

        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) transaction.rollback();
        e.printStackTrace();
    } finally {
        if (session != null) session.close();
    }
}

public void softDeleteCustomers(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    Session session = null;
    Transaction transaction = null;
    try {
        session = sessionFactory.openSession();
        transaction = session.beginTransaction();

        String hql = "UPDATE T002 SET deleteYMD = :deleteDate WHERE id IN (:ids)";
        Query query = session.createQuery(hql);
        query.setDate("deleteDate", new Date()); // Hibernate 3 dùng setDate thay vì setParameter
        query.setParameterList("ids", ids);

        query.executeUpdate();
        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) transaction.rollback();
        e.printStackTrace();
    } finally {
        if (session != null) session.close();
    }
}

-----update
public void updateCustomer(T002 customer) {
    Session session = null;
    Transaction transaction = null;

    try {
        session = sessionFactory.openSession(); // Mở session từ Hibernate 3
        transaction = session.beginTransaction(); // Bắt đầu transaction
        
        session.update(customer); // Cập nhật dữ liệu
        
        transaction.commit(); // Commit transaction
    } catch (Exception e) {
        if (transaction != null) {
            transaction.rollback(); // Rollback nếu có lỗi
        }
        e.printStackTrace();
    } finally {
        if (session != null) {
            session.close(); // Đóng session
        }
    }
}

public void updateCustomerByCriteria(String customerId, String newName) {
    Session session = null;
    Transaction transaction = null;

    try {
        session = sessionFactory.openSession();
        transaction = session.beginTransaction();

        Criteria criteria = session.createCriteria(T002.class);
        criteria.add(Restrictions.eq("id", customerId));

        T002 customer = (T002) criteria.uniqueResult();
        if (customer != null) {
            customer.setName(newName);
            session.update(customer);
        }

        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) {
            transaction.rollback();
        }
        e.printStackTrace();
    } finally {
        if (session != null) {
            session.close();
        }
    }
}
---------
Chức năng	Hibernate 3.2.7.ga
Thêm (INSERT)	session.save(entity)
Lấy (SELECT)	session.get(), session.load()
Cập nhật (UPDATE)	session.update(entity), HQL (createQuery())
Xóa Mềm (UPDATE delete_YMD)	HQL (createQuery())
Xóa Cứng (DELETE)	session.delete(entity), HQL (createQuery())


----

public List<T002> getCustomers(SearchDTO dto, int offset, int limit) {
    List<T002> customers = new ArrayList<>();
    Session session = sessionFactory.getCurrentSession(); // Lấy session từ Hibernate
    
    Criteria criteria = session.createCriteria(T002.class);
    
    // Chỉ lấy những khách hàng chưa bị xóa (delete_YMD IS NULL)
    criteria.add(Restrictions.isNull("delete_YMD"));

    // Lọc theo tên khách hàng (LIKE)
    if (dto.getCustomerName() != null && !dto.getCustomerName().isEmpty()) {
        criteria.add(Restrictions.like("name", "%" + dto.getCustomerName() + "%"));
    }

    // Lọc theo giới tính
    if (dto.getSex() != null && !dto.getSex().isEmpty()) {
        criteria.add(Restrictions.eq("sex", dto.getSex()));
    }

    // Lọc theo ngày sinh từ (>=)
    if (dto.getBirthDayFrom() != null && !dto.getBirthDayFrom().isEmpty()) {
        criteria.add(Restrictions.ge("birthday", dto.getBirthDayFrom()));
    }

    // Lọc theo ngày sinh đến (<=)
    if (dto.getBirthDayTo() != null && !dto.getBirthDayTo().isEmpty()) {
        criteria.add(Restrictions.le("birthday", dto.getBirthDayTo()));
    }

    // Sắp xếp theo ID tăng dần
    criteria.addOrder(Order.asc("id"));

    // Phân trang
    criteria.setFirstResult(offset);
    criteria.setMaxResults(limit);

    customers = criteria.list(); // Thực hiện truy vấn

    return customers;
}
_-----------
public void softDeleteCustomers(List<String> ids) {
    if (ids == null || ids.isEmpty()) {
        return;
    }

    try (Session session = sessionFactory.openSession()) {
        Transaction tx = session.beginTransaction();

        CriteriaBuilder builder = session.getCriteriaBuilder();
        CriteriaUpdate<T002> criteriaUpdate = builder.createCriteriaUpdate(T002.class);
        Root<T002> root = criteriaUpdate.from(T002.class);

        // Cập nhật cột delete_YMD thành ngày hiện tại
        criteriaUpdate.set(root.get("delete_YMD"), new Date());

        // Điều kiện WHERE id IN (:ids)
        criteriaUpdate.where(root.get("id").in(ids));

        // Thực thi update
        int updatedRows = session.createQuery(criteriaUpdate).executeUpdate();
        System.out.println("Số bản ghi bị xóa mềm: " + updatedRows);

        tx.commit();
    } catch (Exception e) {
        e.printStackTrace();
    }
}


------
u
public long getTotalCustomer(SearchDTO dto) {
    try (Session session = sessionFactory.openSession()) {
        CriteriaBuilder builder = session.getCriteriaBuilder();
        CriteriaQuery<Long> criteriaQuery = builder.createQuery(Long.class);
        Root<T002> root = criteriaQuery.from(T002.class);

        // Đếm số bản ghi
        criteriaQuery.select(builder.count(root));

        // Điều kiện WHERE delete_YMD IS NULL
        List<Predicate> predicates = new ArrayList<>();
        predicates.add(builder.isNull(root.get("delete_YMD")));

        if (dto.getCustomerName() != null && !dto.getCustomerName().isEmpty()) {
            predicates.add(builder.like(root.get("name"), "%" + dto.getCustomerName() + "%"));
        }
        if (dto.getSex() != null && !dto.getSex().isEmpty()) {
            predicates.add(builder.equal(root.get("sex"), dto.getSex()));
        }
        if (dto.getBirthDayFrom() != null && !dto.getBirthDayFrom().isEmpty()) {
            predicates.add(builder.greaterThanOrEqualTo(root.get("birthday"), dto.getBirthDayFrom()));
        }
        if (dto.getBirthDayTo() != null && !dto.getBirthDayTo().isEmpty()) {
            predicates.add(builder.lessThanOrEqualTo(root.get("birthday"), dto.getBirthDayTo()));
        }

        criteriaQuery.where(predicates.toArray(new Predicate[0]));

        // Thực thi truy vấn
        return session.createQuery(criteriaQuery).getSingleResult();
    } catch (Exception e) {
        e.printStackTrace();
        return 0;
    }
}
--------------------
-----------------
public T002 getCustomerById(int customerId) {
    Session session = SessionFactoryUtils.getSession(sessionFactory, true);
    try {
        return session.createQuery(
            "FROM T002 WHERE deleteYMD IS NULL AND customerId = :customerId", T002.class)
            .setParameter("customerId", customerId)
            .uniqueResult();
    } catch (Exception e) {
        e.printStackTrace();
        return null;
    }
}


public boolean updateCustomer(T002 customer, int userUpdate) {
    Session session = SessionFactoryUtils.getSession(sessionFactory, true);
    Transaction tx = null;
    try {
        tx = session.beginTransaction();
        Query query = session.createQuery(
            "UPDATE T002 SET customerName = :name, sex = :sex, birthday = :birthday, " +
            "email = :email, address = :address, deleteYMD = NULL, updateYMD = CURRENT_TIMESTAMP, " +
            "updatePsnCd = :userUpdate WHERE customerId = :customerId");
        query.setParameter("name", customer.getCustomerName());
        query.setParameter("sex", customer.getSex());
        query.setParameter("birthday", customer.getBirthDay());
        query.setParameter("email", customer.getEmail());
        query.setParameter("address", customer.getAddress());
        query.setParameter("userUpdate", userUpdate);
        query.setParameter("customerId", customer.getCustomerId());

        int result = query.executeUpdate();
        tx.commit();
        return result > 0;
    } catch (Exception e) {
        if (tx != null) tx.rollback();
        e.printStackTrace();
        return false;
    }
}

public boolean addCustomer(T002 customer, int userInsert) {
    Session session = SessionFactoryUtils.getSession(sessionFactory, true);
    Transaction tx = null;
    try {
        tx = session.beginTransaction();
        customer.setDeleteYMD(null);
        customer.setInsertYMD(new Date());
        customer.setUpdateYMD(new Date());
        customer.setInsertPsnCd(userInsert);
        customer.setUpdatePsnCd(userInsert);

        session.save(customer);
        tx.commit();
        return true;
    } catch (Exception e) {
        if (tx != null) tx.rollback();
        e.printStackTrace();
        return false;
    }
}

-----------
public int getTotalCustomer(SearchDTO dto) {
    Session session = SessionFactoryUtils.getSession(sessionFactory, true);
    try {
        StringBuilder hql = new StringBuilder("SELECT COUNT(c) FROM T002 c WHERE c.deleteYMD IS NULL");

        Map<String, Object> params = new HashMap<>();

        if (dto.getCustomerName() != null && !dto.getCustomerName().isEmpty()) {
            hql.append(" AND c.customerName LIKE :customerName");
            params.put("customerName", "%" + dto.getCustomerName() + "%");
        }
        if (dto.getSex() != null && !dto.getSex().isEmpty()) {
            hql.append(" AND c.sex = :sex");
            params.put("sex", dto.getSex());
        }
        if (dto.getBirthDayFrom() != null) {
            hql.append(" AND c.birthDay >= :birthDayFrom");
            params.put("birthDayFrom", dto.getBirthDayFrom());
        }
        if (dto.getBirthDayTo() != null) {
            hql.append(" AND c.birthDay <= :birthDayTo");
            params.put("birthDayTo", dto.getBirthDayTo());
        }

        Query query = session.createQuery(hql.toString());
        params.forEach(query::setParameter);

        Long result = (Long) query.uniqueResult();
        return result != null ? result.intValue() : 0;
    } catch (Exception e) {
        e.printStackTrace();
        return 0;
    }
}

-----------
public int getTotalCustomer(SearchDTO dto) {
    Transaction transaction = null;
    int total = 0;

    try (Session session = SessionFactoryUtils.getSession(sessionFactory, true)) {
        transaction = session.beginTransaction();
        
        CriteriaBuilder cb = session.getCriteriaBuilder();
        CriteriaQuery<Long> cq = cb.createQuery(Long.class);
        Root<T002> root = cq.from(T002.class);

        // Điều kiện WHERE delete_YMD IS NULL
        List<Predicate> predicates = new ArrayList<>();
        predicates.add(cb.isNull(root.get("deleteYMD")));

        if (dto.getCustomerName() != null && !dto.getCustomerName().isEmpty()) {
            predicates.add(cb.like(root.get("customerName"), "%" + dto.getCustomerName() + "%"));
        }
        if (dto.getSex() != null && !dto.getSex().isEmpty()) {
            predicates.add(cb.equal(root.get("sex"), dto.getSex()));
        }
        if (dto.getBirthDayFrom() != null) {
            predicates.add(cb.greaterThanOrEqualTo(root.get("birthDay"), dto.getBirthDayFrom()));
        }
        if (dto.getBirthDayTo() != null) {
            predicates.add(cb.lessThanOrEqualTo(root.get("birthDay"), dto.getBirthDayTo()));
        }

        // Đếm tổng số bản ghi phù hợp
        cq.select(cb.count(root)).where(predicates.toArray(new Predicate[0]));

        Long result = session.createQuery(cq).getSingleResult();
        total = result != null ? result.intValue() : 0;

        transaction.commit();
    } catch (Exception e) {
        if (transaction != null) {
            transaction.rollback();
        }
        e.printStackTrace();
    }
    
    return total;
}
