package com.example.loginregister.appuser;

import com.example.loginregister.meeting.ParticipantMeetingStatus;
import com.example.loginregister.participantmeeting.ParticipantMeeting;
import com.example.loginregister.session.Session;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@EqualsAndHashCode
@NoArgsConstructor
@Entity
//UserDetails: gets users out of the database and returns them in userdetails form
public class AppUser implements UserDetails
{
    @SequenceGenerator(name = "student_sequence",
    sequenceName = "student_sequence",
    allocationSize = 1)

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE,
    generator = "student_sequence")
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private Boolean locked =false;
    private Boolean enabled =true;
    @Enumerated
    private ParticipantMeetingStatus participantMeetingStatus;

    public AppUser(String firstName, String lastName, String email, String password)
    {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.password = password;
    }

    @JsonIgnore
    @OneToMany(mappedBy = "participant", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<ParticipantMeeting> meetings = new HashSet<>();

    @JsonIgnore
    @ManyToMany(mappedBy = "enrolledParticipants")
    private Set<Session> sessions = new HashSet<>();

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities()
    {
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(firstName);
        return Collections.singletonList(authority);
    }

    @Override
    public String getPassword()
    {
        return password;
    }

    @Override
    public String getUsername()
    {
        return email;
    }

    public String getFirstName()
    {
        return firstName;
    }

    public String getLastName()
    {
        return lastName;
    }

    @Override
    public boolean isAccountNonExpired()
    {
        return true;
    }

    @Override
    public boolean isAccountNonLocked()
    {
        return !locked;
    }

    @Override
    public boolean isCredentialsNonExpired()
    {
        return true;
    }

    @Override
    public boolean isEnabled()
    {
        return enabled;
    }
}
