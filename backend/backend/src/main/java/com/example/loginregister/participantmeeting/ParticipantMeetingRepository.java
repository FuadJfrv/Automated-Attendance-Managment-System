package com.example.loginregister.participantmeeting;

import com.example.loginregister.appuser.AppUser;
import com.example.loginregister.meeting.Meeting;
import com.example.loginregister.meeting.ParticipantMeetingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ParticipantMeetingRepository extends JpaRepository<ParticipantMeeting, Long> {
    @Query("SELECT COUNT(pm) > 0 FROM ParticipantMeeting pm WHERE pm.meeting.id = :meetingId AND pm.participant.id = :participantId AND pm.status = com.example.loginregister.meeting.ParticipantMeetingStatus.PRESENT")
    boolean isParticipantPresent(Long meetingId, Long participantId);

    @Query("SELECT pm.status FROM ParticipantMeeting pm WHERE pm.meeting.id = :meetingId AND pm.participant.id = :participantId")
    ParticipantMeetingStatus findMeetingStatusByMeetingIdAndParticipantId(Long meetingId, Long participantId);


}
