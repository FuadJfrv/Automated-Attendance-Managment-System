package com.example.loginregister.participantmeeting;
import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.meeting.Meeting;
import com.example.loginregister.meeting.ParticipantMeetingStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class ParticipantMeeting {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "meeting_id")
    private Meeting meeting;

    @ManyToOne
    @JoinColumn(name = "participant_id")
    private AppUser participant;

    @Enumerated(EnumType.STRING)
    private ParticipantMeetingStatus status;

    public ParticipantMeeting(Meeting meeting, AppUser participant, ParticipantMeetingStatus status) {
        this.meeting = meeting;
        this.participant = participant;
        this.status = status;
    }
}
