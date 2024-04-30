package com.example.loginregister.meeting;

import com.example.loginregister.appuser.AppUser;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.ToString;

@Getter
@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class ParticipantMeetingRequest
{
    Meeting meeting;
    AppUser participant;
    String status;
}
