package com.example.loginregister.login;


import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.appuser.ParticipantRepository;
import com.example.loginregister.supervisor.Supervisor;
import com.example.loginregister.supervisor.SupervisorRepository;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Objects;
import java.util.Optional;

@RestController
@AllArgsConstructor
public class LoginController
{
    @Autowired
    private final ParticipantRepository userRepository;

    @Autowired
    private final SupervisorRepository supervisorRepository;

    @Autowired
    private final BCryptPasswordEncoder bCryptPasswordEncoder;


    @GetMapping("/api/v1/login/{email}/{password}")
    public ResponseEntity<?> login(@PathVariable String email, @PathVariable String password) {

        Optional<AppUser> participantOptional = userRepository.findByEmail(email);
        Optional<Supervisor> supervisorOptional = supervisorRepository.findByEmail(email);

        if (participantOptional.isPresent()) {
            AppUser participant = participantOptional.get();

            if (bCryptPasswordEncoder.matches(password, participant.getPassword())) {
                return ResponseEntity.ok("PARTICIPANT");
            }
        }
        else if (supervisorOptional.isPresent()) {
            Supervisor supervisor = supervisorOptional.get();

            if (bCryptPasswordEncoder.matches(password, supervisor.getPassword())) {
                return ResponseEntity.ok("SUPERVISOR");
            }
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Username or password not found");
    }

}
