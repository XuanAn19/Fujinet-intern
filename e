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
