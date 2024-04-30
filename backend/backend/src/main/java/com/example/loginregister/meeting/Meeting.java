package com.example.loginregister.meeting;

import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.participantmeeting.ParticipantMeeting;
import com.example.loginregister.qr.QR;
import com.example.loginregister.session.Session;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.security.core.parameters.P;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.Calendar;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class Meeting
{
    @SequenceGenerator(name = "meeting_sequence", sequenceName = "meeting_sequence", allocationSize = 1)
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "meeting_sequence")
    private Long id;
    private boolean ongoing;
    private boolean complete;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private int lateThreshold;
    private int absentThreshold;



    @JsonIgnore
    @ManyToOne
    @JoinColumn(name ="session_id")
    private Session session;


    @JsonIgnore
    @OneToMany(mappedBy = "meeting", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<ParticipantMeeting> participants = new HashSet<>();


    @OneToMany(mappedBy = "meeting",orphanRemoval = true, cascade = CascadeType.ALL)
    private Set<QR> meetingQrCodes = new HashSet<>();


    public void addQr(QR qr) {
        qr.setMeeting(this);

        if (meetingQrCodes.size() >= 2) {
            Iterator<QR> iterator = meetingQrCodes.iterator();
            if (iterator.hasNext()) {
                QR oldestQR = iterator.next();
                meetingQrCodes.remove(oldestQR);
            }
        }
        meetingQrCodes.add(qr);
    }

}
