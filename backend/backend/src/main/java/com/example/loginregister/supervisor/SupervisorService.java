package com.example.loginregister.supervisor;

import lombok.AllArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class SupervisorService
{
    private final SupervisorRepository supervisorRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;

    public String signUpUser(Supervisor supervisor)
    {
        boolean userExists = supervisorRepository.findByEmail(supervisor.getEmail())
                .isPresent();
        if (userExists) {
            throw new IllegalStateException("email already exists");
        }

        String encodedPassword = bCryptPasswordEncoder.encode(supervisor.getPassword());
        supervisor.setPassword(encodedPassword);

        supervisorRepository.save(supervisor);
        return "supervisor signed up";
    }
}
