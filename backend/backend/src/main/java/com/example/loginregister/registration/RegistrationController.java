package com.example.loginregister.registration;

import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "api/v1/registration")
@AllArgsConstructor
public class RegistrationController
{
    private final RegistrationService registrationService;

    @PostMapping("/participant")
    public String registerParticipant(@RequestBody RegistrationRequest request) {
        return registrationService.registerAppUser(request);
    }

    @PostMapping("/supervisor")
    public String registerSupervisor(@RequestBody RegistrationRequest request) {
        return registrationService.registerSupervisor(request);
    }

}
