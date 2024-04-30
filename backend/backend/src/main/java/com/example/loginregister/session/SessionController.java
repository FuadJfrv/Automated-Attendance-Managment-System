package com.example.loginregister.session;

import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.appuser.ParticipantRepository;
import com.example.loginregister.meeting.*;
import com.example.loginregister.participantmeeting.ParticipantMeeting;
import com.example.loginregister.participantmeeting.ParticipantMeetingRepository;
import com.example.loginregister.qr.QRRepository;
import com.example.loginregister.supervisor.Supervisor;
import com.example.loginregister.supervisor.SupervisorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;


@RestController
@RequestMapping("/api/v1/session")
public class SessionController
{
    @Autowired
    private SessionRepository sessionRepository;

    @Autowired
    private ParticipantRepository appUserRepository;


    @Autowired
    private MeetingRepository meetingRepository;

    @Autowired
    private SupervisorRepository supervisorRepository;

    @Autowired
    private ParticipantMeetingRepository participantMeetingRepository;


    @GetMapping("/{sessionId}")
    Optional<Session> getSession(@PathVariable Long sessionId) {
        return sessionRepository.findById(sessionId);
    }


    @PutMapping("/{sessionID}/participant/{participantEmail}")
    Session enrollParticipantToSession(@PathVariable Long sessionID,
                                       @PathVariable String participantEmail) {

        Session session = sessionRepository.findById(sessionID).get();
        AppUser participant = appUserRepository.findByEmail(participantEmail).get();

        session.enrollParticipant(participant);
        return sessionRepository.save(session);
    }

    @PutMapping("/{sessionID}/participant/remove/{participantId}")
    Session removeParticipantFromSession(@PathVariable Long sessionID,
                                       @PathVariable Integer participantId) {

        Session session = sessionRepository.findById(sessionID).get();
        AppUser participant = appUserRepository.findById(participantId).get();

        session.removeParticipant(participant);
        return sessionRepository.save(session);
    }


    @GetMapping("/{sessionID}/meetings")
    Set<Meeting> getSessionMeetings(@PathVariable Long sessionID){
        Session session = sessionRepository.findById(sessionID).get();

        session.removeIncompleteMeetings();
        var trimemdSession = sessionRepository.save(session);

        return trimemdSession.getSessionMeetings();
    }

    @PostMapping("/{sessionID}/stopOngoingMeetings")
    void stopOngoingMeetings(@PathVariable Long sessionID){
        Set<Meeting> meetings = sessionRepository.findById(sessionID).get().getSessionMeetings();
        meetings.removeIf(Meeting::isOngoing);
    }

    @GetMapping("/{sessionID}/meetings/participant/{participantEmail}")
    Set<ParticipantMeetingRequest> getParticipantMeetingsHistory(@PathVariable Long sessionID,
                                                                 @PathVariable String participantEmail){
        Session session = sessionRepository.findById(sessionID)
                .orElseThrow(() -> new IllegalArgumentException("Session with ID: " + sessionID + " not found"));

        // Use Optional to safely extract the participant
        AppUser participant = appUserRepository.findByEmail(participantEmail)
                .orElseThrow(() -> new IllegalArgumentException("Participant with email: " + participantEmail + " not found"));

        Set<Meeting> meetings = session.getSessionMeetings();
        Set<ParticipantMeetingRequest> participantMeetings = new HashSet<>();

        for (Meeting meeting : meetings) {
            // Check if meeting is ongoing, and skip processing if it is
            if (meeting.isOngoing()) {
                continue;  // Skip this iteration if the meeting is ongoing
            }

            ParticipantMeetingStatus status = participantMeetingRepository
                    .findMeetingStatusByMeetingIdAndParticipantId(meeting.getId(), participant.getId());
            if (status == null) {
                throw new IllegalStateException("Status not found for meeting ID: " + meeting.getId() + " and participant ID: " + participant.getId());
            }
            ParticipantMeetingRequest req = new ParticipantMeetingRequest(meeting, participant, status.toString());
            participantMeetings.add(req);
        }

        return participantMeetings;
    }

//    @GetMapping("/{sessionID}/meetingsHistory")
//    Set<ParticipantMeetingRequest> getMeetingsHistory(@PathVariable Long sessionID){
//        Session session = sessionRepository.findById(sessionID)
//                .orElseThrow(() -> new IllegalArgumentException("Session with ID: " + sessionID + " not found"));
//
//
//        Set<Meeting> meetings = session.getSessionMeetings();
//        Set<ParticipantMeetingRequest> participantMeetings = new HashSet<>();
//
//        for (Meeting meeting : meetings) {
//            // Check if meeting is ongoing, and skip processing if it is
//            if (meeting.isOngoing()) {
//                continue;  // Skip this iteration if the meeting is ongoing
//            }
//
//            ParticipantMeetingStatus status = participantMeetingRepository
//                    .findMeetingStatusByMeetingIdAndParticipantId(meeting.getId(), participant.getId());
//            if (status == null) {
//                throw new IllegalStateException("Status not found for meeting ID: " + meeting.getId() + " and participant ID: " + participant.getId());
//            }
//            ParticipantMeetingRequest req = new ParticipantMeetingRequest(meeting, participant, status.toString());
//            participantMeetings.add(req);
//        }
//
//        return participantMeetings;
//    }

