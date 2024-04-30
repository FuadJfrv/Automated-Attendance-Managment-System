package com.example.loginregister.meeting;

import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.appuser.ParticipantRepository;
import com.example.loginregister.participantmeeting.ParticipantMeeting;
import com.example.loginregister.participantmeeting.ParticipantMeetingRepository;
import com.example.loginregister.qr.QR;
import com.example.loginregister.qr.QRRepository;
import com.example.loginregister.session.Session;
import com.example.loginregister.session.SessionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/v1/meeting")
public class MeetingController
{

    @Autowired
    private QRRepository qrRepository;

    @Autowired
    private MeetingRepository meetingRepository;

    @Autowired
    private ParticipantRepository participantRepository;

    @Autowired
    private ParticipantMeetingRepository participantMeetingRepository;

    @PutMapping("/{meetingId}/qr/{qrData}")
    Meeting createSessionQr(@PathVariable Long meetingId,
                            @PathVariable String qrData) {

        Meeting meeting = meetingRepository.findById(meetingId).get();
        QR qr = new QR(qrData);
        qr = qrRepository.save(qr);

        meeting.addQr(qr);
        return meetingRepository.save(meeting);
    }

    @GetMapping("/{meetingId}/qr/{qrData}/record/{email}")
    ResponseEntity<?> checkSessionQr(@PathVariable Long meetingId,
                                     @PathVariable String email,
                                     @PathVariable String qrData) {

        Meeting meeting = meetingRepository.findById(meetingId).get();
        AppUser participant = participantRepository.findByEmail(email).get();
        List<QR> qrCodes = qrRepository.findByDataAndMeeting(qrData, meeting);
        if (qrCodes.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("WRONG QR CODE");
        } else {
            return ResponseEntity.ok("SCANNED");
        }
    }

    @PutMapping("/{meetingId}/record/{email}")
    public ResponseEntity<?> recordParticipant(@PathVariable Long meetingId, @PathVariable String email) {
        // Retrieve meeting and participant entities
        Meeting meeting = meetingRepository.findById(meetingId).orElseThrow(() -> new RuntimeException("Meeting not found"));
        AppUser participant = participantRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Participant not found"));

        // Set thresholds for late and absent (can be set somewhere else if they need to be dynamic)
        //meeting.setLateThreshold(1); // Participant is late if they join 1 minute after the start time
        //meeting.setAbsentThreshold(2); // Participant is absent if they join 3 minutes after the start time

        // Get the current time
        LocalDateTime currentTime = LocalDateTime.now();

        // Calculate the time difference in minutes between the current time and the meeting's start time
        long minutesDifference = Duration.between(meeting.getStartTime(), currentTime).toMinutes();

        // Determine the status based on the thresholds
        ParticipantMeetingStatus status;
        if (minutesDifference < meeting.getSession().getLateThreshold()) {
            status = ParticipantMeetingStatus.PRESENT;
        } else if (minutesDifference < meeting.getSession().getAbsentThreshold()) {
            status = ParticipantMeetingStatus.LATE;
        } else {
            status = ParticipantMeetingStatus.ABSENT;
        }

        // Create or update the participant meeting status
        ParticipantMeeting participantMeeting = new ParticipantMeeting(meeting, participant, status);
        participantMeetingRepository.save(participantMeeting); // Assuming you have a repository for ParticipantMeeting

        // Optionally, you could update the meeting if necessary
        meetingRepository.save(meeting);

        // Return a response indicating the record was updated
        return ResponseEntity.ok("Recorded as " + status);
    }
}
