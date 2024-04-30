package com.example.loginregister.registration;

import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.appuser.AppUserService;
import com.example.loginregister.supervisor.Supervisor;
import com.example.loginregister.supervisor.SupervisorService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class RegistrationService
{
    private final AppUserService appUserService;
    private final SupervisorService supervisorService;

    private final EmailValidator emailValidator;
    public String registerAppUser(RegistrationRequest request)
    {
        boolean isValidEmail = emailValidator.test(request.getEmail());
        if (!isValidEmail) {
            throw new IllegalStateException("appuser email not valid");
        }
        return appUserService.signUpUser(
                new AppUser(
                        request.getFirstName(),
                        request.getLastName(),
                        request.getEmail(),
                        request.getPassword()
                )
        );
    }

    public String registerSupervisor(RegistrationRequest request)
    {
        boolean isValidEmail = emailValidator.test(request.getEmail());
        if (!isValidEmail) {
            throw new IllegalStateException("supervisor email not valid");
        }
        return supervisorService.signUpUser(
                new Supervisor(
                        request.getFirstName(),
                        request.getLastName(),
                        request.getEmail(),
                        request.getPassword()
                )
        );
    }
}
