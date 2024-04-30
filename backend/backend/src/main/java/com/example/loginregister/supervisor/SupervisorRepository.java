package com.example.loginregister.supervisor;


import com.example.loginregister.appuser.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SupervisorRepository extends JpaRepository<Supervisor, Integer>
{
    Optional<Supervisor> findByEmail(String email);
}
