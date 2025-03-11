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
