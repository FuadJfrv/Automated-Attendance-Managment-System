package com.example.loginregister.appuser;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Transactional(readOnly = true)
@Repository
public interface ParticipantRepository extends JpaRepository<AppUser, Integer>
{
    Optional<AppUser> findByEmail(String email);
}
