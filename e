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
