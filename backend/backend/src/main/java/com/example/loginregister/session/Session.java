package com.example.loginregister.session;
import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.meeting.Meeting;
import com.example.loginregister.supervisor.Supervisor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class Session
{
    @SequenceGenerator(name = "course_sequence", sequenceName = "course_sequence", allocationSize = 1)
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "course_sequence")
    private Long id;
    private String name;
    private String description;
    @Column(precision = 18, scale = 15)
    private BigDecimal longitude;
    @Column(precision = 18, scale = 15)
    private BigDecimal latitude;
    private BigDecimal radius;
    private int lateThreshold;
    private int absentThreshold;




//    private BigDecimal sessionDuration;
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

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "meeting_id")
    private Meeting activeMeeting;

    @ManyToMany
    @JoinTable(name="participant_enrolled",
               joinColumns = @JoinColumn(name = "session_id"),
               inverseJoinColumns = @JoinColumn(name = "participant_id"))
    private Set<AppUser> enrolledParticipants = new HashSet<>();



    @OneToMany(mappedBy = "session",orphanRemoval = true, cascade = CascadeType.ALL)
    private Set<Meeting> sessionMeetings = new HashSet<>();

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name ="supervisor_id")
    private Supervisor supervisor;

    public Session(String name)
    {
        this.name = name;
    }

    public void enrollParticipant(AppUser participant) {
        enrolledParticipants.add(participant);
    }
    public void removeParticipant(AppUser participant) {
        enrolledParticipants.remove(participant);
    }

    public void addMeeting(Meeting meeting) {
        meeting.setSession(this);
        sessionMeetings.add(meeting);
    }

    public void removeIncompleteMeetings() {
        sessionMeetings.removeIf(meeting -> !meeting.isComplete());
    }

}
