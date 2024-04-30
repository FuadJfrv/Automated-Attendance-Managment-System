package com.example.loginregister.appuser;

import com.example.loginregister.session.Session;
import com.example.loginregister.session.SessionRepository;
import com.example.loginregister.supervisor.Supervisor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashSet;
import java.util.Optional;


@RestController
@RequestMapping("/api/v1/participant")

public class ParticipantController
{
    @Autowired
    SessionRepository sessionRepository;

    @Autowired
    ParticipantRepository participantRepository;

    @GetMapping("/{participantEmail}/getAllSessions")
    Optional<HashSet<Session>> getAllSupervisorSessions(@PathVariable String participantEmail) {
        AppUser participant = participantRepository.findByEmail(participantEmail).get();

        return sessionRepository.findByEnrolledParticipants(participant);
    }

    @GetMapping("/{participantEmail}/getId")
    Long getId(@PathVariable String participantEmail) {
        AppUser participant = participantRepository.findByEmail(participantEmail).get();
        return participant.getId();
    }
}
