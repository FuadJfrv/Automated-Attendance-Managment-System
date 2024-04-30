package com.example.loginregister.registration;

import org.springframework.stereotype.Component;

import java.util.function.Predicate;

@Component
public class EmailValidator implements Predicate<String>
{

    @Override
    public boolean test(String s)
    {
        //TODO: regex to validate email
        return true;
    }
}