    @PostMapping("/{sessionID}/meetings/start")
    Meeting startSessionMeeting(@PathVariable Long sessionID){

        var meeting = new Meeting();
        meeting.setStartTime(LocalDateTime.now());
        meeting.setOngoing(true);

        var session = sessionRepository.findById(sessionID).get();
        session.addMeeting(meeting);

        return meetingRepository.save(meeting);
    }

    @PutMapping("/{sessionID}/meetings/{meetingId}/end")
    @Transactional  // Ensure the entire operation is transactional
    public Meeting endSessionMeeting(@PathVariable Long sessionID, @PathVariable Long meetingId) {
        Meeting meeting = meetingRepository.findById(meetingId)
                .orElseThrow(() -> new RuntimeException("Meeting not found with ID: " + meetingId));

        // End the meeting
        meeting.setEndTime(LocalDateTime.now());
        meeting.setOngoing(false);
        meeting.setComplete(true);

        // Get all participants in this meeting
        Set<AppUser> participants = meeting.getSession().getEnrolledParticipants();

        // Ensure all participants have a status; set to ABSENT if null
        for (AppUser participant : participants) {
            ParticipantMeetingStatus status = participantMeetingRepository.findMeetingStatusByMeetingIdAndParticipantId(meeting.getId(), participant.getId());
            if (status == null) {
                // Status is null, set to ABSENT
                ParticipantMeeting participantMeeting = new ParticipantMeeting();
                participantMeeting.setMeeting(meeting);
                participantMeeting.setParticipant(participant);
                participantMeeting.setStatus(ParticipantMeetingStatus.ABSENT);
                participantMeetingRepository.save(participantMeeting);
            }
        }

        // Save updates to the meeting
        return meetingRepository.save(meeting);
    }

    @GetMapping("/{sessionID}/meetings/{meetingId}/isCompleted")
    Boolean isMeetingCompleted(@PathVariable Long sessionID, @PathVariable Long meetingId){
        var meeting = meetingRepository.findById(meetingId).get();
        return meeting.isComplete();
    }

    @GetMapping("/{sessionID}/meetings/active")
    public ResponseEntity<?> getActiveMeeting(@PathVariable Long sessionID) {
        List<Meeting> activeMeetings = meetingRepository.findByOngoingTrueAndSessionId(sessionID);
        if (activeMeetings.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("NO ACTIVE MEETINGS");
        }
        else {
            return ResponseEntity.ok(activeMeetings.get(0));
        }
    }


