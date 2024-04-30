package com.example.loginregister.supervisor;

import com.example.loginregister.session.ScheduledSessionRequest;
import com.example.loginregister.session.Session;
import com.example.loginregister.session.SessionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/supervisor")
public class SupervisorController
{
    @Autowired
    SessionRepository sessionRepository;

    @Autowired
    SupervisorRepository supervisorRepository;

    @PostMapping("/createSession/{participantEmail}")
    void createSession(@PathVariable String participantEmail, @RequestBody Session session) {
        Supervisor supervisor = supervisorRepository.findByEmail(participantEmail).get();

        Session s = sessionRepository.save(session);
        supervisor.addSession(s);

        supervisorRepository.save(supervisor);
    }

//    private String name;
//
//    private BigDecimal sessionDuration;
//    private BigDecimal lateAfterDuration;
//    private BigDecimal absentAfterDuration;
//
//    private LocalDateTime scheduledStartTime;
//    private LocalDate scheduledStartDay;
//
//    private boolean oneTime;
//    private boolean daily;
//    private int dayIndex;
//    private boolean weekly;
//    private int weekIndex;
//
//    private Boolean onMonday;
//    private Boolean onTuesday;
//    private Boolean onWednesday;
//    private Boolean onThursday;
//    private Boolean onFriday;
//    private Boolean onSaturday;
//    private Boolean onSunday;

    @GetMapping("/getAllSessions/{supervisorEmail}")
    Optional<HashSet<Session>> getAllSupervisorSessions(@PathVariable String supervisorEmail) {
        Supervisor supervisor = supervisorRepository.findByEmail(supervisorEmail).get();

        return sessionRepository.findBySupervisor(supervisor);
    }
}
