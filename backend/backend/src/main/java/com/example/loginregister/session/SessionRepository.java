package com.example.loginregister.session;

import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.supervisor.Supervisor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@Repository
public interface SessionRepository extends JpaRepository<Session, Long>
{
    Optional <HashSet<Session> > findBySupervisor(Supervisor supervisor);
    Optional< HashSet<Session> > findByEnrolledParticipants(AppUser appUser);
}