    @GetMapping("{sessionId}/meeting/{meetingId}/getParticipantsStatus")
    Set<ParticipantPresentRequest> getParticipantsMeetingStatus(@PathVariable Long sessionId,
                                                                @PathVariable Long meetingId) {
        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found with ID: " + sessionId));
        Meeting meeting = meetingRepository.findById(meetingId)
                .orElseThrow(() -> new RuntimeException("Meeting not found with ID: " + meetingId));

        Set<AppUser> allSessionParticipants = session.getEnrolledParticipants();

        Set<ParticipantPresentRequest> participantsMeetingStatus = new HashSet<>();
        for (var participant : allSessionParticipants) {
            String participantName = participant.getFirstName() + " " + participant.getLastName();

            var status = participantMeetingRepository.findMeetingStatusByMeetingIdAndParticipantId(meeting.getId(), participant.getId());
            if (status == null) status = ParticipantMeetingStatus.ABSENT;
            ParticipantPresentRequest req = new ParticipantPresentRequest(participantName, status.toString());
            participantsMeetingStatus.add(req);
            participantsMeetingStatus.add(req);
        }
        return participantsMeetingStatus;
    }

    @GetMapping("/{sessionId}/description")
    String getSessionDescription(@PathVariable Long sessionId) {
        Session session = sessionRepository.findById(sessionId).get();

        return session.getDescription();
    }

    @PutMapping("/{sessionId}/description")
    public ResponseEntity<?> setSessionDescription(@PathVariable Long sessionId, @RequestBody DescriptionDTO descriptionDTO) {
        Session session = sessionRepository.findById(sessionId).get();
        session.setDescription(descriptionDTO.getDescription());
        sessionRepository.save(session);
        return ResponseEntity.ok("Session description saved");
    }

    @GetMapping("/{sessionId}/geofence")
    GeofenceDTO getSessionGeofence(@PathVariable Long sessionId) {
        Session session = sessionRepository.findById(sessionId).get();

        return new GeofenceDTO(session.getLongitude(),
                session.getLatitude(), session.getRadius());
    }

    @PutMapping("/{sessionId}/geofence")
    public ResponseEntity<?> setSessionGeofence(@PathVariable Long sessionId, @RequestBody GeofenceDTO geofenceDTO) {
        Session session = sessionRepository.findById(sessionId).get();
        session.setLongitude(geofenceDTO.getLongitude());
        session.setLatitude(geofenceDTO.getLatitude());
        session.setRadius(geofenceDTO.getRadius());
        sessionRepository.save(session);
        return ResponseEntity.ok("Session geofence saved");
    }

    @PutMapping("/{sessionId}/setDurations/{lateDuration}/{absentDuration}")
    public ResponseEntity<?> setSessionThresholds(@PathVariable Long sessionId, @PathVariable int lateDuration,
                                                @PathVariable int absentDuration) {
        Session session = sessionRepository.findById(sessionId).get();

        session.setLateThreshold(lateDuration);
        session.setAbsentThreshold(absentDuration);
        sessionRepository.save(session);
        return ResponseEntity.ok("Session thresholds saved");
    }

    @GetMapping("/{sessionId}/getDurations")
    ThresholdsDTO getSessionThreshold(@PathVariable Long sessionId) {
        Session session = sessionRepository.findById(sessionId).get();
        return new ThresholdsDTO(session.getLateThreshold(), session.getAbsentThreshold());
    }



//    @PostMapping("/createScheduledSession/{supervisorEmail}")
//    void createScheduledSession(@PathVariable String supervisorEmail, @RequestBody Session session) {
//        Supervisor supervisor = supervisorRepository.findByEmail(supervisorEmail).get();
//
//        Session s = sessionRepository.save(session);
//        supervisor.addSession(s);
//
//        supervisorRepository.save(supervisor);
//    }
//
//    @PostMapping("/createScheduledSession/{supervisorEmail}")
//    void getSessionsThisMonth(@PathVariable String supervisorEmail, @RequestBody Session session) {
//        Supervisor supervisor = supervisorRepository.findByEmail(supervisorEmail).get();
//
//        Session s = sessionRepository.save(session);
//        supervisor.addSession(s);
//
//        supervisorRepository.save(supervisor);
//    }
}
